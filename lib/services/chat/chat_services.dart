import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverUserID, String message, { String messageType = 'text'}) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final Timestamp timestamp = Timestamp.now();

    List<String> ids = [currentUserId, receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore.collection("chat_rooms").doc(chatRoomId).collection("message").doc().set({
      "message": message,
      "senderId": currentUserId,
      "receiverId": receiverUserID,
      "timestamp": timestamp,
    }).then((_) {
      _firestore.collection('chat_rooms').doc(chatRoomId).set({
        "participants": [currentUserId, receiverUserID],
        "chatroomid": chatRoomId,
        "timestamp": timestamp
      });
    });
  }

  Stream<QuerySnapshot> getMessages(String currentUserId, String receiverUserID) {
    List<String> ids = [currentUserId, receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore.collection('chat_rooms').doc(chatRoomId).collection('message').orderBy('timestamp', descending: false).snapshots();
  }
}
