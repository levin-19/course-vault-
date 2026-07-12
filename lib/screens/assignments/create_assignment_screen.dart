import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/assignments_controller.dart';
import '../../config/app_colors.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final controller = Get.find<AssignmentsController>();
  final titleController = TextEditingController();
  final courseController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    controller.clearAttachments();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Assignment'),
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Assignment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Create and attach resources for this task', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: isDarkMode ? Colors.grey[850] : AppColors.extraLightGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Icon(Icons.calendar_today, color: AppColors.secondary),
              title: Text(selectedDate == null ? 'Select Due Date' : _formatDate(selectedDate!)),
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
            const SizedBox(height: 20),
            // ── Attachment Section ──
            const Text(
              'Attachments (Multiple allowed)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: controller.pickAttachments,
              icon: const Icon(Icons.attach_file, color: Colors.white),
              label: const Text('Select Files to Attach', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            // ── Preview of Selected Files ──
            Obx(() {
              if (controller.selectedAttachments.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                height: 110,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedAttachments.length,
                  itemBuilder: (context, index) {
                    final item = controller.selectedAttachments[index];
                    return Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          margin: const EdgeInsets.only(right: 12, top: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[850] : AppColors.extraLightGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.secondary.withOpacity(0.28)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.isImage
                                ? (kIsWeb
                                    ? Image.memory(item.bytes!, fit: BoxFit.cover)
                                    : Image.file(File(item.path!), fit: BoxFit.cover))
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.insert_drive_file, color: Colors.orange, size: 36),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        // Remove button
                        Positioned(
                          right: 4,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => controller.removeAttachment(index),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red[700],
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isUploading.value
                    ? null
                    : () {
                        if (titleController.text.isNotEmpty &&
                            courseController.text.isNotEmpty &&
                            selectedDate != null) {
                          controller.createAssignment(
                            titleController.text,
                            courseController.text,
                            descriptionController.text,
                            selectedDate!,
                          );
                        } else {
                          Get.snackbar('Error', 'Please fill all required fields');
                        }
                      },
                icon: controller.isUploading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: Text(controller.isUploading.value ? 'Uploading...' : 'Create Assignment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    )
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
    titleController.dispose();
    courseController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
