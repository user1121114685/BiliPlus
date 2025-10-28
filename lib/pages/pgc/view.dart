import 'dart:math';

import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/button/more_btn.dart';
import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/loading_widget/loading_widget.dart';
import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/common/widgets/scroll_physics.dart';
import 'package:bili_plus/common/widgets/view_safe_area.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models/common/fav_type.dart';
import 'package:bili_plus/models/common/home_tab_type.dart';
import 'package:bili_plus/models_new/fav/fav_pgc/list.dart';
import 'package:bili_plus/models_new/pgc/pgc_index_result/list.dart';
import 'package:bili_plus/models_new/pgc/pgc_timeline/result.dart';
import 'package:bili_plus/pages/common/common_page.dart';
import 'package:bili_plus/pages/pgc/controller.dart';
import 'package:bili_plus/pages/pgc/widgets/pgc_card_v.dart';
import 'package:bili_plus/pages/pgc/widgets/pgc_card_v_timeline.dart';
import 'package:bili_plus/pages/pgc_index/controller.dart';
import 'package:bili_plus/pages/pgc_index/view.dart';
import 'package:bili_plus/pages/pgc_index/widgets/pgc_card_v_pgc_index.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PgcPage extends StatefulWidget {
  const PgcPage({super.key, required this.tabType});

  final HomeTabType tabType;

  @override
  State<PgcPage> createState() => _PgcPageState();
}

class _PgcPageState extends CommonPageState<PgcPage, PgcController>
    with AutomaticKeepAliveClientMixin {
  @override
  late PgcController controller = Get.put(
    PgcController(tabType: widget.tabType),
    tag: widget.tabType.name,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData theme = Theme.of(context);
    return onBuild(
      refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildFollow(theme),
            if (controller.showPgcTimeline)
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      Grid.smallCardWidth / 2 / 0.75 +
                      MediaQuery.textScalerOf(context).scale(96),
                  child: Obx(
                    () => _buildTimeline(theme, controller.timelineState.value),
                  ),
                ),
              ),
            ..._buildRcmd(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(
    ThemeData theme,
    LoadingState<List<TimelineResult>?> loadingState,
  ) => switch (loadingState) {
    Loading() => loadingWidget,
    Success(:var response) =>
      response?.isNotEmpty == true
          ? Builder(
              builder: (context) {
                final initialIndex = max(
                  0,
                  response!.indexWhere((item) => item.isToday == 1),
                );
                return DefaultTabController(
                  initialIndex: initialIndex,
                  length: response.length,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Text('追番时间表', style: theme.textTheme.titleMedium),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              dividerHeight: 0,
                              overlayColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              splashFactory: NoSplash.splashFactory,
                              padding: const EdgeInsets.only(right: 10),
                              indicatorPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 10,
                              ),
                              indicator: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor:
                                  theme.colorScheme.onSecondaryContainer,
                              labelStyle:
                                  TabBarTheme.of(
                                    context,
                                  ).labelStyle?.copyWith(fontSize: 14) ??
                                  const TextStyle(fontSize: 14),
                              dividerColor: Colors.transparent,
                              tabs: response.map((item) {
                                return Tab(
                                  text:
                                      '${item.date} ${item.isToday == 1 ? '今天' : '周${const ['一', '二', '三', '四', '五', '六', '日'][item.dayOfWeek! - 1]}'}',
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: response.map((item) {
                            if (item.episodes.isNullOrEmpty) {
                              return const SizedBox.shrink();
                            }
                            return ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: item.episodes!.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: Grid.smallCardWidth / 2,
                                  margin: EdgeInsets.only(
                                    left: StyleString.safeSpace,
                                    right: index == item.episodes!.length - 1
                                        ? StyleString.safeSpace
                                        : 0,
                                  ),
                                  child: PgcCardVTimeline(
                                    item: item.episodes![index],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : const SizedBox.shrink(),
    Error(:var errMsg) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.queryPgcTimeline,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Text(errMsg ?? '', textAlign: TextAlign.center),
      ),
    ),
  };

  List<Widget> _buildRcmd(ThemeData theme) => [
    _buildRcmdTitle(theme),
    SliverPadding(
      padding: const EdgeInsets.only(
        left: StyleString.safeSpace,
        right: StyleString.safeSpace,
        bottom: 100,
      ),
      sliver: Obx(() => _buildRcmdBody(controller.loadingState.value)),
    ),
  ];

  Widget _buildRcmdTitle(ThemeData theme) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('推荐', style: theme.textTheme.titleMedium),
          moreTextButton(
            padding: const EdgeInsets.symmetric(vertical: 2),
            onTap: () {
              if (widget.tabType == HomeTabType.bangumi) {
                Get.to(const PgcIndexPage());
              } else {
                List<String> titles = const ['全部', '电影', '电视剧', '纪录片', '综艺'];
                List<int> types = const [102, 2, 5, 3, 7];
                Get.to(
                  Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(title: const Text('索引')),
                    body: DefaultTabController(
                      length: types.length,
                      child: Builder(
                        builder: (context) {
                          return Column(
                            children: [
                              ViewSafeArea(
                                child: TabBar(
                                  tabs: titles
                                      .map((title) => Tab(text: title))
                                      .toList(),
                                  onTap: (index) {
                                    try {
                                      if (!DefaultTabController.of(
                                        context,
                                      ).indexIsChanging) {
                                        Get.find<PgcIndexController>(
                                          tag: types[index].toString(),
                                        ).animateToTop();
                                      }
                                    } catch (_) {}
                                  },
                                ),
                              ),
                              Expanded(
                                child: tabBarView(
                                  children: types
                                      .map(
                                        (type) => PgcIndexPage(indexType: type),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              }
            },
            color: theme.colorScheme.secondary,
          ),
        ],
      ),
    ),
  );

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth * 0.6,
    childAspectRatio: 0.75,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(50),
  );

  Widget _buildRcmdBody(LoadingState<List<PgcIndexItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => const SliverToBoxAdapter(),
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore();
                  }
                  return PgcCardVPgcIndex(item: response[index]);
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

  Widget _buildFollow(ThemeData theme) => SliverToBoxAdapter(
    child: Obx(
      () => controller.accountService.isLogin.value
          ? Column(
              children: [
                _buildFollowTitle(theme),
                SizedBox(
                  height:
                      Grid.smallCardWidth / 2 / 0.75 +
                      MediaQuery.textScalerOf(context).scale(50),
                  child: Obx(
                    () => _buildFollowBody(controller.followState.value),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    ),
  );

  Widget _buildFollowTitle(ThemeData theme) => Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Row(
      children: [
        Obx(
          () => Text(
            '最近${widget.tabType == HomeTabType.bangumi ? '追番' : '追剧'}${controller.followCount.value == -1 ? '' : ' ${controller.followCount.value}'}',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: '刷新',
          onPressed: () => controller
            ..followPage = 1
            ..followEnd = false
            ..queryPgcFollow(),
          icon: const Icon(Icons.refresh, size: 20),
        ),
        Obx(
          () => controller.accountService.isLogin.value
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: moreTextButton(
                    text: '查看全部',
                    onTap: () => Get.toNamed(
                      '/fav',
                      arguments: widget.tabType == HomeTabType.bangumi
                          ? FavTabType.bangumi.index
                          : FavTabType.cinema.index,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: theme.colorScheme.secondary,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );

  Widget _buildFollowBody(LoadingState<List<FavPgcItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success(:var response) =>
        response?.isNotEmpty == true
            ? ListView.builder(
                controller: controller.followController,
                scrollDirection: Axis.horizontal,
                itemCount: response!.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.queryPgcFollow(false);
                  }
                  return Container(
                    width: Grid.smallCardWidth / 2,
                    margin: EdgeInsets.only(
                      left: StyleString.safeSpace,
                      right: index == response.length - 1
                          ? StyleString.safeSpace
                          : 0,
                    ),
                    child: PgcCardV(item: response[index]),
                  );
                },
              )
            : Center(
                child: Text(
                  '还没有${widget.tabType == HomeTabType.bangumi ? '追番' : '追剧'}',
                ),
              ),
      Error(:var errMsg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Text(errMsg ?? '', textAlign: TextAlign.center),
      ),
    };
  }
}
