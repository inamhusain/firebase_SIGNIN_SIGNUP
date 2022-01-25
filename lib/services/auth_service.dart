// ignore_for_file: empty_catches,unused_field, unused_local_variable, avoid_print, non_constant_identifier_names, unused_element, unnecessary_null_comparison, constant_identifier_names, prefer_const_constructors

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ex_1/services/auth_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthResultStatus {
  successful,
  EMAIL_VERIFIED,
  EMAIL_LINK_EXPIRE,
  wrongPassword,
  invalidEmail,
  userNotFound,
  unknownError,
  weakpassword,
  emailAlredyInUse
}

class AuthService {
  //* init Google sign In..

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  //
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthResultStatus? _status;
  User? _user;
  User? get getUser => _user;
  AuthResultStatus? _emailVerified;
  AuthResultStatus? get getEmailVerified => _emailVerified;

  //* reg with email password
  Future createNewUser(
      {required String email, required String password}) async {
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
          email: email.toLowerCase(), password: password);
      _user = _result.user;
      if (_user != null) {
        _status = AuthResultStatus.successful;
        verifyEmail();
      }
    } catch (e) {
      print(e);
      _status = AuthHandler.handleException(e);
    }
    return _status;
  }

  //* sign in email password
  Future signInWithEmailPass(
      {required String email, required String password}) async {
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: email.toLowerCase(), password: password);
      _user = _result.user;

      if (_user != null) {
        _status = AuthResultStatus.successful;
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthHandler.handleException(e);
    }

    return _status;
  }

  //* sign out
  void signOut() {
    _auth.signOut();
    _googleSignIn.signOut();
  }

  //* Goole SignIn
  Future googleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount? _googleSignInAccount = await _googleSignIn.signIn();
      if (_googleSignInAccount != null) {
        GoogleSignInAuthentication _authentication =
            await _googleSignInAccount.authentication;
        AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: _authentication.idToken,
            accessToken: _authentication.accessToken);
        try {
          UserCredential _userCredential =
              await _auth.signInWithCredential(authCredential);
          // print("User creds ${_userCredential.user}");
          if (_userCredential != null) {
            _status = AuthResultStatus.successful;
            _user = _userCredential.user;
          }
        } on FirebaseAuthException catch (e) {
          _status = AuthHandler.handleException(e);
        }
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthHandler.handleException(e);
    }
    return _status;
  }

  //* Google signOut
  googleSignOut() async {
    _googleSignIn.signOut();
  }

  verifyEmail() async {
    var _counter = 0;
    _emailVerified = null;
    if (!_auth.currentUser!.emailVerified) {
      await _user!.sendEmailVerification();
      // it check after 30 sec if email is verify then sucess else link expire.
      var timer = Timer.periodic(Duration(seconds: 3), (timer) async {
        await _auth.currentUser!.reload();
        _counter++;
        print(_counter);

        if (_auth.currentUser!.emailVerified) {
          timer.cancel();
          _emailVerified = AuthResultStatus.EMAIL_VERIFIED;
          _user = _auth.currentUser;
        } else if (_counter == 5) {
          timer.cancel();
          _counter = 0;
          _emailVerified = AuthResultStatus.EMAIL_LINK_EXPIRE;
          _auth.currentUser!.delete();
        }
      });
    }
  }
}
