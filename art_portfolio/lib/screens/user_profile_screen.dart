import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/db_helper.dart'; // Update with the correct path
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();
  final ImagePicker _picker = ImagePicker();

  Future<void> _addArtwork(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Assuming you have a method in DBHelper to upload images and return the URL
      String imageUrl = await _dbHelper.uploadImage(File(image.path), "artwork_path");
      // Now add the artwork details to Firestore
      await _dbHelper.addArtwork('Artwork Title', imageUrl, 'artist_id_here');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String artistId = 'some_artist_id';

    return Scaffold(
      appBar: AppBar(
        title: Text("Mark's Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen or show edit options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Works section title
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Works', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            // Works section
            SizedBox(
              height: 200, // Adjust the height as needed
              child: StreamBuilder(
                stream: _dbHelper.getArtworks(artistId),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  // Prepare a list of widgets representing artworks + the Add button
                  List<Widget> children = [];

                  // Add button at the start
                  children.add(
                    GestureDetector(
                      onTap: () => _addArtwork(context),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/Add_ArtWork.png'), // Replace with the path to your custom image
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 50,
                            color: Colors.white, // Icon color
                          ),
                        ),
                      ),
                    ),
                  );



                  // Artwork items
                  if (snapshot.hasData) {
                    children.addAll(snapshot.data!.docs.map((document) {
                      return Container(
                        height: 200, // Set a fixed height for the container
                        width: 150, // Adjust the width as needed
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
                    children.add(
                      Center(child: Text('No artworks found')),
                    );
                  }

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: children,
                  );
                },
              ),
            ),


            // Collections section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collections', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  // Add Collection Button
                  ElevatedButton(
                    onPressed: () {
                      // Add collection logic
                    },
                    child: Text('Add Collection'),
                  ),
                  SizedBox(height: 8),
                  // StreamBuilder for displaying collections
                  StreamBuilder(
                    stream: _dbHelper.getCollections(artistId),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No collections found');
                      }
                      // List of collections
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var collection = snapshot.data!.docs[index];
                          return ListTile(
                            title: Text(collection['title']),
                            leading: Image.network(collection['imageUrl']), // Assuming you have an image for the collection
                            onTap: () {
                              // Navigate to collection detail or display it
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
