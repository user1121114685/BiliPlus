import 'package:bili_plus/models_new/follow/data.dart';
import 'package:bili_plus/models_new/follow/list.dart';
import 'package:bili_plus/pages/common/search/common_search_page.dart';
import 'package:bili_plus/pages/follow/widgets/follow_item.dart';
import 'package:bili_plus/pages/follow_search/controller.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FollowSearchPage extends CommonSearchPage {
  const FollowSearchPage({super.key, this.mid, this.isFromSelect = false});

  final int? mid;
  final bool isFromSelect;

  @override
  State<FollowSearchPage> createState() => _FollowSearchPageState();
}

class _FollowSearchPageState
    extends
        CommonSearchPageState<FollowSearchPage, FollowData, FollowItemModel> {
  @override
  late final FollowSearchController controller = Get.put(
    FollowSearchController(widget.mid ?? Get.arguments['mid']),
    tag: Utils.generateRandomString(8),
  );

  @override
  Widget buildList(List<FollowItemModel> list) {
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: ((context, index) {
        if (index == list.length - 1) {
          controller.onLoadMore();
        }
        return FollowItem(
          item: list[index],
          onSelect: widget.mid != null && widget.isFromSelect
              ? (userModel) => Get.back(result: userModel)
              : null,
        );
      }),
    );
  }
}
