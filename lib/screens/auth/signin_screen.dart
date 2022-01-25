// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_field, avoid_print, unnecessary_brace_in_string_interps, prefer_final_fields, must_be_immutable, deprecated_member_use, prefer_const_constructors_in_immutables, unrelated_type_equality_checks

import 'package:firebase_ex_1/screens/auth/signup_screen.dart';
import 'package:firebase_ex_1/screens/home/home_scree.dart';
import 'package:firebase_ex_1/services/auth_service.dart';
import 'package:firebase_ex_1/services/auth_handler.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Sign In'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SIGN IN',
              style: TextStyle(color: Colors.black),
            ),
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
                  dynamic _result = await _authService.signInWithEmailPass(
                      email: _emailController.text,
                      password: _passwordController.text);
                  print('Status  $_result');
                  if (_result == AuthResultStatus.successful) {
                    _emailController.clear();
                    _passwordController.clear();
                    setState(() {
                      isloading = false;
                    });
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            user: _authService.getUser!,
                          ),
                        ));
                    print('signed in');
                  } else {
                    setState(() {
                      isloading = false;
                    });
                    print(AuthHandler.exceptionMessage(authStatus: _result));
                    _scaffoldKey.currentState?.showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text(
                          "${AuthHandler.exceptionMessage(authStatus: _result)}",
                        ),
                      ),
                    );
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
                  : Text('Sign In'),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: isloading == true ? false : true,
              child: ElevatedButton(
                onPressed: () async {
                  var res = await _authService.googleSignIn(context);
                  if (res == AuthResultStatus.successful) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(user: _authService.getUser!),
                        ));
                  } else {
                    print(AuthHandler.exceptionMessage(authStatus: res));
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
                    : Text('Sign In with google'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ));
              },
              child: Text('Sign Up'),
            ),
          ],
        )),
      ),
    );
  }
}
