import 'package:bili_plus/common/widgets/dialog/dialog.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/user.dart';
import 'package:bili_plus/models_new/history/data.dart';
import 'package:bili_plus/models_new/history/list.dart';
import 'package:bili_plus/models_new/history/tab.dart';
import 'package:bili_plus/pages/common/multi_select/multi_select_controller.dart';
import 'package:bili_plus/pages/history/base_controller.dart';
import 'package:bili_plus/utils/accounts/account.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:bili_plus/utils/storage.dart';
import 'package:bili_plus/utils/storage_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class HistoryController
    extends MultiSelectController<HistoryData, HistoryItemModel>
    with GetSingleTickerProviderStateMixin {
  HistoryController(this.type);

  late final baseCtr = Get.put(HistoryBaseController());

  Account get account => baseCtr.account;

  final String? type;
  TabController? tabController;
  late RxList<HistoryTab> tabs = <HistoryTab>[].obs;

  int? max;
  int? viewAt;

  @override
  RxInt get rxCount => baseCtr.checkedCount;

  @override
  RxBool get enableMultiSelect => baseCtr.enableMultiSelect;

  @override
  void onInit() {
    super.onInit();
    historyStatus();
    queryData();
  }

  @override
  Future<void> onRefresh() {
    max = null;
    viewAt = null;
    return super.onRefresh();
  }

  @override
  List<HistoryItemModel>? getDataList(HistoryData response) {
    return response.list;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<HistoryData> response) {
    HistoryData data = response.response;
    isEnd = data.list.isNullOrEmpty;
    max = data.list?.lastOrNull?.history.oid;
    viewAt = data.list?.lastOrNull?.viewAt;

    if (isRefresh && type == null) {
      if (tabs.isEmpty && data.tab?.isNotEmpty == true) {
        tabs.value = data.tab!;
        tabController = TabController(
          length: data.tab!.length + 1,
          vsync: this,
        );
      }
    }

    return false;
  }

  // 观看历史暂停状态
  Future<void> historyStatus() async {
    var res = await UserHttp.historyStatus(account: account);
    if (res['status']) {
      baseCtr.pauseStatus.value = res['data'];
      GStorage.localCache.put(LocalCacheKey.historyPause, res['data']);
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  // 删除某条历史记录
  void delHistory(HistoryItemModel item) {
    _onDelete({item});
  }

  // 删除已看历史记录
  void onDelViewedHistory() {
    final viewedList = loadingState.value.dataOrNull
        ?.where((e) => e.progress == -1)
        .toSet();
    if (viewedList != null && viewedList.isNotEmpty) {
      _onDelete(viewedList);
    } else {
      SmartDialog.showToast('无已看记录');
    }
  }

  Future<void> _onDelete(Set<HistoryItemModel> removeList) async {
    SmartDialog.showLoading(msg: '请求中');
    final response = await UserHttp.delHistory(
      removeList
          .map((item) => '${item.history.business}_${item.kid}')
          .join(','),
      account: account,
    );
    if (response['status']) {
      afterDelete(removeList);
    }
    SmartDialog.dismiss();
    SmartDialog.showToast(response['msg']);
  }

  // 删除选中的记录
  @override
  void onRemove() {
    showConfirmDialog(
      context: Get.context!,
      content: '确认删除所选历史记录吗？',
      title: '提示',
      onConfirm: () => _onDelete(allChecked.toSet()),
    );
  }

  @override
  Future<LoadingState<HistoryData>> customGetData() => UserHttp.historyList(
    type: type ?? 'all',
    max: max,
    viewAt: viewAt,
    account: account,
  );

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

  @override
  Future<void> onReload() {
    scrollController.jumpToTop();
    return super.onReload();
  }
}
