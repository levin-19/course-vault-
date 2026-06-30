import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/resources_controller.dart';

class CreateResourceScreen extends StatefulWidget {
  const CreateResourceScreen({super.key});

  @override
  State<CreateResourceScreen> createState() => _CreateResourceScreenState();
}

class _CreateResourceScreenState extends State<CreateResourceScreen> {
  final controller = Get.find<ResourcesController>();
  final titleController = TextEditingController();
  final urlController = TextEditingController();
  final videoUrlController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedCategory = 'Article';
  final categories = [
    'Video',
    'Article',
    'Tutorial',
    'Documentation',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Resource'),
        backgroundColor: Colors.green,
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
                labelText: 'Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                    value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Resource URL *',
                border: OutlineInputBorder(),
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            if (selectedCategory == 'Video') ...[
              const SizedBox(height: 16),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'https://youtube.com/watch?v=...',
                  prefixIcon: Icon(Icons.video_library, color: Colors.red),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    urlController.text.isNotEmpty) {
                  controller.createResource(
                    titleController.text,
                    urlController.text,
                    selectedCategory,
                    descriptionController.text,
                    videoUrl: selectedCategory == 'Video' &&
                            videoUrlController.text.isNotEmpty
                        ? videoUrlController.text
                        : null,
                  );
                } else {
                  Get.snackbar('Error', 'Please fill required fields');
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Resource'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
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
    urlController.dispose();
    videoUrlController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
