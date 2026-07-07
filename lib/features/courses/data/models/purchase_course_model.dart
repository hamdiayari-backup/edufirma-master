import 'course_model.dart';

/// Purchase Course Model - represents a purchased course or bundle
class PurchaseCourseModel {
  int? id;
  int? sellerId;
  int? buyerId;
  int? orderId;
  int? webinarId;
  int? bundleId;
  int? meetingId;
  int? subscribeId;
  int? ticketId;
  String? paymentMethod;
  String? type;
  String? amount;
  String? tax;
  String? discount;
  String? totalAmount;
  int? accessToPurchasedItem;
  int? createdAt;
  bool? expired;
  int? expiredAt;
  CourseModel? webinar;
  CourseModel? bundle;

  PurchaseCourseModel({
    this.id,
    this.sellerId,
    this.buyerId,
    this.orderId,
    this.webinarId,
    this.bundleId,
    this.meetingId,
    this.subscribeId,
    this.ticketId,
    this.paymentMethod,
    this.type,
    this.amount,
    this.tax,
    this.discount,
    this.totalAmount,
    this.accessToPurchasedItem,
    this.createdAt,
    this.expired,
    this.expiredAt,
    this.webinar,
    this.bundle,
  });

  factory PurchaseCourseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseCourseModel(
      id: json['id'],
      sellerId: json['seller_id'],
      buyerId: json['buyer_id'],
      orderId: json['order_id'],
      webinarId: json['webinar_id'],
      bundleId: json['bundle_id'],
      meetingId: json['meeting_id'],
      subscribeId: json['subscribe_id'],
      ticketId: json['ticket_id'],
      paymentMethod: json['payment_method'],
      type: json['type'],
      amount: json['amount']?.toString(),
      tax: json['tax']?.toString(),
      discount: json['discount']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      accessToPurchasedItem: json['access_to_purchased_item'],
      createdAt: json['created_at'],
      expired: json['expired'],
      expiredAt: json['expired_at'],
      webinar: json['webinar'] != null ? CourseModel.fromJson(json['webinar']) : null,
      bundle: json['bundle'] != null ? CourseModel.fromJson(json['bundle']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'buyer_id': buyerId,
      'order_id': orderId,
      'webinar_id': webinarId,
      'bundle_id': bundleId,
      'meeting_id': meetingId,
      'subscribe_id': subscribeId,
      'ticket_id': ticketId,
      'payment_method': paymentMethod,
      'type': type,
      'amount': amount,
      'tax': tax,
      'discount': discount,
      'total_amount': totalAmount,
      'access_to_purchased_item': accessToPurchasedItem,
      'created_at': createdAt,
      'expired': expired,
      'expired_at': expiredAt,
      'webinar': webinar?.toJson(),
      'bundle': bundle?.toJson(),
    };
  }

  /// Get the course (either webinar or bundle)
  CourseModel? get course => webinar ?? bundle;
  
  /// Check if this is a bundle purchase
  bool get isBundle => bundleId != null && bundle != null;
  
  /// Check if access has expired
  bool get hasExpired => expired == true;
}






