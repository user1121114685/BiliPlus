import 'dart:math';

import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/button/icon_button.dart';
import 'package:bili_plus/common/widgets/loading_widget/loading_widget.dart';
import 'package:bili_plus/common/widgets/pair.dart';
import 'package:bili_plus/http/init.dart';
import 'package:bili_plus/models/common/sponsor_block/action_type.dart';
import 'package:bili_plus/models/common/sponsor_block/post_segment_model.dart';
import 'package:bili_plus/models/common/sponsor_block/segment_type.dart';
import 'package:bili_plus/models_new/sponsor_block/segment_item.dart';
import 'package:bili_plus/pages/common/slide/common_slide_page.dart';
import 'package:bili_plus/pages/video/controller.dart';
import 'package:bili_plus/pages/video/post_panel/popup_menu_text.dart';
import 'package:bili_plus/plugin/pl_player/controller.dart';
import 'package:bili_plus/utils/duration_utils.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:dio/dio.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide Response;

class PostPanel extends CommonSlidePage {
  const PostPanel({
    super.key,
    super.enableSlide,
    required this.videoDetailController,
    required this.plPlayerController,
  });

  final VideoDetailController videoDetailController;
  final PlPlayerController plPlayerController;

  @override
  State<PostPanel> createState() => _PostPanelState();

  static void updateSegment({
    required bool isFirst,
    required PostSegmentModel item,
    required double value,
  }) {
    if (isFirst) {
      item.segment.first = value;
    } else {
      item.segment.second = value;
    }
    if (item.category == SegmentType.poi_highlight ||
        item.actionType == ActionType.full) {
      item.segment.second = value;
    }
  }

  static Widget segmentWidget(
    ThemeData theme, {
    required PostSegmentModel item,
    required double Function() currentPos, // get real-time pos
    required double videoDuration,
  }) {
    Widget segment(bool isFirst) => Builder(
      builder: (context) {
        String value = DurationUtils.formatDuration(
          isFirst ? item.segment.first : item.segment.second,
        );
        return Row(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${isFirst ? '开始' : '结束'}: $value'),
            iconButton(
              context: context,
              size: 26,
              tooltip: '设为当前',
              icon: const Icon(Icons.my_location),
              onPressed: () {
                updateSegment(
                  isFirst: isFirst,
                  item: item,
                  value: currentPos(),
                );
                (context as Element).markNeedsBuild();
              },
            ),
            iconButton(
              context: context,
              size: 26,
              tooltip: isFirst ? '视频开头' : '视频结尾',
              icon: isFirst
                  ? const Icon(Icons.first_page)
                  : const Icon(Icons.last_page),
              onPressed: () {
                updateSegment(
                  isFirst: isFirst,
                  item: item,
                  value: isFirst ? 0 : videoDuration,
                );
                (context as Element).markNeedsBuild();
              },
            ),
            iconButton(
              context: context,
              size: 26,
              tooltip: '编辑',
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final res = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String initV = value;
                    return AlertDialog(
                      content: TextFormField(
                        initialValue: value,
                        autofocus: true,
                        onChanged: (value) => initV = value,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d:.]+')),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: Get.back,
                          child: Text(
                            '取消',
                            style: TextStyle(color: theme.colorScheme.outline),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: initV),
                          child: const Text('确定'),
                        ),
                      ],
                    );
                  },
                );

                if (res != null) {
                  try {
                    List<num> split = res
                        .split(':')
                        .reversed
                        .map(num.parse)
                        .toList();
                    double duration = 0;
                    for (int i = 0; i < split.length; i++) {
                      duration += split[i] * pow(60, i);
                    }
                    if (duration <= videoDuration) {
                      updateSegment(
                        isFirst: isFirst,
                        item: item,
                        value: duration,
                      );
                      (context as Element).markNeedsBuild();
                    }
                  } catch (e) {
                    if (kDebugMode) debugPrint(e.toString());
                  }
                }
              },
            ),
          ],
        );
      },
    );

    if (item.category != SegmentType.poi_highlight) {
      return Wrap(
        runSpacing: 8,
        spacing: 16,
        children: [segment(true), segment(false)],
      );
    }
    return segment(true);
  }
}

class _PostPanelState extends State<PostPanel>
    with SingleTickerProviderStateMixin, CommonSlideMixin {
  late final VideoDetailController videoDetailController =
      widget.videoDetailController;
  late final PlPlayerController plPlayerController = widget.plPlayerController;
  late final List<PostSegmentModel> list = videoDetailController.postList;

  late final double videoDuration =
      plPlayerController.durationSeconds.value.inMilliseconds / 1000;

  double get currentPos =>
      plPlayerController.position.value.inMilliseconds / 1000;

  @override
  Widget buildPage(ThemeData theme) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        primary: false,
        toolbarHeight: 45,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text('提交片段'),
        actions: [
          iconButton(
            size: 32,
            context: context,
            tooltip: '添加片段',
            onPressed: () {
              setState(() {
                list.insert(
                  0,
                  PostSegmentModel(
                    segment: Pair(first: 0, second: currentPos),
                    category: SegmentType.sponsor,
                    actionType: ActionType.skip,
                  ),
                );
              });
            },
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          iconButton(
            size: 32,
            context: context,
            tooltip: '关闭',
            onPressed: Get.back,
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: enableSlide ? slideList(theme) : buildList(theme),
    );
  }

  late Key _key;
  late bool _isNested;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = PrimaryScrollController.of(context);
    _isNested = controller is ExtendedNestedScrollController;
    _key = ValueKey(controller.hashCode);
  }

  @override
  Widget buildList(ThemeData theme) {
    if (list.isNullOrEmpty) {
      return errorWidget();
    }
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    Widget child = ListView.builder(
      key: _key,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 88 + bottom),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildItem(theme, index, list[index]);
      },
    );
    if (_isNested) {
      child = ExtendedVisibilityDetector(
        uniqueKey: const Key('post-panel'),
        child: child,
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: kFloatingActionButtonMargin,
          bottom: kFloatingActionButtonMargin + bottom,
          child: FloatingActionButton(
            tooltip: '提交',
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('确定无误再提交'),
                actions: [
                  TextButton(
                    onPressed: Get.back,
                    child: Text(
                      '取消',
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  ),
                  TextButton(onPressed: _onPost, child: const Text('确定提交')),
                ],
              ),
            ),
            child: const Icon(Icons.check),
          ),
        ),
      ],
    );
  }

  Future<void> _onPost() async {
    Get.back();
    final res = await Request().post(
      '${widget.videoDetailController.blockServer}/api/skipSegments',
      data: {
        'videoID': videoDetailController.bvid,
        'cid': videoDetailController.cid.value.toString(),
        'userID': Pref.blockUserID.toString(),
        'userAgent': Constants.userAgent,
        'videoDuration': videoDuration,
        'segments': list
            .map(
              (item) => {
                'segment': [item.segment.first, item.segment.second],
                'category': item.category.name,
                'actionType': item.actionType.name,
              },
            )
            .toList(),
      },
      options: Options(
        followRedirects: true, // Defaults to true.
        validateStatus: (int? status) {
          return (status! >= 200 && status < 300) ||
              const [400, 403, 429, 409] // reduce extra toast
                  .contains(status);
        },
      ),
    );

    if (res.statusCode == 200) {
      Get.back();
      SmartDialog.showToast('提交成功');
      list.clear();
      if (res.data case List list) {
        videoDetailController.handleSBData(
          list.map((e) => SegmentItemModel.fromJson(e)).toList(),
        );
      }
      if (videoDetailController.positionSubscription == null) {
        videoDetailController.initSkip();
      }
    } else {
      SmartDialog.showToast('提交失败: ${_errMsg(res)}');
    }
  }

  String _errMsg(Response res) {
    if (res.data case String e) {
      if (e.isNotEmpty) {
        return e;
      }
    }
    return switch (res.statusCode) {
      400 => '参数错误',
      403 => '被自动审核机制拒绝',
      429 => '重复提交太快',
      409 => '重复提交',
      _ => '${res.data}(${res.statusCode})',
    };
  }

  Widget _buildItem(ThemeData theme, int index, PostSegmentModel item) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.onInverseSurface,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Builder(
            builder: (context) => Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.actionType != ActionType.full)
                  PostPanel.segmentWidget(
                    theme,
                    item: item,
                    currentPos: () => currentPos,
                    videoDuration: videoDuration,
                  ),
                Wrap(
                  runSpacing: 8,
                  spacing: 16,
                  children: [
                    PopupMenuText(
                      title: '分类',
                      initialValue: item.category,
                      onSelected: (e) {
                        bool flag = false;
                        if (item.category == SegmentType.exclusive_access ||
                            item.category == SegmentType.poi_highlight) {
                          flag = true;
                        }
                        item.category = e;
                        List<ActionType> constraintList = e.toActionType;
                        if (!constraintList.contains(item.actionType)) {
                          item.actionType = constraintList.first;
                          flag = true;
                        }
                        switch (e) {
                          case SegmentType.poi_highlight:
                            PostPanel.updateSegment(
                              isFirst: false,
                              item: item,
                              value: item.segment.first,
                            );
                            break;
                          case SegmentType.exclusive_access:
                            PostPanel.updateSegment(
                              isFirst: true,
                              item: item,
                              value: 0,
                            );
                            break;
                          default:
                        }
                        if (flag) {
                          (context as Element).markNeedsBuild();
                        }
                        return flag;
                      },
                      itemBuilder: (context) => SegmentType.values
                          .map(
                            (e) =>
                                PopupMenuItem(value: e, child: Text(e.title)),
                          )
                          .toList(),
                      getSelectTitle: (category) => category.title,
                    ),
                    PopupMenuText(
                      title: '行为类别',
                      initialValue: item.actionType,
                      onSelected: (e) {
                        bool flag = false;
                        if (item.actionType == ActionType.full) {
                          flag = true;
                        }
                        item.actionType = e;
                        if (e == ActionType.full) {
                          flag = true;
                          PostPanel.updateSegment(
                            isFirst: true,
                            item: item,
                            value: 0,
                          );
                        }
                        if (flag) {
                          (context as Element).markNeedsBuild();
                        }
                        return flag;
                      },
                      itemBuilder: (context) => ActionType.values
                          .map(
                            (e) => PopupMenuItem(
                              enabled: item.category.toActionType.contains(e),
                              value: e,
                              child: Text(e.title),
                            ),
                          )
                          .toList(),
                      getSelectTitle: (i) => i.title,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 4,
          child: iconButton(
            context: context,
            size: 26,
            tooltip: '移除',
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                list.removeAt(index);
              });
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 4,
          child: iconButton(
            context: context,
            size: 26,
            tooltip: '预览',
            icon: const Icon(Icons.preview_outlined),
            onPressed: () async {
              final videoCtr = widget.plPlayerController.videoPlayerController;
              if (videoCtr != null) {
                final start = (item.segment.first * 1000).round();
                final seek = max(0, start - 2000);
                await videoCtr.seek(Duration(milliseconds: seek));
                if (!videoCtr.state.playing) {
                  await videoCtr.play();
                }
                final delay = start - seek;
                if (delay > 0) {
                  await Future.delayed(Duration(milliseconds: delay));
                }
                videoCtr.seek(
                  Duration(milliseconds: (item.segment.second * 1000).round()),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
