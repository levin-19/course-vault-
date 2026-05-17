import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var notes = <Note>[].obs;
  var isLoading = false.obs;

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

  Future<void> createNote(String title, String content, String subject) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final noteId = _firestore.collection('notes').doc().id;
      final note = Note(
        id: noteId,
        userId: userId,
        title: title,
        content: content,
        subject: subject,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('notes').doc(noteId).set(note.toMap());
      notes.insert(0, note);
      Get.back();
      Get.snackbar('Success', 'Note created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create note: $e');
    }
  }

  Future<void> updateNote(String noteId, String title, String content, String subject) async {
    try {
      await _firestore.collection('notes').doc(noteId).update({
        'title': title,
        'content': content,
        'subject': subject,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      await fetchNotes();
      Get.back();
      Get.snackbar('Success', 'Note updated successfully');
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
