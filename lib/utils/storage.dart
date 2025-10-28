import 'dart:convert';
import 'dart:io';

import 'package:bili_plus/models/model_owner.dart';
import 'package:bili_plus/models/user/danmaku_rule_adapter.dart';
import 'package:bili_plus/models/user/info.dart';
import 'package:bili_plus/utils/accounts.dart';
import 'package:bili_plus/utils/accounts/account_adapter.dart';
import 'package:bili_plus/utils/accounts/account_type_adapter.dart';
import 'package:bili_plus/utils/accounts/cookie_jar_adapter.dart';
import 'package:bili_plus/utils/set_int_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

abstract class GStorage {
  static late final Box<UserInfoData> userInfo;
  static late final Box<dynamic> historyWord;
  static late final Box<dynamic> localCache;
  static late final Box<dynamic> setting;
  static late final Box<dynamic> video;

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    regAdapter();

    await Future.wait([
      // 登录用户信息
      Hive.openBox<UserInfoData>(
        'userInfo',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 2;
        },
      ).then((res) => userInfo = res),
      // 本地缓存
      Hive.openBox(
        'localCache',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 4;
        },
      ).then((res) => localCache = res),
      // 设置
      Hive.openBox('setting').then((res) => setting = res),
      // 搜索历史
      Hive.openBox(
        'historyWord',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 10;
        },
      ).then((res) => historyWord = res),
      // 视频设置
      Hive.openBox('video').then((res) => video = res),

      Accounts.init(),
    ]);
  }

  static String exportAllSettings() {
    return const JsonEncoder.withIndent('    ').convert({
      setting.name: setting.toMap(),
      video.name: video.toMap(),
    });
  }

  static Future<void> importAllSettings(String data) =>
      importAllJsonSettings(jsonDecode(data));

  static Future<bool> importAllJsonSettings(Map<String, dynamic> map) async {
    await setting.clear();
    await video.clear();
    await setting.putAll(map[setting.name]);
    await video.putAll(map[video.name]);
    return true;
  }

  static void regAdapter() {
    Hive
      ..registerAdapter(OwnerAdapter())
      ..registerAdapter(UserInfoDataAdapter())
      ..registerAdapter(LevelInfoAdapter())
      ..registerAdapter(BiliCookieJarAdapter())
      ..registerAdapter(LoginAccountAdapter())
      ..registerAdapter(AccountTypeAdapter())
      ..registerAdapter(SetIntAdapter())
      ..registerAdapter(RuleFilterAdapter());
  }

  static Future<void> compact() async {
    await Future.wait([
      userInfo.compact(),
      historyWord.compact(),
      localCache.compact(),
      setting.compact(),
      video.compact(),
      Accounts.account.compact(),
    ]);
  }

  static Future<void> close() async {
    await Future.wait([
      userInfo.close(),
      historyWord.close(),
      localCache.close(),
      setting.close(),
      video.close(),
      Accounts.account.close(),
    ]);
  }
}
