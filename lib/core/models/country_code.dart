/// Country code model for phone number input
class CountryCode {
  /// the name of the country
  final String? name;

  /// the flag emoji or asset path
  final String? flag;

  /// the country code (TN, FR, DZ, etc.)
  final String? code;

  /// the dial code (+216, +33, +213, etc.)
  final String? dialCode;

  const CountryCode({
    this.name,
    this.flag,
    this.code,
    this.dialCode,
  });

  @override
  String toString() => "$dialCode";

  String toLongString() => "$dialCode $name";

  String toCountryStringOnly() => '$name';

  /// Common countries for Tunisia region
  static const List<CountryCode> commonCountries = [
    CountryCode(name: 'Tunisie', flag: '🇹🇳', code: 'TN', dialCode: '+216'),
    CountryCode(name: 'Algérie', flag: '🇩🇿', code: 'DZ', dialCode: '+213'),
    CountryCode(name: 'Maroc', flag: '🇲🇦', code: 'MA', dialCode: '+212'),
    CountryCode(name: 'Libye', flag: '🇱🇾', code: 'LY', dialCode: '+218'),
    CountryCode(name: 'Égypte', flag: '🇪🇬', code: 'EG', dialCode: '+20'),
    CountryCode(name: 'France', flag: '🇫🇷', code: 'FR', dialCode: '+33'),
    CountryCode(name: 'Belgique', flag: '🇧🇪', code: 'BE', dialCode: '+32'),
    CountryCode(name: 'Suisse', flag: '🇨🇭', code: 'CH', dialCode: '+41'),
    CountryCode(name: 'Canada', flag: '🇨🇦', code: 'CA', dialCode: '+1'),
    CountryCode(name: 'Allemagne', flag: '🇩🇪', code: 'DE', dialCode: '+49'),
    CountryCode(name: 'Italie', flag: '🇮🇹', code: 'IT', dialCode: '+39'),
    CountryCode(name: 'Espagne', flag: '🇪🇸', code: 'ES', dialCode: '+34'),
    CountryCode(name: 'Royaume-Uni', flag: '🇬🇧', code: 'GB', dialCode: '+44'),
    CountryCode(name: 'États-Unis', flag: '🇺🇸', code: 'US', dialCode: '+1'),
    CountryCode(name: 'Arabie Saoudite', flag: '🇸🇦', code: 'SA', dialCode: '+966'),
    CountryCode(name: 'Émirats arabes unis', flag: '🇦🇪', code: 'AE', dialCode: '+971'),
    CountryCode(name: 'Qatar', flag: '🇶🇦', code: 'QA', dialCode: '+974'),
    CountryCode(name: 'Koweït', flag: '🇰🇼', code: 'KW', dialCode: '+965'),
    CountryCode(name: 'Jordanie', flag: '🇯🇴', code: 'JO', dialCode: '+962'),
    CountryCode(name: 'Liban', flag: '🇱🇧', code: 'LB', dialCode: '+961'),
    CountryCode(name: 'Irak', flag: '🇮🇶', code: 'IQ', dialCode: '+964'),
    CountryCode(name: 'Palestine', flag: '🇵🇸', code: 'PS', dialCode: '+970'),
    CountryCode(name: 'Syrie', flag: '🇸🇾', code: 'SY', dialCode: '+963'),
    CountryCode(name: 'Soudan', flag: '🇸🇩', code: 'SD', dialCode: '+249'),
    CountryCode(name: 'Mauritanie', flag: '🇲🇷', code: 'MR', dialCode: '+222'),
  ];

  /// Default country (Tunisia)
  static const CountryCode defaultCountry = CountryCode(
    name: 'Tunisie',
    flag: '🇹🇳',
    code: 'TN',
    dialCode: '+216',
  );
}






