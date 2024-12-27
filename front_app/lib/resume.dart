import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'history.dart';
import 'profile.dart';
import 'log-in.dart';
import'recording.dart';
import 'package:flutter/services.dart';


import 'package:permission_handler/permission_handler.dart';

class ResumePage extends StatefulWidget {
  @override
  _ResumePageState createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final storage = FlutterSecureStorage();
  bool _isListening = false;
  String _text = '';

  PermissionStatus _microphonePermissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // Set navigation bar color
    ));
    checkMicrophonePermission();
  }

  Future<void> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _microphonePermissionStatus = status;
    });
  }

  Future<void> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _microphonePermissionStatus = status;
    });
  }

  Future<void> startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) async {
          print('Speech recognition status: $status');
          if (status == 'done') {
            setState(() {
              _isListening = false;
            });
            if (_text.isNotEmpty) {

              var response = await sendTextToServer(_text);
              processResponse(response); // Sending text to server
            }
          }
        },
        onError: (error) {
          print('Speech recognition error: $error');
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
          onSoundLevelChange: (level) {
            print('Sound level: $level');
          },
        );
      }
    }
  }

  void processResponse(http.Response response) {
    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body); // Decode the JSON response
      String displayText = decodedResponse['text']; // Extract the text
      _showPopup('Answer', displayText);
    } else if (response.statusCode == 400) {
      var decodedResponse = jsonDecode(response.body);
      String erro_displayText = decodedResponse['error'];
      _showPopup('Error', erro_displayText);
    } else {
      _showPopup('Error', 'Request failed with status: ${response.statusCode}');
    }
  }


  void stopListening() async {
  }

  Future<http.Response> sendTextToServer(String text) async {
    final token = await storage.read(key: 'token'); // Retrieve the token
    final url = Uri.parse('http://192.168.105.34:8000/Summary%20Answer/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $token', // Include the token in the header
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'speech_txt': text}),
      );
      return response; // Return the response
    } catch (e) {
      // Handle any errors here
      print('Error sending text to server: $e');
      // Return a response indicating an error
      return http.Response('Error: $e', 500); // 500 is a general server error status code
    }
  }


  void _showPopup(String title, String message) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.038),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.black, // Darker text color
                fontSize: 0.04,

                height: screenWidth * 0.005,
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Background color
                onPrimary: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.025),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenWidth * 0.12),
        child: AppBar(
          automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.white,

            // Status bar brightness (optional)
            statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          backgroundColor: Colors.white,

          title: Text('Summary Page', style: TextStyle(    fontSize: screenWidth * 0.56,
              fontWeight: FontWeight.bold,color: Colors.black)),
          actions: [
            IconButton(
              onPressed: () async {
                // Navigate to login
                await storage.delete(key: 'token');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Replace LoginPage with your login page
                );
              },
              icon: Icon(Icons.logout, color: Colors.black),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book,
                  size: screenWidth * 1.01, // Larger microphone icon
                  color: _isListening ? Colors.red : Colors.blue,
                ), // Increased space
                SizedBox(height: screenWidth * 0.12), // Increased space
                ElevatedButton(
                  onPressed: _isListening ? stopListening : startListening,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    minimumSize: Size(screenWidth * 0.51, screenWidth * 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1), // Adjust the radius value
                    ),// Larger button size
                  ),
                  child: Text(
                    _isListening ? 'Stop Listening' : 'Start Listening',
                    style: TextStyle(fontSize: screenWidth * 0.61),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenWidth * 0.127,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: screenWidth * 0.0025,    //1
                    blurRadius: screenWidth * 0.007,         //3
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HistoryPage(),
                      ));
                    },
                    icon: Icon(Icons.history, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {                      Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChangePasswordPage(),
                    ));
                      // Navigate to profile
                    },
                    icon: Icon(Icons.lock, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {   Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SpeechToTextPage(),
                    ));
                      // Navigate to profile
                    },
                    icon: Icon(Icons.mic, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {
                    },
                    icon: Icon(Icons.book, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}