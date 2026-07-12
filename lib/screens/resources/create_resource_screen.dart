import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/resources_controller.dart';
import '../../config/app_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Resource'),
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF071022), const Color(0xFF0B1620)]
                : [AppColors.backgroundColor, AppColors.extraLightGrey],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF08121A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withAlpha((0.08 * 255).round())),
                        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((0.08 * 255).round()), blurRadius: 30, offset: const Offset(0, 18))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [AppColors.primary.withAlpha((0.26 * 255).round()), AppColors.secondary.withAlpha((0.12 * 255).round())], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.library_add, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text('Add New Resource', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Title
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Title *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.title),
                              filled: true,
                              fillColor: isDark ? Colors.white.withAlpha((0.02 * 255).round()) : AppColors.extraLightGrey,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Category + URL row
                           DropdownButtonFormField<String>(
                             value: selectedCategory,
                             decoration: InputDecoration(
                               labelText: 'Category',
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                               prefixIcon: const Icon(Icons.category),
                               filled: true,
                               fillColor: isDark ? Colors.white.withAlpha((0.02 * 255).round()) : AppColors.extraLightGrey,
                             ),
                             items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                             onChanged: (value) => setState(() => selectedCategory = value!),
                           ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: urlController,
                                decoration: InputDecoration(
                                  labelText: 'Resource URL *',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  hintText: 'https://example.com',
                                  prefixIcon: const Icon(Icons.link),
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withAlpha((0.02 * 255).round()) : AppColors.extraLightGrey,
                                ),
                                keyboardType: TextInputType.url,
                              ),
                            

                          if (selectedCategory == 'Video') ...[
                            const SizedBox(height: 14),
                            TextField(
                              controller: videoUrlController,
                              decoration: InputDecoration(
                                labelText: 'Video URL (optional)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                hintText: 'https://youtube.com/watch?v=...',
                                prefixIcon: const Icon(Icons.video_library, color: Colors.red),
                                filled: true,
                                fillColor: isDark ? Colors.white.withAlpha((0.02 * 255).round()) : AppColors.extraLightGrey,
                              ),
                              keyboardType: TextInputType.url,
                            ),
                          ],

                          const SizedBox(height: 14),
                          TextField(
                            controller: descriptionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Description (optional)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: isDark ? Colors.white.withAlpha((0.02 * 255).round()) : AppColors.extraLightGrey,
                            ),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                                      controller.createResource(
                                        titleController.text,
                                        urlController.text,
                                        selectedCategory,
                                        descriptionController.text,
                                        videoUrl: selectedCategory == 'Video' && videoUrlController.text.isNotEmpty ? videoUrlController.text : null,
                                      );
                                      Get.back();
                                    } else {
                                      Get.snackbar('Error', 'Please fill required fields');
                                    }
                                  },
                                  icon: const Icon(Icons.save),
                                  label: const Text('Save Resource'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 52),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
