import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'log-in.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'recording.dart';
import'resume.dart';
import 'history.dart';



class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  final storage = FlutterSecureStorage();

  bool validatePassword(String password) {
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\$@\$!%*?&])[A-Za-z\d\$@\$!%*?&]{8,}';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(password);
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenWidth * 0.127),
        child: AppBar(
          automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          backgroundColor: Colors.white,
          //elevation: 0.0,
          title: Text(
            'Account Settings',
            style: TextStyle(fontSize: screenWidth * 0.056, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await storage.delete(key: 'token');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              icon: Icon(Icons.logout, color: Colors.black),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.vpn_key, size: screenWidth * 0.63, color: Colors.black),
                SizedBox(height: screenHeight * 0.03),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !validatePassword(value)) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                  onChanged: (value) => oldPassword = value,
                ),
                SizedBox(height: screenHeight * 0.03),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !validatePassword(value)) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                  onChanged: (value) => newPassword = value,
                ),
                SizedBox(height: screenHeight * 0.03),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value != newPassword) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onChanged: (value) => confirmPassword = value,
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      changePassword();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, screenHeight * 0.073),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                    ),
                  ),
                  child: Text(
                    'Change Password',
                    style: TextStyle(fontSize: screenWidth * 0.061),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HistoryPage(), // Replace with your actual history page
                ));
              },
              icon: Icon(Icons.history, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                // This button could be disabled or hidden since you're already on the ChangePasswordPage
              },
              icon: Icon(Icons.lock, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SpeechToTextPage(), // Navigate to the SpeechToTextPage
                ));
              },
              icon: Icon(Icons.mic, color: Colors.black),
            ),
            IconButton(
              onPressed: () {                      Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ResumePage(),
              ));
                // Navigate to profile
              },
              icon: Icon(Icons.book, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> changePassword() async {
    final url = Uri.parse('http://192.168.105.34:8000/Change%20Password/');
    try {
      final token = await storage.read(key: 'token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({'old_password': oldPassword, 'new_password': newPassword}),
      );
      if (response.statusCode == 200) {
        _showPopup(context, 'Success', 'Password changed successfully');
      } else {
        _showPopup(context, 'Error', jsonDecode(response.body)['error']);
      }
    } catch (e) {
      _showPopup(context, 'Error', e.toString());
    }
  }

  void _showPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SpeechToTextPage()));
              },
            ),
          ],
        );
      },
    );
  }
}

