import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/chat_user_model.dart';

// ignore: must_be_immutable
class ChatUserCard extends StatefulWidget {
  ChatUserCard({super.key, required this.user});
  late ChatUserModel user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
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
        child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.user.image),
            ),
            title: Text(widget.user.name),
            subtitle: Text(widget.user.about),
            trailing: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.greenAccent.shade100),
            )
            // trailing: Text(
            //   '12:00 pm',
            //   style: TextStyle(color: Colors.black45),
            // ),
            ),
      ),
    );
  }
}
