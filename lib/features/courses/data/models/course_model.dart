import 'user_model.dart';

/// Course Model
class CourseModel {
  final int? id;
  final String? thumbnail;
  final String? image;
  final String? title;
  final String? description;
  final String? type;
  final String? status;
  final String? label;
  final String? link;
  final bool? auth;
  final bool? authHasBought;
  final bool? isFavorite;
  final bool? expired;
  final int? accessDays;
  final int? expireOn;
  final String? liveWebinarStatus;
  final String? priceString;
  final String? bestTicketString;
  final dynamic price;
  final dynamic tax;
  final dynamic taxWithDiscount;
  final dynamic bestTicketPrice;
  final dynamic discountPercent;
  final dynamic priceWithDiscount;
  final dynamic discountAmount;
  final ActiveSpecialOffer? activeSpecialOffer;
  final int? duration;
  final UserModel? teacher;
  final int? studentsCount;
  final String? rate;
  final RateType? rateType;
  final int? createdAt;
  final int? startDate;
  final int? purchasedAt;
  final int? reviewsCount;
  final int? points;
  final int? progress;
  final int? progressPercent;

  /// Total courses in bundle (pack). API: webinars_count, bundle_webinars_count.
  final int? webinarsCount;

  /// Number of bundle courses marked as completed. API: completed_webinars_count.
  final int? completedWebinarsCount;
  final String? category;

  /// Category ID for filtering (API: category_id or category.id).
  final int? categoryId;
  final int? capacity;
  final int? salesCountNumber;
  final int? isPrivate;
  final List<Translation>? translations;
  final List<CustomBadge>? badges;
  final Sales? sales;
  final Can? can;
  final dynamic canViewError;

  /// Order for display inside a bundle (pedagogical order). From API: order, sort_order, position, pivot.order
  final int? order;

  CourseModel({
    this.id,
    this.thumbnail,
    this.image,
    this.title,
    this.description,
    this.type,
    this.status,
    this.label,
    this.link,
    this.auth,
    this.authHasBought,
    this.isFavorite,
    this.expired,
    this.accessDays,
    this.expireOn,
    this.liveWebinarStatus,
    this.priceString,
    this.bestTicketString,
    this.price,
    this.tax,
    this.taxWithDiscount,
    this.bestTicketPrice,
    this.discountPercent,
    this.priceWithDiscount,
    this.discountAmount,
    this.activeSpecialOffer,
    this.duration,
    this.teacher,
    this.studentsCount,
    this.rate,
    this.rateType,
    this.createdAt,
    this.startDate,
    this.purchasedAt,
    this.reviewsCount,
    this.points,
    this.progress,
    this.progressPercent,
    this.webinarsCount,
    this.completedWebinarsCount,
    this.category,
    this.categoryId,
    this.capacity,
    this.salesCountNumber,
    this.isPrivate,
    this.translations,
    this.badges,
    this.sales,
    this.can,
    this.canViewError,
    this.order,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // Helper to convert int/bool to bool
    bool? toBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return null;
    }

    return CourseModel(
      id: json['id'],
      thumbnail: json['thumbnail'] ?? json['image'],
      image: json['image'] ?? json['image_cover'],
      title: json['title'] ?? json['label'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      label: json['label'],
      link: json['link'],
      auth: toBool(json['auth']),
      authHasBought: toBool(json['auth_has_bought']),
      isFavorite: toBool(json['is_favorite']),
      expired: toBool(json['expired']),
      accessDays: json['access_days'],
      expireOn: json['expire_on'],
      liveWebinarStatus: json['live_webinar_status'],
      priceString: json['price_string'],
      bestTicketString: json['best_ticket_string']?.toString(),
      price: json['price'],
      tax: json['tax'],
      taxWithDiscount: json['tax_with_discount'],
      bestTicketPrice: json['best_ticket_price'],
      discountPercent: json['discount_percent'] ?? 0,
      priceWithDiscount: json['price_with_discount'],
      discountAmount: json['discount_amount'],
      activeSpecialOffer: json['active_special_offer'] != null
          ? ActiveSpecialOffer.fromJson(json['active_special_offer'])
          : null,
      duration: int.tryParse(json['duration']?.toString() ?? '0'),
      teacher:
          json['teacher'] != null ? UserModel.fromJson(json['teacher']) : null,
      studentsCount: json['students_count'],
      rate: json['rate']?.toString(),
      rateType: json['rate_type'] != null
          ? RateType.fromJson(json['rate_type'])
          : null,
      createdAt: int.tryParse(json['created_at']?.toString() ?? '0'),
      startDate: json['start_date'],
      purchasedAt: json['purchased_at'],
      reviewsCount: json['reviews_count'],
      points: json['points'],
      progress:
          (double.tryParse(json['progress']?.toString() ?? '0') ?? 0).toInt(),
      progressPercent:
          (double.tryParse(json['progress_percent']?.toString() ?? '0') ?? 0)
              .toInt(),
      webinarsCount: int.tryParse(json['webinars_count']?.toString() ?? '') ??
          int.tryParse(json['bundle_webinars_count']?.toString() ?? ''),
      completedWebinarsCount:
          int.tryParse(json['completed_webinars_count']?.toString() ?? ''),
      category: json['category'] is String
          ? json['category']
          : json['category']?['slug'],
      categoryId: _parseCategoryId(json),
      capacity: json['capacity'],
      salesCountNumber: json['sales_count_number'],
      isPrivate: json['isPrivate'] ?? 0,
      translations: json['translations'] != null
          ? (json['translations'] as List)
              .map((e) => Translation.fromJson(e))
              .toList()
          : null,
      badges: json['badges'] != null
          ? (json['badges'] as List)
              .map((e) => CustomBadge.fromJson(e))
              .toList()
          : null,
      sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
      can: json['can'] != null ? Can.fromJson(json['can']) : null,
      canViewError: json['can_view_error'],
      order: _parseOrder(json),
    );
  }

  static int? _parseOrder(Map<String, dynamic> json) {
    final v = json['order'] ?? json['sort_order'] ?? json['position'];
    if (v != null) return int.tryParse(v.toString());
    final pivot = json['pivot'];
    if (pivot is Map && pivot['order'] != null) {
      return int.tryParse(pivot['order'].toString());
    }
    return null;
  }

  static int? _parseCategoryId(Map<String, dynamic> json) {
    final id = json['category_id'];
    if (id != null) return int.tryParse(id.toString());
    final cat = json['category'];
    if (cat is Map && cat['id'] != null)
      return int.tryParse(cat['id'].toString());
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thumbnail': thumbnail,
      'image': image,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'label': label,
      'link': link,
      'auth': auth,
      'auth_has_bought': authHasBought,
      'is_favorite': isFavorite,
      'price_string': priceString,
      'price': price,
      'discount_percent': discountPercent,
      'price_with_discount': priceWithDiscount,
      'duration': duration,
      'students_count': studentsCount,
      'rate': rate,
      'reviews_count': reviewsCount,
      'category': category,
    };
  }

  /// Get localized title based on current language
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

  /// Get display thumbnail (fallback to image if thumbnail is null)
  String? get displayThumbnail => thumbnail ?? image;

  /// For bundles: progress % = (completedWebinarsCount / webinarsCount) * 100.
  /// Falls back to progressPercent when counts are missing or for single course.
  int get effectiveProgressPercent {
    if (webinarsCount != null &&
        completedWebinarsCount != null &&
        webinarsCount! > 0) {
      return ((completedWebinarsCount! / webinarsCount!) * 100).round();
    }
    return progressPercent ?? 0;
  }

  /// True when this course is a bundle and we have total/completed counts.
  bool get hasBundleProgressCounts =>
      webinarsCount != null &&
      completedWebinarsCount != null &&
      webinarsCount! > 0;

  /// Check if course is free
  bool get isFree => price == 0 || price == null || price == '0';

  /// Check if course has discount
  bool get hasDiscount =>
      discountPercent != null && discountPercent != 0 && discountPercent != '0';

  /// Discount percent as int for display (e.g. badge "-20%").
  int get discountPercentDisplay =>
      _toDouble(discountPercent).round().clamp(0, 100);

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static double parseDouble(dynamic v) => _toDouble(v);

  /// Computed price after discount from raw values. Use when displaying from Map.
  static double effectiveDiscountDisplayPrice(
    dynamic price,
    dynamic discountPercent, [
    dynamic priceWithDiscount,
  ]) {
    final p = _toDouble(price);
    final pc = _toDouble(discountPercent);
    if (pc <= 0 || p <= 0) return p;
    final computed = p * (1 - pc / 100);
    return double.tryParse(computed.toStringAsFixed(2)) ?? computed;
  }

  /// Computed price after discount: price * (1 - discountPercent/100).
  /// Use this when API price_with_discount is wrong or missing.
  double? get effectiveDiscountPrice {
    if (!hasDiscount) return null;
    final p = _toDouble(price);
    final pc = _toDouble(discountPercent);
    if (p <= 0 || pc <= 0 || pc >= 100) return null;
    final discounted = p * (1 - pc / 100);
    return double.tryParse(discounted.toStringAsFixed(2));
  }

  /// Price to display as "current" (after discount if any).
  /// Uses computed discount (price × (1 - %/100)) when we have discountPercent.
  double get displayPriceValue {
    if (isFree) return 0;
    if (hasDiscount) {
      final computed = effectiveDiscountPrice;
      if (computed != null && computed > 0) return computed;
      final api = _toDouble(priceWithDiscount);
      if (api > 0 && api < _toDouble(price)) return api;
    }
    return _toDouble(price);
  }

  /// Original price (before discount) for strikethrough.
  double get originalPriceValue => _toDouble(price);

  /// Get display price string
  String get displayPrice {
    if (isFree) return 'Gratuit';
    if (hasDiscount) return '${displayPriceValue.toStringAsFixed(0)} TND';
    return '${originalPriceValue.toStringAsFixed(0)} TND';
  }
}

/// Sales Model
class Sales {
  final int? count;
  final int? amount;

  Sales({this.count, this.amount});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      count: json['count'],
      amount: json['amount'],
    );
  }
}

/// Rate Type Model
class RateType {
  final double? contentQuality;
  final double? instructorSkills;
  final double? purchaseWorth;
  final double? supportQuality;

  RateType({
    this.contentQuality,
    this.instructorSkills,
    this.purchaseWorth,
    this.supportQuality,
  });

  factory RateType.fromJson(Map<String, dynamic> json) {
    return RateType(
      contentQuality:
          double.tryParse(json['content_quality']?.toString() ?? '0'),
      instructorSkills:
          double.tryParse(json['instructor_skills']?.toString() ?? '0'),
      purchaseWorth: double.tryParse(json['purchase_worth']?.toString() ?? '0'),
      supportQuality:
          double.tryParse(json['support_quality']?.toString() ?? '0'),
    );
  }
}

/// Active Special Offer Model
class ActiveSpecialOffer {
  final int? id;
  final String? name;
  final int? percent;
  final String? status;
  final int? fromDate;
  final int? toDate;

  ActiveSpecialOffer({
    this.id,
    this.name,
    this.percent,
    this.status,
    this.fromDate,
    this.toDate,
  });

  factory ActiveSpecialOffer.fromJson(Map<String, dynamic> json) {
    return ActiveSpecialOffer(
      id: json['id'],
      name: json['name'],
      percent: json['percent'],
      status: json['status'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
    );
  }
}

/// Translation Model
class Translation {
  final int? id;
  final String? locale;
  final String? title;
  final String? description;
  final String? seoDescription;

  Translation({
    this.id,
    this.locale,
    this.title,
    this.description,
    this.seoDescription,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'],
      locale: json['locale'],
      title: json['title'],
      description: json['description'],
      seoDescription: json['seo_description'],
    );
  }
}

/// Custom Badge Model
class CustomBadge {
  final int? id;
  final String? icon;
  final String? color;
  final String? background;
  final String? title;

  CustomBadge({
    this.id,
    this.icon,
    this.color,
    this.background,
    this.title,
  });

  factory CustomBadge.fromJson(Map<String, dynamic> json) {
    final badge = json['badge'];
    return CustomBadge(
      id: badge?['id'] ?? json['id'],
      icon: badge?['icon'] ?? json['icon'],
      color: badge?['color'] ?? json['color'],
      background: badge?['background'] ?? json['background'],
      title: badge?['title'] ?? json['title'],
    );
  }
}

/// Can (Permissions) Model
class Can {
  final bool? view;
  final bool? buy;

  Can({this.view, this.buy});

  factory Can.fromJson(Map<String, dynamic> json) {
    return Can(
      view: json['view'],
      buy: json['buy'],
    );
  }
}
