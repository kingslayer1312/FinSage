import 'package:finsage/api/firebase_api.dart';
import 'package:finsage/auth/auth_management.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: API_KEY,
        appId: APP_ID,
        messagingSenderId: MESSAGING_SENDER_ID,
        projectId: PROJECT_ID
    )
  );
  runApp(const FinSage());
}

class FinSage extends StatelessWidget {
  const FinSage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthManagement()
    );
  }
}