import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk/components/chat_bubble.dart';
import 'package:talk/components/mytextfield.dart';
import 'package:talk/screens/usersProfile.dart';
import 'package:talk/services/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String image;
  final String receiverUserID;
  final String name;
  final String chatroomid;
  final String dob;
  final String linkedin;
  final String profession;
  final String lastname;
  final String bio;

  const ChatPage({
    Key? key,
    required this.image,
    required this.receiverUserID,
    required this.name,
    required this.chatroomid,
    required this.dob,
    required this.linkedin,
    required this.profession,
    required this.lastname, required this.bio,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserProfile(image: widget.image, name: widget.name, bod: widget.dob, linkedin: widget.linkedin, lastname: widget.lastname, profession: widget.profession, bio: widget.bio)));
          },
          child: Container(
            height: 50,
            width: 150,
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(widget.image)),
                Gap(10),
                Text(
                  widget.name,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        _firebaseAuth.currentUser!.uid,
        widget.receiverUserID,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data == null) {
      return const SizedBox();
    }

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChatBubble(
                  message: data['message'] ?? '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          mytextfield(
            Controller: _messageController,
            hinttext: "type",
            obscureText: false,
            keyboardtype: TextInputType.text,
            prefix: Container(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    onPressed: _showBottomSheet,
                  ),
                  Gap(2),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
          Gap(15),
        ],
      ),
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      print("ReceiverUserID: ${widget.receiverUserID}");
      try {
        await _chatService.sendMessage(
          widget.receiverUserID,
          _messageController.text,
        );
        _messageController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

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
}
