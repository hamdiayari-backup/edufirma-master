# Rapport de bugs Backend - EduFirma

**Date:** 2026-02-06
**Application:** EduFirma Mobile (Flutter)
**Priorité:** Haute

---

## Résumé

Ce document décrit les bugs identifiés qui nécessitent une intervention côté backend. Les corrections frontend ont déjà été appliquées pour les problèmes d'UI.

---

## Bug #1 - Notifications "Tout lire" ne fonctionne pas

### Description
Lorsque l'utilisateur clique sur l'option "Tout lire" dans le menu des notifications, les notifications ne sont pas marquées comme lues. Elles ne deviennent lues que si l'utilisateur les ouvre une par une.

### Endpoint concerné
```
POST /panel/notifications/seen-all
```

### Comportement attendu
- L'API doit retourner `{ "success": true }`
- Toutes les notifications de l'utilisateur doivent avoir leur statut mis à jour à `read` / `seen = true` dans la base de données

### Vérifications suggérées
1. Vérifier que la requête met bien à jour toutes les notifications de l'utilisateur authentifié
2. Vérifier les logs pour voir si l'endpoint est bien appelé
3. S'assurer que la transaction est bien commitée

---

## Bug #2 - Retard d'affichage des cours après achat

### Description
Lors de l'achat d'un cours, celui-ci apparaît dans la section "Mes cours" avec un retard anormal, au lieu d'être affiché immédiatement.

### Comportement actuel
Après un paiement réussi, le champ `auth_has_bought` du cours n'est pas mis à jour immédiatement.

### Comportement attendu
Dès que le paiement est confirmé (webhook ou retour gateway), la relation user-course doit être créée instantanément.

### Endpoints concernés
- `POST /panel/payments/credit` (paiement par solde)
- `POST /panel/payments/request` (paiement en ligne)
- Webhook du gateway de paiement

### Solutions suggérées
1. Vérifier que l'inscription au cours se fait de manière synchrone après le paiement
2. Invalider le cache utilisateur après un achat réussi
3. S'assurer que le webhook de paiement traite immédiatement l'inscription

---

## Bug #3 - Notifications envoyées en double ou triple

### Description
Certaines notifications sont envoyées plusieurs fois (2 ou 3 fois), ce qui crée de la confusion pour l'utilisateur.

### Cause probable
- Trigger de notification exécuté plusieurs fois
- Job de notification sans vérification d'idempotence
- Event listener enregistré plusieurs fois

### Solutions suggérées
1. Ajouter une vérification d'unicité avant l'envoi (hash du contenu + user_id + timestamp)
2. Utiliser un flag `notification_sent` sur l'entité source
3. Implémenter un mécanisme de déduplication avec Redis/cache

---

## Bug #4 - Retard d'affichage des cours terminés

### Description
Lorsqu'un cours est complété à 100%, le statut "cours terminé" s'affiche avec un retard.

### Endpoint concerné
```
GET /panel/webinars/{id}
```

### Comportement attendu
Le champ de progression doit être mis à jour en temps réel lorsque l'utilisateur termine une leçon.

### Solutions suggérées
1. Calculer la progression de manière synchrone après chaque leçon complétée
2. Éviter les jobs asynchrones pour la mise à jour de progression
3. Retourner `completed: true` immédiatement quand `progress = 100%`

---

## Bug #5 - Notifications push non reçues (connexion par email)

### Description
Lorsque l'utilisateur est connecté avec une adresse email (et non via OAuth), les notifications push ne sont pas reçues sur le téléphone. Seules les notifications par email arrivent.

### Cause probable
Le token FCM n'est pas correctement associé à l'utilisateur lors de la connexion par email.

### Endpoint concerné
```
POST /panel/users/fcm-token  (ou équivalent)
```

### Solutions suggérées
1. Vérifier que le token FCM est bien enregistré pour les utilisateurs email
2. S'assurer que la logique d'envoi push ne dépend pas du type d'authentification
3. Vérifier les logs Firebase pour les erreurs d'envoi

---

## Bug #6 - Certificat de fin de cours non reçu

### Description
Après avoir terminé un cours à 100%, le certificat correspondant ne parvient pas automatiquement à l'utilisateur.

### Comportement attendu
1. Quand `progress = 100%`, générer automatiquement le certificat
2. Créer une notification pour informer l'utilisateur
3. Le certificat doit apparaître dans `GET /panel/webinars/certificates`

### Endpoints concernés
```
GET /panel/webinars/certificates
GET /panel/certificates/achievements
```

### Solutions suggérées
1. Implémenter un listener sur la complétion de cours
2. Générer le certificat PDF automatiquement
3. Envoyer une notification push + email

---

## Bug #7 - Achat avec points de fidélité non fonctionnel

### Description
La fonctionnalité d'achat de cours via les points de fidélité (bonus) ne fonctionne pas.

### Comportement attendu
L'utilisateur devrait pouvoir utiliser ses points accumulés pour acheter des cours marqués comme "reward".

### Endpoint nécessaire
```
POST /panel/cart/checkout
{
    "payment_method": "points",
    "webinar_id": 123
}
```

Ou un endpoint dédié:
```
POST /panel/rewards/redeem
{
    "webinar_id": 123,
    "points": 500
}
```

### À implémenter
1. Vérifier le solde de points de l'utilisateur
2. Déduire les points du solde
3. Inscrire l'utilisateur au cours
4. Créer un historique de transaction points

---

## Bug #8 - Paiement hors ligne - Commandes non visibles

### Description
Lors d'un paiement hors ligne (virement bancaire):
1. ~~Le message s'affiche en rouge~~ **(Corrigé côté frontend - maintenant orange)**
2. La demande de paiement n'apparaît pas dans "Mes commandes"

### Endpoints concernés
```
POST /panel/offline-payments (création)
GET /panel/orders (liste des commandes)
```

### Comportement attendu
Après soumission d'un paiement hors ligne:
1. Une commande avec statut `pending` doit être créée
2. Cette commande doit apparaître dans `GET /panel/orders`
3. Statut: `pending_verification` ou `awaiting_payment`

### Solutions suggérées
1. Vérifier que `POST /panel/offline-payments` crée bien une entrée dans la table `orders`
2. S'assurer que le filtre de `GET /panel/orders` inclut les commandes en attente de vérification
3. Ajouter le champ `offline_payment_id` à la commande pour traçabilité

---

## Priorités recommandées

| Priorité | Bug | Impact utilisateur |
|----------|-----|-------------------|
| **P1** | #2 - Retard cours après achat | Critique - UX post-achat |
| **P1** | #7 - Points fidélité | Fonctionnalité bloquée |
| **P1** | #8 - Commandes hors ligne | Paiements invisibles |
| **P2** | #1 - Tout lire notifications | UX notifications |
| **P2** | #6 - Certificats | Fonctionnalité incomplète |
| **P2** | #3 - Notifications doubles | Spam utilisateur |
| **P3** | #4 - Retard progression | UX mineure |
| **P3** | #5 - Push email users | Config FCM |

---

## Contact

Pour toute question sur ce rapport, contacter l'équipe mobile.

---

*Document généré automatiquement lors de l'analyse du code frontend.*
