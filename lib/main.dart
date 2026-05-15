import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/theme.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize UserService
  Get.put(UserService());

  runApp(const CourseVaultApp());
}

class CourseVaultApp extends StatelessWidget {
  const CourseVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CourseVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      initialRoute: '/login',
      getPages: [
        GetPage(name: LoginScreen.routeName, page: () => const LoginScreen()),
        GetPage(name: SignupScreen.routeName, page: () => const SignupScreen()),
        GetPage(name: HomeScreen.routeName, page: () => const HomeScreen()),
        GetPage(name: ProfileScreen.routeName, page: () => const ProfileScreen()),
        GetPage(name: AuthGate.routeName, page: () => const AuthGate()),
      ],
      home: const AuthGate(),
    );
  }
}
