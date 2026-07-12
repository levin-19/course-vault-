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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColors = isDarkMode
        ? const [Color(0xFF081120), Color(0xFF0E1728), Color(0xFF111B31)]
        : const [Color(0xFFF3F7FC), Color(0xFFEAF2FF), Color(0xFFFDFEFF)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getTimeBasedGreeting(),
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your command center for notes, tasks, and progress',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF5C6F86),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: () => Get.toNamed('/profile'),
              child: Obx(() {
                final avatarUrl = controller.currentUser.value?.avatarUrl;
                return Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF66A6FF), Color(0xFF6B5CE7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        isDarkMode ? const Color(0xFF101929) : Colors.white,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? const Icon(Icons.person_rounded,
                            color: Color(0xFF1F6FEB))
                        : null,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      body: Obx(
        () => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: backgroundColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90,
                left: -45,
                child: _buildGlow(const Color(0xFF66A6FF).withOpacity(0.30), 190),
              ),
              Positioned(
                top: 180,
                right: -70,
                child: _buildGlow(const Color(0xFF7C5FD4).withOpacity(0.20), 220),
              ),
              Positioned(
                bottom: 120,
                left: -55,
                child: _buildGlow(const Color(0xFFFFB86B).withOpacity(0.16), 180),
              ),
              SafeArea(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => controller.refreshDashboard(),
                        backgroundColor: const Color(0xFF1F6FEB),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEnhancedProfileHeader(context, isDarkMode, controller),
                              const SizedBox(height: 18),
                              _buildAcademicProgress(context, controller, isDarkMode),
                              const SizedBox(height: 18),
                              _buildStudySchedule(context, controller, isDarkMode),
                              const SizedBox(height: 18),
                              _buildEnhancedMetrics(context, controller, isDarkMode),
                              const SizedBox(height: 18),
                              _buildPriorityTasks(context, controller, isDarkMode),
                              const SizedBox(height: 18),
                              _buildDailyTips(context, isDarkMode),
                              const SizedBox(height: 18),
                              _buildEnhancedQuickAccess(context, controller, isDarkMode),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  /// Enhanced Profile Header with Gradient
  Widget _buildEnhancedProfileHeader(
      BuildContext context, bool isDarkMode, HomeController controller) {
    return Obx(
      () {
        final user = controller.currentUser.value;
        final name = user?.fullName ?? 'Student';
        final avatarUrl = user?.avatarUrl;
        final initials = name.trim().isNotEmpty
            ? name.trim().characters.first.toUpperCase()
            : 'S';

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF11284B), Color(0xFF1A57C8), Color(0xFF7C5FD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A57C8).withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -16,
                top: -24,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                left: -28,
                bottom: -36,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.18),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.25), width: 1),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white.withOpacity(0.18),
                            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const Spacer(),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white.withOpacity(0.14),
                        //     borderRadius: BorderRadius.circular(999),
                        //     border: Border.all(
                        //       color: Colors.white.withOpacity(0.16),
                        //       width: 1,
                        //     ),
                        //   ),
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                        //       const SizedBox(width: 6),
                        //       Text(
                        //         'Live',
                        //         style: TextStyle(
                        //           color: Colors.white.withOpacity(0.95),
                        //           fontSize: 11,
                        //           fontWeight: FontWeight.w700,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${user?.department ?? 'Department'} • Semester ${user?.semester ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildHeroStat(
                            'GPA',
                            '${(controller.userStats['gpa'] as num).toDouble().toStringAsFixed(2)}',
                            Icons.auto_graph_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildHeroStat(
                            'Tasks',
                            '${controller.userStats['pendingAssignments']}',
                            Icons.task_alt_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF101929) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF1F6FEB).withOpacity(0.10),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
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
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your current GPA arc',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white60 : const Color(0xFF6A7D93),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3CCF91), Color(0xFF20A7A6)],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3CCF91).withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      '${gpa.toStringAsFixed(2)}/4.0',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1A2435) : const Color(0xFFE4ECF5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: (gpaPercentage / 100).clamp(0.0, 1.0),
                      child: Container(
                        height: 14,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1F6FEB), Color(0xFF7C5FD4)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Steady, polished, and improving',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white60 : const Color(0xFF6A7D93),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${gpaPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                      fontWeight: FontWeight.w800,
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isUrgent
                  ? [const Color(0xFFFF6A6A), const Color(0xFFFF2E7E)]
                  : [const Color(0xFF1F6FEB), const Color(0xFF7C5FD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: (isUrgent ? const Color(0xFFFF6A6A) : const Color(0xFF1F6FEB))
                    .withOpacity(0.28),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isUrgent ? Icons.priority_high_rounded : Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isUrgent ? 'Urgent Deadline' : 'Next Deadline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  nextDeadline['title'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nextDeadline['course'].toString(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.84),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$daysLeft day${daysLeft != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : const Color(0xFF10223A),
              ),
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.08,
            children: [
              _buildEnhancedMetricCard(
                context,
                'Completed',
                '${controller.userStats['completedAssignments']}',
                Icons.check_circle_outline_rounded,
                const Color(0xFF3CCF91),
                isDarkMode,
              ),
              _buildEnhancedMetricCard(
                context,
                'Pending',
                '${controller.userStats['pendingAssignments']}',
                Icons.pending_actions_rounded,
                const Color(0xFFFFA726),
                isDarkMode,
              ),
              _buildEnhancedMetricCard(
                context,
                'Upcoming Exams',
                '${controller.userStats['upcomingExams']}',
                Icons.menu_book_rounded,
                const Color(0xFF4EA1FF),
                isDarkMode,
              ),
              _buildEnhancedMetricCard(
                context,
                'Completion',
                '${((controller.userStats['completedAssignments'] as int) / (((controller.userStats['completedAssignments'] as int) + (controller.userStats['pendingAssignments'] as int)).clamp(1, 1 << 30)) * 100).toStringAsFixed(0)}%',
                Icons.trending_up_rounded,
                const Color(0xFF8E6CF7),
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
        color: isDarkMode ? const Color(0xFF101929) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.25), color.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white60 : const Color(0xFF6A7D93),
                  fontWeight: FontWeight.w600,
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
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showDeadlinesModal(context, controller, isDarkMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F6FEB).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1F6FEB),
                          fontWeight: FontWeight.w700,
                        ),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF101929) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: priorityColor.withOpacity(0.18),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: priorityColor.withOpacity(0.14),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [priorityColor.withOpacity(0.24), priorityColor.withOpacity(0.10)],
                          ),
                          borderRadius: BorderRadius.circular(16),
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
                                color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              deadline['course'].toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode ? Colors.white60 : const Color(0xFF6A7D93),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
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
      'Start assignments early to avoid last-minute stress',
      'Review your notes regularly for better retention',
      'Focus on one subject at a time for better concentration',
      'Take short breaks between study sessions',
      'Track your progress to stay motivated',
    ];

    final randomTip = tips[(DateTime.now().day) % tips.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD56A).withOpacity(0.35),
            const Color(0xFFFF9E5D).withOpacity(0.20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFC857).withOpacity(0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB84D).withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFFFF8F00),
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
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    randomTip,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF4E6075),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF10223A),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
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
          color: isDarkMode ? const Color(0xFF101929) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.16),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.24), color.withOpacity(0.10)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
