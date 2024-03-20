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
      final newUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
        MaterialPageRoute(builder: (context) => Navigation())
      );
    }
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
        backgroundColor: CustomTheme.lightGray,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: CustomTheme.lightGray,
          elevation: 0,
          systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(children: [
                  SizedBox(
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
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Predict | Invest | Save",
                    style: GoogleFonts.montserrat(
                        fontSize: 20, color: Colors.black),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Sign-up",
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                icon: Icon(Icons.email),
                                border: InputBorder.none,
                                hintText: "Email"),
                          ),
                        )),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: Icon(Icons.password),
                              border: InputBorder.none,
                              hintText: "Password",
                            ),
                          ),
                        )),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: Icon(Icons.password_outlined),
                              border: InputBorder.none,
                              hintText: "Confirm Password",
                            ),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Divider(),
                  SizedBox(
                    height: 14,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Here are a few questions that would help us personalize our stock recommendations:",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Choose your professional field:",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 3, 14, 3),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedProfession,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.black),
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
                              child: Text(value),
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
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Please provide your approximate monthly income in INR:",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            controller: _incomeController,
                            decoration: InputDecoration(
                                icon: Icon(Icons.currency_rupee),
                                border: InputBorder.none,
                            ),
                          ),
                        )),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "How much money do you plan to invest in stocks every month?",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 3, 14, 3),
                          child: TextField(
                            controller: _monthlyInvestmentController,
                            decoration: InputDecoration(
                                icon: Icon(Icons.currency_rupee),
                                border: InputBorder.none,
                            ),
                          ),
                        )),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.emeraldGreen,
                          foregroundColor: CustomTheme.richBlack,
                          fixedSize: Size(220, 10)
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
                  SizedBox(
                    height: 30,
                  )
                ]),
              ),
            )));
  }
}
