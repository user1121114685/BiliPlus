import 'package:bili_plus/models_new/live/live_feed_index/card_data_item.dart';
import 'package:bili_plus/models_new/live/live_feed_index/card_data_list_item.dart';

class CardData {
  CardDataItem? bannerV2;
  CardDataItem? myIdolV1;
  CardDataItem? areaEntranceV3;
  CardLiveItem? smallCardV1;

  CardData({
    this.bannerV2,
    this.myIdolV1,
    this.areaEntranceV3,
    this.smallCardV1,
  });

  factory CardData.fromJson(Map<String, dynamic> json) => CardData(
    bannerV2: json['banner_v2'] == null
        ? null
        : CardDataItem.fromJson(json['banner_v2'] as Map<String, dynamic>),
    myIdolV1: json['my_idol_v1'] == null
        ? null
        : CardDataItem.fromJson(json['my_idol_v1'] as Map<String, dynamic>),
    areaEntranceV3: json['area_entrance_v3'] == null
        ? null
        : CardDataItem.fromJson(
            json['area_entrance_v3'] as Map<String, dynamic>,
          ),
    smallCardV1: json['small_card_v1'] == null
        ? null
        : CardLiveItem.fromJson(json['small_card_v1'] as Map<String, dynamic>),
  );
}
