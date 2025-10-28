import 'dart:typed_data';
import 'dart:ui';

import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/button/icon_button.dart';
import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:bili_plus/models/common/video/video_type.dart';
import 'package:bili_plus/models/dynamics/result.dart';
import 'package:bili_plus/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:bili_plus/pages/music/controller.dart';
import 'package:bili_plus/pages/video/introduction/pgc/controller.dart';
import 'package:bili_plus/pages/video/introduction/ugc/controller.dart';
import 'package:bili_plus/pages/video/reply/widgets/reply_item_grpc.dart';
import 'package:bili_plus/utils/context_ext.dart';
import 'package:bili_plus/utils/date_utils.dart';
import 'package:bili_plus/utils/image_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:intl/intl.dart' show DateFormat;
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';

class SavePanel extends StatefulWidget {
  const SavePanel({
    required this.item,
    // reply
    this.upMid,
    super.key,
  });

  final dynamic upMid;
  final dynamic item;

  @override
  State<SavePanel> createState() => _SavePanelState();

  static void toSavePanel({dynamic upMid, dynamic item}) {
    Get.generalDialog(
      barrierLabel: '',
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SavePanel(upMid: upMid, item: item);
      },
      transitionDuration: const Duration(milliseconds: 255),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween<double>(
              begin: 0,
              end: 1,
            ).chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        );
      },
      routeSettings: RouteSettings(arguments: Get.arguments),
    );
  }
}

class _SavePanelState extends State<SavePanel> {
  final boundaryKey = GlobalKey();

  bool showBottom = true;

  // item
  Object get _item => widget.item;
  late String viewType = '查看';
  late String itemType = '内容';

  //reply
  String? cover;
  _CoverType coverType = _CoverType.def16_9;
  String? title;
  int? pubdate;
  DateFormat dateFormat = DateFormatUtils.longFormatDs;
  String? uname;

  String uri = '';

  @override
  void initState() {
    super.initState();
    if (_item case ReplyInfo reply) {
      itemType = '评论';
      final currentRoute = Get.currentRoute;
      late final hasRoot = reply.hasRoot();

      if (currentRoute.startsWith('/video')) {
        final rootId = hasRoot ? reply.root : reply.id;

        uri =
            'https://www.bilibili.com/video/av${reply.oid}?comment_on=1&comment_root_id=$rootId${hasRoot ? '&comment_secondary_id=${reply.id}' : ''}';
        try {
          final heroTag = Get.arguments['heroTag'];
          final videoType = Get.arguments['videoType'];
          if (videoType == VideoType.pgc || videoType == VideoType.pugv) {
            final ctr = Get.find<PgcIntroController>(tag: heroTag);
            final pgcItem = ctr.pgcItem;
            final cid = ctr.cid.value;
            final episode = pgcItem.episodes!.firstWhere((e) => e.cid == cid);
            cover = episode.cover;
            title =
                episode.shareCopy ??
                '${pgcItem.title} ${episode.showTitle ?? episode.longTitle ?? ''}';
            pubdate = episode.pubTime;
            uname = pgcItem.upInfo?.uname;

            final oid = reply.oid;
            final type = reply.type.toInt();
            final anchor = hasRoot ? 'anchor=${reply.id}&' : '';
            uri =
                'bilibili://comment/detail/$type/$oid/$rootId/?${anchor}enterUri=bilibili://pgc/season/ep/${ctr.epId}';
          } else {
            final ctr = Get.find<UgcIntroController>(tag: heroTag);
            final videoDetail = ctr.videoDetail.value;
            cover = videoDetail.pic;
            title = videoDetail.title;
            pubdate = videoDetail.pubdate;
            uname = videoDetail.owner?.name;

            final cid = ctr.cid.value;
            final part =
                ctr.videoDetail.value.pages?.indexWhere((i) => i.cid == cid) ??
                -1;
            if (part > 0) uri += '&p=${part + 1}';
          }
        } catch (_) {}
      } else if (currentRoute.startsWith('/dynamicDetail')) {
        DynamicItemModel? dynItem;
        try {
          dynItem = Get.arguments['item'] as DynamicItemModel;
          uname = dynItem.modules.moduleAuthor?.name;
        } catch (_) {}
        final type = reply.type.toInt();
        final oid = reply.oid;
        final rootId = hasRoot ? reply.root : reply.id;

        if (type == 1) {
          uri =
              'https://www.bilibili.com/video/av$oid?comment_on=1&comment_root_id=$rootId${hasRoot ? '&comment_secondary_id=${reply.id}' : ''}';
        } else {
          final enterUri = dynItem == null
              ? ''
              : 'enterUri=${parseDyn(dynItem)}';
          uri =
              'bilibili://comment/detail/$type/$oid/$rootId/?${hasRoot ? 'anchor=${reply.id}&' : ''}$enterUri';
        }
      } else if (currentRoute.startsWith('/Scaffold')) {
        try {
          final type = reply.type.toInt();
          final oid = Get.arguments['oid'] ?? reply.oid;
          final rootId = hasRoot ? reply.root : reply.id;
          if (type == 1) {
            uri =
                'https://www.bilibili.com/video/av$oid?comment_on=1&comment_root_id=$rootId${hasRoot ? '&comment_secondary_id=${reply.id}' : ''}';
          } else {
            String enterUri = Get.arguments['enterUri'] ?? '';
            if (enterUri.isNotEmpty) {
              enterUri = 'enterUri=${Uri.encodeComponent(enterUri)}';
            } else if (const [11, 12, 17].contains(type)) {
              enterUri = 'enterUri=bilibili://following/detail/$oid';
            }
            uri =
                'bilibili://comment/detail/$type/$oid/$rootId/?${hasRoot ? 'anchor=${reply.id}&' : ''}$enterUri';
          }
        } catch (_) {}
      } else if (currentRoute.startsWith('/articlePage')) {
        try {
          final type = reply.type.toInt();
          final oid = reply.oid;
          final rootId = hasRoot ? reply.root : reply.id;
          final anchor = hasRoot ? 'anchor=${reply.id}&' : '';
          final enterUri =
              'bilibili://following/detail/${Get.parameters['id'] ?? Get.arguments?['id']}';
          uri =
              'bilibili://comment/detail/$type/$oid/$rootId/?${anchor}enterUri=$enterUri';
        } catch (_) {}
      } else if (currentRoute.startsWith('/musicDetail')) {
        final type = reply.type.toInt();
        final oid = reply.oid;
        final rootId = hasRoot ? reply.root : reply.id;
        final anchor = hasRoot ? 'anchor=${reply.id}&' : '';
        String enterUri = '';
        try {
          final ctr = Get.find<MusicDetailController>(
            tag: Get.parameters['musicId'],
          );
          enterUri =
              'enterUri=${Uri.encodeComponent(ctr.shareUrl)}'; // official client cannot parse it
          final data = ctr.infoState.value.dataOrNull;
          if (data != null) {
            coverType = _CoverType.square;
            cover = data.mvCover;
            title = data.musicTitle;
            if (data.musicPublish != null) {
              final time = DateTime.tryParse(
                data.musicPublish!,
              )?.millisecondsSinceEpoch;
              if (time != null) {
                pubdate = time ~/ 1000;
                dateFormat = DateFormatUtils.longFormat;
              }
            }
          }
        } catch (_) {}
        uri = 'bilibili://comment/detail/$type/$oid/$rootId/?$anchor$enterUri';
      }

      if (kDebugMode) debugPrint(uri);
    } else if (_item case DynamicItemModel i) {
      uri = parseDyn(i);

      if (kDebugMode) debugPrint(uri);
    }
  }

  String parseDyn(DynamicItemModel item) {
    String uri = '';
    try {
      switch (item.type) {
        case 'DYNAMIC_TYPE_AV':
          viewType = '观看';
          itemType = '视频';
          uri = 'bilibili://video/${item.basic!.commentIdStr}';
          break;

        case 'DYNAMIC_TYPE_ARTICLE':
          itemType = '专栏';
          uri = 'bilibili://following/detail/${item.idStr}';
          break;

        case 'DYNAMIC_TYPE_LIVE_RCMD':
          viewType = '观看';
          itemType = '直播';
          final roomId = item.modules.moduleDynamic!.major!.liveRcmd!.roomId;
          uri = 'bilibili://live/$roomId';
          break;

        case 'DYNAMIC_TYPE_UGC_SEASON':
          viewType = '观看';
          itemType = '合集';
          final aid = item.modules.moduleDynamic!.major!.ugcSeason!.aid;
          uri = 'bilibili://video/$aid';
          break;

        case 'DYNAMIC_TYPE_PGC':
        case 'DYNAMIC_TYPE_PGC_UNION':
          viewType = '观看';
          itemType =
              item.modules.moduleDynamic?.major?.pgc?.badge?.text ?? '番剧';
          final epid = item.modules.moduleDynamic!.major!.pgc!.epid;
          uri = 'bilibili://pgc/season/ep/$epid';
          break;

        // https://www.bilibili.com/medialist/detail/ml12345678
        case 'DYNAMIC_TYPE_MEDIALIST':
          itemType = '收藏夹';
          final mediaId = item.modules.moduleDynamic!.major!.medialist!.id;
          uri = 'bilibili://medialist/detail/$mediaId';
          break;

        // 纯文字动态查看
        // case 'DYNAMIC_TYPE_WORD':
        // # 装扮/剧集点评/普通分享
        // case 'DYNAMIC_TYPE_COMMON_SQUARE':
        // 转发的动态
        // case 'DYNAMIC_TYPE_FORWARD':
        // 图文动态查看
        // case 'DYNAMIC_TYPE_DRAW':
        default:
          itemType = '动态';
          uri = 'bilibili://following/detail/${item.idStr}';
          break;
      }
    } catch (_) {}
    return uri;
  }

  Future<void> _onSaveOrSharePic([bool isShare = false]) async {
    if (!isShare && Utils.isMobile) {
      if (mounted && !await ImageUtils.checkPermissionDependOnSdkInt(context)) {
        return;
      }
    }
    SmartDialog.showLoading();
    try {
      RenderRepaintBoundary boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      String picName =
          "${Constants.appName}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";
      if (isShare) {
        Get.back();
        SmartDialog.dismiss();
        SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(pngBytes, name: picName, mimeType: 'image/png'),
            ],
            sharePositionOrigin: await Utils.sharePositionOrigin,
          ),
        );
      } else {
        final result = await ImageUtils.saveByteImg(
          bytes: pngBytes,
          fileName: picName,
        );
        if (result != null) {
          if (result.isSuccess) {
            Get.back();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('on save/share reply: $e');
      SmartDialog.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);
    final maxWidth = context.mediaQueryShortestSide;
    late final coverSize = MediaQuery.textScalerOf(context).scale(65);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: Get.back,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 12 + padding.top,
              bottom: 80 + padding.bottom,
            ),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: maxWidth,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: AnimatedSize(
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      duration: const Duration(milliseconds: 255),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_item case ReplyInfo reply)
                            IgnorePointer(
                              child: ReplyItemGrpc(
                                replyItem: reply,
                                replyLevel: 0,
                                needDivider: false,
                                upMid: widget.upMid,
                              ),
                            )
                          else if (_item case DynamicItemModel dyn)
                            IgnorePointer(
                              child: DynamicPanel(
                                item: dyn,
                                isDetail: true,
                                isSave: true,
                                maxWidth: maxWidth - 24,
                              ),
                            ),
                          if (cover?.isNotEmpty == true &&
                              title?.isNotEmpty == true)
                            Container(
                              height: 81,
                              clipBehavior: Clip.hardEdge,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onInverseSurface,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  NetworkImgLayer(
                                    radius: 6,
                                    src: cover!,
                                    height: coverSize,
                                    width: coverType == _CoverType.def16_9
                                        ? coverSize * 16 / 9
                                        : coverSize,
                                    quality: 100,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$title\n',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (pubdate != null) ...[
                                          const Spacer(),
                                          Text(
                                            DateFormatUtils.format(
                                              pubdate,
                                              format: dateFormat,
                                            ),
                                            style: TextStyle(
                                              color: theme.colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          showBottom
                              ? Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    if (uri.isNotEmpty)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                spacing: 4,
                                                children: [
                                                  if (uname?.isNotEmpty == true)
                                                    Text(
                                                      '@$uname',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  Text(
                                                    '识别二维码，$viewType$itemType',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormatUtils.longFormatDs
                                                        .format(DateTime.now()),
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: theme
                                                          .colorScheme
                                                          .outline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => Utils.copyText(uri),
                                              child: Container(
                                                width: 88,
                                                height: 88,
                                                margin: const EdgeInsets.all(
                                                  12,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  3,
                                                ),
                                                color: Get.isDarkMode
                                                    ? Colors.white
                                                    : theme.colorScheme.surface,
                                                child: PrettyQrView.data(
                                                  data: uri,
                                                  decoration:
                                                      const PrettyQrDecoration(
                                                        shape:
                                                            PrettyQrSquaresSymbol(),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Image.asset(
                                        'assets/images/logo/logo_2.png',
                                        width: 100,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: padding.left,
                  right: padding.right,
                  bottom: 25 + padding.bottom,
                ),
                child: Row(
                  spacing: 40,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconButton(
                      size: 42,
                      tooltip: '关闭',
                      icon: const Icon(Icons.clear),
                      onPressed: Get.back,
                      bgColor: theme.colorScheme.onInverseSurface,
                      iconColor: theme.colorScheme.onSurfaceVariant,
                    ),
                    iconButton(
                      size: 42,
                      tooltip: showBottom ? '隐藏' : '显示',
                      context: context,
                      icon: showBottom
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () => setState(() {
                        showBottom = !showBottom;
                      }),
                    ),
                    if (Utils.isMobile)
                      iconButton(
                        size: 42,
                        tooltip: '分享',
                        context: context,
                        icon: const Icon(Icons.share),
                        onPressed: () => _onSaveOrSharePic(true),
                      ),
                    iconButton(
                      size: 42,
                      tooltip: '保存',
                      context: context,
                      icon: const Icon(Icons.save_alt),
                      onPressed: _onSaveOrSharePic,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CoverType { def16_9, square }
