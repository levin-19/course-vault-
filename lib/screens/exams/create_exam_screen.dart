import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exams_controller.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exam'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: examTypeController,
              decoration: const InputDecoration(
                labelText: 'Exam Type (e.g., Midterm, Final)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              leading: const Icon(Icons.calendar_today),
              title: Text(selectedDate == null ? 'Select Exam Date' : _formatDate(selectedDate!)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time (e.g., 10:00 AM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (subjectController.text.isNotEmpty &&
                    examTypeController.text.isNotEmpty &&
                    selectedDate != null &&
                    timeController.text.isNotEmpty &&
                    locationController.text.isNotEmpty) {
                  controller.createExam(
                    subjectController.text,
                    examTypeController.text,
                    selectedDate!,
                    timeController.text,
                    locationController.text,
                    notesController.text,
                  );
                } else {
                  Get.snackbar('Error', 'Please fill all required fields');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Add Exam'),
            ),
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
