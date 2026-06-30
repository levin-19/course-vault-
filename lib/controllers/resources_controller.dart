import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resource.dart';

class ResourcesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var resources = <Resource>[].obs;
  var filteredResources = <Resource>[].obs;
  var isLoading = false.obs;
  var selectedCategory = 'All'.obs;

  final categories = ['All', 'Video', 'Article', 'Tutorial', 'Documentation', 'Other'];

  @override
  void onInit() {
    super.onInit();
    fetchResources();
  }

  Future<void> fetchResources() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('resources')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      resources.value =
          snapshot.docs.map((doc) => Resource.fromMap(doc.data())).toList();
      _applyFilter();
    } catch (e) {
      debugPrint('Error fetching resources: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedCategory.value == 'All') {
      filteredResources.value = resources;
    } else {
      filteredResources.value = resources
          .where((r) =>
              r.category.toLowerCase() ==
              selectedCategory.value.toLowerCase())
          .toList();
    }
  }

  Future<void> createResource(
      String title, String url, String category, String description,
      {String? videoUrl}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final resourceId = _firestore.collection('resources').doc().id;
      final resource = Resource(
        id: resourceId,
        userId: userId,
        title: title,
        url: url,
        category: category,
        description: description,
        createdAt: DateTime.now(),
        videoUrl: videoUrl,
      );

      await _firestore
          .collection('resources')
          .doc(resourceId)
          .set(resource.toMap());
      resources.insert(0, resource);
      _applyFilter();
      Get.back();
      Get.snackbar('Success', 'Resource saved successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save resource: $e');
    }
  }

  Future<void> updateResource(
    String resourceId,
    String title,
    String url,
    String category,
    String description, {
    String? videoUrl,
  }) async {
    try {
      final updateData = {
        'title': title,
        'url': url,
        'category': category,
        'description': description,
        'videoUrl': videoUrl,
      };

      await _firestore
          .collection('resources')
          .doc(resourceId)
          .update(updateData);

      final index = resources.indexWhere((r) => r.id == resourceId);
      if (index != -1) {
        final existing = resources[index];
        resources[index] = Resource(
          id: existing.id,
          userId: existing.userId,
          title: title,
          url: url,
          category: category,
          description: description,
          createdAt: existing.createdAt,
          videoUrl: videoUrl,
        );
        _applyFilter();
      }

      Get.back();
      Get.snackbar('Success', 'Resource updated successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update resource: $e');
    }
  }

  Future<void> deleteResource(String resourceId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();
      resources.removeWhere((r) => r.id == resourceId);
      _applyFilter();
      Get.snackbar('Success', 'Resource deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete resource: $e');
    }
  }

  /// Open a URL externally using url_launcher
  Future<void> openUrl(String url) async {
    if (url.isEmpty) {
      Get.snackbar('Error', 'No URL provided');
      return;
    }
    try {
      String fullUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        fullUrl = 'https://$url';
      }
      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open URL: $fullUrl');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open URL: $e');
    }
  }
}
