# EduFirma - LMS Mobile App

<p align="center">
  <img src="edufirmalogo.png" alt="EduFirma Logo" width="200">
</p>

## 📱 À propos

EduFirma est une application mobile d'apprentissage en ligne (LMS) moderne développée avec Flutter. Elle permet aux utilisateurs de découvrir, acheter et suivre des cours en ligne, ainsi que d'acheter des produits associés.

## 🎨 Design

L'application utilise une palette de couleurs inspirée du logo :
- **Vert Lime** (#7CB342) - Couleur principale
- **Bleu Sarcelle** (#0D3C45) - Couleur secondaire
- **Accents modernes** avec des dégradés et animations fluides

## 🌍 Langues supportées

- 🇹🇳 Français (par défaut)
- 🇹🇳 Arabe

## ✨ Fonctionnalités

### Cours & Bundles
- Explorer les cours disponibles
- Voir les cours en vedette, nouveaux, et les meilleures ventes
- Cours en bundles (forfaits)
- Vidéo de démonstration avant achat
- Accès au contenu après achat
- Suivi de progression

### Boutique
- Catalogue de produits
- Catégories de produits
- Ajouter au panier

### Panier & Paiement
- Gestion du panier
- Application de coupons
- Paiement sécurisé (Carte, Konnect, Virement)

### Profil & Paramètres
- Gestion du compte
- Mes cours achetés
- Favoris
- Certificats
- Changement de langue

## 🛠️ Technologies

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Dependency Injection**: GetIt
- **HTTP Client**: HTTP + Dio
- **Local Storage**: SharedPreferences + Hive
- **Animations**: flutter_animate
- **Icons**: Iconsax

## 📁 Structure du projet

```
lib/
├── config/
│   ├── routes/
│   └── theme/
├── core/
│   ├── constants/
│   ├── di/
│   ├── localization/
│   ├── network/
│   └── storage/
├── features/
│   ├── auth/
│   ├── cart/
│   ├── courses/
│   ├── home/
│   ├── onboarding/
│   ├── profile/
│   ├── splash/
│   └── store/
├── providers/
└── main.dart
```

## 🚀 Installation

1. **Cloner le projet**
```bash
cd edufirma
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer les fichiers Hive (si nécessaire)**
```bash
flutter packages pub run build_runner build
```

4. **Lancer l'application**
```bash
flutter run
```

## 🔧 Configuration

### API Base URL
Modifier dans `lib/core/constants/api_constants.dart`:
```dart
static const String domain = 'https://votre-domaine.com';
```

### API Key
```dart
static const String apiKey = 'votre-api-key';
```

## 📱 Captures d'écran

L'application comprend :
- Écrans d'onboarding animés
- Page d'accueil avec sections dynamiques
- Liste et détails des cours
- Boutique de produits
- Panier et checkout
- Profil utilisateur

## 🏗️ Architecture

L'application suit une architecture en couches :
- **Presentation**: UI, Widgets, Pages
- **Data**: Repositories, Models
- **Core**: Utilities, Constants, Services

## 📄 Licence

Propriétaire - EduFirma Tunisia

---

Développé avec ❤️ pour la Tunisie 🇹🇳






