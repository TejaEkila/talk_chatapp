import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderPhone;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  Message({required this.senderId, required this.senderPhone, required this.receiverId, required this.timestamp, required this.message});
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderPhone': senderPhone,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'message': message,
    };
  }
}
