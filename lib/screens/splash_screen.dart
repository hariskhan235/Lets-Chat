import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/apis/apis.dart';
import 'package:lets_chat/screens/auth/login_screen.dart';
import 'package:lets_chat/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
      if (APIs.auth.currentUser != null) {
        print('User : ${APIs.auth.currentUser}');
        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    });
  }

  _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(),
      ),
    );
  }

  _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(),
      ),
    );
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
            right: size.width * .25,
            width: size.width * .5,
            duration: Duration(seconds: 1),
            child: Image.asset('images/chat.png'),
          ),
          Positioned(
            bottom: size.height * .15,
            width: size.width,
            child: Text(
              'Let\'s Chat ❤️',
              style: TextStyle(fontSize: 19, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
