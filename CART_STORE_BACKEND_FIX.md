# Correction backend : ajout d'un pack (bundle) au panier

## Problème

- **Requête app** : `POST /api/panel/cart/store` avec `{"bundle_id":"7"}` pour un pack.
- **Réponse API** : `{"success":false,"data":{"errors":{"webinar_id":["Le champ webinar id est obligatoire."]}}}`

La validation Laravel exige actuellement `webinar_id` pour toutes les requêtes. Pour un **pack**, l’app envoie uniquement `bundle_id`, donc la validation échoue.

## Solution (côté Laravel)

Sur le contrôleur qui gère `panel/cart/store` (souvent `CartController` ou `Panel\CartController`), il faut que la validation accepte **soit** `webinar_id` (cours), **soit** `bundle_id` (pack).

### Règles à utiliser

Au lieu de :

```php
'webinar_id' => 'required',
```

utiliser :

```php
'webinar_id' => 'required_without:bundle_id|nullable|exists:webinars,id',
'bundle_id'  => 'required_without:webinar_id|nullable|exists:bundles,id',
```

- `required_without:bundle_id` : `webinar_id` est obligatoire **seulement si** `bundle_id` n’est pas envoyé.
- `required_without:webinar_id` : `bundle_id` est obligatoire **seulement si** `webinar_id` n’est pas envoyé.

Ainsi, une requête avec uniquement `bundle_id` (pack) ou uniquement `webinar_id` (cours) est valide.

### Exemple complet

```php
public function store(Request $request)
{
    $validated = $request->validate([
        'webinar_id' => 'required_without:bundle_id|nullable|integer|exists:webinars,id',
        'bundle_id'  => 'required_without:webinar_id|nullable|integer|exists:bundles,id',
        'ticket_id'  => 'nullable|integer',
    ]);

    if (!empty($validated['bundle_id'])) {
        // Logique d'ajout du pack au panier
        // ...
    } else {
        // Logique d'ajout du cours au panier
        // ...
    }

    return $this->successResponse([...]);
}
```

Adapter les noms des tables (`webinars`, `bundles`) et la logique métier selon ton projet.

## Côté app (Flutter)

L’app envoie déjà le bon corps :

- **Cours** : `addCourseToCart(courseId)` → `{"webinar_id": "123"}`
- **Pack** : `addBundleToCart(bundleId)` → `{"bundle_id": "7"}`

Aucun changement nécessaire côté Flutter une fois la validation Laravel corrigée.
