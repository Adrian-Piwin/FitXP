import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthcore/components/icon_button_custom.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/pages/auth/forgot_password_screen.dart';
import 'package:healthcore/pages/auth/auth_gate.dart';

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
        Navigator.pushReplacementNamed(context, AuthGate.routeName);
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
        Navigator.pushReplacementNamed(context, AuthGate.routeName);
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
                top: PaddingSizes.xlarge * 2,
                bottom: PaddingSizes.xlarge * 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: PaddingSizes.xlarge * 2, top: PaddingSizes.xlarge),
                    child: Column(
                      children: [
                        Text(
                          'HealthCore',
                          style: TextStyle(
                            fontSize: screenSize.width > 600 ? 40 : 32,
                            fontWeight: FontWeight.bold,
                            color: CoreColors.textColor,
                          ),
                        ),
                        const SizedBox(height: PaddingSizes.medium),
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
                    padding: EdgeInsets.all(screenSize.width > 600 ? PaddingSizes.xlarge * 1.5 : PaddingSizes.xlarge),
                    margin: const EdgeInsets.symmetric(horizontal: PaddingSizes.medium),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotPasswordScreen(),
                                  ),
                                );
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
                                overlayColor: WidgetStateProperty.all(Colors.transparent),
                              ),
                              child: const Text('Forgot Password?'),
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
                                      if (context.mounted) {
                                        Navigator.pushReplacementNamed(context, AuthGate.routeName);
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
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isRegistering
                                      ? 'Already have an account? '
                                      : 'Don\'t have an account? ',
                                  style: TextStyle(
                                    color: CoreColors.textColor.withOpacity(0.7),
                                    fontSize: screenSize.width > 600 ? FontSizes.medium : FontSizes.small,
                                  ),
                                ),
                                TextButton(
                                  onPressed: (_isEmailSignInLoading || _isGoogleSignInLoading)
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
                                    textStyle: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: screenSize.width > 600 ? FontSizes.medium : FontSizes.small,
                                    ),
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                                  ),
                                  child: Text(_isRegistering ? 'Sign In' : 'Create Account'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Terms Text - Positioned below the form card
                  Padding(
                    padding: EdgeInsets.only(
                      top: PaddingSizes.xxxlarge,
                      bottom: PaddingSizes.xlarge,
                      left: PaddingSizes.xxxlarge,
                      right: PaddingSizes.xxxlarge,
                    ),
                    child: Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CoreColors.textColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
