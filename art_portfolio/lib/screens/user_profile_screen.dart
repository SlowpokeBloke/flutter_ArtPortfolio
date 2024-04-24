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
      String imageUrl = await _dbHelper.uploadImage(File(image.path), "artwork_path");
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
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Works', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _dbHelper.getArtworks(artistId),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      List<Widget> children = [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: GestureDetector(
                            onTap: () => _addArtwork(context),
                            child: Column( // Wrap the button and text in a Column
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 260, // Adjusted height to accommodate text below the button
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/Add_ArtWork.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5), // Spacing between the button and text
                                const Text(
                                  'Add Artwork', // Text label for the button
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                        children.add(Center(child: Text('No artworks found')));
                      }

                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: children,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collections', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: StreamBuilder(
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

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var collection = snapshot.data!.docs[index];
                            return ListTile(
                              title: Text(collection['title']),
                              leading: Image.network(collection['imageUrl']),
                              onTap: () {
                                // Navigate to collection detail or display it
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),


          
        ],
      ),
    );
  }
}
