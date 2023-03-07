import 'package:flutter/material.dart';
import 'package:lets_chat/helpers/my_data_util.dart';
import 'package:lets_chat/models/chat_user_model.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .03,
          ),
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(widget.user.image),
            ),
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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'About : ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: widget.user.about,
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Joined On : ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            MyDateUtil.getLastMessageTime(
                context: context, time: widget.user.createdAt, showYear: true),
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
