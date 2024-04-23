import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUp({required String firstName, required String lastName, required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Create a user document in Firestore with additional information
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        // You can add more fields as needed
      });

      return null; // No error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Sign In with Email and Password
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return null; // No error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Sign Out
  Future<void> signOut() async {
    // Clear authentication state from local storage
    await _firebaseAuth.signOut();
  }
}
