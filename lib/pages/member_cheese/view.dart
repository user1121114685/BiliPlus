import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/space/space_cheese/item.dart';
import 'package:bili_plus/pages/member_cheese/controller.dart';
import 'package:bili_plus/pages/member_cheese/widgets/item.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberCheese extends StatefulWidget {
  const MemberCheese({super.key, required this.heroTag, required this.mid});

  final String? heroTag;
  final int mid;

  @override
  State<MemberCheese> createState() => _MemberCheeseState();
}

class _MemberCheeseState extends State<MemberCheese>
    with AutomaticKeepAliveClientMixin, GridMixin {
  late final _controller = Get.put(
    MemberCheeseController(widget.mid),
    tag: widget.heroTag,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: Obx(() => _buildBody(_controller.loadingState.value)),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildBody(LoadingState<List<SpaceCheeseItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  return MemberCheeseItem(item: response[index]);
                },
                itemCount: response!.length,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}
