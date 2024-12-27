import 'package:flutter/material.dart';
import 'log-in.dart'; // Import the LoginPage file
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'register.dart';
import 'log_or_sing.dart';
import 'recording.dart';
import 'history.dart' ;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final storage = FlutterSecureStorage();

  Future<bool> _checkToken() async {
    String? token = await storage.read(key: 'token');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuralAsk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: _checkToken(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator())); // Show loading indicator while waiting for future
          } else {
            if (snapshot.hasError) {
              return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
            } else {
              // Navigate based on the token's presence
              return snapshot.data == true ? SpeechToTextPage() : WelcomePage();
            }
          }
        },
      ),
    );
  }
}

