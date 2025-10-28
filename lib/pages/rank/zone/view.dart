import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/common/widgets/video_card/video_card_h.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models/model_hot_video_item.dart';
import 'package:bili_plus/pages/common/common_page.dart';
import 'package:bili_plus/pages/rank/zone/controller.dart';
import 'package:bili_plus/pages/rank/zone/widget/pgc_rank_item.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZonePage extends StatefulWidget {
  const ZonePage({super.key, this.rid, this.seasonType});

  final int? rid;
  final int? seasonType;

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends CommonPageState<ZonePage, ZoneController>
    with AutomaticKeepAliveClientMixin, GridMixin {
  @override
  late ZoneController controller = Get.put(
    ZoneController(rid: widget.rid, seasonType: widget.seasonType),
    tag: '${widget.rid}${widget.seasonType}',
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return onBuild(
      refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 7, bottom: 100),
              sliver: Obx(() => _buildBody(controller.loadingState.value)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<dynamic>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  final item = response[index];
                  if (item is HotVideoItemModel) {
                    return VideoCardH(
                      videoItem: item,
                      onRemove: () => controller.loadingState
                        ..value.data!.removeAt(index)
                        ..refresh(),
                    );
                  }
                  return PgcRankItem(item: item);
                },
                itemCount: response!.length,
              )
            : HttpError(onReload: controller.onReload),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
