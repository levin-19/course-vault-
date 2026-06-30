import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/assignment.dart';
import '../models/note.dart' show Attachment;
import '../models/picked_attachment.dart';

class AssignmentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var assignments = <Assignment>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  // Reactively track multiple selected attachments
  final selectedAttachments = <PickedAttachment>[].obs;

  RxList get pendingAssignments =>
      assignments.where((a) => a.status == 'pending').toList().obs;
  RxList get completedAssignments =>
      assignments.where((a) => a.status == 'completed').toList().obs;

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

      assignments.value =
          snapshot.docs.map((doc) => Assignment.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick multiple file attachments
  Future<void> pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
        withData: true, // Need data for previews/memory on web
      );
      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (!selectedAttachments.any((a) => a.name == file.name)) {
            selectedAttachments.add(PickedAttachment(
              name: file.name,
              path: file.path,
              bytes: file.bytes,
            ));
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick files: $e');
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < selectedAttachments.length) {
      selectedAttachments.removeAt(index);
    }
  }

  void clearAttachments() {
    selectedAttachments.clear();
  }

  Future<List<Attachment>> _uploadAllAttachments(String userId, String assignmentId) async {
    final List<Attachment> uploadedList = [];
    if (selectedAttachments.isEmpty) return uploadedList;

    try {
      isUploading.value = true;
      for (final item in selectedAttachments) {
        final storageRef = _storage
            .ref()
            .child('assignment_attachments')
            .child(userId)
            .child('${assignmentId}_${DateTime.now().millisecondsSinceEpoch}_${item.name}');

        UploadTask uploadTask;
        if (kIsWeb && item.bytes != null) {
          uploadTask = storageRef.putData(item.bytes!);
        } else if (!kIsWeb && item.path != null) {
          uploadTask = storageRef.putFile(File(item.path!));
        } else {
          continue;
        }

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedList.add(Attachment(name: item.name, url: downloadUrl));
      }
      return uploadedList;
    } catch (e) {
      debugPrint('Error uploading attachments: $e');
      Get.snackbar('Warning', 'Some attachments failed to upload');
      return uploadedList;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> createAssignment(
      String title, String course, String description, DateTime dueDate) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final assignmentId = _firestore.collection('assignments').doc().id;

      // Upload all attachments
      final uploadedAttachments = await _uploadAllAttachments(userId, assignmentId);

      final assignment = Assignment(
        id: assignmentId,
        userId: userId,
        title: title,
        course: course,
        description: description,
        dueDate: dueDate,
        status: 'pending',
        createdAt: DateTime.now(),
        // Keep single attachment fields populated with the first item for backwards compatibility
        attachmentUrl: uploadedAttachments.isNotEmpty ? uploadedAttachments.first.url : null,
        attachmentName: uploadedAttachments.isNotEmpty ? uploadedAttachments.first.name : null,
        attachments: uploadedAttachments,
      );

      await _firestore
          .collection('assignments')
          .doc(assignmentId)
          .set(assignment.toMap());
      assignments.add(assignment);
      clearAttachments();
      Get.back();
      Get.snackbar('Success', 'Assignment created successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create assignment: $e');
    }
  }

  Future<void> toggleStatus(String assignmentId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'pending' ? 'completed' : 'pending';
      await _firestore
          .collection('assignments')
          .doc(assignmentId)
          .update({'status': newStatus});

      final index = assignments.indexWhere((a) => a.id == assignmentId);
      if (index != -1) {
        final a = assignments[index];
        assignments[index] = Assignment(
          id: a.id,
          userId: a.userId,
          title: a.title,
          course: a.course,
          description: a.description,
          dueDate: a.dueDate,
          status: newStatus,
          createdAt: a.createdAt,
          attachmentUrl: a.attachmentUrl,
          attachmentName: a.attachmentName,
          attachments: a.attachments,
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
