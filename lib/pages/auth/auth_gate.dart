import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:healthcore/pages/auth/custom_sign_in_screen.dart';
import 'package:healthcore/pages/onboarding/onboarding_controller.dart';
import 'package:healthcore/services/user_service.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import '../permissions/permissions_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const routeName = "/";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CustomSignInScreen();
        }
        
        // Identify user with Superwall when app starts with an existing authenticated user
        final user = snapshot.data;
        if (user != null) {
          Superwall.shared.identify(user.uid);
        }
        
        return FutureBuilder<bool>(
          future: UserService().hasCompletedOnboarding(),
          builder: (context, onboardingSnapshot) {
            // Show a loading indicator while checking onboarding status
            if (!onboardingSnapshot.hasData) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // If onboarding is not completed, navigate to the onboarding flow
            if (!onboardingSnapshot.data!) {
              return const OnboardingController();
            }
            
            // If onboarding is completed, proceed to permissions screen
            return const PermissionsView();
          },
        );
      },
    );
  }
}
