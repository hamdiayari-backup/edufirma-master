# ClicToPay — API mobile (Flutter) et flux WebView

Ce document décrit comment payer via **ClicToPay** depuis l’application mobile : endpoints, authentification, passage **sandbox / production**, et ouverture de l’URL de paiement dans un WebView.

## Base URL

Toutes les routes panel sont préfixées par :

```text
{API_BASE}/api/panel
```

Exemple : `https://votredomaine.com/api/panel`

Remplacez par la valeur réelle configurée pour votre API (souvent la même origine que le site ou un sous-domaine dédié).

## Authentification

Les endpoints ci-dessous nécessitent un utilisateur connecté via le guard API habituel (JWT Bearer, selon votre implémentation).

```http
Authorization: Bearer {access_token}
```

---

## 1. Lister les moyens de paiement (dont ClicToPay)

**`GET /payments/channels`**

Réponse utile pour l’UI : titres, images, devises, et pour ClicToPay uniquement des métadonnées **sans secrets**.

### Champs ClicToPay (par canal)

| Champ | Description |
|--------|-------------|
| `clictopay.environment` | `sandbox` ou `production` |
| `clictopay.api_base` | Base REST utilisée côté serveur (`test.clictopay.com` vs `ipay.clictopay.com`) |

Le mode est piloté par l’**admin** : case **test mode** dans les credentials du canal ClicToPay (pas par l’app).

---

## 2. Créer une commande en attente de paiement

Le panier panel (cours, packs, produits boutique selon les lignes du cart) :

**`POST /cart/checkout`**

Corps typique (selon votre app) : coupon, etc.

Réponse : objet contenant notamment **`order`** avec `id`, montants, et `paymentChannels` (peut être redondant avec `GET /payments/channels`).

La commande doit être en statut **`pending`** pour enchaîner avec le paiement.

---

## 3. Démarrer le paiement ClicToPay

**`POST /payments/request`**

### Corps (JSON ou form-data)

| Paramètre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| `order_id` | int | oui | ID de la commande `pending` |
| `gateway_id` | int | oui | ID du canal ClicToPay (voir `GET /payments/channels`) |

### Réponse succès (schéma logique)

Le détail exact dépend du wrapper `apiResponse2` de votre projet ; les données métier incluent :

| Champ | Description |
|--------|-------------|
| `pay_url` | URL du formulaire ClicToPay à ouvrir dans un **WebView** ou le navigateur système |
| `order_id` | ID commande |
| `gateway_id` | ID du canal |
| `order_type` | Type de commande Laravel (`webinar`, `bundle`, `product`, `charge`, etc.) |
| `app_base_url` | `APP_URL` du backend (sans slash final) |
| `verify_path` | Chemin web de retour, ex. `/payments/verify/clictopay` |
| `clictopay.environment` | `sandbox` \| `production` |
| `clictopay.api_base` | URL REST correspondante |

### Erreurs fréquentes

- `disabled_gateway` : canal inactif ou ID invalide  
- `gateway_error` : échec technique (credentials, TLS, erreur ClicToPay, etc.) — consulter `storage/logs/laravel.log`

---

## 4. WebView : URL à charger

1. Ouvrir **`pay_url`** retournée par `POST /payments/request`.
2. Laisser l’utilisateur payer sur la page ClicToPay.
3. Après paiement, ClicToPay redirige le navigateur vers le **returnUrl** configuré côté serveur, du type :

   ```text
   {app_base_url}/payments/verify/clictopay?order_id={ORDER_ID}
   ```

   C’est une route **web** (pas `/api/panel/...`), **publique**, sans JWT.

4. Le backend vérifie le statut via l’API ClicToPay puis enchaîne (panier, ventes, etc.) et **doit** terminer le flux par une redirection vers la page web de statut :

   ```text
   {app_base_url}/payments/status?t={ORDER_ID}
   ```

   (éventuellement avec `order_id` en query selon l’implémentation de `payStatus` — voir ci-dessous).

### Flutter — détection de fin de flux

Sur `NavigationDelegate` / équivalent :

- **Cas nominal** : fermer le WebView (succès) lorsque l’URL contient **`/payments/status`**.
- **Secours** : si une ancienne config ou un cas limite renvoie encore vers l’accueil du site (`/`, `/fr`, etc.), l’app peut aussi fermer sur ce retour **marchand** après un paiement ouvert sur un hôte externe (ex. `test.clictopay.com`) — à garder comme filet de sécurité, pas comme comportement principal.
- Après fermeture : **rafraîchir l’état de la commande** via l’API (voir ci-dessous).

**À ne pas faire** : ne pas configurer le returnUrl banque vers `/api/panel/payments/verify/clictopay` : cette route est protégée par l’auth API et n’est pas adaptée au retour navigateur.

---

## Backend — fin de flux ClicToPay (redirection et session web)

Dans un **WebView**, il n’y a pas de « session web » Laravel alignée sur le JWT de l’app. Sans garde-fous, la redirection après `payments/verify/clictopay` pouvait envoyer vers le panel (`/panel/webinars/purchases`, boutique, etc.), déclencher un **login**, puis l’**accueil** ou la landing « mobile app », au lieu de **`/payments/status`**.

### Causes typiques (avant correctif)

| Sujet | Problème |
|--------|----------|
| **`getRedirectResponse()`** | Renvoyait cours / pack / produit vers des URLs panel ou store ; dans le WebView → login ou mauvaise page. |
| **`payStatus`** | Ne résolvait la commande que si `auth()->id()` = `user_id` de la commande ; sans session web cohérente avec le verify → pas de commande → redirect vers `/panel` ou accueil. |
| **Middleware `CheckMobileApp`** | Comparaison `getPathInfo()` vs `route('mobileAppRoute')` (URL complète vs chemin) ou règles trop larges → redirection vers la landing mobile, y compris après paiement. |

### Comportement attendu après correctif

| Zone | Rôle |
|------|------|
| **`PaymentController::clictopayPaymentVerify`** | Avant `paymentOrderAfterVerify`, pose `session('force_payment_status_redirect', true)` pour forcer la fin de flux sur `/payments/status?t=…`. |
| **`getRedirectResponse`** | Si ce flag est présent (puis retiré avec `pull`), **redirection immédiate** vers `/payments/status` — pas vers le panel ni les achats. |
| **`payStatus`** | Prise en charge de `order_id` en query ; si la session contient `payment.order_id` cohérent avec l’URL → `Auth::loginUsingId` ; sinon, pour une commande **récente** (fenêtre type 15 min) en statut `paid` / `paying` / `fail` → connexion du bon utilisateur pour afficher la vue de statut (`status_pay`). |
| **`CheckMobileApp`** | Exclusion des chemins `payments/*` et `payment/*` ; test de la landing via `$request->is('mobile-app')` plutôt qu’une comparaison à `route()` complet. |

Le flux ClicToPay **termine donc toujours** sur **`/payments/status`**, ce qui correspond à la détection Flutter principale et à la doc mobile.

---

## 5. Vérifier le statut après paiement

**`GET /orders/{orderId}`** (ou liste **`GET /orders`**)

Contrôler que la commande est passée en statut payé / traité selon votre modèle métier.

---

## Sandbox vs production (récap)

| Réglage | Où ? |
|---------|------|
| Test mode ON | Admin → canal ClicToPay → credentials → **test mode** → environnement **sandbox** (`test.clictopay.com`) |
| Test mode OFF | **production** (`ipay.clictopay.com`) + identifiants prod |

L’app lit `clictopay.environment` dans les réponses API à des fins d’affichage / debug ; le comportement réel est entièrement côté serveur et admin.

---

## Cours, packs, boutique

Le flux **`POST /cart/checkout`** + **`POST /payments/request`** s’appuie sur la même table **`orders`** et **`order_items`** que le site : cours (`webinar`), packs (`bundle`), produits (`product`), recharge wallet (`charge`), etc.

Tant que la commande est créée en **`pending`** pour l’utilisateur authentifié, le même `order_id` peut être payé avec ClicToPay.

---

## TLS / erreur cURL 60 (serveur)

Si le serveur ne valide pas les certificats HTTPS vers ClicToPay, voir la configuration :

- `config/payment.php` → section `clictopay`
- Variables d’environnement : `CLICTOPAY_VERIFY_SSL`, `CLICTOPAY_CACERT`

Idéalement : corriger le bundle CA système / `php.ini` (`curl.cainfo` / `openssl.cafile`).

---

## Fichiers code utiles (référence dev)

| Fichier | Rôle |
|---------|------|
| `routes/api/user.php` | `GET payments/channels`, `POST payments/request`, … |
| `app/Http/Controllers/Api/Panel/PaymentsController.php` | Réponses JSON paiement, liste canaux |
| `app/PaymentChannels/ClictopayPaymentChannel.php` | `register.do`, `getOrderStatusExtended.do`, returnUrl web |
| `routes/web.php` | `payments/verify/clictopay` (retour banque) |
| `app/Http/Controllers/Web/PaymentController.php` | `clictopayPaymentVerify`, finalisation commande, flag `force_payment_status_redirect` |
| Middleware `CheckMobileApp` | Exclusions `payments/*`, `payment/*`, test landing cohérent |

---

*Document généré pour le projet KingCoq / Edufirma — à ajuster avec votre `API_BASE` et les chemins exacts observés en recette. Version alignée avec la redirection forcée vers `/payments/status` et le secours Flutter sur l’accueil marchand.*
