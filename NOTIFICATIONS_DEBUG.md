# Diagnostic des notifications système (FCM)

## Modifications apportées

1. **App** : Le token FCM est maintenant envoyé au serveur à chaque ouverture de l'app (MainPage)
2. **Backend** : Logs ajoutés pour diagnostiquer les échecs FCM

## Checklist de vérification

### 1. Vérifier que le token FCM est envoyé (console Flutter)

Au lancement de l'app (connecté), tu dois voir dans la console :
```
FCM Token: eyJ...
FCM token sent OK to server
```

Si tu vois `FCM: Skipped (user not logged in)` → l'utilisateur n'est pas connecté au moment de l'init.
Si tu vois `FCM token FAILED to server` → l'API PUT /panel/users/fcm a échoué.

### 2. Vérifier que le token est en base (backend)

Sur le serveur edufirma.com, exécuter :
```sql
SELECT user_id, LEFT(fcm_token, 30) as token_preview, updated_at 
FROM user_firebase_sessions 
WHERE user_id = 1092 AND fcm_token IS NOT NULL AND fcm_token != '';
```

Si vide → le token n'est pas stocké. Vérifier que les modifications du backend sont déployées.

### 3. Vérifier les logs Laravel (backend)

Sur le serveur : `storage/logs/laravel.log`

- `FCM: No tokens for user_id=X` → Aucun token pour cet utilisateur (réenvoie depuis l'app)
- `FCM send failed: ...` → Firebase a rejeté l'envoi (token invalide, config Firebase, etc.)
- `FCM init/send error: ...` → Erreur de configuration Firebase

### 4. Déployer les modifications backend

Les fichiers modifiés doivent être sur edufirma.com :
- `app/Helpers/ApiHelper.php`
- `app/Helpers/helper.php`
- `app/Http/Controllers/Api/Panel/UsersController.php`

### 5. Firebase

- Fichier `firebase-auth.json` présent à la racine du projet Laravel
- Même projet Firebase que l'app mobile (même `google-services.json`)

### 6. Test manuel

1. Se déconnecter de l'app
2. Se reconnecter
3. Vérifier la console : "FCM token sent OK"
4. Déclencher une notification (admin : changer un badge, etc.)
5. Vérifier `storage/logs/laravel.log` pour les erreurs
