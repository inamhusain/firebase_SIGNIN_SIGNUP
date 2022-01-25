// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ex_1/screens/auth/signin_screen.dart';
import 'package:firebase_ex_1/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  User user;
  HomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    AuthService _authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.user.email.toString()),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _authService.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignInScreen()));
            });
          },
          child: Text('Sign Out'),
        ),
      ),
    );
  }
}
