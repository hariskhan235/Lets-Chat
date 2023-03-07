import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/helpers/dialogs.dart';
import 'package:lets_chat/models/chat_user_model.dart';

import '../apis/apis.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  List<ChatUserModel> list = [];
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // App Bar
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .03,
                  ),
                  // user Profile Picture

                  Stack(
                    children: [
                      // local Image

                      _image != null
                          ? CircleAvatar(
                              radius: 80,
                              backgroundImage: FileImage(
                                File(_image!),
                              ),
                            )
                          :
                          // Image From Server
                          CircleAvatar(
                              radius: 80,
                              backgroundImage: NetworkImage(widget.user.image),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          shape: CircleBorder(),
                          color: Colors.white,
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet(context);
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    //width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .03,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    //width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .03,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (newVal) => APIs.me.name = newVal ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Field Required',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      hintText: 'e.g John Wick',
                      label: Text('Name'),
                    ),
                  ),

                  SizedBox(
                    //width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .03,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (newVal) => APIs.me.about = newVal ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Field Required',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                      ),
                      hintText: 'e.g Feeling Happy',
                      label: Text('About'),
                    ),
                  ),
                  SizedBox(
                    //width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .03,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      minimumSize: Size(MediaQuery.of(context).size.width * .4,
                          MediaQuery.of(context).size.height * .055),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateProfileData().then((value) {
                          Dialogs.showSnackBar(
                              context, 'Profile Updated Successfully');
                        });
                      }
                    },
                    icon: Icon(Icons.edit),
                    label: Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.of(context).pop();
                  APIs.auth = FirebaseAuth.instance;
                  //Navigator.of(context).pop();
                  navigateToLogin(context);
                });
              });
            },
            icon: Icon(Icons.add_comment_outlined),
            label: Text('Logout'),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * .03,
            bottom: MediaQuery.of(context).size.height * .05),
        children: [
          Text(
            'Pick Profile Picture',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                  fixedSize: Size(MediaQuery.of(context).size.width * .3,
                      MediaQuery.of(context).size.height * .15),
                ),
                onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  // Pick an image
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    print(
                        'Image Path : ${image.path} Image MimeType : ${image.mimeType}');
                    setState(() {
                      _image = image.path;
                    });
                    APIs.updateProfileImage(
                      File(_image!),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Image.asset('images/image.png'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                  fixedSize: Size(MediaQuery.of(context).size.width * .3,
                      MediaQuery.of(context).size.height * .15),
                ),
                onPressed: () async {
                  final ImagePicker _picker = ImagePicker();
                  // Pick an image
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);

                  if (image != null) {
                    print('Image Path : ${image.path}');
                    setState(() {
                      _image = image.path;
                    });
                    APIs.updateProfileImage(
                      File(_image!),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Image.asset('images/camera.png'),
              ),
            ],
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
