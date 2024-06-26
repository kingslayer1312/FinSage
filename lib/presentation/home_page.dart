import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/stock_api.dart';
import '../theme/custom_theme.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _stocksData = [];

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
      const SnackBar(
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

      // Push the CompanyInfoScreen only for the selected symbol
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompanyInfoScreen(
            companyInfo: truncatedInfo,
            symbol: symbol,
          ),
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
      backgroundColor: CustomTheme.richBlack,
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
        child: const Icon(Icons.manage_accounts),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: CustomTheme.lightGray,
                title: Text(
                  "Account Details",
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: CustomTheme.richBlack,
                  ),
                ),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email: ${user!.email}",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: CustomTheme.richBlack,
                          ),
                        ),
                        Text(
                          "Monthly Income: \$" +
                              (userData?.entries.elementAt(0).value ?? ""),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: CustomTheme.richBlack,
                          ),
                        ),
                        Text(
                          "Monthly Investment Fund: \$" +
                              (userData?.entries.elementAt(1).value ?? ""),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: CustomTheme.richBlack,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Powered by Finnhub and Gemini Pro",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.richBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.moonstone,
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Good ${greeting()}'.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: CustomTheme.neutralWhite,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "STOCK RECOMMENDATIONS",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            Expanded( // Wrap the ListView.builder with an Expanded widget
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _stocksData.length,
                itemBuilder: (context, index) {
                  final stock = _stocksData[index];
                  return GestureDetector(
                    onTap: () {
                      _showCompanyInfoPopup(stock['symbol']);
                    },
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
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
                                const Divider(
                                  color: CustomTheme.moonstone,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                      const Spacer(),
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
                                      const Spacer(),
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
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyInfoScreen extends StatelessWidget {
  final String companyInfo;
  final String symbol; // Symbol of the company to fetch respective image

  const CompanyInfoScreen({super.key, required this.companyInfo, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 1.2 * kToolbarHeight, 10, 0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CustomTheme.maastrichtBlue,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text(
                      "information".toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.info,
                      size: 30,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Future Stock Price Prediction:",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  color: CustomTheme.moonstone,
                    fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
                      child: Row(
                        children: [
                          // Display Company Logo
                          Image.asset(
                            'assets/images/${symbol.toLowerCase()}.png', // Assuming the image name is same as symbol
                            height: 500, // Adjust height as needed

                          ),
                          const SizedBox(width: 20), // Add spacing between images if needed
                          // Add more images or widgets horizontally if needed
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "About Company:",
                      style: GoogleFonts.montserrat(
                          fontSize: 20,
                          color: CustomTheme.moonstone,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      companyInfo,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: CustomTheme.neutralWhite
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}