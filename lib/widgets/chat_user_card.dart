import 'package:flutter/material.dart';
import 'package:lets_chat/apis/apis.dart';
import 'package:lets_chat/models/chat_user_model.dart';
import 'package:lets_chat/models/message_model.dart';
import 'package:lets_chat/screens/chat_screen.dart';
import 'package:lets_chat/widgets/dialogs/profile_dialog.dart';

// ignore: must_be_immutable
class ChatUserCard extends StatefulWidget {
  ChatUserCard({super.key, required this.user});
  late ChatUserModel user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  _navigateToChatScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(user: widget.user),
      ),
    );
  }

  MessageModel? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
      //color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () => _navigateToChatScreen(),
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;

            final list =
                data?.map((e) => MessageModel.fromJson(e.data())).toList() ??
                    [];
            if (list.isNotEmpty) _message = list[0];
            return ListTile(
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(
                      user: widget.user,
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.image),
                ),
              ),
              title: Text(widget.user.name),
              subtitle: Text(_message != null
                  ? _message!.type == MessageType.image
                      ? 'image'
                      : _message!.msg
                  : widget.user.about),
              trailing: _message == null
                  ? null
                  // : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                  //     ? Container(
                  //         width: 15,
                  //         height: 15,
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: Colors.greenAccent.shade100),
                  //       )
                  : Text(
                      // MyDateUtil.getLastMessageTime(
                      //     context: context, time: _message!.sent
                      _message!.sent,

                      style: TextStyle(color: Colors.black54),
                    ),
            );
          },
        ),
      ),
    );
  }
}
