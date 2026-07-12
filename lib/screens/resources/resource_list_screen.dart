import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/resources_controller.dart';
import '../../models/resource.dart';
import '../../config/app_colors.dart';

class ResourceListScreen extends StatelessWidget {
  const ResourceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResourcesController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Resource Hub'),
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF071022), const Color(0xFF0D1724)]
                : [AppColors.backgroundColor, AppColors.extraLightGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha((0.18 * 255).round()),
                          AppColors.secondary.withAlpha((0.12 * 255).round())
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha((0.06 * 255).round())),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha((0.12 * 255).round()),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.06 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.folder, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Resource Hub', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                              SizedBox(height: 4),
                              Text('Browse and manage study materials', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.toNamed('/create-resource'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text('Add')),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Category Filter Chips
            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: controller.categories.map((category) {
                      final isSelected = controller.selectedCategory.value == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => controller.setCategory(category),
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
                          backgroundColor: isDark ? Colors.white.withAlpha((0x0F * 255).round()) : AppColors.extraLightGrey,
                        ),
                      );
                    }).toList(),
                  ),
                )),

            // Resource List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.filteredResources.isEmpty) return Center(child: _buildEmptyState(isDark: isDark));
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: controller.filteredResources.length,
                  itemBuilder: (context, index) {
                    final resource = controller.filteredResources[index];
                    return _buildResourceCard(context, resource, controller, isDark);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-resource'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, Resource resource, ResourcesController controller, bool isDark) {
    final categoryColor = _getCategoryColor(resource.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF071422) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withAlpha((0.12 * 255).round())),
        boxShadow: [BoxShadow(color: categoryColor.withAlpha((0.06 * 255).round()), blurRadius: 16, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: categoryColor.withAlpha((0.15 * 255).round()), borderRadius: BorderRadius.circular(10)),
                child: Icon(_getCategoryIcon(resource.category), color: categoryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: categoryColor.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(8)),
                      child: Text(resource.category, style: TextStyle(fontSize: 11, color: categoryColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), tooltip: 'Edit', onPressed: () => _showEditDialog(context, resource, controller)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Delete', onPressed: () => _confirmDelete(context, resource.id, controller)),
                ],
              ),
            ],
          ),
          if (resource.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(resource.description, style: TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => controller.openUrl(resource.url),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open Link'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: categoryColor,
                  side: BorderSide(color: categoryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              if (resource.videoUrl != null && resource.videoUrl!.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => controller.openUrl(resource.videoUrl!),
                  icon: const Icon(Icons.video_library, size: 16),
                  label: const Text('Watch Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101929) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha((0.14 * 255).round()), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha((0.10 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withAlpha((0.28 * 255).round()), AppColors.secondary.withAlpha((0.10 * 255).round())],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.folder_open, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              'No Resources',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF10223A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first study resource to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF65788F),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/create-resource'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Resource'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Resource resource, ResourcesController controller) {
    final titleCtrl = TextEditingController(text: resource.title);
    final urlCtrl = TextEditingController(text: resource.url);
    final videoUrlCtrl = TextEditingController(text: resource.videoUrl ?? '');
    final descCtrl = TextEditingController(text: resource.description);
    String category = resource.category;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Resource'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Resource URL',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                if (category == 'Video') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: videoUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Video URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.video_library, color: Colors.red),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.updateResource(
                  resource.id,
                  titleCtrl.text,
                  urlCtrl.text,
                  category,
                  descCtrl.text,
                  videoUrl: category == 'Video' && videoUrlCtrl.text.isNotEmpty ? videoUrlCtrl.text : null,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String resourceId, ResourcesController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resource'),
        content: const Text('Are you sure you want to delete this resource?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.deleteResource(resourceId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'video':
        return Colors.red;
      case 'article':
        return Colors.blue;
      case 'tutorial':
        return Colors.orange;
      case 'documentation':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'video':
        return Icons.video_library;
      case 'article':
        return Icons.article;
      case 'tutorial':
        return Icons.school;
      case 'documentation':
        return Icons.description;
      default:
        return Icons.link;
    }
  }
}
