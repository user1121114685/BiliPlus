import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/common/widgets/view_safe_area.dart';
import 'package:bili_plus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models/common/image_type.dart';
import 'package:bili_plus/models_new/match/match_info/contest.dart';
import 'package:bili_plus/models_new/match/match_info/team.dart';
import 'package:bili_plus/pages/common/dyn/common_dyn_page.dart';
import 'package:bili_plus/pages/match_info/controller.dart';
import 'package:bili_plus/pages/video/reply_reply/view.dart';
import 'package:bili_plus/utils/date_utils.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MatchInfoPage extends StatefulWidget {
  const MatchInfoPage({super.key});

  @override
  State<MatchInfoPage> createState() => _MatchInfoPageState();
}

class _MatchInfoPageState extends CommonDynPageState<MatchInfoPage> {
  @override
  final MatchInfoController controller = Get.putOrFind(
    MatchInfoController.new,
    tag: Get.parameters['cid']!,
  );

  @override
  dynamic get arguments => null;

  @override
  Offset get fabOffset => const Offset(0, 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('比赛详情')),
      body: ViewSafeArea(
        child: refreshIndicator(
          onRefresh: controller.onRefresh,
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              Obx(() => _buildInfo(theme, controller.infoState.value)),
              buildReplyHeader(theme),
              Obx(() => replyList(theme, controller.loadingState.value)),
            ],
          ),
        ),
      ),
      floatingActionButton: SlideTransition(
        position: fabAnim,
        child: replyButton,
      ),
    );
  }

  Widget _buildInfo(ThemeData theme, LoadingState<MatchContest?> infoState) {
    if (infoState.isSuccess) {
      MatchContest? data = infoState.dataOrNull;
      if (data != null) {
        try {
          Widget teamInfo(MatchTeam team) {
            return Column(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                NetworkImgLayer(
                  width: 50,
                  height: 50,
                  src: 'https://i1.hdslb.com${team.logo}',
                  type: ImageType.emote,
                ),
                Text(team.title!),
              ],
            );
          }

          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                spacing: 12,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      '${data.season?.title ?? ''}  ${data.gameStage ?? ''}',
                    ),
                  ),
                  Row(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.homeId != 0)
                        Expanded(
                          child: Align(
                            alignment: const Alignment(0.8, 1),
                            child: teamInfo(data.homeTeam!),
                          ),
                        ),
                      Column(
                        spacing: 10,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (data.homeId != 0)
                            Text(
                              data.contestStatus == 1
                                  ? 'VS'
                                  : '${data.homeScore} : ${data.awayScore}',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else if (data.season?.logo != null)
                            NetworkImgLayer(
                              width: 50,
                              height: 50,
                              src: 'https://i1.hdslb.com${data.season!.logo}',
                              type: ImageType.emote,
                            ),
                          if (data.contestStatus == 2)
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(6),
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () =>
                                  PageUtils.toLiveRoom(data.liveRoom),
                              child: const Text('看直播'),
                            )
                          else if (data.contestStatus == 3)
                            Text(
                              '${DateFormatUtils.dateFormat(data.stime)}${data.contestStatus == 3 ? ' 已结束' : ''}',
                              style: TextStyle(
                                color: theme.colorScheme.outline,
                              ),
                            )
                          else if (data.contestStatus == 1)
                            Text(
                              DateFormatUtils.format(
                                data.stime,
                                format: DateFormat('yy-MM-dd HH:mm'),
                              ),
                              style: TextStyle(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                      if (data.awayId != 0)
                        Expanded(
                          child: Align(
                            alignment: const Alignment(-0.8, -1),
                            child: teamInfo(data.awayTeam!),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } catch (_) {
          return const SliverToBoxAdapter();
        }
      }
    }
    return const SliverToBoxAdapter();
  }

  @override
  void replyReply(
    BuildContext context,
    ReplyInfo replyItem,
    int? id,
    ThemeData theme,
  ) {
    EasyThrottle.throttle('replyReply', const Duration(milliseconds: 500), () {
      int oid = replyItem.oid.toInt();
      int rpid = replyItem.id.toInt();
      Get.to(
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('评论详情'),
            shape: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          body: ViewSafeArea(
            child: VideoReplyReplyPanel(
              enableSlide: false,
              id: id,
              oid: oid,
              rpid: rpid,
              isVideoDetail: false,
              replyType: controller.replyType,
              firstFloor: replyItem,
            ),
          ),
        ),
      );
    });
  }
}
