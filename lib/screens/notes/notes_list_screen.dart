import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notes_controller.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No notes yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('Tap + to create your first note', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.note, color: Colors.white),
                ),
                title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${note.subject} • ${_formatDate(note.createdAt)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, controller, note.id),
                ),
                onTap: () => Get.toNamed('/note-detail', arguments: note),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-note'),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, NotesController controller, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteNote(noteId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
