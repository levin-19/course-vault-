import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/database_service.dart';
import '../services/user_service.dart';

class HomeController extends GetxController {
  final _databaseService = DatabaseService.to;
  final _userService = UserService.to;

  var isLoading = false.obs;

  // Observable for current user profile
  var currentUser = Rx<AppUser?>(null);

  // Observable for user stats calculated from Firebase
  var userStats = {
    'completedAssignments': 0,
    'pendingAssignments': 0,
    'upcomingExams': 0,
    'gpa': 0.0,
  }.obs;

  // Observable for upcoming deadlines (pending assignments)
  var upcomingDeadlines = <Map<String, dynamic>>[].obs;

  // Quick access items (static, no changes needed)
  var quickAccessItems = [
    {'title': 'Notes', 'icon': 'note', 'route': '/notes', 'color': 0xFF2196F3},
    {'title': 'Assignments', 'icon': 'assignment', 'route': '/assignments', 'color': 0xFFFF9800},
    {'title': 'Exams', 'icon': 'exam', 'route': '/exams', 'color': 0xFF9C27B0},
    {'title': 'Resources', 'icon': 'resources', 'route': '/resources', 'color': 0xFF4CAF50},
  ].obs;

  // Store subscriptions for cleanup
  late StreamSubscription _statsSubscription;
  late StreamSubscription _deadlinesSubscription;
  late StreamSubscription _userProfileSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeDashboard();
  }

  /// Initialize dashboard by setting up real-time streams
  Future<void> _initializeDashboard() async {
    isLoading.value = true;

    try {
      // Try to get userId from UserService first
      var userId = _userService.getCurrentUserId();

      // If UserService doesn't have userId, try Firebase Auth as fallback
      if (userId.isEmpty) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          userId = firebaseUser.uid;
          // Also save it to UserService for future use
          _userService.setCurrentUserId(userId);
          print('DEBUG: Retrieved user ID from Firebase Auth: $userId');
        } else {
          print('ERROR: User ID not available. User might not be logged in.');
          isLoading.value = false;
          return;
        }
      }

      print('DEBUG: Initializing dashboard with userId: $userId');

      // Set up real-time stream for user profile
      _userProfileSubscription =
          _databaseService.getUserProfileStream(userId).listen(
        (userProfile) {
          print('DEBUG: User profile stream update: $userProfile');
          if (userProfile != null) {
            currentUser.value = AppUser.fromMap(userId, userProfile);
            print('DEBUG: Current user loaded: ${currentUser.value?.fullName}');
          } else {
            print('DEBUG: User profile is null from Firestore');
          }
        },
        onError: (e) => print('Error fetching user profile: $e'),
      );

      // Set up real-time stream for dashboard stats
      _statsSubscription =
          _databaseService.getDashboardStatsStream(userId).listen(
        (stats) {
          userStats.value = {
            'completedAssignments': stats['completedAssignments'] ?? 0,
            'pendingAssignments': stats['pendingAssignments'] ?? 0,
            'upcomingExams': stats['upcomingExams'] ?? 0,
            'gpa': stats['gpa'] ?? 0.0,
          };
        },
        onError: (e) => print('Error fetching dashboard stats: $e'),
      );

      // Set up real-time stream for upcoming deadlines
      _deadlinesSubscription =
          _databaseService.getUpcomingDeadlinesStream(userId).listen(
        (deadlines) {
          upcomingDeadlines.value = deadlines;
        },
        onError: (e) => print('Error fetching upcoming deadlines: $e'),
      );

      isLoading.value = false;
    } catch (e) {
      print('Error initializing dashboard: $e');
      isLoading.value = false;
    }
  }

  /// Load dashboard data manually (for pull-to-refresh)
  Future<void> loadDashboardData() async {
    try {
      var userId = _userService.getCurrentUserId();

      // Fallback to Firebase Auth if UserService doesn't have userId
      if (userId.isEmpty) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          userId = firebaseUser.uid;
          _userService.setCurrentUserId(userId);
        } else {
          print('ERROR: User ID not available.');
          return;
        }
      }

      // Manually fetch fresh data
      final userProfile = await _databaseService.getUserProfile(userId);
      if (userProfile != null) {
        currentUser.value = AppUser.fromMap(userId, userProfile);
      }

      // Fetch upcoming deadlines fresh
      final deadlines = await _databaseService.getUpcomingDeadlines(userId);
      upcomingDeadlines.value = deadlines;

      // Stats will be automatically updated by the stream
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  /// Refresh dashboard (called from pull-to-refresh)
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  /// Navigate to quick access routes
  void navigateToQuickAccess(String route) {
    Get.toNamed(route);
  }

  /// Calculate days until deadline
  int getDaysUntilDeadline(String dueDate) {
    try {
      final deadline = DateTime.parse(dueDate);
      final now = DateTime.now();
      return deadline.difference(now).inDays;
    } catch (e) {
      print('Error parsing date: $e');
      return 0;
    }
  }

  @override
  void onClose() {
    // Clean up stream subscriptions to prevent memory leaks
    _statsSubscription.cancel();
    _deadlinesSubscription.cancel();
    _userProfileSubscription.cancel();
    super.onClose();
  }
}
