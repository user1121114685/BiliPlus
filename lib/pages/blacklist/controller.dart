import 'package:bili_plus/common/widgets/dialog/dialog.dart';
import 'package:bili_plus/http/black.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/video.dart';
import 'package:bili_plus/models_new/blacklist/data.dart';
import 'package:bili_plus/models_new/blacklist/list.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class BlackListController
    extends CommonListController<BlackListData, BlackListItem> {
  RxInt total = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<BlackListItem>? getDataList(BlackListData response) {
    total.value = response.total ?? 0;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= total.value) {
      isEnd = true;
    }
  }

  void onRemove(BuildContext context, int index, name, mid) {
    showConfirmDialog(
      context: context,
      title: '确定将 $name 移出黑名单？',
      onConfirm: () async {
        var result = await VideoHttp.relationMod(mid: mid, act: 6, reSrc: 11);
        if (result['status']) {
          loadingState
            ..value.data!.removeAt(index)
            ..refresh();
          total.value -= 1;
          SmartDialog.showToast('操作成功');
        }
      },
    );
  }

  @override
  Future<LoadingState<BlackListData>> customGetData() =>
      BlackHttp.blackList(pn: page);
}
