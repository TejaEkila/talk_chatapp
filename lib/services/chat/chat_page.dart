import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk/components/chat_bubble.dart';
import 'package:talk/components/mytextfield.dart';
import 'package:talk/screens/usersProfile.dart';
import 'package:talk/services/chat/chat_services.dart';
import 'package:uuid/uuid.dart';

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
    required this.lastname,
    required this.bio,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  File? image;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottomIfMessagesExist();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomIfMessagesExist() {
    final messages = _chatService.getMessages(
      _firebaseAuth.currentUser!.uid,
      widget.receiverUserID,
    );
    messages.listen((snapshot) {
      final List<DocumentSnapshot> documents = snapshot.docs;
      if (documents.isNotEmpty) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfile(
                  image: widget.image,
                  name: widget.name,
                  bod: widget.dob,
                  linkedin: widget.linkedin,
                  lastname: widget.lastname,
                  profession: widget.profession,
                  bio: widget.bio,
                ),
              ),
            );
          },
          child: SizedBox(
            height: 50,
            width: 150,
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(widget.image)),
                const Gap(10),
                Text(
                  widget.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        decoration: const BoxDecoration(color: Color.fromARGB(255, 48, 43, 43), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                        height: 140,
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 5,
                              width: 55,
                              decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
                            ),
                            const Gap(20),
                            const SizedBox(
                              height: 50,
                              width: 400,
                              child: Center(
                                  child: Text(
                                "Share",
                                style: TextStyle(fontSize: 17, color: Colors.white),
                              )),
                            ),
                            const SizedBox(
                              height: 50,
                              width: 400,
                              child: Center(
                                  child: Text(
                                "Report",
                                style: TextStyle(fontSize: 17, color: Colors.white),
                              )),
                            )
                          ],
                        )),
                      );
                    });
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              )),
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

        final List<DocumentSnapshot> messages = snapshot.data!.docs;

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messages[index]);
          },
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
        child: Row(
          mainAxisAlignment: alignment == Alignment.centerLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alignment == Alignment.centerLeft)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.image),
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: alignment == Alignment.centerLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                ChatBubble(
                  message: data['message'] ?? '',
                  timestamp: data['timestamp'] ?? '',
                )
                
              ],
            ),
            const SizedBox(width: 8),
            if (alignment == Alignment.centerRight) Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        mytextfield(
          Controller: _messageController,
          hinttext: "type",
          obscureText: false,
          keyboardtype: TextInputType.text,
          prefix: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.image,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: _showBottomSheet,
                ),
                const Gap(2),
                IconButton(
                  icon: const Icon(
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
        const Gap(15),
      ],
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
      uploadImage();

      setState(() {
        image = imageFile;
      });
    }
  }

  Future<void> uploadImage() async {
    if (image == null) {
      // Image is null, so inform the user and return
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please select an image before uploading.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    var uuid = Uuid();
    String fileName = uuid.v1();
    var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = ref.putFile(image!);

    var snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    // Now you can use the imageUrl as needed
    print('Image uploaded. Download URL: $imageUrl');
  }

  Future<void> _showBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 48, 43, 43), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        height: 150,
        width: 430,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 55,
                decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
              ),
              Gap(30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          pickImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        "camera",
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(width: 90),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                      const Text("gallery", style: TextStyle(fontSize: 17, color: Colors.white))
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
