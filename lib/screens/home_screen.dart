import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lets_chat/models/chat_user_model.dart';
import 'package:lets_chat/screens/auth/login_screen.dart';
import 'package:lets_chat/widgets/chat_user_card.dart';

import '../apis/apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUserModel> list = [];
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

      // body of the home screen
      body: StreamBuilder(
          stream: APIs.firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final data = snapshot.data?.docs;
                  list = data!
                      .map((e) => ChatUserModel.fromJson(e.data()))
                      .toList();
                }
                if (list.isNotEmpty) {
                  return ListView.builder(
                      itemCount: list.length,
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .01),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user: list[index],
                        );
                        //return Text('Name : ${list[index]}');
                      });
                } else {
                  return Center(
                    child: Text('No connection Found'),
                  );
                }

              default:
                break;
            }
            return Text('Data');
          }),
      // button to add new user to the chat
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut().then((value) {
              navigateToLogin(context);
            });
          },
          child: Icon(Icons.add_comment_outlined),
        ),
      ),
    );
  }
}

navigateToLogin(BuildContext context) {
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
}
