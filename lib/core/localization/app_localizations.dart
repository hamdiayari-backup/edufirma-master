import 'dart:async';
import 'package:flutter/material.dart';

/// App Localizations for French and Arabic (Tunisia)
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  // ============ Translations Map ============
  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': _frenchTranslations,
    'ar': _arabicTranslations,
  };
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
  
  // Getters for all translations
  String get appName => translate('appName');
  String get splashDesc => translate('splashDesc');
  
  // Onboarding
  String get onboardingTitle1 => translate('onboardingTitle1');
  String get onboardingTitle2 => translate('onboardingTitle2');
  String get onboardingTitle3 => translate('onboardingTitle3');
  String get onboardingDesc1 => translate('onboardingDesc1');
  String get onboardingDesc2 => translate('onboardingDesc2');
  String get onboardingDesc3 => translate('onboardingDesc3');
  String get getStarted => translate('getStarted');
  String get skip => translate('skip');
  String get next => translate('next');
  
  // Auth
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get forgotPassword => translate('forgotPassword');
  String get createAccount => translate('createAccount');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get welcomeBack => translate('welcomeBack');
  String get loginDesc => translate('loginDesc');
  String get createAccountDesc => translate('createAccountDesc');
  String get phoneNumber => translate('phoneNumber');
  String get verifyCode => translate('verifyCode');
  String get verifyCodeDesc => translate('verifyCodeDesc');
  String get resendCode => translate('resendCode');
  String get yourName => translate('yourName');
  String get continueText => translate('continueText');
  String get skipLogin => translate('skipLogin');
  
  // Navigation
  String get home => translate('home');
  String get courses => translate('courses');
  String get bundles => translate('bundles');
  String get store => translate('store');
  String get profile => translate('profile');
  String get cart => translate('cart');
  String get favorites => translate('favorites');
  String get settings => translate('settings');
  
  // Home
  String get hello => translate('hello');
  String get letsStartLearning => translate('letsStartLearning');
  String get searchPlaceholder => translate('searchPlaceholder');
  String get viewAll => translate('viewAll');
  String get featuredCourses => translate('featuredCourses');
  String get newestCourses => translate('newestCourses');
  String get bestSelling => translate('bestSelling');
  String get discountedCourses => translate('discountedCourses');
  String get freeCourses => translate('freeCourses');
  String get latestBundles => translate('latestBundles');
  String get categories => translate('categories');
  String get instructors => translate('instructors');
  String get organizations => translate('organizations');
  
  // Course
  String get courseDetails => translate('courseDetails');
  String get information => translate('information');
  String get content => translate('content');
  String get reviews => translate('reviews');
  String get addToCart => translate('addToCart');
  String get buyNow => translate('buyNow');
  String get enrollNow => translate('enrollNow');
  String get free => translate('free');
  String get students => translate('students');
  String get lessons => translate('lessons');
  String get hours => translate('hours');
  String get duration => translate('duration');
  String get level => translate('level');
  String get certificate => translate('certificate');
  String get instructor => translate('instructor');
  String get description => translate('description');
  String get requirements => translate('requirements');
  String get whatYouWillLearn => translate('whatYouWillLearn');
  String get demoVideo => translate('demoVideo');
  String get startLearning => translate('startLearning');
  
  // Cart & Checkout
  String get myCart => translate('myCart');
  String get cartEmpty => translate('cartEmpty');
  String get cartEmptyDesc => translate('cartEmptyDesc');
  String get subtotal => translate('subtotal');
  String get discount => translate('discount');
  String get total => translate('total');
  String get checkout => translate('checkout');
  String get applyCoupon => translate('applyCoupon');
  String get paymentMethod => translate('paymentMethod');
  String get paymentSuccess => translate('paymentSuccess');
  String get paymentFailed => translate('paymentFailed');
  String get remove => translate('remove');
  
  // Store/Products
  String get products => translate('products');
  String get productDetails => translate('productDetails');
  String get allProducts => translate('allProducts');
  String get quantity => translate('quantity');
  
  // Shipping Address
  String get shippingAddress => translate('shippingAddress');
  String get pleaseEnterAddress => translate('pleaseEnterAddress');
  String get firstName => translate('firstName');
  String get lastName => translate('lastName');
  String get fullAddress => translate('fullAddress');
  String get city => translate('city');
  String get country => translate('country');
  String get zipCode => translate('zipCode');
  String get phone => translate('phone');
  String get confirmAddress => translate('confirmAddress');
  String get required => translate('required');
  String get addressRequired => translate('addressRequired');
  String get countryRequired => translate('countryRequired');
  String get phoneRequired => translate('phoneRequired');
  
  // Profile
  String get myProfile => translate('myProfile');
  String get myCourses => translate('myCourses');
  String get myBundles => translate('myBundles');
  String get myOrders => translate('myOrders');
  String get notifications => translate('notifications');
  String get language => translate('language');
  String get logout => translate('logout');
  String get deleteAccount => translate('deleteAccount');
  
  // Common
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get retry => translate('retry');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sortBy => translate('sortBy');
  String get noData => translate('noData');
  String get noDataDesc => translate('noDataDesc');
  String get yes => translate('yes');
  String get no => translate('no');
  
  // Filters
  String get all => translate('all');
  String get newest => translate('newest');
  String get highestPrice => translate('highestPrice');
  String get lowestPrice => translate('lowestPrice');
  String get bestRated => translate('bestRated');
}

// ============ French Translations ============
const Map<String, String> _frenchTranslations = {
  'appName': 'EduFirma',
  'splashDesc': 'La manière la plus simple d\'apprendre...',
  
  // Onboarding
  'onboardingTitle1': 'Découvrez les meilleurs cours',
  'onboardingTitle2': 'Apprenez à votre rythme',
  'onboardingTitle3': 'Obtenez votre certificat',
  'onboardingDesc1': 'Explorez une vaste collection de cours créés par des experts et des formateurs professionnels.',
  'onboardingDesc2': 'Accédez à vos cours n\'importe où, n\'importe quand et progressez à votre propre rythme.',
  'onboardingDesc3': 'Complétez vos cours et obtenez des certificats reconnus pour booster votre carrière.',
  'getStarted': 'Commencer',
  'skip': 'Passer',
  'next': 'Suivant',
  
  // Auth
  'login': 'Connexion',
  'signup': 'Inscription',
  'email': 'Email',
  'password': 'Mot de passe',
  'confirmPassword': 'Confirmer le mot de passe',
  'forgotPassword': 'Mot de passe oublié ?',
  'createAccount': 'Créer un compte',
  'alreadyHaveAccount': 'Vous avez déjà un compte ?',
  'dontHaveAccount': 'Vous n\'avez pas de compte ?',
  'welcomeBack': 'Bon retour !',
  'loginDesc': 'Connectez-vous pour continuer votre apprentissage',
  'createAccountDesc': 'Rejoignez EduFirma et commencez votre parcours d\'apprentissage',
  'phoneNumber': 'Numéro de téléphone',
  'verifyCode': 'Vérifier le code',
  'verifyCodeDesc': 'Entrez le code envoyé à votre téléphone',
  'resendCode': 'Renvoyer le code',
  'yourName': 'Votre nom',
  'continueText': 'Continuer',
  'skipLogin': 'Continuer sans compte',
  
  // Navigation
  'home': 'Accueil',
  'courses': 'Cours',
  'bundles': 'Forfaits',
  'store': 'Boutique',
  'profile': 'Profil',
  'cart': 'Panier',
  'favorites': 'Favoris',
  'settings': 'Paramètres',
  
  // Home
  'hello': 'Bonjour',
  'letsStartLearning': 'Commençons à apprendre !',
  'searchPlaceholder': 'Rechercher des cours...',
  'viewAll': 'Voir tout',
  'featuredCourses': 'Cours en vedette',
  'newestCourses': 'Nouveaux cours',
  'bestSelling': 'Meilleures ventes',
  'discountedCourses': 'Cours en promotion',
  'freeCourses': 'Cours gratuits',
  'latestBundles': 'Derniers forfaits',
  'categories': 'Catégories',
  'instructors': 'Formateurs',
  'organizations': 'Organisations',
  
  // Course
  'courseDetails': 'Détails du cours',
  'information': 'Informations',
  'content': 'Contenu',
  'reviews': 'Avis',
  'addToCart': 'Ajouter au panier',
  'buyNow': 'Acheter maintenant',
  'enrollNow': 'S\'inscrire',
  'free': 'Gratuit',
  'students': 'Étudiants',
  'lessons': 'Leçons',
  'hours': 'Heures',
  'duration': 'Durée',
  'level': 'Niveau',
  'certificate': 'Certificat',
  'instructor': 'Formateur',
  'description': 'Description',
  'requirements': 'Prérequis',
  'whatYouWillLearn': 'Ce que vous apprendrez',
  'demoVideo': 'Vidéo de démonstration',
  'startLearning': 'Commencer l\'apprentissage',
  
  // Cart & Checkout
  'myCart': 'Mon panier',
  'cartEmpty': 'Votre panier est vide',
  'cartEmptyDesc': 'Explorez nos cours et ajoutez-les à votre panier',
  'subtotal': 'Sous-total',
  'discount': 'Réduction',
  'total': 'Total',
  'checkout': 'Passer la commande',
  'applyCoupon': 'Appliquer un coupon',
  'paymentMethod': 'Méthode de paiement',
  'paymentSuccess': 'Paiement réussi !',
  'paymentFailed': 'Échec du paiement',
  'remove': 'Supprimer',
  
  // Store/Products
  'products': 'Produits',
  'productDetails': 'Détails du produit',
  'allProducts': 'Tous les produits',
  'quantity': 'Quantité',
  
  // Shipping Address
  'shippingAddress': 'Adresse de livraison',
  'pleaseEnterAddress': 'Veuillez renseigner votre adresse',
  'firstName': 'Prénom',
  'lastName': 'Nom',
  'fullAddress': 'Adresse complète',
  'city': 'Ville',
  'country': 'Pays',
  'zipCode': 'Code postal',
  'phone': 'Téléphone',
  'confirmAddress': 'Confirmer l\'adresse',
  'required': 'Requis',
  'addressRequired': 'L\'adresse est requise',
  'countryRequired': 'Le pays est requis',
  'phoneRequired': 'Le téléphone est requis',
  
  // Profile
  'myProfile': 'Mon profil',
  'myCourses': 'Mes cours',
  'myBundles': 'Mes forfaits',
  'myOrders': 'Mes commandes',
  'notifications': 'Notifications',
  'language': 'Langue',
  'logout': 'Déconnexion',
  'deleteAccount': 'Supprimer le compte',
  
  // Common
  'loading': 'Chargement...',
  'error': 'Erreur',
  'success': 'Succès',
  'retry': 'Réessayer',
  'cancel': 'Annuler',
  'confirm': 'Confirmer',
  'save': 'Enregistrer',
  'edit': 'Modifier',
  'delete': 'Supprimer',
  'search': 'Rechercher',
  'filter': 'Filtrer',
  'sortBy': 'Trier par',
  'noData': 'Aucune donnée',
  'noDataDesc': 'Aucune donnée disponible pour le moment',
  'yes': 'Oui',
  'no': 'Non',
  
  // Filters
  'all': 'Tous',
  'newest': 'Les plus récents',
  'highestPrice': 'Prix le plus élevé',
  'lowestPrice': 'Prix le plus bas',
  'bestRated': 'Les mieux notés',
};

// ============ Arabic Translations ============
const Map<String, String> _arabicTranslations = {
  'appName': 'إيدو فيرما',
  'splashDesc': 'أسهل طريقة للتعلم...',
  
  // Onboarding
  'onboardingTitle1': 'اكتشف أفضل الدورات',
  'onboardingTitle2': 'تعلم بالسرعة التي تناسبك',
  'onboardingTitle3': 'احصل على شهادتك',
  'onboardingDesc1': 'استكشف مجموعة واسعة من الدورات التي أنشأها خبراء ومدربون محترفون.',
  'onboardingDesc2': 'الوصول إلى دوراتك في أي مكان وفي أي وقت والتقدم بالسرعة التي تناسبك.',
  'onboardingDesc3': 'أكمل دوراتك واحصل على شهادات معترف بها لتعزيز مسيرتك المهنية.',
  'getStarted': 'ابدأ الآن',
  'skip': 'تخطي',
  'next': 'التالي',
  
  // Auth
  'login': 'تسجيل الدخول',
  'signup': 'إنشاء حساب',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'confirmPassword': 'تأكيد كلمة المرور',
  'forgotPassword': 'نسيت كلمة المرور؟',
  'createAccount': 'إنشاء حساب',
  'alreadyHaveAccount': 'لديك حساب بالفعل؟',
  'dontHaveAccount': 'ليس لديك حساب؟',
  'welcomeBack': 'مرحباً بعودتك!',
  'loginDesc': 'سجل الدخول لمتابعة التعلم',
  'createAccountDesc': 'انضم إلى إيدو فيرما وابدأ رحلة التعلم الخاصة بك',
  'phoneNumber': 'رقم الهاتف',
  'verifyCode': 'تأكيد الرمز',
  'verifyCodeDesc': 'أدخل الرمز المرسل إلى هاتفك',
  'resendCode': 'إعادة إرسال الرمز',
  'yourName': 'اسمك',
  'continueText': 'متابعة',
  'skipLogin': 'متابعة بدون حساب',
  
  // Navigation
  'home': 'الرئيسية',
  'courses': 'الدورات',
  'bundles': 'الباقات',
  'store': 'المتجر',
  'profile': 'الملف الشخصي',
  'cart': 'السلة',
  'favorites': 'المفضلة',
  'settings': 'الإعدادات',
  
  // Home
  'hello': 'مرحباً',
  'letsStartLearning': 'لنبدأ التعلم!',
  'searchPlaceholder': 'ابحث عن الدورات...',
  'viewAll': 'عرض الكل',
  'featuredCourses': 'الدورات المميزة',
  'newestCourses': 'أحدث الدورات',
  'bestSelling': 'الأكثر مبيعاً',
  'discountedCourses': 'دورات مخفضة',
  'freeCourses': 'دورات مجانية',
  'latestBundles': 'أحدث الباقات',
  'categories': 'التصنيفات',
  'instructors': 'المدربون',
  'organizations': 'المؤسسات',
  
  // Course
  'courseDetails': 'تفاصيل الدورة',
  'information': 'المعلومات',
  'content': 'المحتوى',
  'reviews': 'التقييمات',
  'addToCart': 'أضف إلى السلة',
  'buyNow': 'اشترِ الآن',
  'enrollNow': 'سجل الآن',
  'free': 'مجاني',
  'students': 'الطلاب',
  'lessons': 'الدروس',
  'hours': 'ساعات',
  'duration': 'المدة',
  'level': 'المستوى',
  'certificate': 'الشهادة',
  'instructor': 'المدرب',
  'description': 'الوصف',
  'requirements': 'المتطلبات',
  'whatYouWillLearn': 'ماذا ستتعلم',
  'demoVideo': 'فيديو تجريبي',
  'startLearning': 'ابدأ التعلم',
  
  // Cart & Checkout
  'myCart': 'سلتي',
  'cartEmpty': 'سلتك فارغة',
  'cartEmptyDesc': 'استكشف دوراتنا وأضفها إلى سلتك',
  'subtotal': 'المجموع الفرعي',
  'discount': 'الخصم',
  'total': 'الإجمالي',
  'checkout': 'إتمام الشراء',
  'applyCoupon': 'تطبيق القسيمة',
  'paymentMethod': 'طريقة الدفع',
  'paymentSuccess': 'تم الدفع بنجاح!',
  'paymentFailed': 'فشل الدفع',
  'remove': 'إزالة',
  
  // Store/Products
  'products': 'المنتجات',
  'productDetails': 'تفاصيل المنتج',
  'allProducts': 'جميع المنتجات',
  'quantity': 'الكمية',
  
  // Shipping Address
  'shippingAddress': 'عنوان التوصيل',
  'pleaseEnterAddress': 'الرجاء إدخال عنوانك',
  'firstName': 'الاسم الأول',
  'lastName': 'اسم العائلة',
  'fullAddress': 'العنوان الكامل',
  'city': 'المدينة',
  'country': 'البلد',
  'zipCode': 'الرمز البريدي',
  'phone': 'الهاتف',
  'confirmAddress': 'تأكيد العنوان',
  'required': 'مطلوب',
  'addressRequired': 'العنوان مطلوب',
  'countryRequired': 'البلد مطلوب',
  'phoneRequired': 'الهاتف مطلوب',
  
  // Profile
  'myProfile': 'ملفي الشخصي',
  'myCourses': 'دوراتي',
  'myBundles': 'باقاتي',
  'myOrders': 'طلباتي',
  'notifications': 'الإشعارات',
  'language': 'اللغة',
  'logout': 'تسجيل الخروج',
  'deleteAccount': 'حذف الحساب',
  
  // Common
  'loading': 'جاري التحميل...',
  'error': 'خطأ',
  'success': 'نجاح',
  'retry': 'إعادة المحاولة',
  'cancel': 'إلغاء',
  'confirm': 'تأكيد',
  'save': 'حفظ',
  'edit': 'تعديل',
  'delete': 'حذف',
  'search': 'بحث',
  'filter': 'تصفية',
  'sortBy': 'ترتيب حسب',
  'noData': 'لا توجد بيانات',
  'noDataDesc': 'لا توجد بيانات متاحة حالياً',
  'yes': 'نعم',
  'no': 'لا',
  
  // Filters
  'all': 'الكل',
  'newest': 'الأحدث',
  'highestPrice': 'الأعلى سعراً',
  'lowestPrice': 'الأقل سعراً',
  'bestRated': 'الأعلى تقييماً',
};

// ============ Delegate ============
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['fr', 'ar'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}






