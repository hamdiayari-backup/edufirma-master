import 'support_conversation_model.dart';

/// Support ticket (platform or course)
class SupportModel {
  final int? id;
  final dynamic department; // map or id
  final String? status;
  final String? type;
  final String? title;
  final Map<String, dynamic>? webinar; // course info (title, etc.)
  final Map<String, dynamic>? user;
  final List<SupportConversationModel>? conversations;
  final int? createdAt;
  final int? updatedAt;

  SupportModel({
    this.id,
    this.department,
    this.status,
    this.type,
    this.title,
    this.webinar,
    this.user,
    this.conversations,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    List<SupportConversationModel>? convs;
    if (json['conversations'] != null && json['conversations'] is List) {
      convs = (json['conversations'] as List)
          .map((v) => SupportConversationModel.fromJson(
              Map<String, dynamic>.from(v as Map)))
          .toList();
    }
    return SupportModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0'),
      department: json['department'],
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      webinar: json['webinar'] != null && json['webinar'] is Map
          ? Map<String, dynamic>.from(json['webinar'] as Map)
          : null,
      user: json['user'] != null && json['user'] is Map
          ? Map<String, dynamic>.from(json['user'] as Map)
          : null,
      conversations: convs,
      createdAt: json['created_at'] is int
          ? json['created_at'] as int
          : int.tryParse(json['created_at']?.toString() ?? '0'),
      updatedAt: json['updated_at'] is int
          ? json['updated_at'] as int
          : int.tryParse(json['updated_at']?.toString() ?? '0'),
    );
  }
}
