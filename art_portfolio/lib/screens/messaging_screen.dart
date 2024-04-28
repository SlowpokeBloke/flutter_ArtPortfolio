import 'package:art_portfolio_showcase/services/messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';


class MessagingScreen extends StatefulWidget {
  const MessagingScreen({Key? key, required this.recipientName, required this.recipientId}) : super(key: key);
  //recipient user info vars
  final String recipientName;
  final String recipientId;
  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen>{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _msgController = TextEditingController();
  final MessagingService _msgService = MessagingService();

  void sendMessage() async {
    if(_msgController.text.isNotEmpty){
      await _msgService.sendMessage(widget.recipientId, _msgController.text);
      _msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MessagingScreen')),
      body: Column(
        children: [
          Expanded(child: _buildMsgList(),),
          _buildMsgInput(),
        ]
        // ListView.builder(
        //   itemCount: rooms.length,
        //   itemBuilder: (context, index) {
        //     Room item = rooms[index];
        //     return ListTile(
        //       title: Text(item.roomName),
        //       onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen(roomId: item.roomId,)));},
        //     );
        //   },
        // ),
      ),
    );
  }

  //build msg list
  Widget _buildMsgList() {
    return StreamBuilder(
      stream: _msgService.getMessages(widget.recipientId, _firebaseAuth.currentUser!.uid), 
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Text('Error$snapshot.error');
        }
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Text("Loading...");
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) => _buildMsgItem(doc)).toList(),

        );
    });
  }

  //build msg item
  Widget _buildMsgItem(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //msgs from curr user aligned right, else left align
    var align = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Alignment.centerRight : Alignment.centerLeft;
    
    return Container(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            Text(data['message']),
          ],
        ), 
      )
    );

  }

  //buld msg input
  Widget _buildMsgInput() {
    return Row(
      children: [
        //txt field
        Expanded(child: TextField(controller: _msgController, obscureText: false,)),
        //send btn
        IconButton(onPressed: sendMessage, icon: const Icon(Icons.send))
      ],
    );
  }
}