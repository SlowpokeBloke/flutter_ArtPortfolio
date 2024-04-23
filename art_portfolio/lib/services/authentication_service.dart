import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs = await SharedPreferences.getInstance();

  // Stream to listen to the authentication state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> registerWithEmailPassword(String email, String password, String firstName, String lastName) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Persist authentication state
      await _prefs.setBool('isAuthenticated', true);
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
      throw e;
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Persist authentication state
      await _prefs.setBool('isAuthenticated', true);
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
      throw e;
    }
  }
  
  // Function to check if user is authenticated
  Future<bool> isUserAuthenticated() async {
    // Read authentication state from local storage
    return _prefs.getBool('isAuthenticated') ?? false;
  }

  // Function to sign out
  Future<void> signOut() async {
    // Clear authentication state from local storage
    await _prefs.remove('isAuthenticated');
    await _firebaseAuth.signOut();
  }
}
