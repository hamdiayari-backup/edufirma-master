/// Product Model for Store
class ProductModel {
  final int? id;
  final String? title;
  final String? slug;
  final String? description;
  final String? summary;
  final String? image;
  final List<String>? images;
  final dynamic price;
  final dynamic priceWithDiscount;
  final dynamic discountPercent;
  final int? quantity;
  final int? salesCount;
  final String? type;
  final String? status;
  final String? category;
  final int? categoryId;
  final String? rate;
  final int? reviewsCount;
  final int? createdAt;
  final bool? isFavorite;
  final bool? inStock;
  final List<ProductAttribute>? attributes;
  final List<ProductVariation>? variations;
  final SellerInfo? seller;

  ProductModel({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.summary,
    this.image,
    this.images,
    this.price,
    this.priceWithDiscount,
    this.discountPercent,
    this.quantity,
    this.salesCount,
    this.type,
    this.status,
    this.category,
    this.categoryId,
    this.rate,
    this.reviewsCount,
    this.createdAt,
    this.isFavorite,
    this.inStock,
    this.attributes,
    this.variations,
    this.seller,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      summary: json['summary'],
      image: json['image'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      price: json['price'],
      priceWithDiscount: json['price_with_discount'],
      discountPercent: json['discount_percent'],
      quantity: json['quantity'],
      salesCount: json['sales_count'],
      type: json['type'],
      status: json['status'],
      category: json['category'],
      categoryId: json['category_id'],
      rate: json['rate']?.toString(),
      reviewsCount: json['reviews_count'],
      createdAt: json['created_at'],
      isFavorite: json['is_favorite'],
      inStock: json['in_stock'] ?? (json['quantity'] != null && json['quantity'] > 0),
      attributes: json['attributes'] != null
          ? (json['attributes'] as List)
              .map((e) => ProductAttribute.fromJson(e))
              .toList()
          : null,
      variations: json['variations'] != null
          ? (json['variations'] as List)
              .map((e) => ProductVariation.fromJson(e))
              .toList()
          : null,
      seller: json['seller'] != null
          ? SellerInfo.fromJson(json['seller'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'image': image,
      'price': price,
      'price_with_discount': priceWithDiscount,
      'discount_percent': discountPercent,
      'quantity': quantity,
      'sales_count': salesCount,
      'category': category,
      'rate': rate,
      'reviews_count': reviewsCount,
      'is_favorite': isFavorite,
    };
  }

  /// Check if product has discount
  bool get hasDiscount =>
      discountPercent != null &&
      discountPercent != 0 &&
      discountPercent != '0';

  /// Get display price
  String get displayPrice {
    if (hasDiscount && priceWithDiscount != null) {
      return '$priceWithDiscount TND';
    }
    return '${price ?? 0} TND';
  }

  /// Get original price formatted
  String get originalPrice => '${price ?? 0} TND';
}

/// Product Attribute Model
class ProductAttribute {
  final int? id;
  final String? name;
  final String? value;

  ProductAttribute({this.id, this.name, this.value});

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'],
      name: json['name'],
      value: json['value'],
    );
  }
}

/// Product Variation Model
class ProductVariation {
  final int? id;
  final String? title;
  final dynamic price;
  final int? quantity;

  ProductVariation({this.id, this.title, this.price, this.quantity});

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}

/// Seller Info Model
class SellerInfo {
  final int? id;
  final String? fullName;
  final String? avatar;
  final String? role;

  SellerInfo({this.id, this.fullName, this.avatar, this.role});

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['id'],
      fullName: json['full_name'],
      avatar: json['avatar'],
      role: json['role'],
    );
  }
}






