// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk/screens/home.dart';
import 'package:talk/screens/login.dart';

class Server extends StatefulWidget {
  const Server({Key? key});

  @override
  State<Server> createState() => _ServerState();
}

class _ServerState extends State<Server> {
  @override
  void initState() {
    super.initState();
    // Start a timer to delay navigation after 30 seconds
    _startTimer();
  }

  _startTimer() async {
    Timer(const Duration(seconds: 3), () {
      checkLogin();
      setState(() {});
    });
  }

  checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? statuslog = pref.getBool("statuslog");

    // final current = await FirebaseAuth.instance.currentUser;
    // final snapshot = await FirebaseFirestore.instance.collection("users").doc(current!.uid).get();

    if (statuslog == false || statuslog == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const LoginPage();
      }));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const HomePage();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset("assets/talk.json"),
      ),
    );
  }
}
