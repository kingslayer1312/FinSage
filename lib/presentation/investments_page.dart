import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/stock_api.dart';
import '../theme/custom_theme.dart';

class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({Key? key});

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  TextEditingController _symbolController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _costPerUnitController = TextEditingController();

  List<Map<String, dynamic>> _investments = [];
  late SharedPreferences _prefs;
  final String apiKey = STOCK_API_KEY;

  @override
  void initState() {
    super.initState();
    _loadInvestments();
  }

  double calculateTotalInvestment(Map<String, dynamic> investment) {
    // Get quantity and cost per unit from investment data
    double quantity = investment['quantity'] ?? 0;
    double costPerUnit = investment['costPerUnit'] ?? 0;

    // Calculate total investment
    return quantity * costPerUnit;
  }

  double calculateTotalEvaluation(Map<String, dynamic> investment) {
    // Get quantity and price from investment data
    double quantity = investment['quantity'] ?? 0;
    double price = investment['c'] ?? 0;

    // Calculate total evaluation
    return quantity * price;
  }

  Color getInvestmentColor(Map<String, dynamic> investment) {
    if (calculateTotalEvaluation(investment) > calculateTotalInvestment(investment)) {
      return CustomTheme.emeraldGreen;
    } else {
      return CustomTheme.crimsonRed;
    }
  }

  Color getContentColor(Map<String, dynamic> investment) {
    if (calculateTotalEvaluation(investment) > calculateTotalInvestment(investment)) {
      return CustomTheme.asparagus;
    } else {
      return CustomTheme.flame;
    }
  }

  Future<void> _loadInvestments() async {
    _prefs = await SharedPreferences.getInstance();
    String investmentsJson = _prefs.getString('investments') ?? '[]';
    setState(() {
      _investments =
      List<Map<String, dynamic>>.from(jsonDecode(investmentsJson));
    });
  }

  Future<void> _saveInvestments() async {
    await _prefs.setString('investments', jsonEncode(_investments));
  }

  void _addInvestment(String symbol, double quantity,
      double costPerUnit) async {
    final String apiUrl = 'https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${apiKey}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['c'] != null) {
        setState(() {
          // Add the new investment
          _investments.add({
            'symbol': symbol,
            'quantity': quantity,
            'costPerUnit': costPerUnit,
            ...data,
          });
        });
        _saveInvestments(); // Save to shared preferences
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

  Future<void> _showAddInvestmentDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomTheme.lightGray,
          title: Text(
              'Add Investment',
              style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: CustomTheme.richBlack
              )
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _symbolController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'Stock Symbol'),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: _costPerUnitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cost Per Unit'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.moonstone, // Custom button background color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)), // Custom text color
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.moonstone, // Custom button background color
              ),
              onPressed: () {
                String symbol = _symbolController.text.toUpperCase();
                double quantity = double.tryParse(_quantityController.text) ?? 0;
                double costPerUnit = double.tryParse(_costPerUnitController.text) ?? 0;
                _addInvestment(symbol, quantity, costPerUnit);
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.black)), // Custom text color
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
        onPressed: _showAddInvestmentDialog,
        tooltip: 'Add Investment',
        child: Icon(Icons.add),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: CustomTheme.lightGray,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Investments'.toUpperCase(),
                style: GoogleFonts.montserrat(
                    fontSize: 32, fontWeight: FontWeight.w600),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _investments.length,
                itemBuilder: (context, index) {
                  final investment = _investments[index];
                  return Container(
                    //height: 300,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: CustomTheme.maastrichtBlue,
                    ),
                    child: ListTile(
                      title: Text(
                        investment['symbol'] ?? '',
                        style: GoogleFonts.montserrat(fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.lightGray),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity: ${investment['quantity'] ?? ''}',
                            style: GoogleFonts.poppins(fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: getContentColor(investment)
                            ),
                          ),
                          Text(
                            'Cost Per Unit: \$${investment['costPerUnit'] ??
                                ''}',
                            style: GoogleFonts.poppins(fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: getContentColor(investment)),
                          ),
                          Text(
                            'Price: \$${investment['c'] ?? ''}',
                            style: GoogleFonts.poppins(fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: getContentColor(investment)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(

                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                      "INVESTMENT",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: getInvestmentColor(investment),
                                    ),
                                  ),
                                  Text(
                                      "\$${calculateTotalInvestment(investment).toString()}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: getInvestmentColor(investment),
                                    ),
                                  )
                                ],
                              ),
                              Spacer(

                              ),
                              Column(
                                children: [
                                  Text(
                                      "EVALUATION",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: getInvestmentColor(investment),
                                    ),
                                  ),
                                  Text(
                                      "\$${calculateTotalEvaluation(investment).toString()}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: getInvestmentColor(investment),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
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