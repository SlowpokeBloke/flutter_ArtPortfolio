import 'package:art_portfolio_showcase/screens/messaging_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/db_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key, required this.artistId});
  final String artistId;

  @override
  _ArtistProfileScreenState createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen> {
  // ArtistProfileScreen({Key? key}) : super(key: key);

  final DBHelper _dbHelper = DBHelper();
  // final ImagePicker _picker = ImagePicker();
  String? _firstCollectionImageUrl;


  @override
  Widget build(BuildContext context) {
    var artistId = widget.artistId;
    //var artistName = "";

    // String artistName = FirebaseFirestore.instance.collection("users").doc(artistId).get().then((doc) => null);
    var artistName = _dbHelper.getArtistInfo(artistId).then((doc) {
      if (doc.exists){
        return doc.get("firstName").toString();
      } else {
        return "NAME_NOTFOUND";
      }
    });
    Widget FutureMsgBtn = FutureBuilder(
      future: artistName,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError){
          return IconButton(icon: const Icon(Icons.mail),
              onPressed: () {
                Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => 
                    MessagingScreen(recipientName: snapshot.data!, recipientId: artistId)
                  )
                );
                },);
        } else if (snapshot.hasError){
          return const Text("failed fetching user profile data");
        } else {
          return const Text("Loading...");
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("$artistName's Profile"),
        actions: [
            // IconButton(
            //   icon: const Icon(Icons.mail),
            //   onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MessagingScreen(recipientName: artistName, recipientId: artistId)));},  //nav to messaging screen on pressed, pass name and id
            // ),
            FutureMsgBtn,
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