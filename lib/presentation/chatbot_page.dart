import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finsage/theme/custom_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/gemini_api.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  TextEditingController _userInput = TextEditingController();
  String _botResponse = '';

  @override
  void initState() {
    super.initState();
    _loadBotResponse(); // Load bot response when widget initializes
  }

  Future<void> _loadBotResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _botResponse = prefs.getString('botResponse') ?? ''; // Load bot response from shared preferences
    });
  }

  Future<void> _saveBotResponse(String response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('botResponse', response); // Save bot response to shared preferences
  }

  Future<void> talkWithGemini() async {
    final _userMessage = _userInput.text.trim();
    final model = GenerativeModel(model: 'gemini-pro', apiKey: GEMINI_API_KEY);
    final content = Content.text(_userMessage);
    final response = await model.generateContent([content]);

    setState(() {
      _botResponse = response.text!;
    });

    await _saveBotResponse(_botResponse); // Save bot response when received
  }

  String minuteString = DateTime.now().minute < 10
      ? "0${DateTime.now().minute}"
      : "${DateTime.now().minute}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: CustomTheme.lightGray,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: CustomTheme.lightGray,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            if (_botResponse.isNotEmpty) // Display card only if there's a response
              Expanded(
                child: Card(
                  color: CustomTheme.maastrichtBlue,
                  elevation: 10,
                  margin: EdgeInsets.all(10),
                  child: Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${_userInput.text.trim()}".toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: CustomTheme.airForceBlue,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - ${DateTime.now().hour}:$minuteString",
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: CustomTheme.lightGray,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                _botResponse,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: CustomTheme.lightGray,
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
                  )
                ),
              ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "FinSage AI",
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: CustomTheme.maastrichtBlue,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 15,
                        child: TextFormField(
                          controller: _userInput,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your message...',
                            hintStyle: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          talkWithGemini();
                        },
                        icon: Icon(Icons.send_sharp),
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),

            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Powered by Gemini Pro",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}