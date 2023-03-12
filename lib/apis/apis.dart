import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:lets_chat/models/chat_user_model.dart';
import 'package:lets_chat/models/message_model.dart';
import 'package:http/http.dart' as http;

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static User get user => auth.currentUser!;
  static late ChatUserModel me;

  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission();
    await messaging.getToken().then((token) {
      if (token != null) {
        me.pushToken = token;
        print('Token is $token');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message from foreground');
      print('Message Data : ${message.data}');
      if (message.notification != null) {
        print('Message also contained Notification : ${message.notification}');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUserModel chatuser, String msg) async {
    try {
      final body = {
        "to": chatuser.pushToken,
        "notification": {
          "title": chatuser.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": " User ID ${me.id}:",
        }
      };
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'key=AAAAgko_H8Q:APA91bFpL3XnRiMAtocDafa27V0YD0Qdkg_7hQIvLtqK6orrlAQFiuVZnz8c6_pxz8o7mm_0WeyIfWFSwObMA1Xpp4z4veckboQ6GT8u-haNXmQIFFSAAFSBkubVYsi70hr9Vem-e-E2',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      print(
        'Error $e',
      );
    }
  }

  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  static Future<void> updateProfileData() async {
    return await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> getMyInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUserModel.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsers() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUserModel chatUser, String msg, MessageType type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then(
      (value) => sendMessage(chatUser, msg, type),
    );
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUserModel chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    return firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch,
      'push_token': me.pushToken,
    });
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
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUserModel chatUser, String msg, MessageType type) async {
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');

    final time = DateTime.now().millisecondsSinceEpoch.toString();
    String formattedDate = DateFormat().add_jm().format(DateTime.now());

    final message = MessageModel(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: type,
        fromId: user.uid,
        sent: formattedDate);

    await ref
        .doc(time)
        .set(
          message.toJson(),
        )
        .then(
          (value) => sendPushNotification(chatUser, msg),
        );
  }

  static Future<void> updateMessageReadStatus(MessageModel message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUserModel user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent')
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUserModel chatUser, File file) async {
    final extension = file.path.split('.').last;
    final time = DateTime.now().millisecondsSinceEpoch;

    final reference = storage.ref().child(
        'chat_images${getConversationId(chatUser.id)}/${time}.$extension');

    await reference
        .putFile(file, SettableMetadata(contentType: 'image/$extension'))
        .then((p0) {});
    final imageUrl = await reference.getDownloadURL();
    await sendMessage(chatUser, imageUrl, MessageType.image);
  }

  static Future<void> deleteMsg(MessageModel message) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == MessageType.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMsg(MessageModel message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({
      'msg': updatedMsg,
    });
  }
}
