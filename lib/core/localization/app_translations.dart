/// App Translations for French and Arabic
class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // Navigation
    'home': {'fr': 'Accueil', 'ar': 'الرئيسية'},
    'courses': {'fr': 'Cours', 'ar': 'الدورات'},
    'store': {'fr': 'Boutique', 'ar': 'المتجر'},
    'cart': {'fr': 'Panier', 'ar': 'السلة'},
    'profile': {'fr': 'Profil', 'ar': 'الملف الشخصي'},

    // Auth
    'login': {'fr': 'Connexion', 'ar': 'تسجيل الدخول'},
    'register': {'fr': 'Inscription', 'ar': 'التسجيل'},
    'logout': {'fr': 'Déconnexion', 'ar': 'تسجيل الخروج'},
    'email': {'fr': 'Email', 'ar': 'البريد الإلكتروني'},
    'password': {'fr': 'Mot de passe', 'ar': 'كلمة المرور'},
    'confirm_password': {
      'fr': 'Confirmer le mot de passe',
      'ar': 'تأكيد كلمة المرور'
    },
    'confirm_password_hint': {
      'fr': 'Confirmez votre mot de passe',
      'ar': 'أكد كلمة المرور'
    },
    'full_name': {'fr': 'Nom complet', 'ar': 'الاسم الكامل'},
    'phone': {'fr': 'Téléphone', 'ar': 'الهاتف'},
    'phone_number': {'fr': 'Numéro de téléphone', 'ar': 'رقم الهاتف'},
    'enter_phone': {'fr': 'Entrez votre numéro', 'ar': 'أدخل رقم هاتفك'},
    'enter_email': {'fr': 'Entrez votre email', 'ar': 'أدخل بريدك الإلكتروني'},
    'enter_password': {
      'fr': 'Entrez votre mot de passe',
      'ar': 'أدخل كلمة المرور'
    },
    'create_password': {'fr': 'Créez un mot de passe', 'ar': 'أنشئ كلمة مرور'},
    'forgot_password': {
      'fr': 'Mot de passe oublié ?',
      'ar': 'نسيت كلمة المرور؟'
    },
    'forgot_password_subtitle_email': {
      'fr':
          'Entrez votre email et nous vous enverrons un code de réinitialisation',
      'ar': 'أدخل بريدك الإلكتروني وسنرسل لك رمز إعادة التعيين'
    },
    'forgot_password_subtitle_phone': {
      'fr': 'Entrez votre numéro et nous vous enverrons un code par SMS',
      'ar': 'أدخل رقمك وسنرسل لك رمزًا عبر الرسائل القصيرة'
    },
    'code_sent_check_email': {
      'fr': 'Code envoyé ! Vérifiez votre email',
      'ar': 'تم إرسال الرمز! تحقق من بريدك الإلكتروني'
    },
    'code_sent_check_sms': {
      'fr': 'Code envoyé ! Vérifiez vos SMS',
      'ar': 'تم إرسال الرمز! تحقق من رسائلك'
    },
    'back_to_login': {
      'fr': 'Retour à la connexion',
      'ar': 'العودة لتسجيل الدخول'
    },
    'no_account': {'fr': 'Pas de compte ?', 'ar': 'ليس لديك حساب؟'},
    'have_account': {'fr': 'Déjà un compte ?', 'ar': 'لديك حساب بالفعل؟'},
    'sign_up': {'fr': 'S\'inscrire', 'ar': 'سجّل'},
    'signup': {'fr': 'S\'inscrire', 'ar': 'تسجيل'},
    'sign_in': {'fr': 'Se connecter', 'ar': 'تسجيل الدخول'},
    'verify_code': {'fr': 'Code de vérification', 'ar': 'رمز التحقق'},
    'complete_code_error': {
      'fr': 'Veuillez entrer le code complet à 5 chiffres',
      'ar': 'الرجاء إدخال الرمز الكامل المكون من 5 أرقام'
    },
    'verification': {'fr': 'Vérification', 'ar': 'التحقق'},
    'verification_email_desc': {
      'fr': 'Entrez le code de vérification envoyé à votre email',
      'ar': 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني'
    },
    'verification_phone_desc': {
      'fr': 'Entrez le code de vérification envoyé à votre numéro de téléphone',
      'ar': 'أدخل رمز التحقق المرسل إلى رقم هاتفك'
    },
    'verify': {'fr': 'Vérifier', 'ar': 'تحقق'},
    'resend_code': {'fr': 'Renvoyer le code', 'ar': 'إعادة إرسال الرمز'},
    'code_resent': {
      'fr': 'Code renvoyé avec succès',
      'ar': 'تم إعادة إرسال الرمز بنجاح'
    },
    'send_code': {'fr': 'Envoyer le code', 'ar': 'إرسال الرمز'},
    'reset_password': {
      'fr': 'Réinitialiser le mot de passe',
      'ar': 'إعادة تعيين كلمة المرور'
    },
    'reset_password_subtitle': {
      'fr': 'Entrez le code reçu par SMS et votre nouveau mot de passe',
      'ar': 'أدخل الرمز المستلم عبر الرسائل والنص الجديد'
    },
    'reset_password_success': {
      'fr': 'Mot de passe mis à jour. Vous pouvez vous connecter.',
      'ar': 'تم تحديث كلمة المرور. يمكنك تسجيل الدخول.'
    },
    'login_to_continue': {
      'fr': 'Connectez-vous pour continuer',
      'ar': 'سجل الدخول للمتابعة'
    },
    'welcome_back_desc': {
      'fr': 'Bienvenue ! Connectez-vous pour continuer',
      'ar': 'مرحبًا بعودتك! سجل دخولك للمتابعة'
    },
    'create_account': {'fr': 'Créer un compte', 'ar': 'إنشاء حساب'},
    'create_account_desc': {
      'fr': 'Inscrivez-vous pour commencer',
      'ar': 'سجل للبدء'
    },
    'or_continue_with': {'fr': 'ou continuer avec', 'ar': 'أو المتابعة عبر'},
    'continue_with_google': {
      'fr': 'Continuer avec Google',
      'ar': 'المتابعة مع Google'
    },
    'required_field': {'fr': 'Ce champ est requis', 'ar': 'هذا الحقل مطلوب'},
    'select_country': {'fr': 'Sélectionner un pays', 'ar': 'اختر دولة'},
    'complete_profile': {
      'fr': 'Compléter le profil',
      'ar': 'إكمال الملف الشخصي'
    },
    'complete_profile_desc': {
      'fr': 'Ajoutez quelques informations pour terminer votre inscription',
      'ar': 'أضف بعض المعلومات لإتمام تسجيلك'
    },
    'enter_full_name': {
      'fr': 'Entrez votre nom complet',
      'ar': 'أدخل اسمك الكامل'
    },
    'referral_code': {'fr': 'Code de parrainage', 'ar': 'رمز الإحالة'},
    'enter_referral_code': {
      'fr': 'Entrez le code de parrainage (optionnel)',
      'ar': 'أدخل رمز الإحالة (اختياري)'
    },
    'complete': {'fr': 'Terminer', 'ar': 'إنهاء'},
    'skip_referral': {
      'fr': 'Passer sans code de parrainage',
      'ar': 'تخطي بدون رمز إحالة'
    },
    'name_required': {
      'fr': 'Veuillez entrer votre nom',
      'ar': 'الرجاء إدخال اسمك'
    },
    'invalid_register_method': {
      'fr':
          'La méthode d\'inscription (email/téléphone) ne correspond pas à la configuration du serveur. Vérifiez les paramètres généraux (register_method) côté backend, ou utilisez l\'autre méthode.',
      'ar':
          'طريقة التسجيل (بريد/هاتف) لا تطابق إعدادات الخادم. تحقق من الإعدادات العامة أو استخدم الطريقة الأخرى.'
    },
    // Auth error messages (normalized)
    'auth_login_failed': {
      'fr': 'Échec de la connexion. Vérifiez vos identifiants.',
      'ar': 'فشل تسجيل الدخول. تحقق من بياناتك.'
    },
    'auth_invalid_credentials': {
      'fr': 'Email/téléphone ou mot de passe incorrect.',
      'ar': 'البريد أو رقم الهاتف أو كلمة المرور غير صحيحة.'
    },
    'auth_connection_error': {
      'fr': 'Impossible de joindre le serveur. Vérifiez votre connexion.',
      'ar': 'تعذر الاتصال بالخادم. تحقق من اتصالك.'
    },
    'auth_registration_failed': {
      'fr': 'L\'inscription a échoué. Réessayez ou utilisez une autre méthode.',
      'ar': 'فشل التسجيل. أعد المحاولة أو استخدم طريقة أخرى.'
    },
    'auth_email_already_used': {
      'fr': 'Cet email est déjà utilisé.',
      'ar': 'هذا البريد الإلكتروني مستخدم بالفعل.'
    },
    'auth_phone_already_used': {
      'fr': 'Ce numéro de téléphone est déjà utilisé.',
      'ar': 'رقم الهاتف هذا مستخدم بالفعل.'
    },
    'auth_verification_failed': {
      'fr': 'Code invalide ou expiré. Demandez un nouveau code.',
      'ar': 'الرمز غير صحيح أو منتهي. اطلب رمزًا جديدًا.'
    },
    'auth_user_not_found': {
      'fr': 'Session expirée. Veuillez recommencer l\'inscription.',
      'ar': 'انتهت الجلسة. يرجى إعادة التسجيل.'
    },
    'auth_error_generic': {
      'fr': 'Une erreur s\'est produite. Réessayez.',
      'ar': 'حدث خطأ. أعد المحاولة.'
    },
    'invalid_phone': {
      'fr': 'Numéro de téléphone invalide',
      'ar': 'رقم الهاتف غير صالح'
    },
    'invalid_email': {
      'fr': 'Email invalide',
      'ar': 'البريد الإلكتروني غير صالح'
    },
    'password_min_length': {
      'fr': 'Minimum 6 caractères',
      'ar': 'الحد الأدنى 6 أحرف'
    },
    'password_mismatch': {
      'fr': 'Les mots de passe ne correspondent pas',
      'ar': 'كلمات المرور غير متطابقة'
    },

    // Home
    'welcome': {'fr': 'Bienvenue', 'ar': 'مرحباً'},
    'search': {'fr': 'Rechercher', 'ar': 'بحث'},
    'search_courses': {
      'fr': 'Rechercher des cours...',
      'ar': 'البحث عن دورات...'
    },
    'featured_courses': {'fr': 'Cours en vedette', 'ar': 'الدورات المميزة'},
    'all_courses': {'fr': 'Tous les cours', 'ar': 'جميع الدورات'},
    'categories': {'fr': 'Catégories', 'ar': 'الفئات'},
    'popular_categories': {
      'fr': 'Catégories populaires',
      'ar': 'الفئات الشائعة'
    },
    'subcategories': {'fr': 'Sous-catégories', 'ar': 'الفئات الفرعية'},
    'bundles': {'fr': 'Packs de cours', 'ar': 'حزم الدورات'},
    'see_all': {'fr': 'Voir tout', 'ar': 'عرض الكل'},
    'new_courses': {'fr': 'Nouveaux cours', 'ar': 'دورات جديدة'},

    // Course Details
    'course_details': {'fr': 'Détails du cours', 'ar': 'تفاصيل الدورة'},
    'overview': {'fr': 'Aperçu', 'ar': 'نظرة عامة'},
    'content': {'fr': 'Contenu', 'ar': 'المحتوى'},
    'reviews': {'fr': 'Avis', 'ar': 'التقييمات'},
    'description': {'fr': 'Description', 'ar': 'الوصف'},
    'instructor': {'fr': 'Formateur', 'ar': 'المدرب'},
    'organization': {'fr': 'Organisation', 'ar': 'المنظمة'},
    'student': {'fr': 'Étudiant', 'ar': 'طالب'},
    'account_type': {'fr': 'Type de compte', 'ar': 'نوع الحساب'},
    'dashboard': {'fr': 'Tableau de bord', 'ar': 'لوحة القيادة'},
    'balance': {'fr': 'Solde', 'ar': 'الرصيد'},
    'pending_meetings': {
      'fr': 'Réunions en attente',
      'ar': 'الاجتماعات المعلقة'
    },
    'monthly_sales': {'fr': 'Ventes mensuelles', 'ar': 'المبيعات الشهرية'},
    'support_messages': {'fr': 'Messages de support', 'ar': 'رسائل الدعم'},
    'my_comments': {'fr': 'Mes commentaires', 'ar': 'تعليقاتي'},
    'reward_points': {'fr': 'Points de récompense', 'ar': 'نقاط المكافآت'},
    'available_points': {'fr': 'Points disponibles', 'ar': 'النقاط المتاحة'},
    'spent_points': {'fr': 'Points dépensés', 'ar': 'النقاط المنفقة'},
    'withdraw': {'fr': 'Retirer', 'ar': 'سحب'},
    'financial': {'fr': 'Financier', 'ar': 'مالي'},
    'duration': {'fr': 'Durée', 'ar': 'المدة'},
    'students': {'fr': 'Étudiants', 'ar': 'الطلاب'},
    'lessons': {'fr': 'Leçons', 'ar': 'الدروس'},
    'chapters': {'fr': 'Chapitres', 'ar': 'الفصول'},
    'price': {'fr': 'Prix', 'ar': 'السعر'},
    'free': {'fr': 'Gratuit', 'ar': 'مجاني'},
    'add_to_cart': {'fr': 'Ajouter au panier', 'ar': 'أضف إلى السلة'},
    'buy_now': {'fr': 'Acheter maintenant', 'ar': 'اشتر الآن'},
    'enroll': {'fr': 'S\'inscrire', 'ar': 'التسجيل'},
    'continue_learning': {'fr': 'Continuer', 'ar': 'متابعة'},
    'watch_demo': {'fr': 'Voir la démo', 'ar': 'شاهد العرض'},
    'see_more': {'fr': 'Voir plus', 'ar': 'عرض المزيد'},
    'see_less': {'fr': 'Voir moins', 'ar': 'عرض أقل'},
    'no_reviews': {
      'fr': 'Aucun avis pour le moment',
      'ar': 'لا توجد تقييمات حتى الآن'
    },
    'write_review': {'fr': 'Écrire un avis', 'ar': 'كتابة تقييم'},
    'rate_course': {'fr': 'Notez ce cours', 'ar': 'قيم هذه الدورة'},
    'content_quality': {'fr': 'Qualité du contenu', 'ar': 'جودة المحتوى'},
    'instructor_skills': {
      'fr': 'Compétences de l\'instructeur',
      'ar': 'مهارات المدرب'
    },
    'purchase_worth': {
      'fr': 'Rapport qualité/prix',
      'ar': 'القيمة مقابل السعر'
    },
    'support_quality': {'fr': 'Qualité du support', 'ar': 'جودة الدعم'},
    'review_description': {
      'fr': 'Décrivez votre expérience...',
      'ar': 'صف تجربتك...'
    },
    'submit_review': {'fr': 'Envoyer l\'avis', 'ar': 'إرسال التقييم'},
    'review_submitted': {
      'fr': 'Avis envoyé avec succès',
      'ar': 'تم إرسال التقييم بنجاح'
    },
    'please_enter_review': {
      'fr': 'Veuillez entrer une description',
      'ar': 'يرجى إدخال وصف'
    },
    'comments': {'fr': 'Commentaires', 'ar': 'التعليقات'},
    'no_comments': {
      'fr': 'Aucun commentaire pour le moment',
      'ar': 'لا توجد تعليقات حتى الآن'
    },
    'be_first_to_comment': {
      'fr': 'Soyez le premier à commenter',
      'ar': 'كن أول من يعلق'
    },
    'leave_comment': {'fr': 'Laisser un commentaire', 'ar': 'اترك تعليقاً'},
    'share_your_thoughts': {
      'fr': 'Partagez vos pensées sur ce cours',
      'ar': 'شارك أفكارك حول هذه الدورة'
    },
    'write_comment': {
      'fr': 'Écrivez votre commentaire...',
      'ar': 'اكتب تعليقك...'
    },
    'submit_comment': {'fr': 'Envoyer le commentaire', 'ar': 'إرسال التعليق'},
    'comment_submitted': {
      'fr': 'Commentaire envoyé avec succès',
      'ar': 'تم إرسال التعليق بنجاح'
    },
    'please_enter_comment': {
      'fr': 'Veuillez entrer un commentaire',
      'ar': 'يرجى إدخال تعليق'
    },
    'pending': {'fr': 'En attente', 'ar': 'قيد الانتظار'},
    'content_not_available': {
      'fr': 'Contenu non disponible',
      'ar': 'المحتوى غير متاح'
    },
    'buy_to_access': {
      'fr': 'Achetez le cours pour accéder au contenu',
      'ar': 'اشتر الدورة للوصول إلى المحتوى'
    },
    'access_days': {'fr': 'jours d\'accès', 'ar': 'أيام الوصول'},

    // Filters
    'filter': {'fr': 'Filtrer', 'ar': 'تصفية'},
    'filter_by': {'fr': 'Filtrer par', 'ar': 'تصفية حسب'},
    'all': {'fr': 'Tous', 'ar': 'الكل'},
    'free_courses': {'fr': 'Gratuit', 'ar': 'مجاني'},
    'promo': {'fr': 'Promo', 'ar': 'عرض'},
    'discount': {'fr': 'Réduction', 'ar': 'خصم'},
    'popular': {'fr': 'Populaire', 'ar': 'الأكثر شعبية'},
    'newest': {'fr': 'Récent', 'ar': 'الأحدث'},
    'best_rated': {'fr': 'Mieux notés', 'ar': 'الأعلى تقييماً'},
    'price_low_high': {'fr': 'Prix croissant', 'ar': 'السعر: من الأقل للأعلى'},
    'price_high_low': {
      'fr': 'Prix décroissant',
      'ar': 'السعر: من الأعلى للأقل'
    },
    'apply_filter': {'fr': 'Appliquer', 'ar': 'تطبيق'},
    'reset_filter': {'fr': 'Réinitialiser', 'ar': 'إعادة تعيين'},
    'select_category': {'fr': 'Sélectionner une catégorie', 'ar': 'اختر فئة'},

    // Cart & Payment
    'my_cart': {'fr': 'Mon Panier', 'ar': 'سلتي'},
    'empty_cart': {'fr': 'Panier vide', 'ar': 'السلة فارغة'},
    'add_courses_to_start': {
      'fr': 'Ajoutez des cours pour commencer',
      'ar': 'أضف دورات للبدء'
    },
    'explore_courses': {'fr': 'Explorer les cours', 'ar': 'استكشف الدورات'},
    'total': {'fr': 'Total', 'ar': 'المجموع'},
    'checkout': {'fr': 'Passer la commande', 'ar': 'إتمام الشراء'},
    'remove': {'fr': 'Supprimer', 'ar': 'حذف'},
    'coupon': {'fr': 'Code promo', 'ar': 'كود الخصم'},
    'apply_coupon': {'fr': 'Appliquer', 'ar': 'تطبيق'},
    'coupon_applied': {'fr': 'Code promo appliqué.', 'ar': 'تم تطبيق كود الخصم.'},
    'coupon_invalid': {'fr': 'Code promo invalide ou expiré.', 'ar': 'كود الخصم غير صالح أو منتهي.'},
    'added_to_cart': {'fr': 'Ajouté au panier', 'ar': 'تمت الإضافة إلى السلة'},
    'removed_from_cart': {
      'fr': 'Supprimé du panier',
      'ar': 'تمت الإزالة من السلة'
    },
    'error_adding_cart': {
      'fr': 'Erreur lors de l\'ajout',
      'ar': 'خطأ في الإضافة'
    },
    'required_prerequisites_message': {
      'fr':
          'Vous devez d\'abord terminer les cours prérequis pour pouvoir acheter ce cours.',
      'ar': 'يجب إكمال الدورات المطلوبة مسبقًا قبل شراء هذه الدورة.'
    },
    'prerequisites': {'fr': 'Prérequis', 'ar': 'المتطلبات المسبقة'},
    'payment_method': {'fr': 'Mode de paiement', 'ar': 'طريقة الدفع'},
    'payment_methods': {'fr': 'Modes de paiement', 'ar': 'طرق الدفع'},
    'select_payment_method': {
      'fr': 'Choisissez votre mode de paiement',
      'ar': 'اختر طريقة الدفع'
    },
    'account_balance': {'fr': 'Solde du compte', 'ar': 'رصيد الحساب'},
    'confirm_payment': {'fr': 'Confirmer le paiement', 'ar': 'تأكيد الدفع'},
    'processing': {'fr': 'Traitement...', 'ar': 'جاري المعالجة...'},
    'payment_success': {'fr': 'Paiement réussi!', 'ar': 'تم الدفع بنجاح!'},
    'payment_pending': {'fr': 'Paiement en cours', 'ar': 'الدفع قيد المعالجة'},
    'payment_failed': {'fr': 'Échec du paiement', 'ar': 'فشل الدفع'},
    'added_to_favorites': {
      'fr': 'Ajouté aux favoris',
      'ar': 'تمت الإضافة للمفضلة'
    },
    'removed_from_favorites': {
      'fr': 'Retiré des favoris',
      'ar': 'تمت الإزالة من المفضلة'
    },

    // Profile
    'my_profile': {'fr': 'Mon Profil', 'ar': 'ملفي الشخصي'},
    'edit_profile': {'fr': 'Modifier le profil', 'ar': 'تعديل الملف'},
    'my_courses': {'fr': 'Mes cours', 'ar': 'دوراتي'},
    'favorites': {'fr': 'Favoris', 'ar': 'المفضلة'},
    'certificates': {'fr': 'Certificats', 'ar': 'الشهادات'},
    'notifications': {'fr': 'Notifications', 'ar': 'الإشعارات'},
    'settings': {'fr': 'Paramètres', 'ar': 'الإعدادات'},
    'language': {'fr': 'Langue', 'ar': 'اللغة'},
    'change_password': {
      'fr': 'Changer le mot de passe',
      'ar': 'تغيير كلمة المرور'
    },
    'about': {'fr': 'À propos', 'ar': 'حول'},
    'help': {'fr': 'Aide', 'ar': 'مساعدة'},
    'privacy_policy': {
      'fr': 'Politique de confidentialité',
      'ar': 'سياسة الخصوصية'
    },
    'terms': {'fr': 'Conditions d\'utilisation', 'ar': 'شروط الاستخدام'},
    'delete_account': {'fr': 'Supprimer le compte', 'ar': 'حذف الحساب'},

    // Store
    'products': {'fr': 'Produits', 'ar': 'المنتجات'},
    'orders': {'fr': 'Commandes', 'ar': 'الطلبات'},
    'my_orders': {'fr': 'Mes commandes', 'ar': 'طلباتي'},
    'order_status_pending': {'fr': 'En attente', 'ar': 'قيد الانتظار'},
    'order_status_paid': {'fr': 'Payée', 'ar': 'مدفوعة'},
    'order_status_completed': {'fr': 'Terminée', 'ar': 'مكتملة'},
    'order_status_cancelled': {'fr': 'Annulée', 'ar': 'ملغاة'},
    'order_status_processing': {'fr': 'En cours', 'ar': 'قيد المعالجة'},
    'order_status_shipped': {'fr': 'Expédiée', 'ar': 'تم الشحن'},
    'order_status_waiting_delivery': {
      'fr': 'En attente de livraison',
      'ar': 'في انتظار التوصيل'
    },
    'order_products': {'fr': 'Produits', 'ar': 'المنتجات'},
    'order_quantity': {'fr': 'Quantité', 'ar': 'الكمية'},
    'order_product_ref': {'fr': 'Réf. produit', 'ar': 'مرجع المنتج'},
    'add_to_bag': {'fr': 'Ajouter au sac', 'ar': 'أضف إلى الحقيبة'},
    'seller': {'fr': 'Vendeur', 'ar': 'البائع'},
    'in_stock': {'fr': 'En stock', 'ar': 'متوفر'},
    'out_of_stock': {'fr': 'Rupture de stock', 'ar': 'غير متوفر'},

    // Notifications
    'no_notifications': {'fr': 'Aucune notification', 'ar': 'لا توجد إشعارات'},
    'mark_all_read': {'fr': 'Tout marquer comme lu', 'ar': 'تحديد الكل كمقروء'},
    'read_all': {'fr': 'Tout lire', 'ar': 'تحديد الكل كمقروء'},
    'delete_all': {'fr': 'Tout supprimer', 'ar': 'حذف الكل'},

    // My Courses
    'in_progress': {'fr': 'En cours', 'ar': 'قيد التقدم'},
    'completed': {'fr': 'Terminés', 'ar': 'مكتملة'},
    'course_completed': {'fr': 'Terminé', 'ar': 'مكتمل'},
    'courses_completed_in_bundle': {
      'fr': '{completed} / {total} cours terminés',
      'ar': '{completed} / {total} دورات مكتملة'
    },
    'progress': {'fr': 'Progression', 'ar': 'التقدم'},
    'no_completed_courses': {
      'fr': 'Aucun cours terminé',
      'ar': 'لا توجد دورات مكتملة'
    },
    'explore_courses_to_start': {
      'fr': 'Explorez les cours pour commencer à apprendre',
      'ar': 'استكشف الدورات لبدء التعلم'
    },
    'complete_courses_to_see': {
      'fr': 'Terminez des cours pour les voir ici',
      'ar': 'أكمل الدورات لرؤيتها هنا'
    },
    'login_to_see_courses': {
      'fr': 'Connectez-vous pour voir vos cours',
      'ar': 'سجل الدخول لرؤية دوراتك'
    },

    // General
    'loading': {'fr': 'Chargement...', 'ar': 'جاري التحميل...'},
    'error': {'fr': 'Erreur', 'ar': 'خطأ'},
    'success': {'fr': 'Succès', 'ar': 'نجاح'},
    'cancel': {'fr': 'Annuler', 'ar': 'إلغاء'},
    'confirm': {'fr': 'Confirmer', 'ar': 'تأكيد'},
    'save': {'fr': 'Enregistrer', 'ar': 'حفظ'},
    'delete': {'fr': 'Supprimer', 'ar': 'حذف'},
    'edit': {'fr': 'Modifier', 'ar': 'تعديل'},
    'close': {'fr': 'Fermer', 'ar': 'إغلاق'},
    'back': {'fr': 'Retour', 'ar': 'رجوع'},
    'next': {'fr': 'Suivant', 'ar': 'التالي'},
    'previous': {'fr': 'Précédent', 'ar': 'السابق'},
    'skip': {'fr': 'Passer', 'ar': 'تخطي'},
    'done': {'fr': 'Terminé', 'ar': 'تم'},
    'retry': {'fr': 'Réessayer', 'ar': 'إعادة المحاولة'},
    'no_data': {'fr': 'Aucune donnée', 'ar': 'لا توجد بيانات'},
    'not_found': {'fr': 'Non trouvé', 'ar': 'غير موجود'},
    'course_not_found': {'fr': 'Cours non trouvé', 'ar': 'الدورة غير موجودة'},
    'please_login': {
      'fr': 'Veuillez vous connecter',
      'ar': 'الرجاء تسجيل الدخول'
    },
    'no_courses': {'fr': 'Aucun cours disponible', 'ar': 'لا توجد دورات متاحة'},
    'hours': {'fr': 'heures', 'ar': 'ساعات'},
    'minutes': {'fr': 'minutes', 'ar': 'دقائق'},
    'days': {'fr': 'jours', 'ar': 'أيام'},

    // Onboarding
    'onboarding_title_1': {
      'fr': 'Apprenez à votre rythme',
      'ar': 'تعلم بسرعتك الخاصة'
    },
    'onboarding_desc_1': {
      'fr': 'Accédez à des cours de qualité partout et à tout moment',
      'ar': 'احصل على دورات عالية الجودة في أي مكان وزمان'
    },
    'onboarding_title_2': {'fr': 'Formateurs experts', 'ar': 'مدربون خبراء'},
    'onboarding_desc_2': {
      'fr': 'Apprenez avec les meilleurs formateurs du domaine',
      'ar': 'تعلم مع أفضل المدربين في المجال'
    },
    'onboarding_title_3': {'fr': 'Certificats reconnus', 'ar': 'شهادات معتمدة'},
    'onboarding_desc_3': {
      'fr': 'Obtenez des certificats pour valoriser vos compétences',
      'ar': 'احصل على شهادات لتعزيز مهاراتك'
    },
    'get_started': {'fr': 'Commencer', 'ar': 'ابدأ الآن'},

    // Quiz
    'quiz': {'fr': 'Quiz', 'ar': 'اختبار'},
    'quiz_info': {'fr': 'Informations du quiz', 'ar': 'معلومات الاختبار'},
    'quiz_review': {'fr': 'Révision du quiz', 'ar': 'مراجعة الاختبار'},
    'question': {'fr': 'Question', 'ar': 'سؤال'},
    'questions': {'fr': 'Questions', 'ar': 'أسئلة'},
    'points': {'fr': 'points', 'ar': 'نقاط'},
    'start_quiz': {'fr': 'Commencer le quiz', 'ar': 'ابدأ الاختبار'},
    'exit_quiz': {'fr': 'Quitter le quiz', 'ar': 'الخروج من الاختبار'},
    'exit_quiz_confirmation': {
      'fr': 'Êtes-vous sûr de vouloir quitter ? Vos réponses seront perdues.',
      'ar': 'هل أنت متأكد من أنك تريد الخروج؟ ستفقد إجاباتك.'
    },
    'exit': {'fr': 'Quitter', 'ar': 'خروج'},
    'submit': {'fr': 'Soumettre', 'ar': 'إرسال'},
    'type_your_answer': {
      'fr': 'Tapez votre réponse ici...',
      'ar': 'اكتب إجابتك هنا...'
    },
    'correct_answer': {'fr': 'Bonne réponse', 'ar': 'الإجابة الصحيحة'},
    'your_grade': {'fr': 'Votre note', 'ar': 'درجتك'},
    'total_mark': {'fr': 'Note totale', 'ar': 'الدرجة الكلية'},
    'pass_mark': {'fr': 'Note de passage', 'ar': 'درجة النجاح'},
    'time': {'fr': 'Temps', 'ar': 'الوقت'},
    'attempts': {'fr': 'Tentatives', 'ar': 'المحاولات'},
    'tries_left': {'fr': 'Essais restants', 'ar': 'المحاولات المتبقية'},
    'ready_to_start': {'fr': 'Prêt à commencer ?', 'ar': 'هل أنت مستعد للبدء؟'},
    'passed': {'fr': 'Réussi', 'ar': 'ناجح'},
    'failed': {'fr': 'Échoué', 'ar': 'راسب'},
    'waiting': {'fr': 'En attente', 'ar': 'في الانتظار'},
    'congratulations_passed': {
      'fr': 'Félicitations ! Vous avez réussi le quiz !',
      'ar': 'تهانينا! لقد اجتزت الاختبار!'
    },
    'try_again_message': {
      'fr': 'Vous n\'avez pas réussi. Réessayez !',
      'ar': 'لم تنجح. حاول مرة أخرى!'
    },
    'waiting_for_review': {
      'fr': 'En attente de correction par l\'instructeur.',
      'ar': 'في انتظار التصحيح من المدرب.'
    },
    'review_answers': {'fr': 'Revoir les réponses', 'ar': 'مراجعة الإجابات'},
    'review_answers_help': {
      'fr':
          'Consultez vos réponses pour identifier vos erreurs et améliorer vos connaissances.',
      'ar': 'راجع إجاباتك لمعرفة أخطائك وتحسين معرفتك.'
    },
    'quiz_status_passed': {'fr': 'Réussi', 'ar': 'ناجح'},
    'quiz_status_failed': {'fr': 'Échoué', 'ar': 'راسب'},
    'my_quizzes': {'fr': 'Quizz', 'ar': 'الاختبارات'},
    'no_quiz_results': {
      'fr': 'Aucun quiz passé pour le moment',
      'ar': 'لا توجد اختبارات منجزة حتى الآن'
    },
    'view_result': {'fr': 'Voir le résultat complet', 'ar': 'عرض النتيجة الكاملة'},
    'quiz_certificate_motivation': {
      'fr': 'Vous avez obtenu votre certificat de quiz ! Consultez-le dans votre espace Certificats.',
      'ar': 'لقد حصلت على شهادة الاختبار! اعرضها من مساحة الشهادات.'
    },
    'view_my_certificate': {'fr': 'Voir mon certificat', 'ar': 'عرض شهادتي'},
    'no_attempts_left': {
      'fr': 'Plus de tentatives',
      'ar': 'لا توجد محاولات متبقية'
    },
    'no_attempts_left_message': {
      'fr': 'Vous avez utilisé toutes vos tentatives pour ce quiz.',
      'ar': 'لقد استخدمت جميع محاولاتك لهذا الاختبار.'
    },
    'no_questions': {'fr': 'Aucune question', 'ar': 'لا توجد أسئلة'},
    'quiz_start_error': {
      'fr': 'Erreur lors du démarrage du quiz',
      'ar': 'خطأ في بدء الاختبار'
    },
    'quiz_submit_error': {
      'fr': 'Erreur lors de la soumission',
      'ar': 'خطأ في الإرسال'
    },
    'back_to_course': {'fr': 'Retour au cours', 'ar': 'العودة إلى الدورة'},
    'quiz_submitted': {'fr': 'Quiz envoyé', 'ar': 'تم إرسال الاختبار'},
    'video_load_error': {
      'fr': 'Impossible de charger la vidéo.',
      'ar': 'تعذر تحميل الفيديو.'
    },
    'video_format_or_unavailable': {
      'fr':
          'Cette vidéo n\'a pas pu être lue. Format non pris en charge ou vidéo indisponible.',
      'ar':
          'تعذر تشغيل هذا الفيديو. قد يكون التنسيق غير مدعوم أو الفيديو غير متاح.'
    },
    'video_open_in_browser': {
      'fr': 'Ouvrir dans le navigateur',
      'ar': 'فتح في المتصفح'
    },

    // Support / Tickets (support_messages already defined above)
    'support_tickets': {'fr': 'Tickets', 'ar': 'التذاكر'},
    'support_course': {'fr': 'Support cours', 'ar': 'دعم الدورة'},
    'support_no_tickets': {
      'fr': 'Aucun ticket',
      'ar': 'لا توجد تذاكر'
    },
    'support_no_tickets_desc': {
      'fr': 'Créez un ticket pour contacter le support',
      'ar': 'أنشئ تذكرة للاتصال بالدعم'
    },
    'support_new_ticket': {'fr': 'Nouveau ticket', 'ar': 'تذكرة جديدة'},
    'support_title': {'fr': 'Titre', 'ar': 'العنوان'},
    'support_select_department': {
      'fr': 'Choisir un département',
      'ar': 'اختر القسم'
    },
    'support_select_course': {
      'fr': 'Choisir un cours',
      'ar': 'اختر الدورة'
    },
    'support_description': {'fr': 'Description', 'ar': 'الوصف'},
    'support_status_closed': {'fr': 'Fermé', 'ar': 'مغلق'},
    'support_status_replied': {'fr': 'Répondu', 'ar': 'تم الرد'},
    'support_status_waiting': {'fr': 'En attente', 'ar': 'في الانتظار'},
    'support_course_context': {
      'fr': 'Support lié au cours',
      'ar': 'دعم مرتبط بالدورة'
    },
    'support_message_hint': {
      'fr': 'Votre message...',
      'ar': 'رسالتك...'
    },
    'support_ticket_not_found': {
      'fr': 'Ticket introuvable',
      'ar': 'التذكرة غير موجودة'
    },
    'support_no_purchased_courses': {
      'fr': 'Aucun cours acheté',
      'ar': 'لا توجد دورات مشتراة'
    },
    'support_no_purchased_courses_desc': {
      'fr': 'Seuls les cours que vous avez achetés ou auxquels vous êtes inscrit apparaissent ici. Achetez ou inscrivez-vous à un cours pour ouvrir un ticket de support cours.',
      'ar': 'فقط الدورات التي اشتريتها أو سجلت فيها تظهر هنا. اشترِ دورة أو سجّل في واحدة لفتح تذكرة دعم الدورة.'
    },
    'send': {'fr': 'Envoyer', 'ar': 'إرسال'},
  };

  /// Get translation for a key
  static String get(String key, String locale) {
    final translation = _translations[key];
    if (translation == null) return key;
    return translation[locale] ?? translation['fr'] ?? key;
  }

  /// Get translation with fallback
  static String tr(String key, {String locale = 'fr'}) {
    return get(key, locale);
  }
}

/// Extension for easy access in widgets
extension TranslationExtension on String {
  String tr(String locale) => AppTranslations.get(this, locale);
}
