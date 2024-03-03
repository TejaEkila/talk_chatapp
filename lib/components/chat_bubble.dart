import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

class ChatBubble extends StatelessWidget {
  final String message;
  final Timestamp timestamp; // Adjust type to Timestamp
  const ChatBubble({Key? key, required this.message, required this.timestamp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 50, // Minimum width for the container
          maxWidth: MediaQuery.of(context).size.width * 0.7, // Maximum width for the container
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromARGB(255, 48, 43, 43),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 15, color: Colors.white),
              maxLines: null, // Allow multiline
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 4),
            Text(
              // Format timestamp to display only time
              DateFormat.jm().format(timestamp.toDate()), // Assuming timestamp is stored as a Firestore Timestamp object
              style: const TextStyle(fontSize: 11, color: Color.fromARGB(255, 134, 134, 134)),
            ),
          ],
        ),
      ),
    );
  }
}
