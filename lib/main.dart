import 'package:blue_notification/models/theme.dart';
import 'package:blue_notification/services/auth_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Make sure Firebase is initialized
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);  // Optional: enable persistence
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Demo',
      theme: theme,
      home: AuthWrapper(),
    );
  }
}
