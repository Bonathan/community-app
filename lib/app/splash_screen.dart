import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_rounded,
              size: 120,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please continue in order to log in or sign up.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
