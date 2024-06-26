//inside of services/db_helper.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DBHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  

  // Function to upload image to Firebase Storage and return the URL
Future<String> uploadImage(File imageFile, String basePath, String artistId) async {
  String fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
  Reference ref = _storage.ref().child('$basePath/$artistId/$fileName');
  UploadTask uploadTask = ref.putFile(imageFile);
  TaskSnapshot snapshot = await uploadTask;
  return await snapshot.ref.getDownloadURL();
}


  // Function to add artwork to Firestore
  Future<void> addArtwork(String title, String imageUrl, String artistId) async {
    await _firestore.collection('artworks').add({
      'title': title,
      'imageUrl': imageUrl,
      'artistId': artistId,
      'timestamp': FieldValue.serverTimestamp(), // For sorting purposes
    });
  }

// Function to create a new collection in Firestore
Future<List<String>> addCollection(String title, List<String> artworkIds, String artistId) async {
  print('Adding collection with URLs: $artworkIds');
  DocumentReference collectionRef = await _firestore.collection('collections').add({
      'title': title,
      'artworkIds': artworkIds, 
      'artistId': artistId,
      'timestamp': FieldValue.serverTimestamp(),
  });


  // Return the ID of the newly added collection
  return [collectionRef.id];
}



  // Function to get artworks for a specific artist
  Stream<QuerySnapshot> getArtworks(String artistId) {
    return _firestore.collection('artworks').where('artistId', isEqualTo: artistId).snapshots();
  }

  // Function to get collections for a specific artist
  Stream<QuerySnapshot> getCollections(String artistId) {
    return _firestore.collection('collections').where('artistId', isEqualTo: artistId).snapshots();
  }

  // Function to get profile information for a specific artist
  Future<DocumentSnapshot> getArtistInfo(String artistId) async {
    return await _firestore.collection('users').doc(artistId).get();
  }
}
