import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String msgBody;
  final Timestamp timestamp;
  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.msgBody,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message' : msgBody,
      'timestamp':timestamp,
    };
  }
}
// class MessageScreen extends StatefulWidget {
//   const MessageScreen({Key? key, required this.roomId}) : super(key: key);
//   final int roomId;
//   final String title = "Chat";

//   @override
//   _MessageScreenState createState() => _MessageScreenState();
// }

// class _MessageScreenState extends State<MessageScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   //method to sign out from firebase
//   void _signOut() async {
//     await _auth.signOut();
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       content: const Text('Signed out successfully'),
//     ));
//     Navigator.pop(context);
//   }

//   late TextEditingController controller;

//   @override
//   void initState(){
//     super.initState();
//     controller = TextEditingController();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   Future<String?> openDialog() => showDialog<String>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Create A New Message'),
//       content: TextField(
//         autofocus: true,
//         decoration: const InputDecoration(hintText: 'Enter Message Name'),
//         controller: controller,
//       ),
//       actions: [
//         TextButton(onPressed: submit, child: const Text('SUBMIT'))
//       ],
//     ),
//   );
//   void submit(){
//     FirebaseFirestore.instance.collection('msgs').doc('test_room').collection('messages').add({
//       'msgBody' : controller.text,
//       'senderId' : "none",
//     });
//     Navigator.of(context).pop(controller.text);
//   }
//   void _createRoom() async {
//     String? newMessage = await openDialog();
//     setState(() {
//       controller.clear();
//       msgs.add(Message(newMessage.toString(), msgs.length));
//     });
//   }
//   List<Message> msgs = [Message("msg1", 1), Message("msg2", 2)];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         actions: <Widget>[
//           ElevatedButton(
//             onPressed: () {
//               _signOut();
//             },
//             child: const Text('Sign Out'),
//           ),
//         ],
//       ),
//       body: Center(
//         child: ListView.builder(
//           itemCount: msgs.length,
//           itemBuilder: (context, index) {
//             Message item = msgs[index];
//             return ListTile(
//               leading: Text("Sender: ${_auth.currentUser?.email}"),
//               title: Text(item.msgBody),
//             );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _createRoom,
//         tooltip: 'Send A Message',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
