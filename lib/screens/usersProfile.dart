import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  final String name;
  final String image;
  final String bod;
  final String linkedin;
  final String lastname;
  final String profession;
  final String bio;

  const UserProfile({super.key, required this.name, required this.image, required this.bod, required this.linkedin, required this.lastname, required this.profession, required this.bio});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Gap(70),
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.quickreply,
                        color: Colors.blueAccent,
                        size: 80,
                      ))),
              Expanded(
                  flex: 3,
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: widget.name,
                      style: TextStyle(fontSize: 40),
                    ),
                    TextSpan(
                      text: widget.lastname,
                      style: TextStyle(fontSize: 30),
                    )
                  ])))
            ],
          ),
          Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                height: 500,
                width: 400,
                child: Image.network(
                  widget.image,
                  fit: BoxFit.cover,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                )),
          ),
          Gap(10),
          Container(
              height: 100,
              width: 400,
              decoration: BoxDecoration(color: const Color.fromARGB(255, 49, 49, 49), borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Text(
                    widget.bod,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Text(
                    widget.profession,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Text(
                    widget.bio,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              )),
          Gap(20),
          GestureDetector(
            onTap: () {
              setState(() {});
              print("working");
              launchURL(widget.linkedin);
            },
            child: Container(
              height: 60,
              width: 200,
              color: Colors.blue,
              child: Center(child: Text("Linkedin",style: TextStyle( fontSize: 20,color: Colors.white),)),
            ),
          )
        ],
      ),
    );
  }
}
