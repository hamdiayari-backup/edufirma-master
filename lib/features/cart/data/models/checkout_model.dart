import 'cart_model.dart';

/// Checkout Model
class CheckoutModel {
  List<PaymentChannel>? paymentChannels;
  Order? order;
  int? count;
  dynamic userCharge;
  bool? razorpay;
  CartAmounts? amounts;

  CheckoutModel({
    this.paymentChannels,
    this.order,
    this.count,
    this.userCharge,
    this.razorpay,
    this.amounts,
  });

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    return CheckoutModel(
      paymentChannels: json['paymentChannels'] != null
          ? (json['paymentChannels'] as List)
              .map((v) => PaymentChannel.fromJson(v))
              .toList()
          : null,
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
      count: json['count'],
      userCharge: json['userCharge'],
      razorpay: json['razorpay'],
      amounts: json['amounts'] != null
          ? CartAmounts.fromJson(json['amounts'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentChannels': paymentChannels?.map((v) => v.toJson()).toList(),
      'order': order?.toJson(),
      'count': count,
      'userCharge': userCharge,
      'razorpay': razorpay,
      'amounts': amounts?.toJson(),
    };
  }
}

/// Payment Channel
class PaymentChannel {
  int? id;
  String? title;
  String? className;
  String? status;
  String? image;
  String? settings;
  List<String>? currencies;
  String? createdAt;
  String type;

  PaymentChannel({
    this.id,
    this.title,
    this.className,
    this.status,
    this.image,
    this.settings,
    this.currencies,
    this.createdAt,
    this.type = 'online',
  });

  factory PaymentChannel.fromJson(Map<String, dynamic> json) {
    return PaymentChannel(
      id: json['id'],
      title: json['title'],
      className: json['class_name'],
      status: json['status'],
      image: json['image'],
      settings: json['settings'],
      currencies: json['currencies'] != null
          ? List<String>.from(json['currencies'])
          : null,
      createdAt: json['created_at'],
      type: json['type'] ?? 'online',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'class_name': className,
      'status': status,
      'image': image,
      'settings': settings,
      'currencies': currencies,
      'created_at': createdAt,
      'type': type,
    };
  }

  /// Check if this is the Konnect payment gateway
  bool get isKonnect => 
      className?.toLowerCase().contains('konnect') == true ||
      title?.toLowerCase().contains('konnect') == true;

  /// ClicToPay (SMT / clictopay channel) — use local logo in checkout grid.
  bool get isClicToPay =>
      className?.toLowerCase().contains('clictopay') == true ||
      className?.toLowerCase().contains('clic_to_pay') == true ||
      title?.toLowerCase().contains('clictopay') == true ||
      title?.toLowerCase().contains('clic to pay') == true;
}

/// Order
class Order {
  int? userId;
  String? status;
  dynamic amount;
  dynamic tax;
  dynamic totalDiscount;
  dynamic totalAmount;
  int? createdAt;
  int? id;

  Order({
    this.userId,
    this.status,
    this.amount,
    this.tax,
    this.totalDiscount,
    this.totalAmount,
    this.createdAt,
    this.id,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      userId: json['user_id'],
      status: json['status'],
      amount: json['amount'],
      tax: json['tax'],
      totalDiscount: json['total_discount'],
      totalAmount: json['total_amount'],
      createdAt: json['created_at'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'status': status,
      'amount': amount,
      'tax': tax,
      'total_discount': totalDiscount,
      'total_amount': totalAmount,
      'created_at': createdAt,
      'id': id,
    };
  }
}






