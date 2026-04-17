import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _seeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final AuthProvider authProvider = context.read<AuthProvider>();
    final bool success = await authProvider.updateProfile(
      name: _nameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    final String message = success
        ? 'Profile updated successfully.'
        : (authProvider.errorMessage ?? 'Failed to update profile.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    if (success) {
      _passwordController.clear();
    }
  }

  Future<void> _logout() async {
    final AuthProvider authProvider = context.read<AuthProvider>();
    await authProvider.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final user = authProvider.appUser;

    if (!_seeded && user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _seeded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: <Widget>[
          TextButton(
            onPressed: authProvider.isLoading ? null : _logout,
            child: const Text('Logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        constraints.maxWidth > 600 ? 500 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: const Color(0xFFD9E8FF),
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null
                                ? const Icon(Icons.person,
                                    size: 48, color: Color(0xFF1F6FEB))
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: 'Name',
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          readOnly: true,
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'New Password (Optional)',
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            final String input = (value ?? '').trim();
                            if (input.isNotEmpty && input.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'Save Changes',
                          isLoading: authProvider.isLoading,
                          onPressed: _saveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
