import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/stock_api.dart';
import '../theme/custom_theme.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _stocksData = [];

  @override
  void initState() {
    super.initState();
    _loadStockData();
    getUserData();
  }

  Future<void> getUserData() async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    DocumentSnapshot snapshot = await database.collection('users').doc(userEmail.toString()).get();
    setState(() {
      userData = snapshot.data() as Map<String, dynamic>?;
    });
  }

  Future<void> _loadStockData() async {
    final List<String> symbols = ['AMZN', 'GOOGL', 'AMD'];
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var symbol in symbols) {
      final String? stockDataString = prefs.getString(symbol);
      if (stockDataString != null) {
        final Map<String, dynamic> stockData = jsonDecode(stockDataString);
        setState(() {
          _stocksData.add({
            'symbol': symbol,
            'buy': stockData['buy'],
            'sell': stockData['sell'],
            'hold': stockData['hold'],
          });
        });
      } else {
        // If data is not available in SharedPreferences, fetch it
        _fetchStockData();
      }
    }
  }

  Future<void> _fetchStockData() async {
    final List<String> symbols = ['AMZN', 'GOOGL', 'AMD'];
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var symbol in symbols) {
      final String apiUrl =
          'https://finnhub.io/api/v1/stock/recommendation?symbol=$symbol&token=$STOCK_API_KEY';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final latestRecommendation = data.isNotEmpty ? data.last : null;
        if (latestRecommendation != null) {
          setState(() {
            _stocksData.add({
              'symbol': symbol,
              'buy': latestRecommendation['buy'] ?? 0,
              'sell': latestRecommendation['sell'] ?? 0,
              'hold': latestRecommendation['hold'] ?? 0,
            });
          });

          // Store the fetched data in SharedPreferences
          await prefs.setString(
              symbol,
              jsonEncode({
                'buy': latestRecommendation['buy'] ?? 0,
                'sell': latestRecommendation['sell'] ?? 0,
                'hold': latestRecommendation['hold'] ?? 0,
              }));
        } else {
          _showErrorSnackbar();
        }
      } else {
        print('Error: ${response.reasonPhrase}');
        _showErrorSnackbar();
      }
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error occurred. Please try again later.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCompanyInfoPopup(String symbol) async {
    // Fetch company information from Wikipedia API
    final String wikiApiUrl =
        'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro&explaintext&redirects=1&titles=$symbol';
    final response = await http.get(Uri.parse(wikiApiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body)['query']['pages'];
      final String pageTitle = data.keys.first;
      final String companyInfo = data[pageTitle]['extract'];

      // Limiting the content to 300 words of complete sentences
      final String truncatedInfo = _truncateCompanyInfo(companyInfo);

      // Navigate to the CompanyInfoScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompanyInfoScreen(companyInfo: truncatedInfo),
        ),
      );
    } else {
      print('Error fetching company information');
    }
  }

  String _truncateCompanyInfo(String info) {
    final List<String> sentences = info.split('. ');
    final StringBuffer buffer = StringBuffer();
    int wordCount = 0;
    for (final sentence in sentences) {
      if (wordCount + sentence.split(' ').length > 70) {
        break;
      }
      buffer.write(sentence);
      buffer.write('. ');
      wordCount += sentence.split(' ').length;
    }
    return buffer.toString();
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

  final user = FirebaseAuth.instance.currentUser;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  final database = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: CustomTheme.lightGray,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: CustomTheme.moonstone,
          foregroundColor: CustomTheme.richBlack,
          child: Icon(Icons.manage_accounts),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: CustomTheme.lightGray, // Custom background color
                  title: Text(
                      "Account Details",
                      style: GoogleFonts.montserrat(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: CustomTheme.richBlack
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
                                color: CustomTheme.richBlack
                            ) // Custom text color
                        ),
                        Text(
                            "Monthly Income: \$" + userData?.entries.elementAt(0).value ?? "",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: CustomTheme.richBlack
                            ) // Custom text color
                        ),
                        Text(
                            "Monthly Investment Fund: \$" + userData?.entries.elementAt(1).value ?? "",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: CustomTheme.richBlack
                            ) // Custom text color
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            "Powered by Finnhub and Gemini Pro",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomTheme.richBlack
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Good ${greeting()}'.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "STOCK RECOMMENDATIONS",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Divider(
                thickness: 2,
              ),
              ListView.builder(
                dragStartBehavior: DragStartBehavior.start,
                shrinkWrap: true,
                itemCount: _stocksData.length,
                itemBuilder: (context, index) {
                  final stock = _stocksData[index];
                  return GestureDetector(
                    onTap: () {
                      _showCompanyInfoPopup(stock['symbol']);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: CustomTheme.maastrichtBlue,
                      ),
                      child: ListTile(
                        title: Text(
                          stock['symbol'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.lightGray,
                          ),
                        ),
                        subtitle: Column(
                          children: [
                            Divider(),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'BUY',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                          color: CustomTheme.emeraldGreen,
                                        ),
                                      ),
                                      Text(
                                        "${stock['buy'] ?? 0}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: CustomTheme.emeraldGreen,
                                        ),
                                      ),

                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        'SELL',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                          color: CustomTheme.crimsonRed,
                                        ),
                                      ),
                                      Text(
                                        "${stock['sell'] ?? 0}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: CustomTheme.crimsonRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        'HOLD',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                          color: CustomTheme.gold,
                                        ),
                                      ),
                                      Text(
                                        "${stock['hold'] ?? 0}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: CustomTheme.gold,
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyInfoScreen extends StatelessWidget {
  final String companyInfo;

  const CompanyInfoScreen({Key? key, required this.companyInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: CustomTheme.lightGray,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 1.2 * kToolbarHeight, 10, 0),
          child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: CustomTheme.maastrichtBlue,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          "Information".toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.info,
                          size: 30,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Text(
                      companyInfo,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              )
          ),
        )
    );
  }
}
