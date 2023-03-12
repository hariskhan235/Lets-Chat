import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/helpers/dialogs.dart';
import 'package:lets_chat/models/chat_user_model.dart';
import 'package:lets_chat/screens/auth/login_screen.dart';
import 'package:lets_chat/screens/profile_screen.dart';
import 'package:lets_chat/widgets/chat_user_card.dart';

import '../apis/apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUserModel> _list = [];
  final List<ChatUserModel> _searchList = [];

  bool _isSearching = false;

  _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          user: APIs.me,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    APIs.getMyInfo();
    //APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }

        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message.toString());
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          // App Bar
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Name , email...'),
                    autofocus: true,
                    style: TextStyle(fontSize: 16, letterSpacing: 1),
                    onChanged: (val) {
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text('Let\'s Chat'),
            actions: [
              // To search user of the app
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching ? CupertinoIcons.clear : Icons.search,
                ),
              ),
              // for more chat features
              IconButton(
                onPressed: _navigateToProfile,
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),

          // body of the home screen
          body: StreamBuilder(
              stream: APIs.getMyUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? [],
                        ),
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
                                _list = data
                                        ?.map((e) =>
                                            ChatUserModel.fromJson(e.data()))
                                        .toList() ??
                                    [];
                              }
                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    itemCount: _isSearching
                                        ? _searchList.length
                                        : _list.length,
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                .01),
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                        user: _isSearching
                                            ? _searchList[index]
                                            : _list[index],
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
                        });
                }
              }),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                _showAddUserDialog();
              },
              child: Icon(
                Icons.add_comment_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
          // button to add new user to the chat
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.person,
              color: Colors.blue,
              size: 28,
            ),
            Text(' Add User')
          ],
        ),
        content: TextFormField(
          onChanged: (value) => email = value,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: Icon(
              Icons.email,
              color: Colors.blue,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (email.isNotEmpty)
                APIs.addChatUser(email).then((value) {
                  if (value == false) {
                    Dialogs.showSnackBar(context, 'User does not exist');
                  }
                });
            },
            child: Text(
              'Add',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

navigateToLogin(BuildContext context) {
  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
}
