# Alignement app EduFirma avec la doc backend et notes client

**Date :** 6 février 2026  
**Référence :** Documentation des corrections backend EduFirma + notes client.

---

## 1. Bug #1 – Notifications « Tout lire »

- **Backend :** Route `POST /api/panel/notifications/seen-all` (alias).
- **App :** Déjà alignée. `NotificationService.markAllAsRead()` appelle `POST panel/notifications/seen-all` (`lib/core/services/notification_service.dart`). Aucun changement nécessaire si le backend expose bien cette route.

---

## 2. Bug #2 – Retard d’affichage des cours après achat

- **Backend :** Transactions + mise à jour immédiate des ventes / statut.
- **App (corrigé) :**
  - Après paiement réussi, le bouton « Mes cours » sur la page statut de paiement envoie vers `MainPage` avec `arguments: {'tab': 2}`.
  - `MainPage` lit ces arguments dans `didChangeDependencies`, affiche l’onglet « Mes cours » (index 2) et recrée `MyCoursesPage` via une clé de refresh, ce qui relance `_loadPurchases()`. Les cours achetés s’affichent donc à jour dès l’arrivée sur « Mes cours ».

---

## 3. Bug #3 (client) – Message de confirmation bloqué après achat

- **Problème client :** Le message de succès après achat ne disparaît pas tout seul.
- **App (corrigé) :** Tous les `SnackBar` de la page checkout ont maintenant une `duration` (3 ou 4 secondes) pour se fermer automatiquement (sélection mode de paiement, solde insuffisant, erreurs, etc.).

---

## 4. Bug #3 backend – Notifications en double/triple

- **Backend :** Déduplication côté serveur (fenêtre 2 min).
- **App :** Aucune modification requise.

---

## 5. Bug #7 – Achat avec points de fidélité

- **Backend :**
  - `POST /api/panel/rewards/redeem` (body: `webinar_id` ou `bundle_id`)
  - `POST /api/panel/payments/pay-with-points` (body: `order_id`)
- **App :** Pour l’instant, l’app n’appelle pas ces endpoints (pas d’UI dédiée « payer en points » / « échanger des points »). À prévoir : bouton/option au checkout ou sur la fiche cours pour utiliser les points, puis appels à ces deux routes.

---

## 6. Bug #8 – Paiement hors ligne / commandes

- **Backend :** Création d’une commande (`Order`) à chaque demande de paiement hors ligne ; `GET /api/panel/orders` inclut ces commandes.
- **App (corrigé) :**
  - Le message de succès après soumission d’une demande de paiement hors ligne est affiché en **vert** (`AppColors.success`) au lieu d’orange/rouge, pour ne plus donner l’impression d’une erreur.
  - La liste « Mes commandes » provient de `GET panel/orders` ; une fois le backend déployé, les demandes hors ligne y apparaîtront.

---

## 7. Notes client sans changement app (ou backend)

- **Retard affichage « cours terminé » :** Dépend du backend (mise à jour de la progression). L’app rafraîchit déjà « Mes cours » à l’ouverture (et après paiement, voir §2).
- **Notifications push (connexion par e-mail) :** Envoi FCM côté backend ; l’app envoie le token (voir `FirebaseNotificationService.sendTokenToServerIfLoggedIn`). À vérifier côté backend que les utilisateurs connectés par e-mail reçoivent bien les push.
- **Certificat non reçu après fin de cours :** Workflow backend (génération / envoi). L’app permet le téléchargement des certificats listés par l’API.

---

## Récapitulatif des modifications app (fichiers)

| Fichier | Modification |
|--------|----------------|
| `lib/features/home/presentation/pages/main_page.dart` | Lecture des `arguments` de la route (`tab`), affichage de l’onglet « Mes cours » (2) et clé de refresh pour recréer `MyCoursesPage` et recharger les achats. |
| `lib/features/cart/presentation/pages/checkout_page.dart` | SnackBar succès paiement hors ligne en vert ; `duration` ajoutée à tous les SnackBar de la page (3–4 s). |

---

*Document généré le 6 février 2026 – Alignement avec la doc backend et les notes client.*
