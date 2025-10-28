import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/badge.dart';
import 'package:bili_plus/common/widgets/image/image_save.dart';
import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/models/common/badge_type.dart';
import 'package:bili_plus/models_new/pgc/pgc_index_result/list.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';

// 视频卡片 - 垂直布局
class PgcCardVPgcIndex extends StatelessWidget {
  const PgcCardVPgcIndex({super.key, required this.item});

  final PgcIndexItem item;

  @override
  Widget build(BuildContext context) {
    void onLongPress() => imageSaveDialog(title: item.title, cover: item.cover);
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: StyleString.mdRadius),
      child: InkWell(
        borderRadius: StyleString.mdRadius,
        onTap: () => PageUtils.viewPgc(seasonId: item.seasonId),
        onLongPress: onLongPress,
        onSecondaryTap: Utils.isMobile ? null : onLongPress,
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
                      PBadge(
                        text: item.badge,
                        top: 6,
                        right: 6,
                        bottom: null,
                        left: null,
                      ),
                      PBadge(
                        text: item.order,
                        top: null,
                        right: null,
                        bottom: 6,
                        left: 6,
                        type: PBadgeType.gray,
                      ),
                    ],
                  );
                },
              ),
            ),
            conetent(context),
          ],
        ),
      ),
    );
  }

  Widget conetent(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 5, 0, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title!,
              textAlign: TextAlign.start,
              style: const TextStyle(letterSpacing: 0.3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            if (item.indexShow != null)
              Text(
                item.indexShow!,
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
