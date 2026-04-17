/// App User Model - Extended with student-specific fields
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.studentId,
    this.university,
    this.department,
    this.semester,
    this.universityEmail,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;

  // Student-specific fields
  final String? studentId;
  final String? university;
  final String? department;
  final String? semester;
  final String? universityEmail;
  final DateTime? createdAt;

  /// Convert to map for Firestore/database storage
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'studentId': studentId,
      'university': university,
      'department': department,
      'semester': semester,
      'universityEmail': universityEmail,
      'createdAt': createdAt,
    };
  }

  /// Create from map (Firestore/database)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: (map['uid'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      avatarUrl: map['avatarUrl'] as String?,
      studentId: map['studentId'] as String?,
      university: map['university'] as String?,
      department: map['department'] as String?,
      semester: map['semester'] as String?,
      universityEmail: map['universityEmail'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  /// Copy with - Create a copy with some fields updated
  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? avatarUrl,
    String? studentId,
    String? university,
    String? department,
    String? semester,
    String? universityEmail,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      studentId: studentId ?? this.studentId,
      university: university ?? this.university,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      universityEmail: universityEmail ?? this.universityEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if user is a complete student profile
  bool get isCompleteStudentProfile {
    return studentId != null &&
        university != null &&
        department != null &&
        semester != null &&
        universityEmail != null;
  }
}
