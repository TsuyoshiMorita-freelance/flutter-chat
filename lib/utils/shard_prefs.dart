import 'package:shared_preferences/shared_preferences.dart';

class ShardPrefs {
  static SharedPreferences? prefsInstance;

  static Future<void> setInstance() async {
    prefsInstance ??= await SharedPreferences.getInstance();
    print('ShardPrefsのインスタンス生成: prefsInstance');
  }

  static Future<void> setUid(String newUid) async {
    await prefsInstance?.setString('uid', newUid);
    print('端末保存完了');
  }

  static String getUid() {
    String uid = prefsInstance?.getString('uid') ?? '';
    return uid;
  }
}