import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/db_helper.dart'; // Ensure the path is correct
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final DBHelper _dbHelper = DBHelper();
  final ImagePicker _picker = ImagePicker();
  String?
      _firstCollectionImageUrl; // Local state to store the first image URL of the new collection

  Future<void> _addArtwork(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String artistId = user?.uid ?? '';

    if (artistId.isNotEmpty) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        String imageUrl = await _dbHelper.uploadImage(
            File(image.path), "artwork_path/$artistId");
        await _dbHelper.addArtwork('Artwork Title', imageUrl, artistId);
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No user logged in.")));
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
          String imageUrl = await _dbHelper.uploadImage(
              File(image.path), "collection_path/$artistId");
          imageUrls.add(imageUrl);
        }
        await _dbHelper.addCollection('New Collection', imageUrls, artistId);
        setState(() {
          _firstCollectionImageUrl = imageUrls
              .first; // Update the local state with the first image URL
        });
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CollectionDetailsScreen(imageUrls),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Please select at least 2 images for the collection.")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No user logged in.")));
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
            onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
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
                  child: Text('Works',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                            child: Column(
                              // Wrap the button and text in a Column
                              children: [
                                SizedBox(

                                  width: 130,
                                  height:260, // Adjusted height to accommodate text below the button
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                            'assets/Add_ArtWork.png'),
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
                                const SizedBox(
                                    height:
                                        5), // Spacing between the button and text
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
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Collections',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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

            List<Widget> children = [
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: GestureDetector(
                  onTap: () => _addCollection(context),
                  child: Container(
                    width: 130,
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('assets/placeholder.png'),
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
              ),
            ];

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              snapshot.data!.docs.forEach((documentSnapshot) {
                Map<String, dynamic> collectionData = documentSnapshot.data() as Map<String, dynamic>;
                List<String> imageUrls = List<String>.from(collectionData['imageUrls'] ?? []);
                ImageProvider<Object> imageProvider = imageUrls.isNotEmpty
                    ? NetworkImage(imageUrls.first) as ImageProvider<Object>
                    : const AssetImage('assets/placeholder.png') as ImageProvider<Object>;

                children.add(
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CollectionDetailsScreen(imageUrls),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              });
            } else {
              children.add(
                Center(
                  child: Text('No collections found'),
                ),
              );
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
