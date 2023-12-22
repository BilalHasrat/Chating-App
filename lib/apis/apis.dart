import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_chat_app/model/chat_user_model.dart';
import 'package:my_chat_app/model/message_model.dart';
import 'package:http/http.dart'as http;

class APIs {
  // For authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For Storing self Information
  static  ChatUser me = ChatUser(
      image: user.photoURL.toString(),
      about: 'hey, i am using Lets Chats! ',
      name: user.displayName.toString(),
      createdAt: '',
      isOnline: false,
      id: user.uid,
      lastActive: '',
      email: user.email.toString(),
      pushToken: 'pushToken');

  // For accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For accessing cloud firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // To return Current user
  static User get user => auth.currentUser!;

  // For accessing firebase messaging (Push notification)
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  // For getting firebase messaging token
  static Future<void> getFirebaseMessagingToken()async{
    await messaging.requestPermission();
    await messaging.getToken().then((token) => {
      if(token != null){
        me.pushToken = token,
        print('------------------$token*******************-------------------------')
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) { });
  }

  // For sending push notification
  static Future<void> sendPushNotification(ChatUser chatUser, String msg)async{
    try{
      var url = 'https://fcm.googleapis.com/fcm/send';
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title":chatUser.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User Id: ${me.id}",
        },
      };
      final responce = await http.post(Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader : 'application/json',
        HttpHeaders.authorizationHeader: 'key=AAAAUu4spYw:APA91bHm5LiX-zlKpToUmAuf9uRXyzuBhhYRrCBkLGMfZYwLTaURrqMQ1zv8xniRg05xprJVJHDG8RIuE3Ck6R219PqPda3MioJJSwdZnaaPrDwCeSM0eBx2pzUCpOVVUSjge6X8cPwM'
      },
      body: jsonEncode(body));
      print('******   ${responce.statusCode} ');
      print('******   ${responce.body}   ********* ');

    }catch(e){
      print('______-----____----__$e--__--__--__--__');
    }
  }

  // For checking that user exist or not
  static Future<bool> userExist() async {
    return (await firestore.collection('user').doc(user.uid).get()).exists;
  }

  // for adding chat user to our conversation
  static Future<bool> addChatUser(String email)async{
    final data = await firestore.collection('user').where('email', isEqualTo: email).get();
    if(data.docs.isNotEmpty && data.docs.first.id != user.uid){
      print('user print ------ ${data.docs.first.data()}--------');
      firestore.collection('user').doc(user.uid).collection('my_user').doc(data.docs.first.id).set({});
      return true;
    }else{
      return false;
    }
  }


  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('user').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        // for setting user status to active
        APIs.updateStatusActive(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // For creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm Using Lets Chat",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive:time,
      pushToken: ''
    );
    return await firestore
        .collection('user')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // For getting all user from fireStore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(List<String> userId) {
    return firestore
        .collection('user')
        .where('id',whereIn: userId.isEmpty ? [''] : userId)
        //.where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // For getting id's of a known users from fireStore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId(){
    return firestore.collection('user').doc(user.uid).collection('my_user').snapshots();
  }

  // For adding user to my_user when first message is send
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type)async{
    await firestore.collection('user').doc(chatUser.id).collection('my_user').doc(user.uid).set(
        {}).then((value) => sendMessage(chatUser, msg, type));
  }

  // For updating user information
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('user')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // For updating user profile picture
  static Future<void> updateUserProfile(File file) async {

    // getting img file extension
    final ext = file.path.split('.').last;

    // Storage file ref with path
    final ref = storage.ref().child('profile picture/${user.uid}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data transfered : ${p0.bytesTransferred / 1000} kb');
    });

    // updating image in fireStore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('user')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // For Getting specific user id
  static Stream<QuerySnapshot<Map<String, dynamic>>> getSpecificUserInfo(ChatUser chatUser){
    return  firestore.collection('user').where('id', isEqualTo: chatUser.id).snapshots();
  }
  // Update online or last active status for user
  static Future<void> updateStatusActive(bool isOnline)async{
    firestore.collection('user').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  // ************* Chat Screen related Api *********
//chats collections => conversation id(doc) => message (collection) => message(doc)

  // For getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // For getting all messages of a specific user from fireStore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        . orderBy('sent', descending:  true)
        .snapshots();
  }

  // For sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final MessageModel messageModel = MessageModel(
      msg: msg,
      toId: chatUser.id,
      read: '',
      type: type,
      sent: time,
      fromId: user.uid,
    );
    final ref = firestore.collection(
        'chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(messageModel.toJson()).then((value) => sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  // update Read status of message
  static Future<void> updateMessageReadStatus(MessageModel message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return firestore.collection('chats/${getConversationId(user.id)}/messages/')
        . orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // For sending Chat image
  static Future<void> sendChatImage( ChatUser chatUser,File file)async{
    final ext = file.path.split('.').last;

    // storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // uploading image
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0) => null );

    // updating image in fireStore Database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // For Delete message
  static Future<void> deleteMessage( MessageModel message)async{
    await firestore.collection('chats/${getConversationId(message.toId)}/messages/').doc(message.sent).delete();
    if(message.type == Type.image){
      await storage.refFromURL(message.msg).delete();
    }
  }

  
  // For update message
  static Future<void> updateMessage( MessageModel message,  String updateMessage)async{
    await firestore.collection('chats/${getConversationId(message.toId)}/messages/').doc(message.sent).update(
        {'msg': updateMessage});
    
  }
}

