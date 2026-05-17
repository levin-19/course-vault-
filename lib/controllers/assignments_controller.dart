import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/assignment.dart';

class AssignmentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var assignments = <Assignment>[].obs;
  var isLoading = false.obs;

  RxList get pendingAssignments => assignments.where((a) => a.status == 'pending').toList().obs;
  RxList get completedAssignments => assignments.where((a) => a.status == 'completed').toList().obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('assignments')
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate', descending: false)
          .get();

      assignments.value = snapshot.docs.map((doc) => Assignment.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAssignment(String title, String course, String description, DateTime dueDate) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final assignmentId = _firestore.collection('assignments').doc().id;
      final assignment = Assignment(
        id: assignmentId,
        userId: userId,
        title: title,
        course: course,
        description: description,
        dueDate: dueDate,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('assignments').doc(assignmentId).set(assignment.toMap());
      assignments.add(assignment);
      Get.back();
      Get.snackbar('Success', 'Assignment created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create assignment: $e');
    }
  }

  Future<void> toggleStatus(String assignmentId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'pending' ? 'completed' : 'pending';
      await _firestore.collection('assignments').doc(assignmentId).update({'status': newStatus});
      
      final index = assignments.indexWhere((a) => a.id == assignmentId);
      if (index != -1) {
        final assignment = assignments[index];
        assignments[index] = Assignment(
          id: assignment.id,
          userId: assignment.userId,
          title: assignment.title,
          course: assignment.course,
          description: assignment.description,
          dueDate: assignment.dueDate,
          status: newStatus,
          createdAt: assignment.createdAt,
        );
      }
      Get.snackbar('Success', 'Status updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).delete();
      assignments.removeWhere((a) => a.id == assignmentId);
      Get.snackbar('Success', 'Assignment deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete assignment: $e');
    }
  }
}
