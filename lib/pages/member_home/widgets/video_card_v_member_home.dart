import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/badge.dart';
import 'package:bili_plus/common/widgets/image/image_save.dart';
import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/http/search.dart';
import 'package:bili_plus/models/common/badge_type.dart';
import 'package:bili_plus/models_new/space/space_archive/item.dart';
import 'package:bili_plus/utils/app_scheme.dart';
import 'package:bili_plus/utils/duration_utils.dart';
import 'package:bili_plus/utils/id_utils.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';

// 视频卡片 - 垂直布局
class VideoCardVMemberHome extends StatelessWidget {
  final SpaceArchiveItem videoItem;

  const VideoCardVMemberHome({super.key, required this.videoItem});

  Future<void> onPushDetail() async {
    String? goto = videoItem.goto;
    switch (goto) {
      case 'bangumi':
        PageUtils.viewPgc(epId: videoItem.param);
        break;

      case 'av':
        if (videoItem.isPgc == true) {
          if (videoItem.uri?.isNotEmpty == true) {
            PageUtils.viewPgcFromUri(videoItem.uri!);
          }
          return;
        }

        String? aid = videoItem.param;
        String? bvid = videoItem.bvid;
        if (aid == null && bvid == null) {
          return;
        }

        bvid ??= IdUtils.av2bv(int.parse(aid!));
        int? cid = videoItem.cid ?? await SearchHttp.ab2c(aid: aid, bvid: bvid);
        if (cid != null) {
          PageUtils.toVideoPage(
            bvid: bvid,
            cid: cid,
            cover: videoItem.cover,
            title: videoItem.title,
          );
        }
        break;

      default:
        if (videoItem.uri?.isNotEmpty == true) {
          PiliScheme.routePushFromUrl(videoItem.uri!);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    void onLongPress() => imageSaveDialog(
      title: videoItem.title,
      cover: videoItem.cover,
      aid: videoItem.param,
      bvid: videoItem.bvid,
    );
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPushDetail,
        onLongPress: onLongPress,
        onSecondaryTap: Utils.isMobile ? null : onLongPress,
        child: Column(
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
                        src: videoItem.cover,
                        width: maxWidth,
                        height: maxHeight,
                        radius: 0,
                      ),
                      if (videoItem.duration > 0)
                        PBadge(
                          bottom: 6,
                          right: 7,
                          size: PBadgeSize.small,
                          type: PBadgeType.gray,
                          text: DurationUtils.formatDuration(
                            videoItem.duration,
                          ),
                        ),
                      if (videoItem.badges?.isNotEmpty == true)
                        PBadge(
                          text: videoItem.badges!
                              .map((e) => e.text ?? '')
                              .join('|'),
                          top: 6,
                          right: 6,
                          type: videoItem.badges!.first.text == '充电专属'
                              ? PBadgeType.error
                              : PBadgeType.primary,
                        )
                      else if (videoItem.isCooperation == true)
                        const PBadge(text: '合作', top: 6, right: 6)
                      else if (videoItem.isSteins == true)
                        const PBadge(text: '互动', top: 6, right: 6),
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
        child: Text(
          '${videoItem.title}\n',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(height: 1.38),
        ),
      ),
    );
  }
}
