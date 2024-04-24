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
    final String currentUserName = 'Mark'; // Replace with dynamic data as needed

    return Scaffold(
      appBar: AppBar(
        title: Text("$currentUserName's Profile"),
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
            // Works section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Works', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  // GridView for artwork thumbnails
                  SizedBox(
                    height: 150,
                    child: StreamBuilder(
                      stream: _dbHelper.getArtworks(artistId),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No artworks found');
                        }
                        // Grid of artworks
                        return GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                          ),
                          itemBuilder: (context, index) {
                            var artwork = snapshot.data!.docs[index];
                            return Container(
                              margin: EdgeInsets.all(8),
                              width: 150, // Adjust width
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(artwork['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  // Add Artwork Button
                  ElevatedButton(
                    onPressed: () => _addArtwork(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // No padding
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Adjust the button shape
                    ),
                    child: Container(
                      width: 150, // Set a fixed width for the container
                      height: 250, // Set a fixed height for the container
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            // Custom background image
                            Image.asset(
                              'assets/Add_ArtWork.png', // Replace with the path to your custom image
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            // Plus icon
                            const Center(
                              child: Icon(
                                Icons.add,
                                size: 50,
                                color: Colors.white, // Icon color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
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
