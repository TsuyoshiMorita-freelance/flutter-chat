
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:improvement/model/message.dart';
import 'package:improvement/model/room.dart';
import 'package:improvement/model/talk_room.dart';
import 'package:improvement/model/user.dart';
import 'package:improvement/utils/shard_prefs.dart';

class Firestore {
  static FirebaseFirestore _firebaseInstance = FirebaseFirestore.instance;
  static final userRef =_firebaseInstance.collection('user');
  static final roomRef =_firebaseInstance.collection('room');
  static final roomSnapshot = roomRef.snapshots();

  static Future<void> addUser() async {
    try{
      print('アカウント登録開始前！！！');
      final newDoc = await userRef.add({
        'name': '山田 太郎',
        'imagePath': 'https://item-shopping.c.yimg.jp/i/l/project1-6_4530956470801',
        'lastMessage': 'こんにちは',
      });
      print('アカウント作成に成功しました。$newDoc');

      print('DB_UID: ${newDoc.id}');
      await ShardPrefs.setUid(newDoc.id);
      String uid = ShardPrefs.getUid();
      print('SET_UID: ${uid}');
      List<String> userIds = await getUser();
      userIds.forEach((userId) async {
        if (userId != newDoc.id) {
          await roomRef.add({
            'joined_user_ids': [userId, newDoc.id],
            'updated_time': Timestamp.now()
          });
          print('ルーム作成完了： $userId -- ${newDoc.id}');
        }
      });

    } catch (e){
      print('アカウント作成またはルーム作成に失敗しました  $e');
    }
  }

  static Future<List<String>> getUser() async {
    try{
      final snapshot = await userRef.get();
      List<String> userIds = [];
      snapshot.docs.forEach((user) {
        userIds.add(user.id);
        print('ドキュメントID： ${user.id} 名前: ${user.data()['name']}');
      });
      print('アカウント取得に成功しました。$userIds');
      return userIds;
    } catch (e){
      print('アカウント取得に失敗しました  $e');
      return [];
    }
  }

  static Future<User> getProfile(String uid) async {
    final profile = await userRef.doc(uid).get();
    try {
      User myProfile = User(
          name: profile.data()!['name'],
          imagePath: profile.data()!['image_path'],
          uuid: uid
      );
      return myProfile;
    } catch (e) {
      return User(
          name: '',
          imagePath: '',
          uuid: ''
      );
    }
  }

  static Future<void> updateProfile(User newProfile) async {
    String myUid = ShardPrefs.getUid();
    userRef.doc(myUid).update({
      'name': newProfile.name,
      'image_path': newProfile.imagePath
    });
  }

  static Future<List<TalkRoom>> getRooms(String myUid) async{
    final snapshot = await roomRef.get();
    List<TalkRoom> roomList = [];

    print('roomの部屋数： ${snapshot.docs.length}');
    for(int i = 0; i < snapshot.docs.length; i++) {
      late var doc = snapshot.docs[i];
      print('AAAA含まれるものがあるか？ ${doc.data()['joined_user_ids'].contains(myUid)}');
      if (doc.data()['joined_user_ids'].contains(myUid)) {
        late String yourUid;
        print(doc.data()['joined_user_ids']);
        doc.data()['joined_user_ids'].forEach((id) {
          if (id != myUid) {
            yourUid = id;
            return;
          }
        });
        User yourProfile = await getProfile(yourUid);
        // すでに退会済みのユーザーがいた場合の対応
        if (yourProfile.name != '') {
          print('aaaaaa ${yourProfile}');

          TalkRoom room = TalkRoom(
              roomId: doc.id,
              talkUser: yourProfile,
              lastMessage: doc.data()['last_message'] ?? ''
          );
          roomList.add(room);
        }
      }
    }
    return roomList;
  }

  static Future<List<Message>> getMessages(String roomId) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    List<Message> messageList = [];
    final snapshot = await messageRef.get();
    for (var i = 0; i < snapshot.docs.length; i++) {
      var doc = snapshot.docs[i];
      bool isMe;
      String myUid = ShardPrefs.getUid();
      if (doc.data()['sender_id'] == myUid) {
        isMe = true;
      } else {
        isMe = false;
      }
      Message message = Message(
          message: doc.data()['message'],
          isMe: isMe,
          sendTime: doc.data()['send_time']);
      messageList.add(message);
    }
    messageList.sort((a, b) => b.sendTime.compareTo(a.sendTime));
    return messageList;
  }

  static Future<void> sendMessage(String roomId, String message) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    String myUid = ShardPrefs.getUid();
    await messageRef.add({
      'message': message,
      'sender_id': myUid,
      'send_time': Timestamp.now()
    });

    roomRef.doc(roomId).update({
      'last_message': message
    });
  }

  static Stream<QuerySnapshot> messageSnapshot(String roomId) {
    return roomRef.doc(roomId).collection('message').snapshots();
  }
}