import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/services/user_service.dart';
import 'package:healthcore/services/error_logger.service.dart';
import 'package:healthcore/pages/settings/change_password_page.dart';

class AccountManagementPage extends StatefulWidget {
  static const routeName = '/account-management';
  
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final _userService = UserService();
  final _auth = FirebaseAuth.instance;

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    bool isPasswordEmpty = true;
    
    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                const Text('Please enter your current password to confirm:'),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      isPasswordEmpty = value.isEmpty;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Current Password',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isPasswordEmpty
                    ? null
                    : () async {
                        try {
                          // Delete user data from Firestore
                          await _userService.deleteUserData();

                          // Delete the account
                          await _auth.currentUser?.delete();

                          if (!mounted) return;
                          
                          // Sign out to clear any remaining auth state
                          await _auth.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                          }
                        } catch (e) {
                          if (!mounted) return;
                          
                          String errorMessage = 'An error occurred while deleting your account.';
                          if (e is FirebaseAuthException) {
                            errorMessage = switch (e.code) {
                              'requires-recent-login' => 'Please sign in again to delete your account.',
                              'invalid-credential' => 'Incorrect password. Please try again.',
                              _ => 'Unable to delete account. Please try again later.',
                            };
                          }
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: CoreColors.errorColor,
                              ),
                            );
                          }
                          await ErrorLogger.logError('Error deleting account: $e');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete Account'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () => Navigator.pushNamed(context, ChangePasswordPage.routeName),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            subtitle: const Text('This action cannot be undone'),
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
} 
