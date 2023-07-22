import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'components/record_card.dart';

class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  int _countElement = 0;
  bool _isUploaded = false;

  bool getIsUploaded() {
    return _isUploaded;
  }

  int getCountElement() {
    return _countElement;
  }

  void setIsUpload(bool value) {
    _isUploaded = value;
  }

  void setCount(int value) {
    _countElement = value;
  }

  Stream<User?> changeState() {
    return _auth.idTokenChanges();
  }

  void logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  User? getUser() {
    final User? user = _auth.currentUser;
    return user;
  }

  String? getUserEmail() {
    final User? user = _auth.currentUser;
    return user?.email;
  }

  // Future<String> getUserEmail() async {
  //   User? user = FirebaseAuth.instance.currentUser;

  //   if (user != null) {
  //     String email = user.email!;
  //     return email;
  //   } else {
  //     throw Exception('No user is currently logged in.');
  //   }
  // }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
