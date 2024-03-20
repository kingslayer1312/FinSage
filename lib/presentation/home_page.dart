import 'package:finsage/presentation/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            child: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: CustomTheme.maastrichtBlue, // Custom background color
                    title: Text("Signed in as:", style: TextStyle(color: CustomTheme.neutralWhite)), // Custom text color
                    content: Text(
                      user!.email.toString(),
                      style: TextStyle(color: CustomTheme.lightGray), // Custom text color
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
                      Text(
                        "user details comes here"
                      )
                    ]
                )
            )
        )
    );
  }
}