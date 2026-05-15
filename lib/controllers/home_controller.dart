import 'package:get/get.dart';

class HomeController extends GetxController {
  // Reactive variables
  final isLoading = false.obs;
  final refreshing = false.obs;

  // Dashboard data - Static
  final userStats = {
    'completedAssignments': 12,
    'pendingAssignments': 5,
    'upcomingExams': 3,
    'gpa': 3.85,
  }.obs;

  final upcomingDeadlines = [
    {
      'title': 'Database Assignment',
      'subject': 'Database Management',
      'dueDate': '2026-05-18',
      'priority': 'high',
    },
    {
      'title': 'Software Design Project',
      'subject': 'Software Engineering',
      'dueDate': '2026-05-22',
      'priority': 'medium',
    },
    {
      'title': 'Data Structures Quiz',
      'subject': 'Data Structures',
      'dueDate': '2026-05-20',
      'priority': 'high',
    },
    {
      'title': 'Web Development Project',
      'subject': 'Web Development',
      'dueDate': '2026-05-25',
      'priority': 'low',
    },
    {
      'title': 'System Design Document',
      'subject': 'System Design',
      'dueDate': '2026-05-21',
      'priority': 'medium',
    },
  ].obs;

  final recentActivities = [
    {
      'title': 'Assignment Submitted',
      'subject': 'Web Development',
      'timestamp': '2 hours ago',
      'icon': 'assignment',
    },
    {
      'title': 'Quiz Result Published',
      'subject': 'Data Structures - 95/100',
      'timestamp': '5 hours ago',
      'icon': 'quiz',
    },
    {
      'title': 'New Class Note Added',
      'subject': 'Database Management',
      'timestamp': '1 day ago',
      'icon': 'note',
    },
    {
      'title': 'Exam Schedule Updated',
      'subject': 'Final Semester Exams',
      'timestamp': '2 days ago',
      'icon': 'exam',
    },
    {
      'title': 'Grade Posted',
      'subject': 'Software Engineering - A',
      'timestamp': '3 days ago',
      'icon': 'grade',
    },
  ].obs;

  final quickAccessItems = [
    {
      'title': 'My Notes',
      'icon': 'note',
      'route': '/notes',
      'color': 0xFF1F6FEB,
    },
    {
      'title': 'Assignments',
      'icon': 'assignment',
      'route': '/assignments',
      'color': 0xFF7C5FD4,
    },
    {
      'title': 'Exam Routine',
      'icon': 'exam',
      'route': '/exams',
      'color': 0xFFFF6B6B,
    },
    {
      'title': 'Resources',
      'icon': 'resources',
      'route': '/resources',
      'color': 0xFF4ECDC4,
    },
    {
      'title': 'Videos',
      'icon': 'video',
      'route': '/videos',
      'color': 0xFFFFA502,
    },
    {
      'title': 'Dashboard',
      'icon': 'dashboard',
      'route': '/dashboard',
      'color': 0xFF95E1D3,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      isLoading(true);
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      // Data is already initialized as static
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Refresh dashboard
  Future<void> refreshDashboard() async {
    try {
      refreshing(true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar('Success', 'Dashboard refreshed',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(milliseconds: 500));
    } finally {
      refreshing(false);
    }
  }

  // Get days until deadline
  int getDaysUntilDeadline(String dueDate) {
    final deadline = DateTime.parse(dueDate);
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  // Navigate to quick access item
  void navigateToQuickAccess(String route) {
    Get.snackbar('Navigation', 'Opening $route',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(milliseconds: 500));
  }
}
