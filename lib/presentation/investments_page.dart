import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsage/theme/custom_theme.dart';

class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({super.key});
  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {

          },
          foregroundColor: CustomTheme.gold,
          backgroundColor: CustomTheme.maastrichtBlue,
          child: const Icon(Icons.add, weight: 3,),
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: CustomTheme.lightGray,
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
                child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "investments".toUpperCase(),
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