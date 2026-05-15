import 'package:flutter/material.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    // For demo purposes, route to login screen
    // In real app, check authentication state from a controller
    return const LoginScreen();
  }
}
