import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/resource.dart';

class ResourcesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var resources = <Resource>[].obs;
  var isLoading = false.obs;

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

      resources.value = snapshot.docs.map((doc) => Resource.fromMap(doc.data())).toList();
    } catch (e) {
            debugPrint('Error fetching exams: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createResource(String title, String url, String category, String description) async {
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
      );

      await _firestore.collection('resources').doc(resourceId).set(resource.toMap());
      resources.insert(0, resource);
      Get.back();
      Get.snackbar('Success', 'Resource saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save resource: $e');
    }
  }

  Future<void> deleteResource(String resourceId) async {
    try {
      await _firestore.collection('resources').doc(resourceId).delete();
      resources.removeWhere((r) => r.id == resourceId);
      Get.snackbar('Success', 'Resource deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete resource: $e');
    }
  }
}
