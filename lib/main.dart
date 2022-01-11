import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:improvement/pages/top_page.dart';
import 'package:improvement/utils/firebase.dart';
import 'package:improvement/utils/shard_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // キャッシュクリア？
  FirebaseFirestore.instance.settings=Settings(
    persistenceEnabled: false,
  );
  //Firestore.getUser();
  await ShardPrefs.setInstance();
  checkAccount();
  // デバイス情報取得
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print('Running on ${androidInfo.androidId}');  // => Android デバイスID出力


  runApp(const MyApp());
}

Future<void> checkAccount() async {
  String uid = ShardPrefs.getUid();
  print('uuid: ${uid}');
  if (uid == ''){
    Firestore.addUser();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 画面右上に表示されている赤いバナーを非表示にする
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TopPage(),
    );
  }
}
