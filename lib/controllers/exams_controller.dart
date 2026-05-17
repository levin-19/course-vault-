import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exam.dart';

class ExamsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var exams = <Exam>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExams();
  }

  Future<void> fetchExams() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('exams')
          .where('userId', isEqualTo: userId)
          .orderBy('examDate', descending: false)
          .get();

      exams.value = snapshot.docs.map((doc) => Exam.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching exams: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createExam(String subject, String examType, DateTime examDate, String time, String location, String notes) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final examId = _firestore.collection('exams').doc().id;
      final exam = Exam(
        id: examId,
        userId: userId,
        subject: subject,
        examType: examType,
        examDate: examDate,
        time: time,
        location: location,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('exams').doc(examId).set(exam.toMap());
      exams.add(exam);
      Get.back();
      Get.snackbar('Success', 'Exam added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create exam: $e');
    }
  }

  Future<void> deleteExam(String examId) async {
    try {
      await _firestore.collection('exams').doc(examId).delete();
      exams.removeWhere((e) => e.id == examId);
      Get.snackbar('Success', 'Exam deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete exam: $e');
    }
  }
}
