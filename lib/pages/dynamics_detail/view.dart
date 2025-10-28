import 'dart:math';

import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/font_icon/bilibili_icons.dart';
import 'package:bili_plus/http/constants.dart';
import 'package:bili_plus/models/dynamics/result.dart';
import 'package:bili_plus/pages/common/dyn/common_dyn_page.dart';
import 'package:bili_plus/pages/dynamics/widgets/author_panel.dart';
import 'package:bili_plus/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:bili_plus/pages/dynamics_detail/controller.dart';
import 'package:bili_plus/pages/dynamics_repost/view.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:bili_plus/utils/num_utils.dart';
import 'package:bili_plus/utils/request_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;

class DynamicDetailPage extends StatefulWidget {
  const DynamicDetailPage({super.key});

  @override
  State<DynamicDetailPage> createState() => _DynamicDetailPageState();
}

class _DynamicDetailPageState extends CommonDynPageState<DynamicDetailPage> {
  @override
  final DynamicDetailController controller = Get.putOrFind(
    DynamicDetailController.new,
    tag: (Get.arguments['item'] as DynamicItemModel).idStr.toString(),
  );

  @override
  dynamic get arguments => {'item': controller.dynItem};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        controller.showTitle.value =
            scrollController.positions.first.pixels > 55;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: padding.left, right: padding.right),
        child: isPortrait
            ? refreshIndicator(
                onRefresh: controller.onRefresh,
                child: _buildBody(theme),
              )
            : _buildBody(theme),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    title: Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Obx(() {
        final showTitle = controller.showTitle.value;
        return AnimatedOpacity(
          opacity: showTitle ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !showTitle,
            child: AuthorPanel(item: controller.dynItem, isDetail: true),
          ),
        );
      }),
    ),
    actions: isPortrait
        ? null
        : [ratioWidget(maxWidth), const SizedBox(width: 16)],
  );

  Widget _buildBody(ThemeData theme) {
    double padding = max(maxWidth / 2 - Grid.smallCardWidth, 0);
    Widget child;
    if (isPortrait) {
      child = Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DynamicPanel(
                item: controller.dynItem,
                isDetail: true,
                maxWidth: maxWidth - this.padding.horizontal - 2 * padding,
                isDetailPortraitW: isPortrait,
              ),
            ),
            buildReplyHeader(theme),
            Obx(() => replyList(theme, controller.loadingState.value)),
          ],
        ),
      );
    } else {
      padding = padding / 4;
      final flex = controller.ratio[0].toInt();
      final flex1 = controller.ratio[1].toInt();
      child = Row(
        children: [
          Expanded(
            flex: flex,
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: padding,
                    bottom: this.padding.bottom + 100,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: DynamicPanel(
                      item: controller.dynItem,
                      isDetail: true,
                      maxWidth:
                          (maxWidth - this.padding.horizontal) *
                              (flex / (flex + flex1)) -
                          padding,
                      isDetailPortraitW: isPortrait,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: flex1,
            child: Padding(
              padding: EdgeInsets.only(right: padding),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: false,
                body: refreshIndicator(
                  onRefresh: controller.onRefresh,
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      buildReplyHeader(theme),
                      Obx(
                        () => replyList(theme, controller.loadingState.value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [child, _buildBottom(theme)],
    );
  }

  Widget _buildBottom(ThemeData theme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: fabAnim,
        child: Builder(
          builder: (context) {
            if (!controller.showDynActionBar) {
              return Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: kFloatingActionButtonMargin,
                    bottom: padding.bottom + kFloatingActionButtonMargin,
                  ),
                  child: replyButton,
                ),
              );
            }

            final moduleStat = controller.dynItem.modules.moduleStat;
            final primary = theme.colorScheme.primary;
            final outline = theme.colorScheme.outline;
            final btnStyle = TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              foregroundColor: outline,
            );

            Widget textIconButton({
              required IconData icon,
              required String text,
              required DynamicStat? stat,
              required VoidCallback onPressed,
              IconData? activitedIcon,
            }) {
              final status = stat?.status == true;
              final color = status ? primary : outline;
              return TextButton.icon(
                onPressed: onPressed,
                icon: Icon(
                  status ? activitedIcon : icon,
                  size: 16,
                  color: color,
                ),
                style: btnStyle,
                label: Text(
                  stat?.count != null ? NumUtils.numFormat(stat!.count) : text,
                  style: TextStyle(color: color),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: kFloatingActionButtonMargin,
                    bottom: kFloatingActionButtonMargin,
                  ),
                  child: replyButton,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(bottom: padding.bottom),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (btnContext) {
                            final forward = moduleStat?.forward;
                            return textIconButton(
                              icon: BiliBiliIcons.arrow_share_line500,
                              text: '转发',
                              stat: forward,
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (context) => RepostPanel(
                                  item: controller.dynItem,
                                  callback: () {
                                    if (forward != null) {
                                      int count = forward.count ?? 0;
                                      forward.count = count + 1;
                                      if (btnContext.mounted) {
                                        (btnContext as Element)
                                            .markNeedsBuild();
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: textIconButton(
                          icon: BiliBiliIcons.arrow_share_line500,
                          text: '分享',
                          stat: null,
                          onPressed: () => Utils.shareText(
                            '${HttpString.dynamicShareBaseUrl}/${controller.dynItem.idStr}',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            return textIconButton(
                              icon: BiliBiliIcons.hand_thumbsup_line500,
                              activitedIcon:
                                  BiliBiliIcons.hand_thumbsup_fill500,
                              text: '点赞',
                              stat: moduleStat?.like,
                              onPressed: () => RequestUtils.onLikeDynamic(
                                controller.dynItem,
                                () {
                                  if (context.mounted) {
                                    (context as Element).markNeedsBuild();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
