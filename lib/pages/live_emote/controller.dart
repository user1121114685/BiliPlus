import 'package:bili_plus/http/live.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/live/live_emote/datum.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveEmotePanelController
    extends CommonListController<List<LiveEmoteDatum>?, LiveEmoteDatum>
    with GetSingleTickerProviderStateMixin {
  LiveEmotePanelController(this.roomId);
  final int roomId;
  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<List<LiveEmoteDatum>?> response,
  ) {
    if (response.response?.isNotEmpty == true) {
      tabController = TabController(
        length: response.response!.length,
        vsync: this,
      );
    }
    loadingState.value = response;
    return true;
  }

  @override
  Future<LoadingState<List<LiveEmoteDatum>?>> customGetData() =>
      LiveHttp.getLiveEmoticons(roomId: roomId);

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
