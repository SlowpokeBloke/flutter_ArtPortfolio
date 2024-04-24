import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/db_helper.dart'; // Ensure the path is correct
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();
  final ImagePicker _picker = ImagePicker();

  UserProfileScreen({Key? key}) : super(key: key);

  Future<void> _addArtwork(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String artistId = user?.uid ?? '';

    if (artistId.isNotEmpty) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        String imageUrl = await _dbHelper.uploadImage(File(image.path), "artwork_path/$artistId");
        await _dbHelper.addArtwork('Artwork Title', imageUrl, artistId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No user logged in.")));
    }
  }

  Future<void> _addCollection(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String artistId = user?.uid ?? '';

    if (artistId.isNotEmpty) {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.length >= 2) {
        List<String> imageUrls = [];
        for (var image in images) {
          String imageUrl = await _dbHelper.uploadImage(File(image.path), "collection_path/$artistId");
          imageUrls.add(imageUrl);
        }
        await _dbHelper.addCollection('New Collection', imageUrls, artistId);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CollectionDetailsScreen(imageUrls),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select at least 2 images for the collection.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No user logged in.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String artistId = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Mark's Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/editProfile'),
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
                          // Placeholder for adding new collections
                          return Column(
                            children: [
                              InkWell(
                                onTap: () => _addCollection(context),
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text('No collections found. Tap to add a new collection.', style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () => _addCollection(context),
                                  child: Text('Add Collection'),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var collection = snapshot.data!.docs[index];
                            List<String> imageUrls = List<String>.from(collection['imageUrls']); // Assuming 'imageUrls' is a list of strings stored in your collection document
                            return ListTile(
                              title: Text(collection['title']),
                              leading: Image.network(collection['imageUrl'], width: 100, height: 100, fit: BoxFit.cover), // Displaying the collection thumbnail
                              onTap: () {
                                // Navigate to collection detail screen and display it
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CollectionDetailsScreen(imageUrls),
                                ));
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



// You might need a details screen for collections to show all images
class CollectionDetailsScreen extends StatelessWidget {
  final List<String> imageUrls;

  CollectionDetailsScreen(this.imageUrls);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection Details'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(imageUrls[index], fit: BoxFit.cover);
        },
      ),
    );
  }
}