import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exams_controller.dart';
import '../../config/app_colors.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final controller = Get.find<ExamsController>();
  final subjectController = TextEditingController();
  final examTypeController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Add Exam'),
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((0.16 * 255).round()), blurRadius: 26, offset: const Offset(0, 14))],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withAlpha((0.08 * 255).round()), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.school, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Create Exam', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('Add schedule details and location', style: TextStyle(color: AppColors.white.withAlpha((0.9 * 255).round()), fontSize: 13))])),
              ]),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: examTypeController,
                    decoration: const InputDecoration(labelText: 'Exam Type (e.g., Midterm, Final)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: isDark ? const Color(0xFF0D1622) : AppColors.extraLightGrey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: Icon(Icons.calendar_today, color: AppColors.secondary),
                    title: Text(selectedDate == null ? 'Select Exam Date' : _formatDate(selectedDate!)),
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (date != null) setState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time (e.g., 10:00 AM)', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder(), alignLabelWithHint: true)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (subjectController.text.isNotEmpty && examTypeController.text.isNotEmpty && selectedDate != null && timeController.text.isNotEmpty && locationController.text.isNotEmpty) {
                        controller.createExam(subjectController.text, examTypeController.text, selectedDate!, timeController.text, locationController.text, notesController.text);
                      } else {
                        Get.snackbar('Error', 'Please fill all required fields');
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Add Exam'),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    subjectController.dispose();
    examTypeController.dispose();
    timeController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
