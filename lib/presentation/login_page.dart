import 'package:finsage/presentation/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsage/theme/custom_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim()
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    "Sign-In",
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
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.emeraldGreen,
                      foregroundColor: CustomTheme.richBlack,
                      fixedSize: Size(150, 10)
                    ),
                      onPressed: () {
                        signIn();
                      },
                      child: Text(
                        "PROCEED",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,

                        ),
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Not a member yet?"),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage())
                        );
                      },
                      child: Text(
                        "Create an account now!"
                      )
                  )
                ]),
              ),
            )));
  }
}

