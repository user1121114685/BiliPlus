import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/skeleton/msg_feed_top.dart';
import 'package:bili_plus/common/skeleton/video_card_v.dart';
import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models/common/live_search_type.dart';
import 'package:bili_plus/pages/live_search/child/controller.dart';
import 'package:bili_plus/pages/live_search/widgets/live_search_room.dart';
import 'package:bili_plus/pages/live_search/widgets/live_search_user.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveSearchChildPage extends StatefulWidget {
  const LiveSearchChildPage({
    super.key,
    required this.controller,
    required this.searchType,
  });

  final LiveSearchChildController controller;
  final LiveSearchType searchType;

  @override
  State<LiveSearchChildPage> createState() => _LiveSearchChildPageState();
}

class _LiveSearchChildPageState extends State<LiveSearchChildPage>
    with AutomaticKeepAliveClientMixin {
  LiveSearchChildController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double padding = widget.searchType == LiveSearchType.room ? 12 : 0;
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: padding,
              left: padding,
              right: padding,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: Obx(() => _buildBody(_controller.loadingState.value)),
          ),
        ],
      ),
    );
  }

  Widget get _buildLoading {
    return switch (widget.searchType) {
      LiveSearchType.room => SliverGrid.builder(
        gridDelegate: roomDelegate,
        itemBuilder: (context, index) => const VideoCardVSkeleton(),
        itemCount: 10,
      ),
      LiveSearchType.user => SliverGrid.builder(
        gridDelegate: userDelegate,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
        itemCount: 12,
      ),
    };
  }

  late final roomDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth,
    childAspectRatio: StyleString.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(60),
  );

  late final userDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Grid.smallCardWidth * 2,
    mainAxisExtent: 60,
  );

  Widget _buildBody(LoadingState<List?> loadingState) {
    return switch (loadingState) {
      Loading() => _buildLoading,
      Success(:var response) =>
        response?.isNotEmpty == true
            ? Builder(
                builder: (context) {
                  return switch (widget.searchType) {
                    LiveSearchType.room => SliverGrid.builder(
                      gridDelegate: roomDelegate,
                      itemBuilder: (context, index) {
                        if (index == response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return LiveCardVSearch(item: response[index]);
                      },
                      itemCount: response!.length,
                    ),
                    LiveSearchType.user => SliverGrid.builder(
                      gridDelegate: userDelegate,
                      itemBuilder: (context, index) {
                        if (index == response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return LiveSearchUserItem(item: response[index]);
                      },
                      itemCount: response!.length,
                    ),
                  };
                },
              )
            : HttpError(onReload: _controller.onReload),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
