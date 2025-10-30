import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/badge.dart';
import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/common/widgets/progress_bar/video_progress_indicator.dart';
import 'package:bili_plus/common/widgets/select_mask.dart';
import 'package:bili_plus/font_icon/bilibili_icons.dart';
import 'package:bili_plus/http/search.dart';
import 'package:bili_plus/http/user.dart';
import 'package:bili_plus/models/common/badge_type.dart';
import 'package:bili_plus/models_new/history/list.dart';
import 'package:bili_plus/pages/common/multi_select/base.dart';
import 'package:bili_plus/utils/date_utils.dart';
import 'package:bili_plus/utils/duration_utils.dart';
import 'package:bili_plus/utils/id_utils.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class HistoryItem extends StatelessWidget {
  final HistoryItemModel item;
  final MultiSelectBase ctr;
  final void Function(int kid, String business) onDelete;

  const HistoryItem({
    super.key,
    required this.item,
    required this.ctr,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDuration = item.duration != null && item.duration != 0;
    int aid = item.history.oid!;
    String bvid = item.history.bvid ?? IdUtils.av2bv(aid);
    final business = item.history.business;
    final enableMultiSelect = ctr.enableMultiSelect.value;

    final onLongPress = enableMultiSelect
        ? null
        : () => ctr
            ..enableMultiSelect.value = true
            ..onSelect(item);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enableMultiSelect
            ? () => ctr.onSelect(item)
            : () async {
                if (business?.contains('article') == true) {
                  PageUtils.toDupNamed(
                    '/articlePage',
                    parameters: {
                      'id': business == 'article-list'
                          ? '${item.history.cid}'
                          : '${item.history.oid}',
                      'type': 'read',
                    },
                  );
                } else if (business == 'live') {
                  if (item.liveStatus == 1) {
                    PageUtils.toLiveRoom(item.history.oid);
                  } else {
                    SmartDialog.showToast('直播未开播');
                  }
                } else if (business == 'pgc') {
                  PageUtils.viewPgc(epId: item.history.epid);
                } else if (business == 'cheese') {
                  if (item.uri?.isNotEmpty == true) {
                    PageUtils.viewPgcFromUri(
                      item.uri!,
                      isPgc: false,
                      aid: item.history.oid,
                    );
                  }
                } else {
                  int? cid =
                      item.history.cid ??
                      await SearchHttp.ab2c(
                        aid: aid,
                        bvid: bvid,
                        part: item.history.page,
                      );
                  if (cid != null) {
                    PageUtils.toVideoPage(
                      aid: aid,
                      bvid: bvid,
                      cid: cid,
                      cover: item.cover,
                      title: item.title,
                    );
                  }
                }
              },
        onLongPress: onLongPress,
        onSecondaryTap: Utils.isMobile ? null : onLongPress,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: StyleString.safeSpace,
                vertical: 5,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        double maxWidth = boxConstraints.maxWidth;
                        double maxHeight = boxConstraints.maxHeight;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NetworkImgLayer(
                              src: item.cover?.isNotEmpty == true
                                  ? item.cover
                                  : item.covers?.firstOrNull ?? '',
                              width: maxWidth,
                              height: maxHeight,
                            ),
                            if (hasDuration)
                              PBadge(
                                text: item.progress == -1
                                    ? '已看完'
                                    : '${DurationUtils.formatDuration(item.progress)}/${DurationUtils.formatDuration(item.duration)}',
                                right: 6.0,
                                bottom: 8.0,
                                type: PBadgeType.gray,
                              ),
                            if (item.isFav == 1)
                              const PBadge(
                                text: '已收藏',
                                top: 6.0,
                                right: 6.0,
                                type: PBadgeType.gray,
                              )
                            else if (item.badge?.isNotEmpty == true)
                              PBadge(
                                text: item.badge,
                                top: 6.0,
                                right: 6.0,
                                type: business == 'live' && item.liveStatus != 1
                                    ? PBadgeType.gray
                                    : PBadgeType.primary,
                              ),
                            if (hasDuration &&
                                item.progress != null &&
                                item.progress != 0)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: videoProgressIndicator(
                                  item.progress == -1
                                      ? 1
                                      : item.progress! / item.duration!,
                                ),
                              ),
                            Positioned.fill(
                              child: selectMask(theme, item.checked == true),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  content(theme),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 0,
              child: SizedBox(
                width: 29,
                height: 29,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  tooltip: '功能菜单',
                  icon: Icon(
                    Icons.more_vert_outlined,
                    color: theme.colorScheme.outline,
                    size: 18,
                  ),
                  position: PopupMenuPosition.under,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        if (item.authorMid != null &&
                            item.authorName?.isNotEmpty == true)
                          PopupMenuItem<String>(
                            onTap: () =>
                                Get.toNamed('/member?mid=${item.authorMid}'),
                            height: 35,
                            child: Row(
                              children: [
                                Icon(
                                  BiliBiliIcons.uploader_name_square_line500,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '访问：${item.authorName}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        if (business != 'pgc' &&
                            item.badge != '番剧' &&
                            item.tagName?.contains('动画') != true &&
                            business != 'live' &&
                            business?.contains('article') != true)
                          PopupMenuItem<String>(
                            onTap: () async {
                              var res = await UserHttp.toViewLater(
                                bvid: item.history.bvid,
                              );
                              SmartDialog.showToast(res['msg']);
                            },
                            height: 35,
                            child: const Row(
                              children: [
                                Icon(Icons.watch_later_outlined, size: 16),
                                SizedBox(width: 6),
                                Text('稍后再看', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        PopupMenuItem<String>(
                          onTap: () => onDelete(item.kid!, business!),
                          height: 35,
                          child: const Row(
                            children: [
                              Icon(Icons.close_outlined, size: 16),
                              SizedBox(width: 6),
                              Text('删除记录', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget content(ThemeData theme) {
    return Expanded(
      child: Column(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title!,
            style: TextStyle(
              fontSize: theme.textTheme.bodyMedium!.fontSize,
              height: 1.42,
              letterSpacing: 0.3,
            ),
            maxLines: item.videos! > 1 ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.history.business == 'pgc' &&
              item.showTitle?.isNotEmpty == true)
            Text(
              item.showTitle!,
              style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          if (item.authorName?.isNotEmpty == true)
            Text(
              item.authorName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: theme.textTheme.labelMedium!.fontSize,
                color: theme.colorScheme.outline,
              ),
            ),
          Text(
            DateFormatUtils.chatFormat(item.viewAt!, isHistory: true),
            style: TextStyle(
              fontSize: theme.textTheme.labelMedium!.fontSize,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
