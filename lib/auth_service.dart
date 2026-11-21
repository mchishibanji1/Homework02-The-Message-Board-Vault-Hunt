import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> saveUserRecord(
    User user, {
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'role': role.trim(),
      'registrationDateTime': FieldValue.serverTimestamp(),
    });
  }
}
