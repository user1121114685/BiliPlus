import 'package:bili_plus/models/common/video/source_type.dart';
import 'package:bili_plus/models_new/later/data.dart';
import 'package:bili_plus/models_new/later/list.dart';
import 'package:bili_plus/pages/common/search/common_search_page.dart';
import 'package:bili_plus/pages/later/widgets/video_card_h_later.dart';
import 'package:bili_plus/pages/later_search/controller.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LaterSearchPage extends CommonSearchPage {
  const LaterSearchPage({super.key});

  @override
  State<LaterSearchPage> createState() => _LaterSearchPageState();
}

class _LaterSearchPageState
    extends CommonSearchPageState<LaterSearchPage, LaterData, LaterItemModel> {
  @override
  final LaterSearchController controller = Get.put(
    LaterSearchController(),
    tag: Utils.generateRandomString(8),
  );

  late final gridDelegate = Grid.videoCardHDelegate(context, minHeight: 110);

  @override
  Widget buildList(List<LaterItemModel> list) {
    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        if (index == list.length - 1) {
          controller.onLoadMore();
        }
        final item = list[index];
        return VideoCardHLater(
          index: index,
          videoItem: item,
          ctr: controller,
          onViewLater: (cid) {
            PageUtils.toVideoPage(
              bvid: item.bvid,
              cid: cid,
              cover: item.pic,
              title: item.title,
              extraArguments: {
                'oid': item.aid,
                'sourceType': SourceType.watchLater,
                'count': controller.count,
                'favTitle': '稍后再看',
                'mediaId': controller.mid,
                'desc': false,
                'isContinuePlaying': index != 0,
              },
            );
          },
        );
      },
      itemCount: list.length,
    );
  }
}
