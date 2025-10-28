import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/badge.dart';
import 'package:bili_plus/common/widgets/image/image_save.dart';
import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/models/common/badge_type.dart';
import 'package:bili_plus/models_new/pgc/pgc_timeline/episode.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';

// 视频卡片 - 垂直布局
class PgcCardVTimeline extends StatelessWidget {
  const PgcCardVTimeline({super.key, required this.item});

  final Episode item;

  @override
  Widget build(BuildContext context) {
    void onLongPress() => imageSaveDialog(title: item.title, cover: item.cover);
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: StyleString.mdRadius),
      child: InkWell(
        borderRadius: StyleString.mdRadius,
        onLongPress: onLongPress,
        onSecondaryTap: Utils.isMobile ? null : onLongPress,
        onTap: () =>
            PageUtils.viewPgc(seasonId: item.seasonId, epId: item.episodeId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.75,
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  final double maxWidth = boxConstraints.maxWidth;
                  final double maxHeight = boxConstraints.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NetworkImgLayer(
                        src: item.cover,
                        width: maxWidth,
                        height: maxHeight,
                      ),
                      if (item.follow == 1)
                        const PBadge(text: '已追番', right: 6, top: 6),
                      PBadge(
                        text: '${item.pubTime}',
                        left: 6,
                        bottom: 6,
                        type: PBadgeType.gray,
                      ),
                    ],
                  );
                },
              ),
            ),
            content(context),
          ],
        ),
      ),
    );
  }

  Widget content(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 5, 0, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? '',
              textAlign: TextAlign.start,
              style: const TextStyle(letterSpacing: 0.3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.pubIndex ?? '',
              maxLines: 1,
              style: TextStyle(
                fontSize: theme.textTheme.labelMedium!.fontSize,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
