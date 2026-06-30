import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // If user is logged in, check role and status
        if (snapshot.hasData) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _getUserRoleAndStatus(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              final status = roleSnapshot.data?['status'] ?? 'active';
              if (status == 'suspended') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FirebaseAuth.instance.signOut();
                  Get.snackbar(
                    'Suspended',
                    'Your account has been suspended by the administrator.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                });
                return const LoginScreen();
              }
              
              final role = roleSnapshot.data?['role'] ?? 'student';
              
              // If admin, show admin dashboard
              if (role == 'admin') {
                return const AdminDashboardScreen();
              }
              
              // Otherwise show regular home screen
              return const HomeScreen();
            },
          );
        }
        
        // Otherwise show login screen
        return const LoginScreen();
      },
    );
  }

  /// Get and validate user role and status
  Future<Map<String, dynamic>> _getUserRoleAndStatus(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() ?? {};
        final role = data['role'] ?? 'student';
        final status = data['status'] ?? 'active';
        return {'role': role, 'status': status};
      }
      
      // Document doesn't exist, create it with student role
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'uid': userId,
        'role': 'student',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return {'role': 'student', 'status': 'active'};
    } catch (e) {
      print('Error checking user role and status: $e');
      return {'role': 'student', 'status': 'active'};
    }
  }
}
