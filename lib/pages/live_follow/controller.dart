import 'package:bili_plus/http/live.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/live/live_follow/data.dart';
import 'package:bili_plus/models_new/live/live_follow/item.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class LiveFollowController
    extends CommonListController<LiveFollowData, LiveFollowItem> {
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  Rx<int?> count = Rx<int?>(null);

  @override
  void checkIsEnd(int length) {
    final count = this.count.value;
    if (count != null && length >= count) {
      isEnd = true;
    }
  }

  @override
  List<LiveFollowItem>? getDataList(LiveFollowData response) {
    count.value = response.liveCount;
    return response.list;
  }

  @override
  Future<LoadingState<LiveFollowData>> customGetData() =>
      LiveHttp.liveFollow(page);
}
