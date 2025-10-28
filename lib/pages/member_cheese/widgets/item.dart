import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/badge.dart';
import 'package:bili_plus/common/widgets/button/icon_button.dart';
import 'package:bili_plus/common/widgets/image/image_save.dart';
import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/models_new/space/space_cheese/item.dart';
import 'package:bili_plus/utils/date_utils.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';

class MemberCheeseItem extends StatelessWidget {
  const MemberCheeseItem({super.key, required this.item, this.onRemove});

  final SpaceCheeseItem item;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title!, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (item.status != null) ...[
          const SizedBox(height: 6),
          Text(
            item.status!,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (item.ctime != null) ...[
          const Spacer(),
          Text(
            '收藏于${DateFormatUtils.dateFormat(int.parse(item.ctime!))}',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
          ),
        ],
      ],
    );
    if (onRemove != null) {
      child = Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            right: 0,
            bottom: -8,
            child: iconButton(
              tooltip: '移除',
              onPressed: onRemove,
              icon: const Icon(Icons.clear),
              iconColor: theme.colorScheme.outline,
            ),
          ),
        ],
      );
    }
    void onLongPress() => imageSaveDialog(title: item.title, cover: item.cover);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => PageUtils.viewPugv(seasonId: item.seasonId),
        onLongPress: onLongPress,
        onSecondaryTap: Utils.isMobile ? null : onLongPress,
        child: Padding(
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
                    Widget child = NetworkImgLayer(
                      radius: 4,
                      src: item.cover,
                      width: boxConstraints.maxWidth,
                      height: boxConstraints.maxHeight,
                    );
                    if (item.marks?.isNotEmpty == true) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          child,
                          PBadge(right: 6, top: 6, text: item.marks!.join('|')),
                        ],
                      );
                    }
                    return child;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
