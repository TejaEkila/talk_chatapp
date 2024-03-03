// ignore_for_file: file_names, unused_local_variable, deprecated_member_use, avoid_print
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
          const Gap(50),
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
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
                      style: const TextStyle(fontSize: 40),
                    ),
                    TextSpan(
                      text: widget.lastname,
                      style: const TextStyle(fontSize: 30),
                    )
                  ])))
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                height: 500,
                width: 400,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 48, 43, 43),
                ),
                child: Image.network(
                  widget.image,
                  fit: BoxFit.cover,
                )),
          ),
          const Gap(10),
          Container(
              height: 60,
              width: 400,
              decoration: BoxDecoration(color: const Color.fromARGB(255, 48, 43, 43), borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Text(
                    widget.bod,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Text(
                    widget.profession,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                 
                ],
              )
              ),
              Gap(10),
              Column(
                      children: [
                        Stack(
                          children: [
                            Center(
                              child: Container(
                                height: 80,
                                width: 400,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 48, 43, 43),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(20),
                                  Text(widget.bio, style: const TextStyle(fontSize: 17, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
          const Gap(14),
          GestureDetector(
            onTap: () {
              setState(() {});
              print("working");
              launchURL(widget.linkedin);
            },
            child: Container(
              height: 60,
              width: 200,
              
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text("Linkedin",style: TextStyle( fontSize: 20,color: Colors.white),)),
            ),
          )
        ],
      ),
    );
  }
}
