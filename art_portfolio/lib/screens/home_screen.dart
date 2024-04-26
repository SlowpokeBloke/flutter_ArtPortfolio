import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/db_helper.dart'; // Ensure the path is correct

class HomeScreen extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String artistId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
              child:
                  Text('Welcome back, User', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        centerTitle: true,
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
)






            
          ],
        ),
      ),
    );
  }
}
