import 'dart:convert';
import 'package:flutter/material.dart';
import 'register.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'recording.dart'; // Import your SpeechToTextPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add a form key
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = FlutterSecureStorage(); // Create an instance of FlutterSecureStorage

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();

      final String loginUrl = 'http://192.168.105.34:8000/Login/';

      try {
        final response = await http.post(
          Uri.parse(loginUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': username,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          await storage.write(key: 'token', value: jsonResponse['token']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SpeechToTextPage()), // Navigate to the next page
          );
        } else if (response.statusCode == 401) {
          final jsonResponse = json.decode(response.body);
          _showDialog(context, jsonResponse['message']);
        } else {
          _showDialog(context, 'Error: ${response.statusCode}');
        }
      } catch (e) {
        _showDialog(context, 'Exception during login: $e');
      }
    }
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Status'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Use any color of your choice
      statusBarBrightness: Brightness.dark, // or Brightness.dark for light status bar icons
      statusBarIconBrightness: Brightness.dark, // or Brightness.dark for light status bar icons
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.03),
              Image.asset(
                'assets/images/logo.png', // Replace with your image asset path
                width: screenWidth, // Adjust the size as needed
                height: screenWidth * 0.9,
              ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Welcome to AuralAsk !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.071,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    value=value!.trim();
                    if (value == null || value.isEmpty) {
                      return 'Username cannot be empty';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value)) {
                      return 'Only letters and numbers allowed';
                    }
                    if (value.length < 5) {
                      return 'Username must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password cannot be empty';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password should contain at least one uppercase letter';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Password should contain at least one lowercase letter';
                    }
                    if (!RegExp(r'\d').hasMatch(value)) {
                      return 'Password should contain at least one digit';
                    }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'Password should contain at least one special character';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // Background color
                    onPrimary: Colors.white, // Text color
                    minimumSize: Size(screenWidth * 0.5, screenHeight * 0.073),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(fontSize: screenWidth * 0.061),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: screenWidth * 0.076, bottom: screenHeight * 0.06),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text(
                      'Dont have an account?',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

