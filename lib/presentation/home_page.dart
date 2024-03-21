import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finsage/presentation/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsage/theme/custom_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final user = FirebaseAuth.instance.currentUser;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  final database = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    DocumentSnapshot snapshot = await database.collection('users').doc(userEmail.toString()).get();
    setState(() {
      userData = snapshot.data() as Map<String, dynamic>?;
    });
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: CustomTheme.lightGray,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle:
              const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: CustomTheme.maastrichtBlue,
            foregroundColor: CustomTheme.lightGray,
            child: Icon(Icons.manage_accounts),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: CustomTheme.maastrichtBlue, // Custom background color
                    title: Text(
                        "Account Details",
                        style: GoogleFonts.montserrat(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: CustomTheme.lightGray
                        )
                    ), // Custom text color
                    content: Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email: " + user!.email.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: CustomTheme.lightGray
                            ) // Custom text color
                          ),
                          Text(
                              "Monthly Income: ₹" + userData?.entries.elementAt(0).value ?? "",
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: CustomTheme.lightGray
                              ) // Custom text color
                          ),
                          Text(
                              "Monthly Investment Fund: ₹" + userData?.entries.elementAt(1).value ?? "",
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: CustomTheme.lightGray
                              ) // Custom text color
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.moonstone, // Custom button background color
                        ),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage())
                          );
                        },
                        child: Text("Sign Out", style: TextStyle(color: Colors.black)), // Custom text color
                      ),
                    ],
                  );
                },
              );
            }
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 0),
            child: SingleChildScrollView(
                child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Good ${greeting()}".toUpperCase(),
                        style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ]
                )
            )
        )
    );
  }
}