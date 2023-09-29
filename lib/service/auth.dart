import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/custom_toaster.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (error) {
      log(error.toString());

      // Check if error is a FirebaseAuthException
      if (error is FirebaseAuthException) {
        String message;
        // Match the error code with FirebaseAuthException error codes

        switch (error.code) {
          case 'invalid-email':
            message = 'The email address is badly formatted.';
            break;
          case 'user-not-found':
            message = 'No user found for the given email address.';
            break;
          case 'wrong-password':
            message = 'Wrong password provided for the given email address.';
            break;
          case 'INVALID_LOGIN_CREDENTIALS':
            message = 'Invalid Login Credentials';
            break;
          default:
            message = 'An unknown error occurred. Please try again later.';
        }
        showCustomToast(context: context, message: message);
      } else {
        // Handle any other errors here
        showCustomToast(
            context: context,
            message: 'An error occurred. Please try again later.');
      }
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (error) {
      print(error);
      log(error.toString());

      // Check if error is a FirebaseAuthException
      if (error is FirebaseAuthException) {
        log(error.code.toString());
        String message;
        // Match the error code with FirebaseAuthException error codes
        switch (error.code) {
          case 'invalid-email':
            message = 'The email address is badly formatted.';
            break;
          case 'user-not-found':
            message = 'No user found for the given email address.';
            break;
          case 'wrong-password':
            message = 'Wrong password provided for the given email address.';
            break;
          case 'INVALID_LOGIN_CREDENTIALS':
            message = 'Invalid Login Credentials';
            break;
          default:
            message = 'An unknown error occurred. Please try again later.';
        }
        showCustomToast(context: context, message: message);
      } else {
        // Handle any other errors here
        showCustomToast(
            context: context,
            message: 'An error occurred. Please try again later.');
      }
      return null;
    }
  }
}
