import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/helpers/my_data_util.dart';
import 'package:lets_chat/models/chat_user_model.dart';
import 'package:lets_chat/models/message_model.dart';
import 'package:lets_chat/screens/view_profile.dart';
import 'package:lets_chat/widgets/message_card.dart';

import '../apis/apis.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  final _messageController = TextEditingController();
  bool showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        backgroundColor: Color.fromARGB(255, 221, 245, 255),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.done:
                      case ConnectionState.active:
                        final data = snapshot.data?.docs;

                        _list = data!
                            .map((e) => MessageModel.fromJson(e.data()))
                            .toList();

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * .01),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              });
                        } else {
                          return Center(
                            child: Text('Say Hii..'),
                          );
                        }

                      default:
                        break;
                    }
                    return Text('Data');
                  }),
            ),
            if (_isUploading)
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            _messageField(),
            showEmoji
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * .35,
                    width: MediaQuery.of(context).size.width,
                    child: EmojiPicker(
                      textEditingController: _messageController,
                      config: Config(
                        bgColor: Colors.white,
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return SafeArea(
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;

            final list =
                data?.map((e) => ChatUserModel.fromJson(e.data())).toList() ??
                    [];
            //if (list.isNotEmpty) _message = list[0];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ViewProfileScreen(user: widget.user),
                  ),
                );
              },
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      //color: Colors.black,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                        list.isNotEmpty ? list[0].image : widget.user.image),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastactiveTime(
                                    context, list[0].lastActive)
                            : MyDateUtil.getLastactiveTime(
                                context, widget.user.lastActive),
                        style: TextStyle(
                          fontSize: 13,
                          //fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }

  Widget _messageField() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .01,
            vertical: MediaQuery.of(context).size.width * .025),
        child: Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showEmoji = !showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        onTap: () {
                          if (showEmoji) {
                            setState(() {
                              showEmoji = !showEmoji;
                            });
                          }
                        },
                        controller: _messageController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type Message here..',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        // if (images != null) {
                        //   await APIs.sendChatImage(
                        //     widget.user,
                        //     File(file.path),
                        //   );
                        // }
                        for (var i in images) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? file =
                            await picker.pickImage(source: ImageSource.camera);
                        if (file != null) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(
                            widget.user,
                            File(file.path),
                          );
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MaterialButton(
              minWidth: 0,
              color: Colors.green,
              shape: CircleBorder(),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  if (_list.isEmpty) {
                    APIs.sendFirstMessage(
                        widget.user, _messageController.text, MessageType.text);
                  } else
                    APIs.sendMessage(widget.user,
                            _messageController.text.trim(), MessageType.text)
                        .then((value) {
                      _messageController.text = '';
                    });
                }
              },
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 28,
              ),
            )
          ],
        ),
      ),
    );
  }
}
