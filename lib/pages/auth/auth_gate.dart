import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
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
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: "896043199805-p3gv6veoitiib3jqgmkl8825ihst51nv.apps.googleusercontent.com")
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/logo-1024.png',
                    width: constraints.maxWidth * 0.8,  // 80% of screen width
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          );
        }

        return const PermissionsView();
      },
    );
  }
}
