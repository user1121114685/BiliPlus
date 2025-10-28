import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/badge.dart';
import 'package:bili_plus/common/widgets/button/icon_button.dart';
import 'package:bili_plus/common/widgets/image/image_save.dart';
import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/common/widgets/select_mask.dart';
import 'package:bili_plus/common/widgets/stat/stat.dart';
import 'package:bili_plus/grpc/bilibili/app/listener/v1.pbenum.dart'
    show PlaylistSource;
import 'package:bili_plus/models/common/badge_type.dart';
import 'package:bili_plus/models/common/stat_type.dart';
import 'package:bili_plus/models_new/fav/fav_detail/media.dart';
import 'package:bili_plus/pages/audio/view.dart';
import 'package:bili_plus/pages/fav_detail/controller.dart';
import 'package:bili_plus/utils/date_utils.dart';
import 'package:bili_plus/utils/duration_utils.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 收藏视频卡片 - 水平布局
class FavVideoCardH extends StatelessWidget {
  final FavDetailItemModel item;
  final int? index;
  final BaseFavController? ctr;

  const FavVideoCardH({
    super.key,
    required this.item,
    this.index,
    this.ctr,
  }) : assert(ctr == null || index != null);

  bool get isSort => ctr == null;

  @override
  Widget build(BuildContext context) {
    final isOwner = !isSort && ctr!.isOwner;
    late final enableMultiSelect = ctr?.enableMultiSelect.value ?? false;
    final theme = Theme.of(context);

    final onLongPress = isSort || enableMultiSelect
        ? null
        : isOwner && !enableMultiSelect
        ? () {
            ctr!
              ..enableMultiSelect.value = true
              ..onSelect(item);
          }
        : () => imageSaveDialog(
            title: item.title,
            cover: item.cover,
            bvid: item.bvid,
          );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: isSort
            ? null
            : enableMultiSelect
            ? () => ctr!.onSelect(item)
            : () {
                if (!const [0, 16].contains(item.attr)) {
                  Get.toNamed('/member?mid=${item.upper?.mid}');
                  return;
                }

                switch (item.type) {
                  case 12:
                    AudioPage.toAudioPage(
                      oid: item.id!,
                      itemType: 3,
                      from: PlaylistSource.AUDIO_CARD,
                    );
                    break;
                  case 24:
                    PageUtils.viewPgc(
                      seasonId: item.ogv!.seasonId,
                      epId: item.id,
                    );
                    break;
                  default:
                    ctr!.onViewFav(item, index);
                    break;
                }
              },
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
                    double maxWidth = boxConstraints.maxWidth;
                    double maxHeight = boxConstraints.maxHeight;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        NetworkImgLayer(
                          src: item.cover,
                          width: maxWidth,
                          height: maxHeight,
                        ),
                        PBadge(
                          text: DurationUtils.formatDuration(item.duration),
                          right: 6.0,
                          bottom: 6.0,
                          type: PBadgeType.gray,
                        ),
                        if (item.type == 12)
                          const PBadge(
                            text: '音频',
                            top: 6.0,
                            right: 6.0,
                            type: PBadgeType.gray,
                          )
                        else
                          PBadge(
                            text: item.ogv?.typeName,
                            top: 6.0,
                            right: 6.0,
                            bottom: null,
                            left: null,
                          ),
                        if (!isSort)
                          Positioned.fill(
                            child: selectMask(
                              theme,
                              item.checked == true,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              content(context, theme, isOwner),
            ],
          ),
        ),
      ),
    );
  }

  Widget content(BuildContext context, ThemeData theme, isOwner) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            spacing: 3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title!,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.type == 24 && item.intro?.isNotEmpty == true)
                Text(
                  item.intro!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.outline,
                  ),
                ),
              const Spacer(),
              Text(
                '${DateFormatUtils.dateFormat(item.favTime)} ${item.upper?.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1,
                  fontSize: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
              if (item.type != 24)
                Row(
                  spacing: 8,
                  children: [
                    StatWidget(
                      type: StatType.play,
                      value: item.cntInfo?.play,
                    ),
                    StatWidget(
                      type: StatType.danmaku,
                      value: item.cntInfo?.danmaku,
                    ),
                  ],
                ),
            ],
          ),
          if (isOwner)
            Positioned(
              right: 0,
              bottom: -8,
              child: iconButton(
                icon: const Icon(Icons.clear),
                tooltip: '取消收藏',
                iconColor: theme.colorScheme.outline,
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('提示'),
                      content: const Text('要取消收藏吗?'),
                      actions: [
                        TextButton(
                          onPressed: Get.back,
                          child: Text(
                            '取消',
                            style: TextStyle(color: theme.colorScheme.outline),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            ctr!.onCancelFav(index!, item.id!, item.type!);
                          },
                          child: const Text('确定取消'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
