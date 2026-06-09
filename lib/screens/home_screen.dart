import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  /// Get time-based greeting
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTimeBasedGreeting(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Welcome back to your learning hub',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => Get.toNamed('/profile'),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F6FEB), Color(0xFF0D47A1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  child: const Icon(Icons.person, color: Color(0xFF1F6FEB)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => controller.refreshDashboard(),
                backgroundColor: const Color(0xFF1F6FEB),
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Profile Header with Gradient
                      _buildEnhancedProfileHeader(context, isDarkMode, controller),
                      const SizedBox(height: 24),

                      // Academic Progress Section
                      _buildAcademicProgress(context, controller, isDarkMode),
                      const SizedBox(height: 24),

                      // Study Schedule (Next Deadline/Exam)
                      _buildStudySchedule(context, controller, isDarkMode),
                      const SizedBox(height: 24),

                      // Key Metrics with Better Layout
                      _buildEnhancedMetrics(context, controller, isDarkMode),
                      const SizedBox(height: 24),

                      // Priority-based Upcoming Tasks
                      _buildPriorityTasks(context, controller, isDarkMode),
                      const SizedBox(height: 24),

                      // Daily Tips Section
                      _buildDailyTips(context, isDarkMode),
                      const SizedBox(height: 24),

                      // Quick Access - Improved Layout
                      _buildEnhancedQuickAccess(context, controller, isDarkMode),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Enhanced Profile Header with Gradient
  Widget _buildEnhancedProfileHeader(
      BuildContext context, bool isDarkMode, HomeController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F6FEB), Color(0xFF5E35B1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  (controller.currentUser.value?.fullName ?? 'S').characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentUser.value?.fullName ?? 'Student',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${controller.currentUser.value?.department ?? 'Department'} • Sem ${controller.currentUser.value?.semester ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Academic Progress Gauge
  Widget _buildAcademicProgress(BuildContext context, HomeController controller,
      bool isDarkMode) {
    return Obx(
      () {
        final gpa = (controller.userStats['gpa'] as num).toDouble();
        final gpaPercentage = (gpa / 4.0) * 100; // Assuming 4.0 is max GPA

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your current GPA',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${gpa.toStringAsFixed(2)}/4.0',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: gpaPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          gpaPercentage >= 80 ? const Color(0xFF4CAF50) : 
                          gpaPercentage >= 60 ? const Color(0xFFFF9800) : 
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${gpaPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Study Schedule - Next Deadline/Exam
  Widget _buildStudySchedule(BuildContext context, HomeController controller,
      bool isDarkMode) {
    return Obx(
      () {
        if (controller.upcomingDeadlines.isEmpty) {
          return const SizedBox.shrink();
        }

        final nextDeadline = controller.upcomingDeadlines.first;
        final daysLeft =
            controller.getDaysUntilDeadline(nextDeadline['dueDate'].toString());
        final isUrgent = daysLeft <= 3;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isUrgent
                  ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                  : [const Color(0xFF2196F3), const Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isUrgent
                    ? const Color(0xFFFF5252).withOpacity(0.3)
                    : const Color(0xFF2196F3).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isUrgent ? Icons.schedule : Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isUrgent ? 'Urgent Deadline' : 'Next Deadline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nextDeadline['title'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    nextDeadline['course'].toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$daysLeft day${daysLeft != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Enhanced Metrics with Better Visual Hierarchy
  Widget _buildEnhancedMetrics(BuildContext context, HomeController controller,
      bool isDarkMode) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Performance Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildEnhancedMetricCard(
                context,
                'Completed',
                '${controller.userStats['completedAssignments']}',
                Icons.check_circle_outline,
                const Color(0xFF4CAF50),
                isDarkMode,
              ),
              _buildEnhancedMetricCard(
                context,
                'Pending',
                '${controller.userStats['pendingAssignments']}',
                Icons.assignment_late,
                const Color(0xFFFF9800),
                isDarkMode,
              ),
              _buildEnhancedMetricCard(
                context,
                'Upcoming Exams',
                '${controller.userStats['upcomingExams']}',
                Icons.auto_stories_rounded,
                const Color(0xFF2196F3),
                isDarkMode,
              ),
              _buildEnhancedMetricCard(
                context,
                'Completion',
                '${((controller.userStats['completedAssignments'] as int) / ((controller.userStats['completedAssignments'] as int) + (controller.userStats['pendingAssignments'] as int)) * 100).toStringAsFixed(0)}%',
                Icons.trending_up,
                const Color(0xFF9C27B0),
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Enhanced Metric Card
  Widget _buildEnhancedMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Priority-based Upcoming Tasks
  Widget _buildPriorityTasks(BuildContext context, HomeController controller,
      bool isDarkMode) {
    return Obx(
      () {
        if (controller.upcomingDeadlines.isEmpty) return const SizedBox.shrink();

        // Show only top 3 deadlines
        final topDeadlines =
            controller.upcomingDeadlines.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Deadlines',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showDeadlinesModal(context, controller, isDarkMode),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1F6FEB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(topDeadlines.length, (index) {
              final deadline = topDeadlines[index];
              final daysLeft = controller
                  .getDaysUntilDeadline(deadline['dueDate'].toString());
              final priorityColor = _getPriorityColor(
                  deadline['priority']?.toString() ?? 'low');

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: priorityColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: priorityColor.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          color: priorityColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deadline['title'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              deadline['course'].toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$daysLeft d',
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  /// Daily Tips Section
  Widget _buildDailyTips(BuildContext context, bool isDarkMode) {
    final tips = [
      '💡 Start assignments early to avoid last-minute stress',
      '⏰ Review your notes regularly for better retention',
      '🎯 Focus on one subject at a time for better focus',
      '📚 Take short breaks between study sessions',
      '✅ Track your progress to stay motivated',
    ];

    final randomTip = tips[(DateTime.now().day) % tips.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC107).withOpacity(0.2),
            const Color(0xFFFF9800).withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFFFC107),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Tip',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  randomTip,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced Quick Access
  Widget _buildEnhancedQuickAccess(BuildContext context,
      HomeController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: controller.quickAccessItems.map((item) {
            return _buildQuickAccessButton(
              context,
              item['title'].toString(),
              _getIconData(item['icon'].toString()),
              Color(item['color'] as int),
              () => controller.navigateToQuickAccess(item['route'].toString()),
              isDarkMode,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Quick Access Button
  Widget _buildQuickAccessButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeadlinesModal(
      BuildContext context, HomeController controller, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Upcoming Deadlines',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // All Deadlines List
              Obx(
                () {
                  if (controller.upcomingDeadlines.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No upcoming deadlines',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.upcomingDeadlines.length,
                    itemBuilder: (context, index) {
                      final deadline = controller.upcomingDeadlines[index];
                      final daysLeft = controller
                          .getDaysUntilDeadline(deadline['dueDate'].toString());
                      final priorityColor = _getPriorityColor(
                          deadline['priority']?.toString() ?? 'low');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: priorityColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.assignment_turned_in_rounded,
                                  color: priorityColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deadline['title'].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      deadline['course'].toString(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$daysLeft d',
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper: Convert icon string to IconData
  IconData _getIconData(String icon) {
    switch (icon) {
      case 'note':
        return Icons.note;
      case 'assignment':
        return Icons.assignment;
      case 'exam':
        return Icons.school;
      case 'resources':
        return Icons.folder;
      case 'video':
        return Icons.video_library;
      case 'dashboard':
        return Icons.dashboard;
      default:
        return Icons.help;
    }
  }

  /// Helper: Get priority color
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF5252);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'low':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF2196F3);
    }
  }
}
