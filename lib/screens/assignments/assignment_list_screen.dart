import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/assignments_controller.dart';

class AssignmentListScreen extends StatelessWidget {
  const AssignmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssignmentsController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColors = isDarkMode
        ? const [Color(0xFF08111F), Color(0xFF111A2D), Color(0xFF151E35)]
        : const [Color(0xFFF6F9FF), Color(0xFFEAF1FF), Color(0xFFFFFFFF)];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          toolbarHeight: 76,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Assignments',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Track deadlines with a premium workspace',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF65788F),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => Get.toNamed('/create-assignment'),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6FEB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: isDarkMode
                      ? Colors.white.withAlpha((0.06 * 255).round())
                      : Colors.white.withAlpha((0.72 * 255).round()),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDarkMode
                      ? Colors.white.withAlpha((0.08 * 255).round())
                      : Colors.white.withAlpha((0.55 * 255).round()),
                  ),
                  boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(((isDarkMode ? 0.22 : 0.08) * 255).round()),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: TabBar(
                  labelColor: isDarkMode ? Colors.white : const Color(0xFF10223A),
                  unselectedLabelColor:
                      isDarkMode ? Colors.white60 : const Color(0xFF66788D),
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F6FEB), Color(0xFF7C5FD4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F6FEB).withAlpha((0.25 * 255).round()),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Pending'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          return Container(
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
                  top: -80,
                  left: -40,
                  child: _buildGlow(const Color(0xFF66A6FF).withAlpha((0.26 * 255).round()), 190),
                ),
                Positioned(
                  top: 120,
                  right: -60,
                  child: _buildGlow(const Color(0xFFFFA24A).withAlpha((0.18 * 255).round()), 220),
                ),
                SafeArea(
                  child: controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => controller.fetchAssignments(),
                          color: Colors.white,
                          backgroundColor: const Color(0xFF1F6FEB),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                                child: _buildSummaryCard(context, controller, isDarkMode),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildAssignmentList(controller,
                                        controller.pendingAssignments, const Color(0xFFFFA726), isDarkMode),
                                    _buildAssignmentList(controller,
                                        controller.completedAssignments, const Color(0xFF3CCF91), isDarkMode),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed('/create-assignment'),
          backgroundColor: const Color(0xFF1F6FEB),
          foregroundColor: Colors.white,
          elevation: 8,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAssignmentList(
      AssignmentsController controller,
      RxList assignments,
      Color statusColor,
      bool isDarkMode) {
    if (assignments.isEmpty) {
      return _buildEmptyState(
        isDarkMode: isDarkMode,
        color: statusColor,
        label: statusColor == const Color(0xFF3CCF91)
            ? 'No completed assignments yet'
            : 'No pending assignments right now',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final fileAttachments = assignment.attachments;
        return _buildAssignmentCard(
          context,
          assignment: assignment,
          attachments: fileAttachments,
          controller: controller,
          statusColor: statusColor,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AssignmentsController controller,
    bool isDarkMode,
  ) {
    final total = controller.assignments.length;
    final completed = controller.assignments.where((a) => a.status == 'completed').length;
    final progress = total == 0 ? 0.0 : completed / total;
    final pending = total - completed;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF11284B),
                const Color(0xFF1F6FEB),
                const Color(0xFF7C5FD4).withAlpha((0.94 * 255).round()),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withAlpha((0.12 * 255).round()),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F6FEB).withAlpha((0.28 * 255).round()),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha((0.10 * 255).round()),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.14 * 255).round()),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall completion',
                              style: TextStyle(
                                color: Colors.white.withAlpha((0.92 * 255).round()),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completed of $total finished',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
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
                            color: Colors.white.withAlpha((0.16 * 255).round()),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 14,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF3CCF91), Color(0xFF1F6FEB)],
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
                      _buildSummaryChip('Pending $pending', Colors.white),
                      _buildSummaryChip('${(progress * 100).toStringAsFixed(0)}%', Colors.white),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.14 * 255).round()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha((0.12 * 255).round()), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDarkMode,
    required Color color,
    required String label,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF101929) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withAlpha((0.14 * 255).round()),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha((0.12 * 255).round()),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withAlpha((0.28 * 255).round()), color.withAlpha((0.10 * 255).round())],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: color,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new assignment to start tracking deadlines and progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color(0xFF65788F),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/create-assignment'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Assignment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6FEB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context, {
    required dynamic assignment,
    required List attachments,
    required AssignmentsController controller,
    required Color statusColor,
    required bool isDarkMode,
  }) {
    final dueDate = _formatDate(assignment.dueDate);
    final isPending = assignment.status == 'pending';
    final attachmentCount = attachments.length;

    return InkWell(
      onTap: () => Get.toNamed('/create-assignment'),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF101929) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: statusColor.withAlpha((0.16 * 255).round()),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withAlpha((0.14 * 255).round()),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withAlpha((0.10 * 255).round()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor.withAlpha((0.28 * 255).round()), statusColor.withAlpha((0.10 * 255).round())],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          isPending ? Icons.assignment_turned_in_rounded : Icons.done_all_rounded,
                          color: statusColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    assignment.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => controller.toggleStatus(
                                      assignment.id, assignment.status),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha((0.10 * 255).round()),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isPending
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.undo_rounded,
                                      color: statusColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => controller.deleteAssignment(assignment.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5A6A).withAlpha((0.10 * 255).round()),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFFF5A6A),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildTag(assignment.course, statusColor),
                                _buildTag('Due $dueDate', isDarkMode ? Colors.white54 : const Color(0xFF65788F)),
                                _buildTag(isPending ? 'Pending' : 'Completed', statusColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    assignment.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF5E7086),
                    ),
                  ),
                  if (attachmentCount > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withAlpha((0.04 * 255).round())
                            : const Color(0xFFF7FAFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withAlpha((0.12 * 255).round()),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_file_rounded, size: 16, color: statusColor),
                              const SizedBox(width: 6),
                              Text(
                                '$attachmentCount attachment${attachmentCount == 1 ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.white70 : const Color(0xFF10223A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: attachments.map<Widget>((attachment) {
                              return InkWell(
                                onTap: () => _openAttachment(attachment.url),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        statusColor.withAlpha((0.18 * 255).round()),
                                        statusColor.withAlpha((0.08 * 255).round()),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: statusColor.withAlpha((0.16 * 255).round()),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.insert_drive_file_outlined,
                                          size: 13, color: statusColor),
                                      const SizedBox(width: 6),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 140),
                                        child: Text(
                                          attachment.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.open_in_new_rounded, size: 12, color: statusColor),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
            ),
          );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withAlpha((0.16 * 255).round()),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
          colors: [color, color.withAlpha(0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Cannot open attachment');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open attachment');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
