import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lets_chat/models/chat_user_model.dart';
import 'package:lets_chat/models/message_model.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;
  static late ChatUserModel me;

  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> updateProfileData() async {
    return await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> getMyInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) {
      if (user.exists) {
        me = ChatUserModel.fromJson(user.data()!);
      } else {
        createUser().then((value) => getMyInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUserModel(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: 'Hey I am using Lets Chat',
        createdAt: time,
        lastActive: time,
        id: user.uid,
        isOnline: false,
        email: user.email.toString(),
        pushToken: '');

    return await firestore.collection('users').doc(user.uid).set(
          chatUser.toJson(),
        );
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateProfileImage(File file) async {
    final extention = file.path.split('.').last;
    print(extention);

    final reference =
        storage.ref().child('profile_pictures/${user.uid}.$extention');

    await reference
        .putFile(
            file,
            SettableMetadata(
              contentType: 'image/$extention',
            ))
        .then((p0) {
      print('Data Transfered : ${p0.bytesTransferred / 1000}');
    });

    me.image = await reference.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // For Chat Screen Apis

  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUserModel chatUser) {
    return firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUserModel chatUser, String msg) async {
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');

    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final message = MessageModel(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: MessageType.text,
        fromId: user.uid,
        sent: time);

    await ref.doc(time).set(
          message.toJson(),
        );
  }
}
