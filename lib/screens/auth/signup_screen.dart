// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_field, avoid_print, unnecessary_brace_in_string_interps, prefer_final_fields, must_be_immutable, unnecessary_null_comparison, deprecated_member_use

import 'dart:async';

import 'package:firebase_ex_1/screens/auth/signin_screen.dart';
import 'package:firebase_ex_1/screens/home/home_scree.dart';
import 'package:firebase_ex_1/services/auth_service.dart';
import 'package:firebase_ex_1/services/auth_handler.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  bool isloading = false;
  // TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sign Up'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SIGN UP',
              style: TextStyle(color: Colors.black),
            ),
            // TextField(
            //   controller: _emailController,
            //   decoration: InputDecoration(
            //     label: Text("Name"),
            //   ),
            // ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                label: Text("Email"),
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                label: Text("Password"),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isloading = true;
                });

                if (_emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  dynamic result = await _authService.createNewUser(
                      email: _emailController.text,
                      password: _passwordController.text);

                  if (result == AuthResultStatus.successful) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Verify Your Email"),
                        content: Text("Please confirm your email address"),
                      ),
                    );
                    Timer.periodic(
                      Duration(seconds: 1),
                      (timer) {
                        if (_authService.getEmailVerified ==
                            AuthResultStatus.EMAIL_VERIFIED) {
                          if (_authService.getUser!.emailVerified) {
                            timer.cancel();
                            _emailController.clear();
                            _passwordController.clear();

                            setState(() {
                              isloading = false;
                            });
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HomeScreen(user: _authService.getUser!),
                                ));
                          }
                        } else if (_authService.getEmailVerified ==
                            AuthResultStatus.EMAIL_LINK_EXPIRE) {
                          timer.cancel();
                          Navigator.pop(context);
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("Link Expired"),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      _emailController.clear();
                                      _passwordController.clear();
                                      isloading = false;
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Text('Back'))
                              ],
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    setState(() {
                      isloading = false;
                    });
                    _scaffoldKey.currentState?.showSnackBar(SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text(
                            "${AuthHandler.exceptionMessage(authStatus: result)}")));
                  }
                } else {
                  setState(() {
                    isloading = false;
                  });
                  _scaffoldKey.currentState?.showSnackBar(SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text('Please Enter value')));
                }
              },
              child: isloading == true
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text('Sign Up'),
            ),

            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                navigateToSignIn();
              },
              child: Text('Sign In '),
            ),
          ],
        )),
      ),
    );
  }

  navigateToSignIn() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ));
  }
}
