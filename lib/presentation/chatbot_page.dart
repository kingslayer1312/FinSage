import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finsage/theme/custom_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/gemini_api.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _userInput = TextEditingController();
  String _botResponse = '';
  String _botTitle = '';

  String _text = '';
  int _currentIndex = 0;
  final String _fullText = "Hi, how can I help you?";

  @override
  void initState() {
    super.initState();
    _loadBotResponse();
    _loadUserInput();
    _startTyping();
  }

  void _startTyping() {
    const duration = Duration(milliseconds: 100);
    Timer.periodic(duration, (Timer timer) {
      setState(() {
        if (_currentIndex < _fullText.length) {
          _text = _fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _loadBotResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _botResponse = prefs.getString('botResponse') ?? '';
      _botTitle = prefs.getString('botTitle') ?? '';
    });
  }

  Future<void> _saveBotResponse(String title, String response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('botTitle', title);
    await prefs.setString('botResponse', response);
  }

  Future<void> _loadUserInput() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userInput.text = prefs.getString('userInput') ?? ''; // Load user input from shared preferences
    });
  }

  Future<void> _saveUserInput(String userInput) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userInput', userInput); // Save user input to shared preferences
  }

  Future<void> talkWithGemini() async {
    final userMessage = _userInput.text.trim();
    final model = GenerativeModel(model: 'gemini-pro', apiKey: GEMINI_API_KEY);
    final content = Content.text(userMessage);
    final response = await model.generateContent([content]);

    setState(() {
      _botResponse = response.text!;
      _botTitle = _userInput.text.trim(); // Update bot title with user input
    });

    await _saveBotResponse(_botTitle, _botResponse);
  }

  String minuteString = DateTime.now().minute < 10
      ? "0${DateTime.now().minute}"
      : "${DateTime.now().minute}";

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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 1.2 * kToolbarHeight, 20, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            if (_botResponse.isEmpty) // Display text only if there's no response
              Expanded(
                child: Center(
                  child: Text(
                    _text,
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.neutralWhite,
                    ),
                  ),
                ),
              ),
            if (_botResponse.isNotEmpty) // Display card only if there's a response
              Expanded(
                child: Card(
                  surfaceTintColor: CustomTheme.richBlack,
                  color: CustomTheme.maastrichtBlue,
                  elevation: 20,
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            _botTitle.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.neutralWhite,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - ${DateTime.now().hour}:$minuteString",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _botResponse,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: CustomTheme.neutralWhite,
                              fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "FinSage AI",
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    )
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: CustomTheme.maastrichtBlue,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 15,
                        child: TextFormField(
                          controller: _userInput,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(color: CustomTheme.neutralWhite, fontSize: 18),
                          onChanged: (value) {
                            _saveUserInput(value); // Save user input on change
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your message...',
                            hintStyle: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Generating response...'),
                              duration: Duration(seconds: 8),
                            ),
                          );
                          talkWithGemini();
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Icons.send_sharp),
                        color: CustomTheme.moonstone,
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Powered by Gemini Pro",
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    color: Colors.white
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