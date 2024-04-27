import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagingScreen extends StatefulWidget {
  final String receiverId; // Assuming you pass the receiver's ID when navigating to this screen

  const MessagingScreen({Key? key, required this.receiverId}) : super(key: key);

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('messages').add({
        'text': _messageController.text,
        'senderId': _auth.currentUser!.uid,
        'receiverId': widget.receiverId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: FutureBuilder<DocumentSnapshot>(
    future: _firestore.collection('users').doc(widget.receiverId).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Loading...");
      } else if (snapshot.hasError) {
        return Text("Error: ${snapshot.error}");
      } else if (snapshot.hasData && snapshot.data!.exists) {
        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        String receiverFirstName = data['firstName'] ?? 'Unknown';  // Updated to use 'firstName'
        return Text('Messaging with $receiverFirstName');
      } else {
        return Text('Messaging with Unknown');  // Updated to give a more specific fallback message
      }
    },
  ),
),



    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('messages')
              .where('senderId', isEqualTo: _auth.currentUser!.uid)
              .where('receiverId', isEqualTo: widget.receiverId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error loading messages: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                return Text('No messages');
              } else {
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(message['text']),
                      subtitle: Text(message['senderId'] == _auth.currentUser!.uid ? 'You' : 'Them'),
                    );
                  },
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(labelText: 'Send a message...'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
