import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthxp/components/icon_button_custom.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/pages/permissions/permissions_view.dart';

class CustomSignInScreen extends StatefulWidget {
  const CustomSignInScreen({super.key});

  @override
  State<CustomSignInScreen> createState() => _CustomSignInScreenState();
}

class _CustomSignInScreenState extends State<CustomSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailSignInLoading = false;
  bool _isGoogleSignInLoading = false;
  bool _isForgotPasswordLoading = false;
  bool _isRegistering = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEmailSignInLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, PermissionsView.routeName);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'user-not-found' => 'No user found with this email.',
          'wrong-password' => 'Wrong password provided.',
          'invalid-email' => 'Invalid email address.',
          _ => 'An error occurred. Please try again.',
        };
      });
    } finally {
      if (mounted) {
        setState(() {
          _isEmailSignInLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleSignInLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: "896043199805-p3gv6veoitiib3jqgmkl8825ihst51nv.apps.googleusercontent.com",
      ).signIn();

      if (googleUser == null) {
        setState(() {
          _isGoogleSignInLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacementNamed(context, PermissionsView.routeName);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSignInLoading = false;
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
                bottom: PaddingSizes.xlarge * 4, // Extra space for terms text
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: PaddingSizes.xlarge * 3),
                    child: Column(
                      children: [
                        Text(
                          'HealthCore',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: CoreColors.textColor,
                          ),
                        ),
                        const SizedBox(height: PaddingSizes.large),
                        Container(
                          width: 80,
                          height: 4,
                          decoration: BoxDecoration(
                            color: CoreColors.coreOrange,
                            borderRadius: BorderRadius.circular(BorderRadiusSizes.small),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                        // Welcome Text
                        Text(
                          _isRegistering ? 'Create Account' : 'Welcome back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CoreColors.textColor,
                          ),
                        ),
                        const SizedBox(height: GapSizes.small),
                        Text(
                          _isRegistering 
                              ? 'Please fill in your details to register'
                              : 'Please sign in to continue',
                          style: TextStyle(
                            color: CoreColors.textColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: PaddingSizes.xlarge),

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
                          child: Column(
                            children: [
                              TextFormField(
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
                                  return null;
                                },
                              ),
                              const SizedBox(height: PaddingSizes.xlarge),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: CoreColors.textColor.withOpacity(0.7),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: CoreColors.textColor.withOpacity(0.7),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        // Forgot Password Link
                        if (!_isRegistering) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isForgotPasswordLoading
                                  ? null
                                  : () async {
                                      if (_emailController.text.isEmpty) {
                                        setState(() {
                                          _errorMessage = 'Please enter your email address first';
                                        });
                                        return;
                                      }
                                      setState(() {
                                        _isForgotPasswordLoading = true;
                                        _errorMessage = null;
                                      });
                                      try {
                                        await FirebaseAuth.instance.sendPasswordResetEmail(
                                          email: _emailController.text.trim(),
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Password reset email sent'),
                                            ),
                                          );
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        setState(() {
                                          _errorMessage = switch (e.code) {
                                            'user-not-found' => 'No user found with this email.',
                                            'invalid-email' => 'Invalid email address.',
                                            _ => 'An error occurred. Please try again.',
                                          };
                                        });
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isForgotPasswordLoading = false;
                                          });
                                        }
                                      }
                                    },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                foregroundColor: CoreColors.textColor.withOpacity(0.7),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                textStyle: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: FontSizes.small,
                                ),
                              ).copyWith(
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                              ),
                              child: _isForgotPasswordLoading
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Forgot Password?'),
                            ),
                          ),
                          const SizedBox(height: PaddingSizes.xlarge),
                        ],
                        if(_isRegistering) ...[
                          const SizedBox(height: PaddingSizes.xlarge * 3),
                        ],

                        // Primary Action Button
                        IconButtonCustom(
                          label: _isRegistering ? 'Create Account' : 'Sign In',
                          icon: _isRegistering ? Icons.person_add : Icons.login,
                          onPressed: _isEmailSignInLoading
                              ? null
                              : () async {
                                  if (_isRegistering) {
                                    setState(() {
                                      _isEmailSignInLoading = true;
                                      _errorMessage = null;
                                    });
                                    try {
                                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      );
                                      if (mounted) {
                                        Navigator.pushReplacementNamed(context, PermissionsView.routeName);
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      setState(() {
                                        _errorMessage = switch (e.code) {
                                          'weak-password' => 'The password provided is too weak.',
                                          'email-already-in-use' => 'An account already exists for that email.',
                                          'invalid-email' => 'Invalid email address.',
                                          _ => 'An error occurred. Please try again.',
                                        };
                                      });
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isEmailSignInLoading = false;
                                        });
                                      }
                                    }
                                  } else {
                                    await _signInWithEmail();
                                  }
                                },
                          isLoading: _isEmailSignInLoading,
                          backgroundColor: CoreColors.coreOrange,
                        ),
                        const SizedBox(height: PaddingSizes.large),

                        // Google Sign In Button
                        if (!_isRegistering) ...[
                          IconButtonCustom(
                            label: 'Sign in with Google',
                            icon: Icons.g_mobiledata,
                            onPressed: _isGoogleSignInLoading ? null : _signInWithGoogle,
                            isLoading: _isGoogleSignInLoading,
                            backgroundColor: CoreColors.accentColor,
                          ),
                          const SizedBox(height: PaddingSizes.xlarge),
                        ],

                        // Toggle Register/Sign In
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isRegistering
                                    ? 'Already have an account? '
                                    : 'Don\'t have an account? ',
                                style: TextStyle(
                                  color: CoreColors.textColor.withOpacity(0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: (_isEmailSignInLoading || _isGoogleSignInLoading || _isForgotPasswordLoading)
                                    ? null
                                    : () {
                                        setState(() {
                                          _isRegistering = !_isRegistering;
                                          _errorMessage = null;
                                        });
                                      },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  foregroundColor: CoreColors.coreOrange,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  textStyle: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                                ),
                                child: Text(_isRegistering ? 'Sign In' : 'Create Account'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Terms Text - Positioned at bottom with proper margins
          Positioned(
            left: 0,
            right: 0,
            bottom: PaddingSizes.xxlarge,
            child: Container(
              width: formWidth,
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 
                    ? (MediaQuery.of(context).size.width - 500) / 2 
                    : MediaQuery.of(context).size.width * 0.075,
              ),
              padding: const EdgeInsets.symmetric(horizontal: PaddingSizes.xlarge),
              child: Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CoreColors.textColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
