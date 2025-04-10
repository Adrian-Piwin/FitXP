import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/components/icon_button_custom.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';
  
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resetEmailSent = false;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _resetEmailSent = true;
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = switch (e.code) {
            'user-not-found' => 'No user found with this email.',
            'invalid-email' => 'Invalid email address.',
            _ => 'An error occurred. Please try again.',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final formWidth = screenSize.width > 600 ? 500.0 : screenSize.width * 0.85;

    return Scaffold(
      backgroundColor: CoreColors.backgroundColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: PaddingSizes.xlarge * 3,
                bottom: PaddingSizes.xlarge * 4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Form Card
                  Container(
                    width: formWidth,
                    padding: const EdgeInsets.all(PaddingSizes.xlarge * 1.5),
                    margin: const EdgeInsets.symmetric(horizontal: PaddingSizes.xlarge),
                    decoration: BoxDecoration(
                      color: CoreColors.foregroundColor,
                      borderRadius: BorderRadius.circular(BorderRadiusSizes.large),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Instruction Text
                        Text(
                          'Forgot Your Password?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CoreColors.textColor,
                          ),
                        ),
                        const SizedBox(height: GapSizes.small),
                        Text(
                          'Enter your email address and we\'ll send you a link to reset your password.',
                          style: TextStyle(
                            color: CoreColors.textColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: PaddingSizes.xlarge),

                        // Success Message
                        if (_resetEmailSent) ...[
                          Container(
                            padding: const EdgeInsets.all(PaddingSizes.medium),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: IconSizes.medium,
                                ),
                                const SizedBox(width: GapSizes.medium),
                                Expanded(
                                  child: Text(
                                    'Password reset email sent successfully! Please check your inbox.',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: FontSizes.medium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: PaddingSizes.xlarge),
                        ],

                        // Error Message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(PaddingSizes.medium),
                            decoration: BoxDecoration(
                              color: CoreColors.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                              border: Border.all(
                                color: CoreColors.errorColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: CoreColors.errorColor,
                                  size: IconSizes.medium,
                                ),
                                const SizedBox(width: GapSizes.medium),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: CoreColors.errorColor,
                                      fontSize: FontSizes.medium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: PaddingSizes.xlarge),
                        ],

                        // Form Fields
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: CoreColors.textColor.withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              // Basic email validation
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: PaddingSizes.xlarge * 2),

                        // Reset Password Button
                        IconButtonCustom(
                          label: 'Send Reset Link',
                          icon: Icons.send,
                          onPressed: _isLoading ? null : _sendPasswordResetEmail,
                          isLoading: _isLoading,
                          backgroundColor: CoreColors.coreOrange,
                        ),
                        const SizedBox(height: PaddingSizes.large),

                        // Back to Sign In
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: CoreColors.coreOrange,
                              backgroundColor: Colors.transparent,
                            ),
                            child: const Text('Back to Sign In'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: CoreColors.textColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
