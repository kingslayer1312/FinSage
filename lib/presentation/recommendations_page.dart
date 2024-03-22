import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsage/theme/custom_theme.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});
  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
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
                    child: Column(
                        children: [
                          Text(
                            "Recommendations Page",
                            style: GoogleFonts.montserrat(
                                fontSize: 20
                            ),
                          )
                        ]
                    )
                )
            )
        )
    );
  }
}