class Attachment {
  final String name;
  final String url;

  Attachment({required this.name, required this.url});

  Map<String, dynamic> toMap() => {'name': name, 'url': url};

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      name: map['name'] ?? '',
      url: map['url'] ?? '',
    );
  }
}

class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String subject;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? attachmentUrl;
  final String? attachmentName;
  final List<Attachment> attachments;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.subject,
    required this.createdAt,
    required this.updatedAt,
    this.attachmentUrl,
    this.attachmentName,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'subject': subject,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (attachmentName != null) 'attachmentName': attachmentName,
      'attachments': attachments.map((a) => a.toMap()).toList(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    final rawAttachments = map['attachments'] as List<dynamic>?;
    List<Attachment> list = [];
    if (rawAttachments != null) {
      list = rawAttachments
          .map((x) => Attachment.fromMap(Map<String, dynamic>.from(x)))
          .toList();
    } else if (map['attachmentUrl'] != null && map['attachmentName'] != null) {
      list = [Attachment(name: map['attachmentName'], url: map['attachmentUrl'])];
    }
    return Note(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      subject: map['subject'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      attachmentUrl: map['attachmentUrl'] as String?,
      attachmentName: map['attachmentName'] as String?,
      attachments: list,
    );
  }
}
