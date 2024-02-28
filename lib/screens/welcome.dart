import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk/components/mybutton.dart';
import 'package:talk/components/mytextfield.dart';
import 'package:talk/screens/home.dart';

class WelcomePage extends StatefulWidget {
  final String phoneID;
  WelcomePage({Key? key, required this.phoneID}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController linkedin = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController profession = TextEditingController();
  final TextEditingController bio = TextEditingController();
  File? image;
  String? url;

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        image = imageFile;
      });
    }
  }

  Future<void> _showBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 150,
        width: 430,
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 40,
                    ),
                    onPressed: () {
                      pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "camera",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(width: 60),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.image,
                      size: 40,
                    ),
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                  const Text("gallery", style: TextStyle(fontSize: 20, color: Colors.black))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            GestureDetector(
              onTap: () {
                _showBottomSheet();
              },
              child: Container(
                height: 200,
                width: 280,
                decoration: BoxDecoration(
                  color: Color.fromARGB(125, 60, 59, 59),
                  shape: BoxShape.circle,
                  image: image != null ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover) : null,
                ),
                child: image == null
                    ? const Icon(
                        Icons.camera_alt_outlined,
                        color: Color.fromARGB(255, 116, 115, 115),
                        size: 60,
                      )
                    : null,
              ),
            ),
            const Text(
              "Enter your details!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 20),
            mytextfield(Controller: firstname, hinttext: "First Name", obscureText: false, keyboardtype:TextInputType.name, prefix: null,),
            const SizedBox(height: 10),
            mytextfield(Controller: lastname, hinttext: "Last Name", obscureText: false, keyboardtype: TextInputType.name, prefix: null,),
            const SizedBox(height: 10),
             mytextfield(Controller: dob, hinttext: "Date of Birth", obscureText: false, keyboardtype: TextInputType.number, prefix: null,),
            const SizedBox(height: 10),
            mytextfield(Controller: linkedin, hinttext: "Linkedin", obscureText: false, keyboardtype: TextInputType.url, prefix: null),
            const SizedBox(height: 10),
             mytextfield(Controller: profession, hinttext: "Profession", obscureText: false, keyboardtype: TextInputType.text, prefix: null,),
            const SizedBox(height: 20),
            mytextfield(Controller: bio, hinttext: "Bio", obscureText: false, keyboardtype: TextInputType.multiline, prefix: null),
            const SizedBox(height: 20),
            Mybutton(
              ontap: () async {
                if (image == null ||
                    firstname.text.isEmpty ||
                    lastname.text.isEmpty ||
                    linkedin.text.isEmpty ||
                    dob.text.isEmpty ||
                    profession.text.isEmpty ||
                    bio.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
                  return;
                }
                try {
                  final filename = "${DateTime.now().microsecondsSinceEpoch}.jpg";
                  final storageRef = FirebaseStorage.instance.ref();
                  final imageRef = storageRef.child("image/$filename");
                  await imageRef.putFile(image!);
                  final imageUrl = await imageRef.getDownloadURL();
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
                      "Firstname": firstname.text,
                      "lastname": lastname.text,
                      "linkedin": linkedin.text,
                      "dataofbrith": dob.text,
                      "profession": profession.text,
                      "Bio": bio.text,
                      "phonenumber": widget.phoneID,
                      "date": DateTime.now(),
                      "imageurl": imageUrl,
                    }, SetOptions(merge: true));
                    final pref = await SharedPreferences.getInstance();
                    await pref.setBool('statuslog', true);
                    firstname.clear();
                    lastname.clear();
                    linkedin.clear();
                    dob.clear();
                    profession.clear();
                    bio.clear();
                    setState(() {
                      image = null;
                      url = null;
                    });
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  }
                } catch (e) {
                  print("Error submitting data: $e");
                }
              },
               buttontext: 'Submit',
            ),
          ],
        ),
      ),
    );
  }
}
