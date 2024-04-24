import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DBHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Function to upload image to Firebase Storage and return the URL
  Future<String> uploadImage(File imageFile, String path) async {
    Reference ref = _storage.ref().child(path);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
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
  Future<void> addCollection(String title, List<String> artworkIds, String artistId) async {
    await _firestore.collection('collections').add({
      'title': title,
      'artworkIds': artworkIds,
      'artistId': artistId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Function to get artworks for a specific artist
  Stream<QuerySnapshot> getArtworks(String artistId) {
    return _firestore.collection('artworks').where('artistId', isEqualTo: artistId).snapshots();
  }

  // Function to get collections for a specific artist
  Stream<QuerySnapshot> getCollections(String artistId) {
    return _firestore.collection('collections').where('artistId', isEqualTo: artistId).snapshots();
  }
}
