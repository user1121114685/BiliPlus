import 'package:bili_plus/http/dynamics.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/msg.dart';
import 'package:bili_plus/models/common/dynamic/dynamics_type.dart';
import 'package:bili_plus/models/dynamics/result.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';
import 'package:bili_plus/pages/dynamics/controller.dart';
import 'package:bili_plus/pages/main/controller.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class DynamicsTabController
    extends CommonListController<DynamicsDataModel, DynamicItemModel> {
  DynamicsTabController({required this.dynamicsType});
  final DynamicsTabType dynamicsType;
  String offset = '';
  int? mid;
  late final MainController mainController = Get.find<MainController>();
  final dynamicsController = Get.find<DynamicsController>();

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> onRefresh() {
    if (dynamicsType == DynamicsTabType.all) {
      mainController.setDynCount();
    }
    offset = '';
    return super.onRefresh();
  }

  @override
  List<DynamicItemModel>? getDataList(DynamicsDataModel response) {
    offset = response.offset ?? '';
    return response.items;
  }

  @override
  Future<LoadingState<DynamicsDataModel>> customGetData() =>
      DynamicsHttp.followDynamic(
        type: dynamicsType,
        offset: offset,
        mid: mid,
        tempBannedList: dynamicsController.tempBannedList,
      );

  Future<void> onRemove(int index, dynamic dynamicId) async {
    var res = await MsgHttp.removeDynamic(dynIdStr: dynamicId);
    if (res['status']) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
      SmartDialog.showToast('删除成功');
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  @override
  Future<void> onReload() {
    scrollController.jumpToTop();
    return super.onReload();
  }

  void onBlock(int index) {
    if (dynamicsType != DynamicsTabType.up) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
    }
  }

  void onUnfold(DynamicItemModel item, int index) {
    try {
      final list = loadingState.value.data!;
      final ids = item.modules.moduleFold!.ids!;
      final flag = index + ids.length + 1;
      for (int i = index + 1; i < flag; i++) {
        list[i].visible = true;
      }
      item.modules.moduleFold = null;
      loadingState.refresh();
    } catch (_) {}
  }
}
