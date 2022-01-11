import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:improvement/model/talk_room.dart';
import 'package:improvement/model/user.dart';
import 'package:improvement/pages/settings_profile.dart';
import 'package:improvement/pages/talk_room.dart';
import 'package:improvement/utils/firebase.dart';
import 'package:improvement/utils/shard_prefs.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<TalkRoom> talkUserList = [];

  Future<void> createRooms() async {
    String myUid = ShardPrefs.getUid();
    talkUserList = await Firestore.getRooms(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャットアプリ'),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder: (context) => SettingsProfile()));
          }, icon: Icon(Icons.settings))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.roomSnapshot,
        builder: (context, snapshot) {
          return FutureBuilder(
            future: createRooms(),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                    itemCount: talkUserList.length,
                    itemBuilder: (context, index){
                      return InkWell(
                        onTap: () {
                          print(talkUserList[index].roomId);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TalkRoomPage(talkUserList[index])));
                        },
                        child: Container(
                          height: 70,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(talkUserList[index].talkUser.imagePath ?? ''),
                                  radius: 30,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // 横方向
                                mainAxisAlignment: MainAxisAlignment.center, // 縦方向
                                children: [
                                  Text(talkUserList[index].talkUser.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(talkUserList[index].lastMessage, style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            });
        }
      )
    );
  }
}

