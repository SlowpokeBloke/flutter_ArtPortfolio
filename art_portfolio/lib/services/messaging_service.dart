import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/messages.dart';

class MessagingService extends ChangeNotifier{
  //get auth + firestore inst
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //send msg
  Future<void> sendMessage(String receiverId, String msg) async{
    //get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    //create new msg
    Message newMessage = Message(senderId: currentUserId, senderEmail: currentUserEmail, receiverId: receiverId, msgBody: msg, timestamp: timestamp);
    //construct roomid(private room between current user and recipient) 
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String roomId = ids.join("_");
    //add msg to db
    await _fireStore.collection('rooms').doc(roomId).collection('messages').add(newMessage.toMap());
  }
  //get msg
  Stream<QuerySnapshot> getMessages(String userId_a, String userId_b){
    List<String> ids = [userId_a, userId_b];
    ids.sort();
    String roomId = ids.join("_");
    return _fireStore.collection('rooms').doc(roomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }
}