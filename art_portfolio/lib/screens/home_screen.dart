//inside of home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  // This would be passed down or fetched from your user authentication logic
  final String currentUserName = 'Mark'; // Replace with dynamic data as needed

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            Navigator.pushNamed(context, '/user_profile');
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text('Welcome back $currentUserName', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          // If you have more actions, they would go here
          // For now it's just an empty container to balance the title
          Container(width: 48.0),
        ],
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('collections').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No Data Available'));
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return ListTile(
                title: Text(document['title']),  // Access data directly using the field name
                subtitle: Text('ID: ${document.id}'),
                onTap: () {
                  // Handle the tap, perhaps show more details or navigate
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
