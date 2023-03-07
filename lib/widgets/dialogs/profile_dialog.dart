import 'package:flutter/material.dart';
import 'package:lets_chat/models/chat_user_model.dart';
import 'package:lets_chat/screens/view_profile.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUserModel user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .6,
        height: MediaQuery.of(context).size.height * .35,
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 12,
              child: Text(
                user.name,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: user),
                    ),
                  );
                },
                icon: Icon(
                  Icons.info,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(
                  user.image,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
