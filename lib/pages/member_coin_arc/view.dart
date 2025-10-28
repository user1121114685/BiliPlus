import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/skeleton/video_card_v.dart';
import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/member/coin_like_arc/item.dart';
import 'package:bili_plus/pages/member_coin_arc/controller.dart';
import 'package:bili_plus/pages/member_coin_arc/widgets/item.dart';
import 'package:bili_plus/services/account_service.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberCoinArcPage extends StatefulWidget {
  const MemberCoinArcPage({super.key, required this.mid, this.name});

  final dynamic mid;
  final String? name;

  @override
  State<MemberCoinArcPage> createState() => _MemberCoinArcPageState();
}

class _MemberCoinArcPageState extends State<MemberCoinArcPage> {
  AccountService accountService = Get.find<AccountService>();

  late final _ctr = Get.put(
    MemberCoinArcController(mid: widget.mid),
    tag: Utils.makeHeroTag(widget.mid),
  );

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '${widget.mid == accountService.mid ? '我' : '${widget.name}'}的最近投币',
        ),
      ),
      body: refreshIndicator(
        onRefresh: _ctr.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: 7,
                left: StyleString.safeSpace + padding.left,
                right: StyleString.safeSpace + padding.right,
                bottom: padding.bottom + 100,
              ),
              sliver: Obx(() => _buildBody(_ctr.loadingState.value)),
            ),
          ],
        ),
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth,
    childAspectRatio: StyleString.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(75),
  );

  Widget _buildBody(LoadingState<List<CoinLikeArcItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: 16,
        itemBuilder: (context, index) => const VideoCardVSkeleton(),
      ),
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: response!.length,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _ctr.onLoadMore();
                  }
                  return MemberCoinLikeItem(item: response[index]);
                },
              )
            : HttpError(onReload: _ctr.onReload),
      Error(:var errMsg) => HttpError(errMsg: errMsg, onReload: _ctr.onReload),
    };
  }
}
