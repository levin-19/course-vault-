import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        
        // If user is logged in, check role
        if (snapshot.hasData) {
          return FutureBuilder<String>(
            future: _getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              // If admin, show admin dashboard
              if (roleSnapshot.data == 'admin') {
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

  /// Get and validate user role
  Future<String> _getUserRole(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final role = doc.data()?['role'];
        if (role == 'admin') {
          return 'admin';
        } else if (role == 'student') {
          return 'student';
        } else {
          // Update missing or invalid role to student
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'role': 'student'});
          return 'student';
        }
      }
      
      // Document doesn't exist, create it with student role
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'uid': userId,
        'role': 'student',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return 'student';
    } catch (e) {
      print('Error checking user role: $e');
      return 'student';
    }
  }
}
