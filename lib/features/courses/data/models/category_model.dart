/// Category Model
class CategoryModel {
  final int? id;
  final String? title;
  final String? slug;
  final String? icon; // This is the image URL from API
  final String? color;
  final int? coursesCount;
  final int? bundlesCount;
  final int? webinarsCount;
  final List<CategoryModel>? subCategories;
  final List<Translation>? translations;

  CategoryModel({
    this.id,
    this.title,
    this.slug,
    this.icon,
    this.color,
    this.coursesCount,
    this.bundlesCount,
    this.webinarsCount,
    this.subCategories,
    this.translations,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      icon: json['icon'], // Image URL
      color: json['color'],
      coursesCount: json['courses_count'] ?? json['webinars_count'],
      bundlesCount: json['bundles_count'],
      webinarsCount: json['webinars_count'],
      subCategories: json['sub_categories'] != null
          ? (json['sub_categories'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList()
          : null,
      translations: json['translations'] != null
          ? (json['translations'] as List)
              .map((e) => Translation.fromJson(e))
              .toList()
          : null,
    );
  }

  /// Get localized title
  String getTitle(String currentLanguage) {
    if (translations != null && translations!.isNotEmpty) {
      final translation = translations!.firstWhere(
        (t) => t.locale == currentLanguage,
        orElse: () => translations!.firstWhere(
          (t) => t.locale == 'en',
          orElse: () => translations!.first,
        ),
      );
      if (translation.title != null && translation.title!.isNotEmpty) {
        return translation.title!;
      }
    }
    return title ?? '';
  }

  /// Get total count (courses + bundles)
  int get totalCount => (coursesCount ?? 0) + (bundlesCount ?? 0);
  
  /// Get image URL with proper prefix if needed
  String? get imageUrl {
    if (icon == null || icon!.isEmpty) return null;
    if (icon!.startsWith('http')) return icon;
    return 'https://edufirma.com$icon';
  }
}

/// Translation Model for Category
class Translation {
  final int? id;
  final String? locale;
  final String? title;

  Translation({this.id, this.locale, this.title});

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'],
      locale: json['locale'],
      title: json['title'],
    );
  }
}
