//inside of home_screen.dart

import 'package:art_portfolio_showcase/screens/artist_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/db_helper.dart'; // Ensure the path is correct
import '../services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../screens/messaging_screen.dart';
import '../screens/artist_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();

  HomeScreen({Key? key}) : super(key: key);

  Future<String> _fetchUserName() async {
  var user = FirebaseAuth.instance.currentUser;
  return user?.displayName ?? "User";  // Assuming the display name is set, otherwise default to "User"
}


  @override
  Widget build(BuildContext context) {
    final String artistId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      final List<String> iconPaths = [
    'assets/ppl/1.png',
    'assets/ppl/2.png',
    'assets/ppl/3.png',
    'assets/ppl/4.png',
    'assets/ppl/5.png',
    'assets/ppl/6.png',
    'assets/ppl/7.png',
    'assets/ppl/8.png',
    'assets/ppl/9.png',
    'assets/ppl/10.png',
    'assets/ppl/11.png',
    'assets/ppl/12.png',
    'assets/ppl/13.png',

    // Add more paths as needed
  ];
  final Random random = Random();

    return Scaffold(

      appBar:AppBar(

        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            Navigator.pushNamed(context, '/user_profile');
          },
        ),
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...", overflow: TextOverflow.ellipsis);
            }
            if (snapshot.hasError) {
              return Text("Error", overflow: TextOverflow.ellipsis);
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text("Welcome back, User", overflow: TextOverflow.ellipsis);
            }
            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
            String userName = userData['firstName'] ?? 'User';  // Assuming 'firstName' is stored in Firestore
            return Text('Welcome back, $userName', overflow: TextOverflow.ellipsis);
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Provider.of<AuthenticationService>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),


      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Artworks',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),


            StreamBuilder<QuerySnapshot>(
              stream: _dbHelper.getArtworks(artistId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No artworks found');
                }

                return Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
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
                    },
                  ),
                );
              },
            ),
            
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Collections',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),


            StreamBuilder<QuerySnapshot>(
              stream: _dbHelper.getCollections(artistId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No collections found');
                }

                // Build the list of collection widgets
                var collectionWidgets = snapshot.data!.docs.map((document) {
                  var collectionData = document.data() as Map<String, dynamic>;
                  List<dynamic> artworkIds = List<dynamic>.from(collectionData['artworkIds'] ?? []);
                  ImageProvider imageProvider;
                  
                  // Check if artworkIds is not empty and assign the correct ImageProvider
                  if (artworkIds.isNotEmpty && artworkIds[0] is String) {
                    String imageUrl = artworkIds[0];
                    imageProvider = NetworkImage(imageUrl);
                  } else {
                    // Provide a placeholder image if there's no artwork
                    String placeholder = 'assets/placeholder.png';
                    imageProvider = AssetImage(placeholder);
                  }

                  return GestureDetector(
                    onTap: () {
                      // Handle collection tap
                    },
                    child: Container(
                      width: 150,
                      height: 300,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          collectionData['title'] ?? 'Untitled Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList();

                return Container(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: collectionWidgets,
                  ),
                );
              },
            ),

            const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Connect',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),

      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No users found');
          }

          final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return Container(
            height: 120, // Adjusted height for better UI
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var userDocument = snapshot.data!.docs[index];
                var userData = userDocument.data() as Map<String, dynamic>;
                String userId = userDocument.id; // Get the user's ID from the document
                
                // Skip the currently logged-in user
                if (userId == currentUserId) {
                  return SizedBox.shrink(); // This will not take any space in the ListView
                }

                String firstName = userData['firstName'] ?? 'Unknown';
                String iconPath = iconPaths[random.nextInt(iconPaths.length)]; // Randomly select an icon

                return GestureDetector(
                  onTap: () {
                    // Navigate to the ArtistProfileScreen with the selected user's ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArtistProfileScreen(artistId: userId),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    margin: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(iconPath),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          firstName,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),


          ],
        ),
      ),

    );
  }
}


