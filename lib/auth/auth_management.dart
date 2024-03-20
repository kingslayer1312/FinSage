import 'package:finsage/navigation/navigation.dart';
import 'package:finsage/presentation/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthManagement extends StatelessWidget {
  const AuthManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Navigation();
          }
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}