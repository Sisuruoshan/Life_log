import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? getCurrentAuthUser() => _auth.currentUser;

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    debugPrint('🔓 Authenticating with Firebase: $email');
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint('✅ Firebase Auth successful: ${credential.user?.uid}');
    return credential;
  }

  Future<UserCredential> signUp(
    String name,
    String email,
    String password,
  ) async {
    debugPrint('🔑 Creating Firebase Auth user for $email...');
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint('✅ Firebase Auth user created: ${credential.user?.uid}');

    if (credential.user != null) {
      final userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      debugPrint('📝 Writing user profile to Firestore (async)...');
      // Save without awaiting to prevent the UI from freezing on network delays
      _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap())
          .then((_) => debugPrint('✅ User profile saved to Firestore'))
          .catchError((e) => debugPrint('❌ Error saving user document: $e'));
    }
    return credential;
  }

  Future<void> updateUserProfile(String userId, {String? name, String? profileImageUrl}) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
    
    if (updates.isNotEmpty) {
      debugPrint('📝 Updating user profile in Firestore: $updates');
      await _firestore.collection('users').doc(userId).update(updates);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
