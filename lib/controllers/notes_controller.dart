import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/note.dart';
import '../models/picked_attachment.dart';

class NotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var notes = <Note>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  // Reactively track multiple selected attachments for create/edit
  final selectedAttachments = <PickedAttachment>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      notes.value = snapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick multiple files for attachment
  Future<void> pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: true,
        withData: true, // Need data for previews/memory on web
      );
      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          // Avoid duplicate selection of the same filename
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

  /// Upload all selected attachments to Firebase Storage and return list of Attachment models
  Future<List<Attachment>> _uploadAllAttachments(String userId, String noteId) async {
    final List<Attachment> uploadedList = [];
    if (selectedAttachments.isEmpty) return uploadedList;

    try {
      isUploading.value = true;
      for (final item in selectedAttachments) {
        final ext = item.name.split('.').last;
        final storageRef = _storage
            .ref()
            .child('note_attachments')
            .child(userId)
            .child('${noteId}_${DateTime.now().millisecondsSinceEpoch}_${item.name}');

        UploadTask uploadTask;
        if (kIsWeb && item.bytes != null) {
          uploadTask = storageRef.putData(
            item.bytes!,
            SettableMetadata(contentType: _getMimeType(ext)),
          );
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

  String _getMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> createNote(String title, String content, String subject) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final noteId = _firestore.collection('notes').doc().id;

      // Upload attachments
      final uploadedAttachments = await _uploadAllAttachments(userId, noteId);

      final note = Note(
        id: noteId,
        userId: userId,
        title: title,
        content: content,
        subject: subject,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Keep single attachment fields populated with the first item for backwards compatibility
        attachmentUrl: uploadedAttachments.isNotEmpty ? uploadedAttachments.first.url : null,
        attachmentName: uploadedAttachments.isNotEmpty ? uploadedAttachments.first.name : null,
        attachments: uploadedAttachments,
      );

      await _firestore.collection('notes').doc(noteId).set(note.toMap());
      notes.insert(0, note);
      clearAttachments();
      Get.back();
      Get.snackbar('Success', 'Note created successfully',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } catch (e) {
      Get.snackbar('Error', 'Failed to create note: $e');
    }
  }

  Future<void> updateNote(
      String noteId, String title, String content, String subject,
      {required List<Attachment> existingAttachments}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Upload new attachments if any
      final newUploaded = await _uploadAllAttachments(userId, noteId);
      final finalAttachments = [...existingAttachments, ...newUploaded];

      final updateData = {
        'title': title,
        'content': content,
        'subject': subject,
        'updatedAt': DateTime.now().toIso8601String(),
        'attachmentUrl': finalAttachments.isNotEmpty ? finalAttachments.first.url : null,
        'attachmentName': finalAttachments.isNotEmpty ? finalAttachments.first.name : null,
        'attachments': finalAttachments.map((a) => a.toMap()).toList(),
      };

      await _firestore.collection('notes').doc(noteId).update(updateData);

      clearAttachments();
      await fetchNotes();
      Get.back();
      Get.snackbar('Success', 'Note updated successfully',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF));
    } catch (e) {
      Get.snackbar('Error', 'Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
      notes.removeWhere((note) => note.id == noteId);
      Get.snackbar('Success', 'Note deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete note: $e');
    }
  }
}
