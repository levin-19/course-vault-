import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notes_controller.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final controller = Get.find<NotesController>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.clearAttachments();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Note'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            // ── Attachment Section ──
            const Text(
              'Attachments (Multiple allowed, PDF/Images)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: controller.pickAttachments,
              icon: const Icon(Icons.attach_file, color: Colors.deepPurple),
              label: const Text(
                'Select Files to Attach',
                style: TextStyle(color: Colors.deepPurple),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.deepPurple),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            // ── Preview of Picked Files ──
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
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
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
                                        const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
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
                        // Close / Delete Button
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
                            contentController.text.isNotEmpty) {
                          controller.createNote(
                            titleController.text,
                            contentController.text,
                            subjectController.text,
                          );
                        } else {
                          Get.snackbar('Error', 'Please fill all fields');
                        }
                      },
                icon: controller.isUploading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                    controller.isUploading.value ? 'Uploading...' : 'Save Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    subjectController.dispose();
    super.dispose();
  }
}
