import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:healthcore/pages/auth/custom_sign_in_screen.dart';
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
        
        return const PermissionsView();
      },
    );
  }
}
