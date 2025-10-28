import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/reply.dart';
import 'package:bili_plus/models_new/emote/package.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmotePanelController extends CommonListController<List<Package>?, Package>
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<List<Package>?> response) {
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
  Future<LoadingState<List<Package>?>> customGetData() =>
      ReplyHttp.getEmoteList(business: 'reply');

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
