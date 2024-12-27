import 'package:flutter/material.dart';
import 'log-in.dart';
import 'register.dart';
class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
        padding:  EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Placeholder for a large image
            SizedBox(height: screenWidth * 0.025),

            Image.asset(
              'assets/images/logo.png', // Replace with your image asset path
              width: screenWidth * 0.89, // Adjust the size as needed
              height: screenWidth * 0.89,
            ),
            // App description
            Text(
              'Welcome to AuralAsk!',
              style: TextStyle(fontSize: screenWidth * 0.076, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenWidth * 0.076),
            Text(
              'AuralAsk, powered by ChatGPT AI, smartly responds to voice commands, offering quick answers and personalized recommendations for an intuitive user experience.\n\n'
                  'Log in to start exploring or sign up if you\'re new!',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: screenWidth * 0.045,height: screenWidth * 0.0038),

            ),
            SizedBox(height: screenWidth * 0.045),
            // Login button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Replace LoginPage with your actual login page widget
                );
              },
              child: Text('Login',style: TextStyle(fontSize: screenWidth * 0.05)),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                minimumSize: Size(screenWidth * 0.76, screenWidth * 0.12), // double.infinity is the width and 50 is the height
              ),
            ),
            SizedBox(height: screenWidth * 0.038),
            // Signup button
            Padding(
                padding:  EdgeInsets.only(bottom: screenWidth * 0.05),
                child:ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()), // Replace SignupPage with your actual signup page widget
                );
              },
              child: Text('Sign Up',style: TextStyle(fontSize: screenWidth * 0.05)),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                minimumSize: Size(screenWidth * 0.76, screenWidth * 0.12), // double.infinity is the width and 50 is the height
              ),
            )),
          ],
        ),
      ),
    ),
    );
  }
}
