import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:lets_chat/apis/apis.dart';
import 'package:lets_chat/helpers/dialogs.dart';
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
        _showModalBottomSheet(isMe);
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
              : SizedBox(),
        ),
        Text(
          widget.message.sent,
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }

  void _showModalBottomSheet(bool isMe) {
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
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            widget.message.type == MessageType.text
                ? OptionIteem(
                    icon: Icon(
                      Icons.copy_all_rounded,
                      size: 26,
                      color: Colors.blue,
                    ),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: widget.message.msg),
                      ).then((value) {
                        Navigator.of(context).pop();
                        Dialogs.showSnackBar(context, 'Text Copied');
                      });
                    },
                  )
                : OptionIteem(
                    icon: Icon(
                      Icons.download,
                      size: 26,
                      color: Colors.blue,
                    ),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        print(widget.message.msg);
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'Lets Chat')
                            .then(
                          (value) {
                            Navigator.of(context).pop();
                            if (value != null && value) {
                              Dialogs.showSnackBar(
                                  context, 'Image Saved Successfully');
                            }
                          },
                        );
                      } catch (e) {
                        print('Error is $e');
                      }
                    },
                  ),
            Divider(
              color: Colors.black54,
              endIndent: MediaQuery.of(context).size.width * .04,
              indent: MediaQuery.of(context).size.width * .04,
            ),
            if (widget.message.type == MessageType.text && isMe)
              OptionIteem(
                icon: Icon(
                  Icons.edit,
                  size: 26,
                  color: Colors.blue,
                ),
                name: 'Edit Message',
                onTap: () {
                  Navigator.of(context).pop();
                  _showMessageEditDialog();
                },
              ),
            OptionIteem(
              icon: Icon(
                Icons.delete,
                size: 26,
                color: Colors.red,
              ),
              name: 'Delete Message',
              onTap: () async {
                await APIs.deleteMsg(widget.message).then(
                  (value) {
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessageEditDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.update,
              color: Colors.blue,
              size: 28,
            ),
            Text(' Update Message')
          ],
        ),
        content: TextFormField(
          onChanged: (value) => updatedMsg = value,
          maxLines: null,
          initialValue: updatedMsg,
          decoration: InputDecoration(
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
              await APIs.updateMsg(widget.message, updatedMsg);
              Navigator.pop(context);
              //setState(() {});
            },
            child: Text(
              'Update',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

class OptionIteem extends StatelessWidget {
  const OptionIteem(
      {super.key, required this.icon, required this.name, required this.onTap});
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .05,
            top: MediaQuery.of(context).size.height * .015,
            bottom: MediaQuery.of(context).size.height * .025),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '   $name',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
