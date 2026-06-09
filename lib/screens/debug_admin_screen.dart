import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Debug screen to test and verify admin status
class DebugAdminScreen extends StatefulWidget {
  const DebugAdminScreen({super.key});

  @override
  State<DebugAdminScreen> createState() => _DebugAdminScreenState();
}

class _DebugAdminScreenState extends State<DebugAdminScreen> {
  String userId = '';
  String userEmail = '';
  String roleValue = 'Loading...';
  bool isAdmin = false;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  Future<void> checkStatus() async {
    setState(() => isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        setState(() {
          userId = 'Not logged in';
          userEmail = 'Not logged in';
          roleValue = 'N/A';
          isAdmin = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        userId = user.uid;
        userEmail = user.email ?? 'No email';
      });

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userData = data;
          roleValue = data?['role']?.toString() ?? 'No role field';
          isAdmin = roleValue == 'admin';
          isLoading = false;
        });
      } else {
        setState(() {
          roleValue = 'Document does not exist';
          isAdmin = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        roleValue = 'Error: $e';
        isAdmin = false;
        isLoading = false;
      });
    }
  }

  Future<void> makeCurrentUserAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'No user logged in');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'role': 'admin'}, SetOptions(merge: true));

      Get.snackbar(
        'Success',
        'Admin role added! Refreshing...',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(seconds: 1));
      checkStatus();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to set admin: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Admin Debug Tool'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    color: isAdmin ? Colors.green[50] : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isAdmin ? Icons.check_circle : Icons.cancel,
                                color: isAdmin ? Colors.green : Colors.red,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isAdmin ? 'ADMIN ACCESS' : 'NOT ADMIN',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isAdmin ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Info
                  _buildInfoSection('User Information', [
                    _buildInfoRow('User ID', userId),
                    _buildInfoRow('Email', userEmail),
                    _buildInfoRow('Role', roleValue),
                  ]),

                  const SizedBox(height: 20),

                  // Full User Data
                  _buildInfoSection('Full User Document', [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userData?.toString() ?? 'No data',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Actions
                  _buildInfoSection('Quick Actions', [
                    ElevatedButton.icon(
                      onPressed: checkStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: makeCurrentUserAdmin,
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Make Me Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isAdmin)
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/admin'),
                        icon: const Icon(Icons.dashboard),
                        label: const Text('Go to Admin Dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                  ]),

                  const SizedBox(height: 20),

                  // Instructions
                  Card(
                    color: Colors.blue[50],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'How to Fix',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '1. Click "Make Me Admin" button above',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '2. Or manually add in Firebase Console:\n'
                            '   • Go to Firestore Database\n'
                            '   • Collection: users\n'
                            '   • Find your document\n'
                            '   • Add field: role = "admin"',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '3. Click "Refresh Status" to verify',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
