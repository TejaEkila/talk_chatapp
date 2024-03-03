// ignore_for_file: file_names, use_build_context_synchronously, avoid_print, prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk/components/mybutton.dart';
import 'package:talk/components/mytextfield.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _image;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
        setState(() {
          _firstnameController.text = userData['Firstname'] ?? '';
          _lastnameController.text = userData['lastname'] ?? '';
          _linkedinController.text = userData['linkedin'] ?? '';
          _dobController.text = userData['dataofbrith'] ?? '';
          _professionController.text = userData['profession'] ?? '';
          _bioController.text = userData['Bio'] ?? '';
          _imageUrl = userData['imageurl'];
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
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
                      _pickImage(ImageSource.camera);
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
                      _pickImage(ImageSource.gallery);
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

  Future<void> _updateProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String imageUrl = _imageUrl ?? ''; // Use existing image URL if available
        if (_image != null) {
          // Upload new image if it's selected
          final filename = "${DateTime.now().microsecondsSinceEpoch}.jpg";
          final storageRef = FirebaseStorage.instance.ref();
          final imageRef = storageRef.child("image/$filename");
          await imageRef.putFile(_image!);
          imageUrl = await imageRef.getDownloadURL();
        }
        // Update user data with the new or existing image URL
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "Firstname": _firstnameController.text,
          "lastname": _lastnameController.text,
          "linkedin": _linkedinController.text,
          "dataofbirth": _dobController.text,
          "profession": _professionController.text,
          "Bio": _bioController.text,
          "date": DateTime.now(),
          "imageurl": imageUrl,
        }, SetOptions(merge: true));
        // Clear text controllers and reset image state
        _firstnameController.clear();
        _lastnameController.clear();
        _linkedinController.clear();
        _dobController.clear();
        _professionController.clear();
        _bioController.clear();
        setState(() {
          _image = null;
          _imageUrl = null;
        });
        // Navigate to profile page
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error submitting data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(10),
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
                  image: _image != null
                      ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                      : _imageUrl != null
                          ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                          : null,
                ),
                child: _image == null && _imageUrl == null
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
            mytextfield(
              Controller: _firstnameController,
              hinttext: "First Name",
              obscureText: false,
              keyboardtype: TextInputType.name,
              prefix: null,
            ),
            const SizedBox(height: 10),
            mytextfield(
              Controller: _lastnameController,
              hinttext: "Last Name",
              obscureText: false,
              keyboardtype: TextInputType.name,
              prefix: null,
            ),
            const SizedBox(height: 10),
            mytextfield(
              Controller: _dobController,
              hinttext: "Date of Birth",
              obscureText: false,
              keyboardtype: TextInputType.number,
              prefix: null,
            ),
            const SizedBox(height: 10),
            mytextfield(
              Controller: _linkedinController,
              hinttext: "Linkedin",
              obscureText: false,
              keyboardtype: TextInputType.url,
              prefix: null,
            ),
            const SizedBox(height: 10),
            mytextfield(
              Controller: _professionController,
              hinttext: "Profession",
              obscureText: false,
              keyboardtype: TextInputType.text,
              prefix: null,
            ),
            const SizedBox(height: 20),
            mytextfield(
              Controller: _bioController,
              hinttext: "Bio",
              obscureText: false,
              keyboardtype: TextInputType.multiline,
              prefix: null,
            ),
            const SizedBox(height: 20),
            Mybutton(
              ontap: _updateProfileData,
              buttontext: 'Submit',
            ),
          ],
        ),
      ),
    );
  }
}
