import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsage/theme/custom_theme.dart';

import '../navigation/navigation.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _incomeController = TextEditingController();
  final _monthlyInvestmentController = TextEditingController();

  var _selectedProfession = "Healthcare";

  Future signUp() async {
    if ((_passwordController.text.trim() == _confirmPasswordController.text.trim()) && _passwordController.text.trim().isNotEmpty) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      );

      CollectionReference usersCollection = _firestore.collection('users');

      await usersCollection.doc(_emailController.text.trim()).set({
        'email': _emailController.text.trim(),
        'income': _incomeController.text.trim(),
        'monthlyInvestment': _monthlyInvestmentController.text.trim(),
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navigation())
      );
    } else if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showPasswordMismatchAlert();
    } else if ((_passwordController.text.trim() == _confirmPasswordController.text.trim()) && _passwordController.text.trim().length < 8) {
      _showShortPasswordAlert();
    }
  }

  void _showPasswordMismatchAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Passwords do not match'),
          content: const Text('Please make sure the passwords match.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showShortPasswordAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Passwords too short'),
          content: const Text('Please make sure the password is at least 8 characters long.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _incomeController.dispose();
    _monthlyInvestmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: CustomTheme.richBlack,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    "./assets/images/logo.png",
                    height: 150,
                    width: 150,
                  ),
                  Text(
                    "FinSage",
                    style: GoogleFonts.montserrat(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Predict | Invest | Save",
                    style: GoogleFonts.montserrat(
                        fontSize: 20, color: Colors.white70),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Sign-up",
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.maastrichtBlue,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            cursorColor: Colors.white70,
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                icon: Icon(Icons.email, color: CustomTheme.emeraldGreen,),
                                border: InputBorder.none,
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    color: CustomTheme.neutralWhite
                                )
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.maastrichtBlue,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            cursorColor: Colors.white70,
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.password, color: CustomTheme.emeraldGreen,),
                              border: InputBorder.none,
                              hintText: "Password",
                                hintStyle: TextStyle(
                                    color: CustomTheme.neutralWhite
                                )
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.maastrichtBlue,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            cursorColor: Colors.white70,
                            controller: _confirmPasswordController,
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.password_outlined, color: CustomTheme.emeraldGreen,),
                              border: InputBorder.none,
                              hintText: "Confirm Password",
                                hintStyle: TextStyle(
                                    color: CustomTheme.neutralWhite
                                )
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 14,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Here are a few questions that would help us personalize our stock recommendations:",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          color: CustomTheme.neutralWhite
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Choose your professional field:",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CustomTheme.neutralWhite
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomTheme.maastrichtBlue,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 3, 14, 3),
                        child: DropdownButton<String>(
                          dropdownColor: CustomTheme.maastrichtBlue,
                          isExpanded: true,
                          value: _selectedProfession,
                          icon: const Icon(Icons.arrow_drop_down, color: CustomTheme.emeraldGreen,),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.black), // Set the text color here
                          underline: Container(
                            height: 0,
                            color: Colors.transparent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedProfession = newValue!;
                            });
                          },
                          items: <String>['Healthcare', 'Education', 'Information Technology', 'Business', 'Entertainment']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Container( // Wrap the DropdownMenuItem with Container
                                color: CustomTheme.maastrichtBlue, // Set the background color here
                                child: Text(
                                  value,
                                  style: GoogleFonts.poppins(
                                      color: CustomTheme.neutralWhite
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Please provide your approximate monthly income in USD:",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CustomTheme.neutralWhite
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.maastrichtBlue,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            cursorColor: Colors.white70,
                            controller: _incomeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                icon: Icon(Icons.monetization_on_outlined, color: CustomTheme.emeraldGreen,),
                                border: InputBorder.none,
                            ),
                          ),
                        )),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "How much money do you plan to invest in stocks every month?",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CustomTheme.neutralWhite
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.maastrichtBlue,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            cursorColor: Colors.white70,
                            style: const TextStyle(color: Colors.white),
                            controller: _monthlyInvestmentController,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.monetization_on_outlined, color: CustomTheme.emeraldGreen,),
                                border: InputBorder.none,
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.emeraldGreen,
                          foregroundColor: CustomTheme.richBlack,
                          fixedSize: const Size(220, 10)
                      ),
                      onPressed: () {
                        signUp();
                      },
                      child: Text(
                        "CREATE ACCOUNT",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ]),
              ),
            )));
  }
}
