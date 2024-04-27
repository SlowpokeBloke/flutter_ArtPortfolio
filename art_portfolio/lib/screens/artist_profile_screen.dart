import '/screens/messaging_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/db_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/db_helper.dart';

class ArtistProfileScreen extends StatefulWidget {
  final String artistId;
  const ArtistProfileScreen({Key? key, required this.artistId}) : super(key: key);

  @override
  _ArtistProfileScreenState createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  // Assuming DBHelper is correctly implemented and has a method getArtistInfo that returns a Future<DocumentSnapshot>.
  final DBHelper _dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    var artistId = widget.artistId;

    // Use a FutureBuilder to handle the asynchronous fetch of artist data.
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("users").doc(artistId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData && snapshot.data!.exists) {
              var artistData = snapshot.data!.data() as Map<String, dynamic>;
              return Text("${artistData['firstName']}'s Profile"); // Use the 'firstName' from the snapshot.
            } else {
              return Text("Artist's Profile");
            }
          },
        ),
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("users").doc(artistId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error");
              } else if (snapshot.hasData && snapshot.data!.exists) {
                return IconButton(
                  icon: Icon(Icons.mail),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagingScreen(receiverId: artistId),
                      ),
                    );
                  },
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Works', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _dbHelper.getArtworks(artistId),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      List<Widget> children = [
                        // Padding(
                        //   padding: EdgeInsets.only(left: 16.0),
                        //   )
                      ];
                      if (snapshot.hasData) {
                        children.addAll(snapshot.data!.docs.map((document) {
                          return Container(
                            width: 150,
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(document['imageUrl']),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }).toList());
                      } else {
                        children.add(const Center(child: Text('No artworks found')));
                      }
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: children,
                      );
                    }
                    ))
              ],
              
            ))
        ],
        ),
    );
  }
}

// Future<String> getArtistName(){
//   await _dbHelper.getArtistInfo(artistId).then((doc) {
//       if (doc.exists){
//         return doc.get("firstName").toString();
//       } else {
//         return "NAME_NOTFOUND";
//       }
//     })
// }