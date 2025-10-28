import 'dart:async';

import 'package:bili_plus/pages/common/common_controller.dart';
import 'package:bili_plus/pages/home/controller.dart';
import 'package:bili_plus/pages/main/controller.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

abstract class CommonPageState<
  T extends StatefulWidget,
  R extends CommonController
>
    extends State<T> {
  R get controller;
  StreamController<bool>? mainStream;
  StreamController<bool>? searchBarStream;
  // late double _downScrollCount = 0.0; // 向下滚动计数器
  late double _upScrollCount = 0.0; // 向上滚动计数器
  double? _lastScrollPosition; // 记录上次滚动位置
  final _enableScrollThreshold = Pref.enableScrollThreshold;
  late final double _scrollThreshold = Pref.scrollThreshold; // 滚动阈值
  late final scrollController = controller.scrollController;

  @override
  void initState() {
    super.initState();
    try {
      mainStream = Get.find<MainController>().bottomBarStream;
      searchBarStream = Get.find<HomeController>().searchBarStream;
    } catch (_) {}
    if (_enableScrollThreshold &&
        (mainStream != null || searchBarStream != null)) {
      controller.scrollController.addListener(listener);
    }
  }

  Widget onBuild(Widget child) {
    if (!_enableScrollThreshold &&
        (mainStream != null || searchBarStream != null)) {
      return NotificationListener<UserScrollNotification>(
        onNotification: onNotification,
        child: child,
      );
    }
    return child;
  }

  bool onNotification(UserScrollNotification notification) {
    if (notification.metrics.axis == Axis.horizontal) return false;
    final direction = notification.direction;
    if (direction == ScrollDirection.forward) {
      mainStream?.add(true);
      searchBarStream?.add(true);
    } else if (direction == ScrollDirection.reverse) {
      mainStream?.add(false);
      searchBarStream?.add(false);
    }
    return false;
  }

  void listener() {
    final direction = scrollController.position.userScrollDirection;

    final double currentPosition = scrollController.position.pixels;

    // 初始化上次位置
    _lastScrollPosition ??= currentPosition;

    // 计算滚动距离
    final double scrollDelta = currentPosition - _lastScrollPosition!;

    if (direction == ScrollDirection.reverse) {
      mainStream?.add(false);
      searchBarStream?.add(false); // // 向下滚动，累加向下滚动距离，重置向上滚动计数器
      _upScrollCount = 0.0; // 重置向上滚动计数器
      // if (scrollDelta > 0) {
      //   _downScrollCount += scrollDelta;
      //   // _upScrollCount = 0.0; // 重置向上滚动计数器

      //   // 当累计向下滚动距离超过阈值时，隐藏顶底栏
      //   if (_downScrollCount >= _scrollThreshold) {
      //     mainStream?.add(false);
      //     searchBarStream?.add(false);
      //   }
      // }
    } else if (direction == ScrollDirection.forward) {
      // 向上滚动，累加向上滚动距离，重置向下滚动计数器
      if (scrollDelta < 0) {
        _upScrollCount += (-scrollDelta); // 使用绝对值
        // _downScrollCount = 0.0; // 重置向下滚动计数器

        // 当累计向上滚动距离超过阈值时，显示顶底栏
        if (_upScrollCount >= _scrollThreshold) {
          mainStream?.add(true);
          searchBarStream?.add(true);
        }
      }
    }

    // 更新上次位置
    _lastScrollPosition = currentPosition;
  }

  @override
  void dispose() {
    controller.scrollController.removeListener(listener);
    super.dispose();
  }
}
