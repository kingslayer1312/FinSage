import 'dart:convert';
import 'package:finsage/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/stock_api.dart';

/*
TODO:
  1. on clicking a stock in the watchlist, a screen with more details appears
  2. a graph showing future stock prediction (must)
  3. other features are optional, implement based on time
  */

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({Key? key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _watchlist = [];
  late SharedPreferences _prefs;
  final String apiKey = STOCK_API_KEY;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    _prefs = await SharedPreferences.getInstance();
    String watchlistJson = _prefs.getString('watchlist') ?? '[]';
    setState(() {
      _watchlist = List<Map<String, dynamic>>.from(jsonDecode(watchlistJson));
    });
  }

  Future<void> _saveWatchlist() async {
    await _prefs.setString('watchlist', jsonEncode(_watchlist));
  }

  void _addToWatchlist(String stockSymbol) async {
    final String apiUrl =
        'https://finnhub.io/api/v1/quote?symbol=${stockSymbol}&token=${apiKey}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['c'] != null) {
        setState(() {
          // Add the new stock with its symbol as stockName
          _watchlist.add({'stockName': stockSymbol, ...data});
        });
        _saveWatchlist(); // Save to shared preferences
      } else {
        _showSymbolNotFoundSnackbar();
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      _showErrorSnackbar();
    }
  }

  void _showSymbolNotFoundSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stock symbol not found'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error occurred. Please try again later.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAddStockDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomTheme.lightGray,
          title: Text('Add Stock Symbol',
              style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: CustomTheme.richBlack)),
          content: TextField(
            controller: _searchController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(hintText: 'Enter stock symbol'),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    CustomTheme.moonstone, // Custom button background color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(color: Colors.black)), // Custom text color
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    CustomTheme.moonstone, // Custom button background color
              ),
              onPressed: () {
                String symbol = _searchController.text.toUpperCase();
                _addToWatchlist(symbol);
                Navigator.of(context).pop();
              },
              child: Text('OK',
                  style: TextStyle(color: Colors.black)), // Custom text color
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomTheme.moonstone,
        foregroundColor: CustomTheme.richBlack,
        onPressed: _showAddStockDialog,
        tooltip: 'Add Stock',
        child: Icon(Icons.add),
      ),
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
        padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Watchlist'.toUpperCase(),
              style: GoogleFonts.montserrat(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: CustomTheme.neutralWhite),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _watchlist.length,
                itemBuilder: (context, index) {
                  final stock = _watchlist[index];
                  return Column(
                    children: [
                      Dismissible(
                        direction: DismissDirection.endToStart,
                        key: Key(stock['stockName']
                            .toString()), // Unique key for each item
                        onDismissed: (direction) {
                          setState(() {
                            _watchlist.removeAt(
                                index); // Remove the item from the list
                            _saveWatchlist(); // Save the updated list
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Stock removed from watchlist'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        background: ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Container(
                            height: 100,
                            color: Colors.transparent,
                            padding: EdgeInsets.only(
                                right:
                                    20), // Adjust the padding to control the width of the delete slider
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.delete, color: Colors.white70),
                          ),
                          clipBehavior: Clip
                              .hardEdge, // Ensure clipping is done correctly
                        ),
                        child: Container(
                          height: 100,
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: CustomTheme.maastrichtBlue,
                          ),
                          child: ListTile(
                              title: Text(stock['stockName'] ?? '',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: CustomTheme.lightGray)),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('\$${stock['c'] ?? ''}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w400,
                                          color: CustomTheme.lightSeaGreen)),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
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
