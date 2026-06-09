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
        
        // If user is logged in, check if admin
        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _checkIfAdmin(snapshot.data!.uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              // If admin, show admin dashboard
              if (adminSnapshot.data == true) {
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

  /// Check if user is admin
  Future<bool> _checkIfAdmin(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final role = doc.data()?['role'] ?? 'user';
        return role == 'admin';
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
