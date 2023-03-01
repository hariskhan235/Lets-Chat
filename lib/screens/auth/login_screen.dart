import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lets_chat/helpers/dialogs.dart';
import 'package:lets_chat/screens/home_screen.dart';

import '../../apis/apis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleButtonClick() async {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.of(context).pop();
      if (user != null) {
        print('\nUser : ${user.user}');
        print('\nAdditional Info : ${user.additionalUserInfo}');
        if (await APIs.userExist()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(),
            ),
          );
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(),
              ),
            );
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print('\n _signInWithGoogle : $e');
      Dialogs.showSnackBar(
          context, 'SomeThing went wrong check internet connection');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // App Bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Let\'s Chat'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: size.height * .15,
            right: _isAnimate ? size.width * .25 : -size.width * .5,
            width: size.width * .5,
            duration: Duration(seconds: 1),
            child: Image.asset('images/chat.png'),
          ),
          Positioned(
            bottom: size.height * .15,
            left: size.width * .05,
            width: size.width * .9,
            height: size.height * .06,
            child: ElevatedButton.icon(
              onPressed: () => _handleGoogleButtonClick(),
              icon: Image.asset(
                'images/google.png',
                height: size.height * .04,
              ),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 19),
                  children: [
                    TextSpan(text: 'Sign In With', style: TextStyle()),
                    TextSpan(
                        text: ' Google',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 1,
                shape: StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
