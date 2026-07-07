/// Single message in a support ticket conversation
class SupportConversationModel {
  final int? id;
  final Map<String, dynamic>? sender; // user who sent (null = support team)
  final String? message;
  final String? fileTitle;
  final String? filePath;
  final int? createdAt;

  SupportConversationModel({
    this.id,
    this.sender,
    this.message,
    this.fileTitle,
    this.filePath,
    this.createdAt,
  });

  factory SupportConversationModel.fromJson(Map<String, dynamic> json) {
    return SupportConversationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      sender: json['sender'] != null && json['sender'] is Map
          ? Map<String, dynamic>.from(json['sender'] as Map)
          : null,
      message: json['message']?.toString(),
      fileTitle: json['file_title']?.toString(),
      filePath: json['file_path']?.toString() ?? json['attach']?.toString(),
      createdAt: json['created_at'] is int
          ? json['created_at'] as int
          : int.tryParse(json['created_at']?.toString() ?? '0'),
    );
  }
}
