import 'package:flutter/material.dart';

/// Enhanced Student Profile Model with Firebase data
class StudentProfile {
  final String uid;
  final String fullName;
  final String email;
  final String studentId;
  final String department;
  final String university;
  final String semester;
  final String programType; // Undergraduate, Diploma, Masters
  final String? phone;
  final String? profileImageUrl;
  final double cgpa;
  final String batch;
  final bool isVerified;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Profile completion tracking
  final Map<String, bool> completedFields;

  StudentProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.department,
    required this.university,
    required this.semester,
    required this.programType,
    this.phone,
    this.profileImageUrl,
    required this.cgpa,
    required this.batch,
    required this.isVerified,
    required this.isOnline,
    required this.createdAt,
    this.updatedAt,
    Map<String, bool>? completedFields,
  }) : completedFields = completedFields ?? _defaultCompletedFields();

  /// Calculate profile completion percentage
  double get completionPercentage {
    if (completedFields.isEmpty) return 0;
    final completed = completedFields.values.where((v) => v).length;
    return (completed / completedFields.length) * 100;
  }

  /// Get list of missing fields
  List<String> get missingFields {
    return completedFields.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();
  }

  /// Default profile completion fields
  static Map<String, bool> _defaultCompletedFields() {
    return {
      'fullName': false,
      'email': false,
      'phone': false,
      'department': false,
      'semester': false,
      'profileImage': false,
    };
  }

  /// Create from Firestore document
  factory StudentProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return StudentProfile(
      uid: uid,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      studentId: data['studentId'] ?? '',
      department: data['department'] ?? '',
      university: data['university'] ?? 'Not Set',
      semester: data['semester'] ?? '',
      programType: data['programType'] ?? 'Undergraduate',
      phone: data['phone'],
      profileImageUrl: data['profileImage'],
      cgpa: (data['cgpa'] ?? 0.0).toDouble(),
      batch: data['batch'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isOnline: data['isOnline'] ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
      completedFields: _calculateCompletedFields(data),
    );
  }

  /// Calculate which fields are completed
  static Map<String, bool> _calculateCompletedFields(Map<String, dynamic> data) {
    return {
      'fullName': (data['fullName'] as String?)?.isNotEmpty ?? false,
      'email': (data['email'] as String?)?.isNotEmpty ?? false,
      'phone': (data['phone'] as String?)?.isNotEmpty ?? false,
      'department': (data['department'] as String?)?.isNotEmpty ?? false,
      'semester': (data['semester'] as String?)?.isNotEmpty ?? false,
      'profileImage': (data['profileImage'] as String?)?.isNotEmpty ?? false,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'studentId': studentId,
      'department': department,
      'university': university,
      'semester': semester,
      'programType': programType,
      'phone': phone,
      'profileImage': profileImageUrl,
      'cgpa': cgpa,
      'batch': batch,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'updatedAt': DateTime.now(),
    };
  }

  @override
  String toString() => 'StudentProfile($uid, $fullName, $email)';
}

/// Academic Statistics Model
class AcademicStats {
  final int totalNotesUploaded;
  final int pendingAssignments;
  final int completedAssignments;
  final int savedResources;
  final int upcomingExams;
  final double assignmentCompletionPercentage;
  final int studyStreak;
  final List<String> badges;

  AcademicStats({
    required this.totalNotesUploaded,
    required this.pendingAssignments,
    required this.completedAssignments,
    required this.savedResources,
    required this.upcomingExams,
    required this.assignmentCompletionPercentage,
    required this.studyStreak,
    required this.badges,
  });

  factory AcademicStats.empty() {
    return AcademicStats(
      totalNotesUploaded: 0,
      pendingAssignments: 0,
      completedAssignments: 0,
      savedResources: 0,
      upcomingExams: 0,
      assignmentCompletionPercentage: 0,
      studyStreak: 0,
      badges: [],
    );
  }

  factory AcademicStats.fromFirestore(Map<String, dynamic> data) {
    return AcademicStats(
      totalNotesUploaded: data['totalNotesUploaded'] ?? 0,
      pendingAssignments: data['pendingAssignments'] ?? 0,
      completedAssignments: data['completedAssignments'] ?? 0,
      savedResources: data['savedResources'] ?? 0,
      upcomingExams: data['upcomingExams'] ?? 0,
      assignmentCompletionPercentage:
          (data['assignmentCompletionPercentage'] ?? 0.0).toDouble(),
      studyStreak: data['studyStreak'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }
}

/// Activity Model
class StudentActivity {
  final String id;
  final String type; // 'note', 'assignment', 'resource', 'exam'
  final String title;
  final String? description;
  final String icon;
  final DateTime timestamp;
  final Color color;

  StudentActivity({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.icon,
    required this.timestamp,
    required this.color,
  });

  factory StudentActivity.fromFirestore(Map<String, dynamic> data, String id) {
    return StudentActivity(
      id: id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      icon: data['icon'] ?? '📝',
      timestamp: (data['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      color: _getColorForType(data['type'] ?? ''),
    );
  }

  static Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'note':
        return Colors.orange;
      case 'assignment':
        return Colors.green;
      case 'resource':
        return Colors.blue;
      case 'exam':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

/// Deadline Model
class StudentDeadline {
  final String id;
  final String title;
  final DateTime dueDate;
  final String type; // 'assignment' or 'exam'
  final String subject;
  final bool isCompleted;

  StudentDeadline({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.type,
    required this.subject,
    required this.isCompleted,
  });

  factory StudentDeadline.fromFirestore(Map<String, dynamic> data, String id) {
    return StudentDeadline(
      id: id,
      title: data['title'] ?? '',
      dueDate: (data['dueDate'] as dynamic)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'assignment',
      subject: data['subject'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  /// Calculate days until deadline
  int get daysUntilDeadline {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Get urgency level
  String get urgencyLevel {
    final days = daysUntilDeadline;
    if (days < 0) return 'overdue';
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    if (days <= 3) return 'urgent';
    if (days <= 7) return 'upcoming';
    return 'later';
  }

  /// Get urgency color
  Color get urgencyColor {
    switch (urgencyLevel) {
      case 'overdue':
      case 'today':
        return Colors.red;
      case 'tomorrow':
      case 'urgent':
        return Colors.orange;
      case 'upcoming':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }
}

/// Badge Model
class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
  });

  factory AchievementBadge.fromFirestore(Map<String, dynamic> data, String id) {
    return AchievementBadge(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🏆',
      unlockedAt: (data['unlockedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
