import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: const Text('Let\'s Chat'),
        actions: [
          // To search user of the app
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
          // for more chat features
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      // button to add new user to the chat
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add_comment_outlined),
        ),
      ),
    );
  }
}
