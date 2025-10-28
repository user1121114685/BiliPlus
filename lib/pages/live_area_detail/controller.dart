import 'dart:math';

import 'package:bili_plus/http/live.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/live/live_area_list/area_item.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';

class LiveAreaDatailController
    extends CommonListController<List<AreaItem>?, AreaItem> {
  LiveAreaDatailController(this.areaId, this.parentAreaId);
  final dynamic areaId;
  final dynamic parentAreaId;

  late int initialIndex = 0;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<AreaItem>? getDataList(List<AreaItem>? response) {
    if (response?.isNotEmpty == true) {
      initialIndex = max(0, response!.indexWhere((e) => e.id == areaId));
    }
    return response;
  }

  @override
  Future<LoadingState<List<AreaItem>?>> customGetData() =>
      LiveHttp.liveRoomAreaList(parentid: parentAreaId);
}
