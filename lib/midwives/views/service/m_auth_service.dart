import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return autoI8lnGen.translate("N_USER_F");
      case 'wrong-password':
        return autoI8lnGen.translate("WRONG_P");
      case 'email-already-in-use':
        return autoI8lnGen.translate("AEC");
      case 'weak-password':
        return autoI8lnGen.translate("WEAK_T_P");
      case 'invalid-email':
        return autoI8lnGen.translate("THE_A_V");
      case 'user-disabled':
        return autoI8lnGen.translate("D_ACCOUNT");;
      case 'too-many-requests':
        return autoI8lnGen.translate("TRTL");;
      default:
        return autoI8lnGen.translate("ERR_CCRD");
    }
  }
}