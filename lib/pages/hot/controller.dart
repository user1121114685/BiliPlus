import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/video.dart';
import 'package:bili_plus/models/model_hot_video_item.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:get/get.dart';

class HotController
    extends CommonListController<List<HotVideoItemModel>, HotVideoItemModel> {
  final RxBool showHotRcmd = Pref.showHotRcmd.obs;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<LoadingState<List<HotVideoItemModel>>> customGetData() =>
      VideoHttp.hotVideoList(pn: page, ps: 20);
}
