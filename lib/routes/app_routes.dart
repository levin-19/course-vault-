import 'package:get/get.dart';
import '../screens/auth_gate.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_profile_screen.dart';
import '../screens/debug_admin_screen.dart';
import '../screens/users_list_screen.dart';
import '../screens/user_details_screen.dart';
import '../screens/notes/notes_list_screen.dart';
import '../screens/notes/note_detail_screen.dart';
import '../screens/notes/create_note_screen.dart';
import '../screens/assignments/assignment_list_screen.dart';
import '../screens/assignments/create_assignment_screen.dart';
import '../screens/exams/exam_list_screen.dart';
import '../screens/exams/create_exam_screen.dart';
import '../screens/resources/resource_list_screen.dart';
import '../screens/resources/create_resource_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => const SplashScreen()),
    GetPage(name: '/auth', page: () => const AuthGate()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/signup', page: () => const SignupScreen()),
    GetPage(name: '/home', page: () => const HomeScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(name: '/admin', page: () => const AdminScreen()),
    GetPage(name: '/admin-dashboard', page: () => const AdminDashboardScreen()),
    GetPage(name: '/admin-profile', page: () => const AdminProfileScreen()),
    GetPage(name: '/debug-admin', page: () => const DebugAdminScreen()),
    GetPage(name: '/users-list', page: () => const UsersListScreen()),
    GetPage(name: '/user-details', page: () => const UserDetailsScreen()),
    GetPage(name: '/notes', page: () => const NotesListScreen()),
    GetPage(name: '/note-detail', page: () => const NoteDetailScreen()),
    GetPage(name: '/create-note', page: () => const CreateNoteScreen()),
    GetPage(name: '/assignments', page: () => const AssignmentListScreen()),
    GetPage(name: '/create-assignment', page: () => const CreateAssignmentScreen()),
    GetPage(name: '/exams', page: () => const ExamListScreen()),
    GetPage(name: '/create-exam', page: () => const CreateExamScreen()),
    GetPage(name: '/resources', page: () => const ResourceListScreen()),
    GetPage(name: '/create-resource', page: () => const CreateResourceScreen()),
  ];
}
