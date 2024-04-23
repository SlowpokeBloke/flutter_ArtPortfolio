// Inside of services/authentication_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign Up with Email and Password
  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
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
    await _firebaseAuth.signOut();
  }
}
