import 'dart:async';

import 'package:chat_app/Activity/Home.dart';
import 'package:chat_app/Activity/SignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp()
        .whenComplete(() => {
              if (FirebaseAuth.instance.currentUser == null)
                {
                  Timer(new Duration(seconds: 3), () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                        (r) => false);
                  })
                }else{
                Timer(new Duration(seconds: 3), () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                          (r) => false);
                })
              }
            })
        .catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar("Error connecting to server. Please Try again"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
            Theme.of(context).primaryColor.withOpacity(0.5),
            Theme.of(context).primaryColorDark
          ])),
      alignment: Alignment.center,
      child: Text(
        'You Chat',
        style: GoogleFonts.goldman(color: Colors.white, fontSize: 20),
      ),
    ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
  SnackBar createSnackBar(String title){
    return SnackBar(content: Text(title,style: TextStyle(color: Colors.white),),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.purple,);
  }
}
