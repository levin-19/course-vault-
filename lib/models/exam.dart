class Exam {
  final String id;
  final String userId;
  final String subject;
  final String examType;
  final DateTime examDate;
  final String time;
  final String location;
  final String notes;
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.userId,
    required this.subject,
    required this.examType,
    required this.examDate,
    required this.time,
    required this.location,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'examType': examType,
      'examDate': examDate.toIso8601String(),
      'time': time,
      'location': location,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      subject: map['subject'] ?? '',
      examType: map['examType'] ?? '',
      examDate: DateTime.parse(map['examDate']),
      time: map['time'] ?? '',
      location: map['location'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
