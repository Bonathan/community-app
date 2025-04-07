import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app/login_screen.dart';
import '../app/home_screen.dart';
import '../app/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking auth state, show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // User is signed in
        if (snapshot.hasData) {
          return HomeScreen();
        }

        // User is NOT signed in
        return SplashScreen();
      },
    );
  }
}

String getCurrentUserId() {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid; // This is the user ID
  } else {
    throw Exception("No user is signed in");
  }
}
