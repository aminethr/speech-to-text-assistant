import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'log-in.dart';
import'resume.dart';
import 'profile.dart';
import 'package:flutter/services.dart';
import 'recording.dart';




class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<RequestHistory>> requestHistory;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    requestHistory = fetchRequestHistory();
  }

  Future<List<RequestHistory>> fetchRequestHistory() async {
    final token = await storage.read(key: 'token'); // Retrieve the token
    final response = await http.get(
      Uri.parse('http://192.168.105.34:8000/Requests%20History/'), // Replace with your specific URL
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<dynamic> reqList = jsonData['history_req'];
      List<dynamic> ansList = jsonData['history_ans'];

      List<RequestHistory> historyList = [];
      for (int i = reqList.length - 1; i >= 0; i--) {
        historyList.add(RequestHistory(
            history_req: reqList[i],
            history_ans: ansList[i]
        ));
      }

      return historyList;
    } else {
      // Handle errors
      throw Exception('Failed to load history');
    }
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
    // Status bar color
    statusBarColor: Colors.white,

    // Status bar brightness (optional)
    statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
    statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ),
    backgroundColor: Colors.white,
    // elevation: 0.0, // Add some elevation
    title: Text('Requests History', style: TextStyle(    fontSize: screenWidth * 0.056,
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
      body: FutureBuilder<List<RequestHistory>>(
        future: requestHistory,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.025), // Adds space around the card
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                  child: ListTile(
                    title: Text(snapshot.data![index].history_req,
                        textAlign: TextAlign.justify,
                        style: TextStyle(

                          fontSize: screenWidth * 0.045, // Change the font size as needed
                          fontWeight: FontWeight.w500,
                            height: screenWidth * 0.003// Use FontWeight.w500, FontWeight.w600, etc., for different weights
                        )
                    ), // Display history_req as title
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.038),
                            ),
                            title: Text("The Answer" ,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),

                            content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text("${snapshot.data![index].history_ans}",
                                    textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04, // Change the font size as needed
                                          fontWeight: FontWeight.w400,
                                            height: screenWidth * 0.005,// Use FontWeight.w500, FontWeight.w600, etc., for different weights
                                        )

                                    )
                                  ],
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
                    },
                  ),
                ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
      bottomNavigationBar: Container(
        height: screenWidth * 0.127,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: screenWidth * 0.0025,
              blurRadius: screenWidth * 0.007,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                // Add navigation logic for history
              },
              icon: Icon(Icons.history, color: Colors.black),
            ),
            IconButton(
              onPressed: () {                      Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChangePasswordPage(),
              ));
                // Add navigation logic for profile
              },
              icon: Icon(Icons.lock, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SpeechToTextPage(),
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
}

class RequestHistory {
  final String history_req;
  final String history_ans;

  RequestHistory({required this.history_req, required this.history_ans});

  factory RequestHistory.fromJson(Map<String, dynamic> json) {
    return RequestHistory(
      history_req: json['history_req'],
      history_ans: json['history_ans'],
    );
  }
}
