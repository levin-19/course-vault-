import 'note.dart' show Attachment;

class Assignment {
  final String id;
  final String userId;
  final String title;
  final String course;
  final String description;
  final DateTime dueDate;
  final String status; // 'pending' or 'completed'
  final DateTime createdAt;
  final String? attachmentUrl;
  final String? attachmentName;
  final List<Attachment> attachments;

  Assignment({
    required this.id,
    required this.userId,
    required this.title,
    required this.course,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.attachmentUrl,
    this.attachmentName,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'course': course,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (attachmentName != null) 'attachmentName': attachmentName,
      'attachments': attachments.map((a) => a.toMap()).toList(),
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    final rawAttachments = map['attachments'] as List<dynamic>?;
    List<Attachment> list = [];
    if (rawAttachments != null) {
      list = rawAttachments
          .map((x) => Attachment.fromMap(Map<String, dynamic>.from(x)))
          .toList();
    } else if (map['attachmentUrl'] != null && map['attachmentName'] != null) {
      list = [Attachment(name: map['attachmentName'], url: map['attachmentUrl'])];
    }
    return Assignment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      course: map['course'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      attachmentUrl: map['attachmentUrl'] as String?,
      attachmentName: map['attachmentName'] as String?,
      attachments: list,
    );
  }
}
