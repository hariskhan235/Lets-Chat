import 'package:flutter/material.dart';
import 'package:lets_chat/apis/apis.dart';
import 'package:lets_chat/models/message_model.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final MessageModel message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showModalBottomSheet();
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // SizedBox(
        //   width: MediaQuery.of(context).size.width * .04,
        // ),
        // if (widget.message.read.isEmpty)
        //   Icon(
        //     Icons.done_all_rounded,
        //     size: 20,
        //     color: Colors.blue,
        //   ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * .04,
            ),
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                size: 20,
                color: Colors.blue,
              ),
            SizedBox(
              width: 2,
            ),
            Text(
              widget.message.sent,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .04,
              vertical: MediaQuery.of(context).size.height * .01,
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 255, 176),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              border: Border.all(color: Colors.lightGreen),
            ),
            child: widget.message.type == MessageType.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * .3,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.message.msg),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _blueMessage() {
    // if (widget.message.read.isEmpty) {
    //   APIs.updateMessageReadStatus(widget.message);
    // }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .04,
              vertical: MediaQuery.of(context).size.height * .01,
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 221, 245, 255),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              border: Border.all(color: Colors.lightBlue),
            ),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ),
        Padding(
            padding:
                EdgeInsets.only(right: MediaQuery.of(context).size.width * .04),
            child: widget.message.type == MessageType.image
                ? Container(
                    width: MediaQuery.of(context).size.width * .5,
                    height: MediaQuery.of(context).size.height * .3,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.message.msg),
                      ),
                    ),
                  )
                : SizedBox()),
        Text(
          widget.message.sent,
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }

  void _showModalBottomSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * .015,
                    horizontal: MediaQuery.of(context).size.height * .4),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text(
                'Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .02,
              ),
            ],
          );
        });
  }
}
