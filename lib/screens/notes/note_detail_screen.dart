import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  void initState() {
    super.initState();
    note = Get.arguments as Note;
    titleController = TextEditingController(text: note.title);
    contentController = TextEditingController(text: note.content);
    subjectController = TextEditingController(text: note.subject);
  }

  @override
  Widget build(BuildContext context) {
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
