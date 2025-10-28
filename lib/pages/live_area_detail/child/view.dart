import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/skeleton/video_card_v.dart';
import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/common/widgets/self_sized_horizontal_list.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/live/live_feed_index/card_data_list_item.dart';
import 'package:bili_plus/pages/live/widgets/live_item_app.dart';
import 'package:bili_plus/pages/live_area_detail/child/controller.dart';
import 'package:bili_plus/pages/search/widgets/search_text.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveAreaChildPage extends StatefulWidget {
  const LiveAreaChildPage({
    super.key,
    required this.areaId,
    required this.parentAreaId,
  });

  final dynamic areaId;
  final dynamic parentAreaId;

  @override
  State<LiveAreaChildPage> createState() => _LiveAreaChildPageState();
}

class _LiveAreaChildPageState extends State<LiveAreaChildPage>
    with AutomaticKeepAliveClientMixin {
  late final _controller = Get.put(
    LiveAreaChildController(widget.areaId, widget.parentAreaId),
    tag: '${widget.areaId}${widget.parentAreaId}',
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData theme = Theme.of(context);
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: StyleString.safeSpace,
              right: StyleString.safeSpace,
              top: StyleString.safeSpace,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: Obx(
              () => _buildBody(theme, _controller.loadingState.value),
            ),
          ),
        ],
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth,
    childAspectRatio: StyleString.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
  );

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<CardLiveItem>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemBuilder: (context, index) => const VideoCardVSkeleton(),
        itemCount: 10,
      ),
      Success(:var response) => SliverMainAxisGroup(
        slivers: [
          if (_controller.newTags?.isNotEmpty == true)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SelfSizedHorizontalList(
                  gapSize: 12,
                  childBuilder: (index) {
                    late final item = _controller.newTags![index];
                    return Obx(
                      () {
                        final isCurr = index == _controller.tagIndex.value;
                        return SearchText(
                          fontSize: 14,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          text: '${item.name}',
                          bgColor: isCurr
                              ? theme.colorScheme.secondaryContainer
                              : Colors.transparent,
                          textColor: isCurr
                              ? theme.colorScheme.onSecondaryContainer
                              : null,
                          onTap: (value) {
                            _controller.onSelectTag(
                              index,
                              item.sortType,
                            );
                          },
                        );
                      },
                    );
                  },
                  itemCount: _controller.newTags!.length,
                ),
              ),
            ),
          response?.isNotEmpty == true
              ? SliverGrid.builder(
                  gridDelegate: gridDelegate,
                  itemBuilder: (context, index) {
                    if (index == response.length - 1) {
                      _controller.onLoadMore();
                    }
                    return LiveCardVApp(item: response[index]);
                  },
                  itemCount: response!.length,
                )
              : HttpError(onReload: _controller.onReload),
        ],
      ),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
