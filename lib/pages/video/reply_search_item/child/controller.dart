import 'package:bili_plus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show SearchItemReply, SearchItem, SearchItemType;
import 'package:bili_plus/grpc/reply.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models/common/reply/reply_search_type.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';
import 'package:bili_plus/pages/video/reply_search_item/controller.dart';

class ReplySearchChildController
    extends CommonListController<SearchItemReply, SearchItem> {
  ReplySearchChildController(this.controller, this.searchType);

  final ReplySearchController controller;
  final ReplySearchType searchType;

  @override
  List<SearchItem>? getDataList(SearchItemReply response) {
    if (response.cursor.hasNext == false) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  Future<LoadingState<SearchItemReply>> customGetData() {
    return ReplyGrpc.searchItem(
      page: page,
      itemType: searchType == ReplySearchType.video
          ? SearchItemType.VIDEO
          : SearchItemType.ARTICLE,
      oid: controller.oid,
      type: controller.type,
      keyword: controller.editingController.text,
    );
  }
}
