import 'package:get/get.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  
  var userStats = {
    'completedAssignments': 12,
    'pendingAssignments': 5,
    'upcomingExams': 3,
    'gpa': 3.8,
  }.obs;

  var quickAccessItems = [
    {'title': 'Notes', 'icon': 'note', 'route': '/notes', 'color': 0xFF2196F3},
    {'title': 'Assignments', 'icon': 'assignment', 'route': '/assignments', 'color': 0xFFFF9800},
    {'title': 'Exams', 'icon': 'exam', 'route': '/exams', 'color': 0xFF9C27B0},
    {'title': 'Resources', 'icon': 'resources', 'route': '/resources', 'color': 0xFF4CAF50},
  ].obs;

  var upcomingDeadlines = [
    {'title': 'Math Assignment', 'subject': 'Calculus II', 'dueDate': '2027-02-15', 'priority': 'high'},
    {'title': 'Physics Lab Report', 'subject': 'Physics', 'dueDate': '2024-02-18', 'priority': 'medium'},
    {'title': 'CS Project', 'subject': 'Data Structures', 'dueDate': '2024-02-20', 'priority': 'high'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }

  Future<void> refreshDashboard() async {
    loadDashboardData();
  }

  void navigateToQuickAccess(String route) {
    Get.toNamed(route);
  }

  int getDaysUntilDeadline(String dueDate) {
    final deadline = DateTime.parse(dueDate);
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }
}
