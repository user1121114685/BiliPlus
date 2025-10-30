import 'dart:io';

import 'package:bili_plus/font_icon/bilibili_icons.dart';
import 'package:bili_plus/models/common/settings_type.dart';
import 'package:bili_plus/models/common/video/subtitle_pref_type.dart';
import 'package:bili_plus/pages/main/controller.dart';
import 'package:bili_plus/pages/setting/models/model.dart';
import 'package:bili_plus/pages/setting/widgets/select_dialog.dart';
import 'package:bili_plus/plugin/pl_player/models/bottom_progress_behavior.dart';
import 'package:bili_plus/plugin/pl_player/models/fullscreen_mode.dart';
import 'package:bili_plus/plugin/pl_player/utils/fullscreen.dart'
    show allowRotateScreen;
import 'package:bili_plus/services/service_locator.dart';
import 'package:bili_plus/utils/storage.dart';
import 'package:bili_plus/utils/storage_key.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

List<SettingsModel> get playSettings => [
  SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '弹幕开关',
    subtitle: '是否展示弹幕',
    leading: Icon(BiliBiliIcons.danmu_setting_line500),
    setKey: SettingBoxKey.enableShowDanmaku,
    defaultVal: true,
  ),
  if (Utils.isMobile)
    const SettingsModel(
      settingsType: SettingsType.sw1tch,
      title: '启用点击弹幕',
      subtitle: '点击弹幕悬停，支持点赞、复制、举报操作',
      leading: Icon(Icons.touch_app_outlined),
      setKey: SettingBoxKey.enableTapDm,
      defaultVal: true,
    ),
  SettingsModel(
    settingsType: SettingsType.normal,
    onTap: (setState) => Get.toNamed('/playSpeedSet'),
    leading: const Icon(Icons.speed_outlined),
    title: '倍速设置',
    subtitle: '设置视频播放速度',
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '自动播放',
    subtitle: '进入详情页自动播放',
    leading: Icon(Icons.motion_photos_auto_outlined),
    setKey: SettingBoxKey.autoPlayEnable,
    defaultVal: false,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '全屏显示锁定按钮',
    leading: Icon(Icons.lock_outline),
    setKey: SettingBoxKey.showFsLockBtn,
    defaultVal: true,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '全屏显示截图按钮',
    leading: Icon(Icons.photo_camera_outlined),
    setKey: SettingBoxKey.showFsScreenshotBtn,
    defaultVal: true,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '双击快退/快进',
    subtitle: '左侧双击快退/右侧双击快进，关闭则双击均为暂停/播放',
    leading: Icon(Icons.touch_app_outlined),
    setKey: SettingBoxKey.enableQuickDouble,
    defaultVal: true,
  ),
  SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '左右侧滑动调节亮度/音量',
    leading: Icon(Icons.swipe_vertical_outlined),
    setKey: SettingBoxKey.enableSlideVolumeBrightness,
    defaultVal: true,
  ),
  SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '中间滑动进入/退出全屏',
    leading: Icon(Icons.swipe_up),
    setKey: SettingBoxKey.enableSlideFS,
    defaultVal: true,
  ),
  getVideoFilterSelectModel(
    context: Get.context!,
    title: '双击快进/快退时长',
    suffix: 's',
    key: SettingBoxKey.fastForBackwardDuration,
    values: [5, 10, 15],
    defaultValue: 10,
    isFilter: false,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '滑动快进/快退使用相对时长',
    leading: Icon(Icons.swap_horiz_outlined),
    setKey: SettingBoxKey.useRelativeSlide,
    defaultVal: false,
  ),
  getVideoFilterSelectModel(
    context: Get.context!,
    title: '滑动快进/快退时长',
    subtitle: '从播放器一端滑到另一端的快进/快退时长',
    suffix: Pref.useRelativeSlide ? '%' : 's',
    key: SettingBoxKey.sliderDuration,
    values: [25, 50, 90, 100],
    defaultValue: 90,
    isFilter: false,
  ),
  SettingsModel(
    settingsType: SettingsType.normal,
    title: '自动启用字幕',
    leading: const Icon(Icons.closed_caption_outlined),
    getSubtitle: () =>
        '当前选择偏好：${SubtitlePrefType.values[Pref.subtitlePreferenceV2].desc}',
    onTap: (setState) async {
      int? result = await showDialog(
        context: Get.context!,
        builder: (context) {
          return SelectDialog<int>(
            title: '字幕选择偏好',
            value: Pref.subtitlePreferenceV2,
            values: SubtitlePrefType.values
                .map((e) => (e.index, e.desc))
                .toList(),
          );
        },
      );
      if (result != null) {
        await GStorage.setting.put(SettingBoxKey.subtitlePreferenceV2, result);
        setState();
      }
    },
  ),
  if (Utils.isDesktop)
    SettingsModel(
      settingsType: SettingsType.sw1tch,
      title: '最小化时暂停/还原时播放',
      leading: const Icon(Icons.pause_circle_outline),
      setKey: SettingBoxKey.pauseOnMinimize,
      defaultVal: false,
      onChanged: (value) {
        try {
          Get.find<MainController>().pauseOnMinimize = value;
        } catch (_) {}
      },
    ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '启用键盘控制',
    leading: Icon(Icons.keyboard_alt_outlined),
    setKey: SettingBoxKey.keyboardControl,
    defaultVal: true,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '显示 SuperChat (醒目留言)',
    leading: Icon(Icons.live_tv),
    setKey: SettingBoxKey.showSuperChat,
    defaultVal: true,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '竖屏扩大展示',
    subtitle: '小屏竖屏视频宽高比由16:9扩大至1:1（不支持收起）；横屏适配时，扩大至9:16',
    leading: Icon(Icons.expand_outlined),
    setKey: SettingBoxKey.enableVerticalExpand,
    defaultVal: false,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '自动全屏',
    subtitle: '视频开始播放时进入全屏',
    leading: Icon(Icons.fullscreen_outlined),
    setKey: SettingBoxKey.enableAutoEnter,
    defaultVal: false,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '自动退出全屏',
    subtitle: '视频结束播放时退出全屏',
    leading: Icon(Icons.fullscreen_exit_outlined),
    setKey: SettingBoxKey.enableAutoExit,
    defaultVal: true,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '延长播放控件显示时间',
    subtitle: '开启后延长至30秒，便于屏幕阅读器滑动切换控件焦点',
    leading: Icon(Icons.timer_outlined),
    setKey: SettingBoxKey.enableLongShowControl,
    defaultVal: false,
  ),
  SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '全向旋转',
    subtitle: '小屏可受重力转为临时全屏，若系统锁定旋转仍触发请关闭，关闭会影响横屏适配',
    leading: const Icon(Icons.screen_rotation_alt_outlined),
    setKey: SettingBoxKey.allowRotateScreen,
    defaultVal: true,
    onChanged: (value) => allowRotateScreen = value,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '后台播放',
    subtitle: '进入后台时继续播放',
    leading: Icon(Icons.motion_photos_pause_outlined),
    setKey: SettingBoxKey.continuePlayInBackground,
    defaultVal: false,
  ),
  if (Platform.isAndroid) ...[
    SettingsModel(
      settingsType: SettingsType.sw1tch,
      title: '后台画中画',
      subtitle: '进入后台时以小窗形式（PiP）播放',
      leading: const Icon(Icons.picture_in_picture_outlined),
      setKey: SettingBoxKey.autoPiP,
      defaultVal: false,
      onChanged: (val) {
        if (val && !videoPlayerServiceHandler!.enableBackgroundPlay) {
          SmartDialog.showToast('建议开启后台音频服务');
        }
      },
    ),
    SettingsModel(
      settingsType: SettingsType.sw1tch,
      title: '画中画不加载弹幕',
      subtitle: '当弹幕开关开启时，小窗屏蔽弹幕以获得较好的体验',
      leading: Icon(BiliBiliIcons.dm_off),
      setKey: SettingBoxKey.pipNoDanmaku,
      defaultVal: false,
    ),
  ],
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '全屏手势反向',
    subtitle: '默认播放器中部向上滑动进入全屏，向下退出\n开启后向下全屏，向上退出',
    leading: Icon(Icons.swap_vert),
    setKey: SettingBoxKey.fullScreenGestureReverse,
    defaultVal: false,
  ),
  SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '全屏展示点赞/投币/收藏等操作按钮',
    leading: Icon(BiliBiliIcons.more_circle_line500),
    setKey: SettingBoxKey.showFSActionItem,
    defaultVal: true,
  ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '观看人数',
    subtitle: '展示同时在看人数',
    leading: Icon(Icons.people_outlined),
    setKey: SettingBoxKey.enableOnlineTotal,
    defaultVal: false,
  ),
  SettingsModel(
    settingsType: SettingsType.normal,
    title: '默认全屏方向',
    leading: const Icon(Icons.open_with_outlined),
    getSubtitle: () =>
        '当前全屏方向：${FullScreenMode.values[Pref.fullScreenMode].desc}',
    onTap: (setState) async {
      int? result = await showDialog(
        context: Get.context!,
        builder: (context) {
          return SelectDialog<int>(
            title: '默认全屏方向',
            value: Pref.fullScreenMode,
            values: FullScreenMode.values
                .map((e) => (e.index, e.desc))
                .toList(),
          );
        },
      );
      if (result != null) {
        await GStorage.setting.put(SettingBoxKey.fullScreenMode, result);
        setState();
      }
    },
  ),
  SettingsModel(
    settingsType: SettingsType.normal,
    title: '底部进度条展示',
    leading: const Icon(Icons.border_bottom_outlined),
    getSubtitle: () =>
        '当前展示方式：${BtmProgressBehavior.values[Pref.btmProgressBehavior].desc}',
    onTap: (setState) async {
      int? result = await showDialog(
        context: Get.context!,
        builder: (context) {
          return SelectDialog<int>(
            title: '底部进度条展示',
            value: Pref.btmProgressBehavior,
            values: BtmProgressBehavior.values
                .map((e) => (e.index, e.desc))
                .toList(),
          );
        },
      );
      if (result != null) {
        await GStorage.setting.put(SettingBoxKey.btmProgressBehavior, result);
        setState();
      }
    },
  ),
  if (Utils.isMobile)
    SettingsModel(
      settingsType: SettingsType.sw1tch,
      title: '后台音频服务',
      subtitle: '避免画中画没有播放暂停功能',
      leading: const Icon(Icons.volume_up_outlined),
      setKey: SettingBoxKey.enableBackgroundPlay,
      defaultVal: true,
      onChanged: (value) {
        videoPlayerServiceHandler!.enableBackgroundPlay = value;
      },
    ),
  const SettingsModel(
    settingsType: SettingsType.sw1tch,
    title: '播放器设置仅对当前生效',
    subtitle: '弹幕、字幕及部分设置中没有的设置除外',
    leading: Icon(Icons.video_settings_outlined),
    setKey: SettingBoxKey.tempPlayerConf,
    defaultVal: false,
  ),
];
