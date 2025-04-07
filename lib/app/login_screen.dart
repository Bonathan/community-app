import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool isLogin = true;
  String? error;

  @override
  void initState() {
    super.initState();
    testFirestoreConnection();  // Call the test function here
  }

  Future<void> testFirestoreConnection() async {
    try {
      // Simple test to write data to Firestore
      await FirebaseFirestore.instance.collection('test').doc('testDoc').set({
        'field': 'value',
      });
      print('Firestore connection works!');
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to show Snackbar with error message
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 8.0// Inner padding for SnackBar content.
        ),
        behavior: SnackBarBehavior.floating,

      ),
    );
  }

  Future<void> _submit() async {
    setState(() => error = null);

    if (_formKey.currentState?.validate() ?? false) {
      // Only proceed if form is valid
      try {
        if (isLogin) {
          // Login existing user
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          if (mounted) {
            Navigator.of(context).pop(); // ⬅️ This removes LoginScreen
          }
        } else {
          // Register new user
          UserCredential cred = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // Create Firestore user profile
          if (cred.user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(cred.user!.uid)
                .set({
              'email': cred.user!.email,
              'name': _nameController.text.trim(),
              'roles': ['member'],
              'signedUpEvents': [],
            });
            print('Firestore user doc created for ${cred.user!.uid}');
          }
        }
      } catch (e) {
        setState(() => error = e.toString());
        _showErrorSnackbar(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment(value: true, label: Text('Login')),
                ButtonSegment(value: false, label: Text('Register')),
              ],
              selected: <bool>{isLogin},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  isLogin = newSelection.first;
                });
              },
              showSelectedIcon: false,
            ),
          ),
          Padding(
            padding:EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  if (!isLogin)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  if (!isLogin)
                    SizedBox(height: 10),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // You can add more email validation here if needed
                      return null;
                    },
                  ),

                  SizedBox(height: 10),

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(isLogin ? 'Login' : 'Register'),
                  ),
                ],
              )
            )
          )
        ],
      )
    );
  }
}
