/// Student Profile Data Model
/// Contains all student information displayed on the profile screen
class StudentProfile {
  final String uid;
  final String fullName;
  final String studentId;
  final String department;
  final String university;
  final String semester;
  final String programType; // Undergraduate, Diploma, Masters
  final String phoneNumber;
  final String dateOfBirth;
  final String address;
  final String gender;
  final String profileImageUrl;
  final double cgpa;
  final String batch;
  final String universityEmail;
  final bool isVerified;
  final bool isOnline;

  // Statistics
  final int totalNotesUploaded;
  final int pendingAssignments;
  final int completedAssignments;
  final int savedResources;
  final int upcomingExams;

  // Profile completion percentage
  final double profileCompletionPercentage;

  // Recent activities
  final List<ActivityItem> recentActivities;

  StudentProfile({
    required this.uid,
    required this.fullName,
    required this.studentId,
    required this.department,
    required this.university,
    required this.semester,
    required this.programType,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.address,
    required this.gender,
    required this.profileImageUrl,
    required this.cgpa,
    required this.batch,
    required this.universityEmail,
    required this.isVerified,
    required this.isOnline,
    required this.totalNotesUploaded,
    required this.pendingAssignments,
    required this.completedAssignments,
    required this.savedResources,
    required this.upcomingExams,
    required this.profileCompletionPercentage,
    required this.recentActivities,
  });

  /// Create a dummy student profile for testing/preview
  static StudentProfile dummyProfile() {
    return StudentProfile(
      uid: 'student_123',
      fullName: 'Alex Johnson',
      studentId: 'SID-2024-0847',
      department: 'Computer Science & Engineering',
      university: 'Harvard University',
      semester: '4th Semester',
      programType: 'Undergraduate',
      phoneNumber: '+1 (555) 123-4567',
      dateOfBirth: '15 March 2003',
      address: 'Cambridge, MA 02138, USA',
      gender: 'Male',
      profileImageUrl:
          'https://i.pravatar.cc/300?img=33', // Placeholder avatar
      cgpa: 3.87,
      batch: '2022-2026',
      universityEmail: 'alex.johnson@harvard.edu',
      isVerified: true,
      isOnline: true,
      totalNotesUploaded: 42,
      pendingAssignments: 3,
      completedAssignments: 28,
      savedResources: 156,
      upcomingExams: 5,
      profileCompletionPercentage: 92.0,
      recentActivities: [
        ActivityItem(
          type: ActivityType.noteUploaded,
          title: 'Data Structures & Algorithms Notes',
          subtitle: 'Uploaded 2 hours ago',
          icon: '📝',
        ),
        ActivityItem(
          type: ActivityType.assignmentSubmitted,
          title: 'Web Development Assignment',
          subtitle: 'Submitted 5 hours ago',
          icon: '✅',
        ),
        ActivityItem(
          type: ActivityType.resourceSaved,
          title: 'Machine Learning Research Paper',
          subtitle: 'Saved 1 day ago',
          icon: '💾',
        ),
        ActivityItem(
          type: ActivityType.examReminder,
          title: 'Database Systems Final Exam',
          subtitle: 'Tomorrow at 2:00 PM',
          icon: '📅',
        ),
        ActivityItem(
          type: ActivityType.noteUploaded,
          title: 'Operating Systems Lecture Notes',
          subtitle: 'Uploaded 2 days ago',
          icon: '📝',
        ),
      ],
    );
  }
}

/// Recent Activity Item Model
class ActivityItem {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String icon;

  ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Activity Type Enumeration
enum ActivityType {
  noteUploaded,
  assignmentSubmitted,
  resourceSaved,
  examReminder,
  profileUpdated,
}
