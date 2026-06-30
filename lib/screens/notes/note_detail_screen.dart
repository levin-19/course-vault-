import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/notes_controller.dart';
import '../../models/note.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final controller = Get.find<NotesController>();
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController subjectController;
  late Note note;
  bool isEditing = false;
  late List<Attachment> currentAttachments;

  @override
  void initState() {
    super.initState();
    note = Get.arguments as Note;
    titleController = TextEditingController(text: note.title);
    contentController = TextEditingController(text: note.content);
    subjectController = TextEditingController(text: note.subject);
    currentAttachments = List<Attachment>.from(note.attachments);
    controller.clearAttachments();
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
      Get.snackbar('Error', 'Failed to open attachment: $e');
    }
  }

  void _removeExistingAttachment(int index) {
    setState(() {
      currentAttachments.removeAt(index);
    });
  }

  bool _isImageFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Note Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                controller.updateNote(
                  note.id,
                  titleController.text,
                  contentController.text,
                  subjectController.text,
                  existingAttachments: currentAttachments,
                );
              }
              setState(() => isEditing = !isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              enabled: isEditing,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subjectController,
              enabled: isEditing,
              decoration: InputDecoration(
                hintText: 'Subject',
                border: isEditing ? const OutlineInputBorder() : InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              enabled: isEditing,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Content',
                border: isEditing ? const OutlineInputBorder() : InputBorder.none,
              ),
            ),
            const SizedBox(height: 24),
            // ── Attachments Header ──
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // ── Existing Attachments ──
            if (currentAttachments.isNotEmpty) ...[
              const Text(
                'Current Attached Files (Tap to open/download):',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentAttachments.length,
                  itemBuilder: (context, index) {
                    final item = currentAttachments[index];
                    final isImg = _isImageFile(item.name);
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _openAttachment(item.url),
                          child: Container(
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
                              child: isImg
                                  ? Image.network(item.url, fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Icon(Icons.broken_image));
                                    })
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
                        ),
                        if (isEditing)
                          Positioned(
                            right: 4,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _removeExistingAttachment(index),
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
              ),
            ] else if (!isEditing) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No attached files.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            ],
            // ── Edit/Add More Attachments ──
            if (isEditing) ...[
              const SizedBox(height: 16),
              const Text(
                'Add More Attachments:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: controller.pickAttachments,
                icon: const Icon(Icons.attach_file, color: Colors.deepPurple),
                label: const Text('Select More Files', style: TextStyle(color: Colors.deepPurple)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple),
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.selectedAttachments.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 110,
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
            ],
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
