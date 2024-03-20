import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsage/theme/custom_theme.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({Key? key}) : super(key: key);

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = []; // List to store search results
  List<String> _watchlist = []; // List to store stocks in the watchlist
  bool _showSearchSuggestions = false;

  void _searchStocks(String query) {
    // Filter stocks based on the search query
    setState(() {
      _searchResults = _dummyStocks
          .where((stock) => stock.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _showSearchSuggestions = true; // Show search suggestions when user types
    });
  }

  void _addToWatchlist(String stockSymbol) {
    // Add the selected stock to the watchlist
    setState(() {
      _watchlist.add(stockSymbol);
      _searchController.clear(); // Clear the search box
      _searchResults.clear(); // Clear the search results
      _showSearchSuggestions = false; // Hide search suggestions after selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomTheme.lightGray,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "watchlist".toUpperCase(),
                  style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(_showSearchSuggestions ? 0 : 20),
                      bottomRight: Radius.circular(_showSearchSuggestions ? 0 : 20),
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.grey[200], // Background color
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _searchStocks,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search for stocks',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      _showSearchSuggestions
                          ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showSearchSuggestions = false; // Hide search suggestions
                            _searchController.clear(); // Clear the search text
                            _searchResults.clear(); // Clear the search results
                          });
                        },
                      )
                          : SizedBox(), // Show close icon only when search suggestions are visible
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _watchlist.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: CustomTheme.maastrichtBlue,
                      shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: ListTile(
                          title: Text(
                            _watchlist[index],
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CustomTheme.neutralWhite
                            ),
                          ),
                          subtitle: Text(
                            "\$138.08",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: CustomTheme.neutralWhite
                            ),
                          ), // Replace XXXX with actual price
                        ),
                      )
                    );
                  },
                ),
              ],
            ),
          ),
          if (_showSearchSuggestions && _searchResults.isNotEmpty)
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, kToolbarHeight + MediaQuery.of(context).padding.top + 100, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200]?.withOpacity(0.95),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.9),
                      //     spreadRadius: 2,
                      //     blurRadius: 5,
                      //     offset: Offset(0, 2), // changes position of shadow
                      //   ),
                      // ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _searchResults
                          .map((result) => ListTile(
                        title: Text(result),
                        onTap: () {
                          _addToWatchlist(result);
                        },
                      ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<String> _dummyStocks = [
    'AAPL', 'GOOGL', 'TSLA', 'AMZN', 'MSFT', 'FB', 'NFLX', 'NVDA', 'AMD', 'DIS'
  ];
}
