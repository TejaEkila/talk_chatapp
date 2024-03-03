import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk/screens/Profile.dart';
import 'package:talk/services/chat/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentUserID;
  List<String> recentChats = [];

  @override
  void initState() {
    super.initState();
    currentUserID = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection("users").doc(currentUserID).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  var data = snapshot.data?.data();
                  if (data == null || data.isEmpty || !data.containsKey('imageurl')) {
                    // Return a placeholder if no image URL is available
                    return const Icon(Icons.person);
                  } else {
                    // Display the user's image using the retrieved URL
                    return CircleAvatar(
                      backgroundImage: NetworkImage(data['imageurl']),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              size: 30,
              color: Colors.white,
            ),
          )
        ],
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quickreply,
              size: 40,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading!!');
        }
        final users = snapshot.data!.docs;
        final currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

        // Filter out the current user's data from the snapshot
        final filteredUsers = users.where((user) => user.id != currentUserUid).toList();


        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            final userData = filteredUsers[index].data() as Map<String, dynamic>;
            final userId = filteredUsers[index].id;
            final name = userData['Firstname'] ?? '';
            final profile = userData['imageurl'] ?? '';
            final linkedin = userData['linkedin'] ?? '';
            final lastname = userData['lastname'] ?? '';
            final profession = userData['profession'] ?? '';
            final dob = userData['dataofbrith'] ?? '';
            final bio = userData['Bio'] ?? '';

            return Card(
              color: Colors.black,
              child: GestureDetector(
                onTap: () {
                  final senderId = FirebaseAuth.instance.currentUser?.uid;
                  final receiverId = userId;
                  if (receiverId != null) {
                    final chatRoomId = _generateChatRoomId(senderId!, receiverId);
                    // Navigate to chat page without storing chat room in Firestore
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatroomid: chatRoomId,
                          receiverUserID: receiverId,
                          image: profile,
                          name: name,
                          profession: profession,
                          linkedin: linkedin,
                          lastname: lastname,
                          dob: dob,
                          bio: bio,
                        ),
                      ),
                    );
                  }
                },
                child: ListTile(
                  hoverColor: Colors.black87,
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(profile),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            );
          },
          itemCount: filteredUsers.length,
        );
      },
    );
  }

  String _generateChatRoomId(String senderId, String receiverId) {
    // Concatenate sender and receiver IDs and sort them alphabetically
    List<String> ids = [senderId, receiverId];
    ids.sort();
    return ids.join('_');
  }
}
