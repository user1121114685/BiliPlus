import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/music.dart';
import 'package:bili_plus/models_new/music/bgm_detail.dart';
import 'package:bili_plus/pages/common/dyn/common_dyn_controller.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:get/get.dart';

class MusicDetailController extends CommonDynController {
  @override
  late final int oid;
  @override
  late final int replyType;

  @override
  dynamic get sourceId => oid.toString();

  final infoState = LoadingState<MusicDetail>.loading().obs;

  late final String musicId;

  bool get showDynActionBar => Pref.showDynActionBar;

  String get shareUrl =>
      'https://music.bilibili.com/h5/music-detail?music_id=$musicId';

  @override
  void onInit() {
    super.onInit();
    musicId = Get.parameters['musicId']!;
    getMusicDetail();
  }

  Future<void> getMusicDetail() async {
    final res = await MusicHttp.bgmDetail(musicId);
    if (res.isSuccess) {
      final comment = res.data.musicComment!;
      oid = comment.oid!;
      replyType = comment.pageType ?? 47;
      count.value = comment.nums ?? -1;
      queryData();
    }
    infoState.value = res;
  }
}
