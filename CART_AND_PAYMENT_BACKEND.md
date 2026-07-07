# Panier et paiement — exigences backend

L’app Flutter **n’envoie plus de montant client** au paiement. Les montants (prix après réduction, total) doivent venir **uniquement du backend**, comme dans le projet legacy kingco.

---

## 1. Panier — `GET /api/panel/cart/list`

Réponse attendue (structure existante) :

- **`cart.items[]`** (CartResource) : chaque article doit avoir :
  - `price` : prix d’origine (ou prix du ticket)
  - `discountPrice` (ou `discount_price`) : **prix après réduction** calculé par le backend (ex. CartItemInfo : `price - getDiscount(ticket)` si remise, sinon `null`)
- **`cart.amounts`** :
  - `sub_total` : somme des prix d’origine
  - `total_discount` : remise totale calculée
  - `tax` / `tax_price` : taxes
  - `total` : **montant total à payer**

L’app Flutter parse `discountPrice` (camelCase) et `discount_price` (snake_case) pour l’affichage du panier.

### Pack (bundle) : prix après réduction

L’app envoie désormais **`ticket_id`** lors de l’ajout d’un pack au panier (`POST /api/panel/cart/store` avec `bundle_id` + optionnel `ticket_id`), comme pour les cours. Pour que le **montant après réduction** soit bien utilisé au paiement pour les packs :

- Soit le backend utilise **`ticket_id`** pour les bundles (comme pour les webinars) et calcule le prix / `discountPrice` à partir du ticket.
- Soit le backend, lorsqu’il crée la ligne panier pour un `bundle_id`, applique la réduction du pack (**`discount_percent`** / **`price_with_discount`**) et renvoie `discountPrice` (prix après réduction) dans la réponse panier.

Sans l’un de ces deux comportements, le pack est ajouté au panier au **prix original** et le paiement utilise ce montant au lieu du montant après réduction.

---

## 2. Checkout — `POST /api/panel/cart/checkout`

- Le backend crée une **commande** à partir du panier actuel.
- Il doit calculer le **total à payer** (après remises, taxes, etc.) et le stocker sur la commande.
- Réponse attendue (structure existante) :
  - **`order`** : id, `total_amount` (ou équivalent) = montant total de la commande.
  - **`amounts`** : mêmes infos que pour le panier, mais **pour la commande** (total à payer, etc.).

L’app utilise **uniquement** ces données pour afficher le total sur l’écran de paiement et pour le flux de paiement.

---

## 3. Paiement gateway — `POST /api/panel/payments/request`

Corps envoyé par l’app (seuls paramètres envoyés) :

- `gateway_id` (required, exists payment_channels)
- `order_id` (required, exists orders)

**L’app n’envoie pas `amount`.**

- Le backend utilise **le montant de la commande** : `order.total_amount` pour créer la session (ex. Konnect : `amount = order.total_amount * 1000` en millimes).

---

## 4. Récapitulatif

| Étape              | Qui calcule le montant | Rôle de l’app                          |
|--------------------|-------------------------|----------------------------------------|
| Panier (liste)     | Backend                 | Affiche `cart.amounts` et `items`      |
| Checkout           | Backend                 | Affiche `checkout.amounts` / `order`   |
| Paiement gateway   | Backend (order total)   | Envoie `gateway_id` + `order_id` uniquement |
| Paiement offline   | Backend (order total)   | Affiche `order.total` pour info        |

---

## 5. Statut / Conformité

| Exigence | Statut |
|----------|--------|
| Panier retourne `discountPrice` (prix après réduction) calculé par le backend | ✅ OK |
| Checkout crée la commande avec `total_amount` (createOrderAndOrderItems) | ✅ OK |
| Payment request n’accepte que `gateway_id` + `order_id` ; Konnect utilise `order.total_amount` | ✅ OK |
| L’app Flutter n’envoie pas de montant au paiement | ✅ OK |

Le backend est conforme au comportement legacy kingco. L’app envoie uniquement `gateway_id` et `order_id` ; le backend utilise le montant de la commande pour le gateway.
