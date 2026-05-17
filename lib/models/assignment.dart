class Assignment {
  final String id;
  final String userId;
  final String title;
  final String course;
  final String description;
  final DateTime dueDate;
  final String status; // 'pending' or 'completed'
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.userId,
    required this.title,
    required this.course,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.createdAt,
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
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      course: map['course'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
