import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exams_controller.dart';
import '../../config/app_colors.dart';

class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExamsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? const [Color(0xFF071024), Color(0xFF0D1726)]
        : const [Color(0xFFF6F9FF), Color(0xFFEAF1FF)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Exam Schedule'),
        foregroundColor: AppColors.textPrimary,
      ),
      body: Obx(() {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: bg, begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Stack(
            children: [
              Positioned(top: -80, left: -40, child: _buildGlow(const Color(0xFF66A6FF).withAlpha((0.22 * 255).round()), 180)),
              Positioned(top: 120, right: -60, child: _buildGlow(const Color(0xFF7C5FD4).withAlpha((0.16 * 255).round()), 220)),
              SafeArea(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => controller.fetchExams(),
                        color: AppColors.primary,
                        backgroundColor: AppColors.primary.withAlpha((0x14 * 255).round()),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildHeader(controller, isDark),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: controller.exams.isEmpty
                                  ? _buildEmpty(controller, isDark)
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                      itemCount: controller.exams.length,
                                      itemBuilder: (context, index) {
                                        final exam = controller.exams[index];
                                        return _buildExamCard(exam, controller, isDark);
                                      },
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
        onPressed: () => Get.toNamed('/create-exam'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(ExamsController controller, bool isDark) {
    final total = controller.exams.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary.withAlpha((0.18 * 255).round()), AppColors.secondary.withAlpha((0.12 * 255).round())], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
            boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((0.14 * 255).round()), blurRadius: 20, offset: const Offset(0, 12))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withAlpha((0.06 * 255).round()), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.school, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Upcoming Exams', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('$total scheduled', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              ),
              ElevatedButton(
                onPressed: () => Get.toNamed('/create-exam'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text('Add Exam')),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ExamsController controller, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF0B1724) : Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((0.12 * 255).round()), blurRadius: 24, offset: const Offset(0, 14))]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withAlpha((0.28 * 255).round()), AppColors.secondary.withAlpha((0.10 * 255).round())]), borderRadius: BorderRadius.circular(22)), child: Icon(Icons.school_outlined, color: AppColors.white, size: 48)),
            const SizedBox(height: 16),
            Text('No exams scheduled', style: TextStyle(fontSize: 18, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Tap + to add an exam', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: () => Get.toNamed('/create-exam'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Create Exam'))
          ]),
        ),
      ),
    );
  }

  Widget _buildExamCard(dynamic exam, ExamsController controller, bool isDark) {
    return InkWell(
      onTap: () => Get.toNamed('/create-exam'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF071422) : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.primary.withAlpha((0.08 * 255).round())), boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((0.10 * 255).round()), blurRadius: 20, offset: const Offset(0, 12))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withAlpha((0.18 * 255).round()), AppColors.secondary.withAlpha((0.12 * 255).round())]), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.school, color: AppColors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(exam.subject, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)), const SizedBox(height: 4), Text(exam.examType, style: TextStyle(color: AppColors.textSecondary))])),
            IconButton(onPressed: () => controller.deleteExam(exam.id), icon: Icon(Icons.delete_outline, color: const Color(0xFFFF5A6A))),
          ]),
          const SizedBox(height: 12),
          Row(children: [Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary), const SizedBox(width: 8), Text(_formatDate(exam.examDate), style: TextStyle(color: AppColors.textPrimary)), const SizedBox(width: 20), Icon(Icons.access_time, size: 14, color: AppColors.textSecondary), const SizedBox(width: 8), Text(exam.time, style: TextStyle(color: AppColors.textPrimary))]),
          const SizedBox(height: 8),
          Row(children: [Icon(Icons.location_on, size: 14, color: AppColors.textSecondary), const SizedBox(width: 8), Expanded(child: Text(exam.location, style: TextStyle(color: AppColors.textPrimary)))]),
          if (exam.notes.isNotEmpty) ...[const SizedBox(height: 8), Text(exam.notes, style: TextStyle(color: AppColors.textSecondary))]
        ]),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withAlpha(0)], stops: const [0.0, 1.0]),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
