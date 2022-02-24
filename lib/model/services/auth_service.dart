// import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/main.dart';
import 'package:wildberries/model/data/userData.dart';

class AuthService {
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //Checking if user is signed in
  // Stream<String> get onAuthStateChanged => _firebaseAuth.authStateChanges().map(
  //       (User user) => user?.uid,
  //     );

  //Get UID
  Future<String> getCurrentUID() async {
    // return (_firebaseAuth.currentUser).uid;
  }

  //Get Email
  Future<String> getCurrentEmail() async {
    // if (_firebaseAuth.currentUser == null) return null;
    // return (_firebaseAuth.currentUser).email;
  }

  //Get Current user
  Future<UserDataProfile> getCurrentUser() async {}

  //Email and Pasword Sign Up
  Future<String> createUserWithEmailAndPassword(
    email,
    password,
    name,
  ) async {
    // final User currentUser =
    //     (await _firebaseAuth.createUserWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // ))
    //         .user;

    // await currentUser.reload();
    // return currentUser.uid;
  }

  //Phone Number Sign in
  Future<String> signInWithPhoneNumber(
    String phone,
    String otp,
  ) async {
    // return ((await _firebaseAuth.signInWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // ))
    //         .user)
    //     .uid;
  }

  //Sign Out
  signOut() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    preferences.remove('user');
    // return FirebaseAuth.instance.signOut();
  }

  //Reset password
  Future sendPasswordResetEmail(String email) async {
    // return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
