/// Cart Model
class CartModel {
  List<CartItem>? items;
  CartAmounts? amounts;
  dynamic totalCashbackAmount;
  UserGroup? userGroup;

  CartModel({this.items, this.amounts, this.totalCashbackAmount, this.userGroup});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: json['items'] != null
          ? (json['items'] as List).map((v) => CartItem.fromJson(v)).toList()
          : null,
      amounts: json['amounts'] != null
          ? CartAmounts.fromJson(json['amounts'])
          : null,
      totalCashbackAmount: json['totalCashbackAmount'],
      userGroup: json['user_group'] != null
          ? UserGroup.fromJson(json['user_group'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((v) => v.toJson()).toList(),
      'amounts': amounts?.toJson(),
      'totalCashbackAmount': totalCashbackAmount,
      'user_group': userGroup?.toJson(),
    };
  }

  bool get isEmpty => items == null || items!.isEmpty;
  int get itemCount => items?.length ?? 0;
}

/// Cart Item
class CartItem {
  int? id;
  String? type;
  String? image;
  String? title;
  String? teacherName;
  String? rate;
  String? day;
  String? timezone;
  int? price;
  int? discount;
  int? quantity;
  CartTime? time;
  CartTime? timeUser;

  CartItem({
    this.id,
    this.type,
    this.image,
    this.title,
    this.teacherName,
    this.rate,
    this.day,
    this.timezone,
    this.price,
    this.discount,
    this.quantity,
    this.time,
    this.timeUser,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      type: json['type'],
      image: json['image'],
      title: json['title'],
      day: json['day'],
      timezone: json['timezone'],
      teacherName: json['teacher_name'],
      rate: json['rate']?.toString(),
      price: _parsePrice(json['price']),
      // discountPrice / discount_price = prix après remise (backend). On stocke le prix après remise pour finalPrice.
      discount: _parsePrice(json['discountPrice'] ?? json['discount_price'] ?? json['discount']),
      quantity: json['quantity'] ?? 1,
      time: json['time'] != null ? CartTime.fromJson(json['time']) : null,
      timeUser: json['time_user'] != null ? CartTime.fromJson(json['time_user']) : null,
    );
  }

  static int _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    if (price is double) return price.toInt();
    return double.tryParse(price.toString())?.toInt() ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'image': image,
      'title': title,
      'teacher_name': teacherName,
      'rate': rate,
      'price': price,
      'discount': discount,
      'quantity': quantity,
      'time': time?.toJson(),
      'time_user': timeUser?.toJson(),
    };
  }

  /// Get discounted price
  int get finalPrice => discount ?? price ?? 0;
  
  /// Get discount percentage
  int get discountPercent {
    if (price == null || price == 0 || discount == null) return 0;
    return (((price! - discount!) / price!) * 100).toInt();
  }
}

/// Cart Time (for meetings)
class CartTime {
  String? start;
  String? end;

  CartTime({this.start, this.end});

  factory CartTime.fromJson(Map<String, dynamic> json) {
    return CartTime(
      start: json['start'],
      end: json['end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}

/// Cart Amounts
class CartAmounts {
  dynamic subTotal;
  dynamic totalDiscount;
  String? tax;
  dynamic taxPrice;
  dynamic commission;
  dynamic commissionPrice;
  dynamic total;
  dynamic productDeliveryFee;
  bool? taxIsDifferent;

  CartAmounts({
    this.subTotal,
    this.totalDiscount,
    this.tax,
    this.taxPrice,
    this.commission,
    this.commissionPrice,
    this.total,
    this.productDeliveryFee,
    this.taxIsDifferent,
  });

  factory CartAmounts.fromJson(Map<String, dynamic> json) {
    return CartAmounts(
      subTotal: json['sub_total'],
      totalDiscount: json['total_discount'],
      tax: json['tax']?.toString(),
      taxPrice: json['tax_price'],
      commission: json['commission'],
      commissionPrice: json['commission_price'],
      total: json['total'],
      productDeliveryFee: json['product_delivery_fee'],
      taxIsDifferent: json['tax_is_different'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_total': subTotal,
      'total_discount': totalDiscount,
      'tax': tax,
      'tax_price': taxPrice,
      'commission': commission,
      'commission_price': commissionPrice,
      'total': total,
      'product_delivery_fee': productDeliveryFee,
      'tax_is_different': taxIsDifferent,
    };
  }

  /// Get formatted total (int, may truncate decimals)
  int get totalInt => (total is int) ? total : (total != null ? (total is num ? (total as num).round() : int.tryParse(total.toString()) ?? 0) : 0);

  /// Total as double (montant après remise) — use for payment and display with decimals
  double get totalDouble {
    if (total == null) return 0.0;
    if (total is int) return (total as int).toDouble();
    if (total is double) return total as double;
    return double.tryParse(total.toString()) ?? 0.0;
  }
}

/// User Group (for group discounts)
class UserGroup {
  int? id;
  String? name;
  int? discount;

  UserGroup({this.id, this.name, this.discount});

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['id'],
      name: json['name'],
      discount: json['discount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discount': discount,
    };
  }
}






