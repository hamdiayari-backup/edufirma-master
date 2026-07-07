# Gestion du code promo (coupon) – Kingco vs Edufirma

## Kingco (D:\2025\kingco\Source)

### API
- **Validation** : `POST panel/cart/coupon/validate`  
  - Body : `{"coupon": "CODE"}`  
  - Succès : `data.amounts` (montants mis à jour), `data.discount.id` → stocké en `discount_id`

### UI
- **Panier** : bouton « Ajouter un code promo » ouvre un **bottom sheet** (`CartWidget.showCouponSheet()`).
- Sheet : champ texte pour le code + bouton « Valider » → `CartService.validateCoupon(code)`.
- Si succès : la sheet se ferme et renvoie `{ 'amount': Amounts, 'discount_id': id }` ; la page panier met à jour `cartData.amounts` et `discountId` (état local).

### Checkout
- **Cours / packs** : `CartService.checkout()` avec body `{}` (pas de `discount_id` dans la requête). Le backend applique la remise via la session après `coupon/validate`.
- **Boutique (store)** : `StoreService.getWebCheckoutLink(discountId)` envoie `discount_id` au checkout store.

---

## Edufirma (ce projet)

### Déjà en place
- **API** : même endpoint `POST panel/cart/coupon/validate`, même body et même forme de réponse.
- **CartService** : `validateCoupon(coupon)` → retourne `{ 'amounts': CartAmounts, 'discount_id': id }`.
- **CartProvider** : `validateCoupon()` met à jour `_cart.amounts` et `_discountId`.
- **Page panier** : champ « Code promo » + bouton « Appliquer » (inline, pas de sheet) → `_applyCoupon()` appelle `provider.validateCoupon(...)`.
- **Checkout cours** : `checkout()` sans body (comme Kingco). Le backend doit appliquer la remise côté session après validation du coupon.
- **Boutique** : `getWebCheckoutLink(discountId)` envoie bien `discount_id`.

### Modifs faites
- Messages du coupon traduits (FR/AR) : `coupon_applied`, `coupon_invalid` utilisés dans la SnackBar après application du code.

---

## Conclusion

La gestion du **code promo pour les cours et packs** existe bien dans Edufirma et est alignée avec Kingco :

1. L’utilisateur saisit un code sur la page panier et clique sur « Appliquer ».
2. L’app appelle `panel/cart/coupon/validate` ; le backend met à jour le panier (session) et renvoie les nouveaux montants + `discount.id`.
3. L’app affiche les montants mis à jour et garde `discount_id` dans le provider.
4. Au checkout (`panel/cart/checkout`), le backend utilise la session pour créer la commande avec la remise déjà appliquée (aucun `discount_id` dans le body, comme dans Kingco).

Si le backend exige un `discount_id` explicite dans `POST panel/cart/checkout`, il faudra l’ajouter dans `CartService.checkout()` et `CartProvider.checkout()` en passant `discountId` du provider.
