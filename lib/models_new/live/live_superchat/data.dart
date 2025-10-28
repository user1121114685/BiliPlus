import 'package:bili_plus/models_new/live/live_superchat/item.dart';

class SuperChatData {
  List<SuperChatItem>? list;

  SuperChatData({this.list});

  factory SuperChatData.fromJson(Map<String, dynamic> json) => SuperChatData(
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => SuperChatItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
