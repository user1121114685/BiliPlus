import 'dart:async';

import 'package:bili_plus/common/widgets/dialog/dialog.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/search.dart';
import 'package:bili_plus/models/search/suggest.dart';
import 'package:bili_plus/models_new/search/search_rcmd/data.dart';
import 'package:bili_plus/models_new/search/search_trending/data.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:bili_plus/utils/id_utils.dart';
import 'package:bili_plus/utils/storage.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:stream_transform/stream_transform.dart';

mixin DebounceStreamMixin<T> {
  Duration duration = const Duration(milliseconds: 200);
  StreamController<T>? ctr;
  StreamSubscription<T>? sub;
  void onValueChanged(T value);

  void subInit() {
    ctr = StreamController<T>();
    sub = ctr!.stream.debounce(duration, trailing: true).listen(onValueChanged);
  }

  void subDispose() {
    sub?.cancel();
    ctr?.close();
    sub = null;
    ctr = null;
  }
}

abstract class DebounceStreamState<T extends StatefulWidget, S> extends State<T>
    with DebounceStreamMixin<S> {
  @override
  void dispose() {
    subDispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    subInit();
  }
}

class BaseSearchController extends GetxController {
  final historyList = List<String>.from(
    GStorage.historyWord.get('cacheList') ?? [],
  ).obs;

  late final Rx<LoadingState<SearchTrendingData>> trendingState;

  final recordSearchHistory = Pref.recordSearchHistory.obs;
  final searchSuggestion = Pref.searchSuggestion;
  final enableTrending = Pref.enableTrending;
  final enableSearchRcmd = Pref.enableSearchRcmd;

  @override
  void onInit() {
    super.onInit();

    if (enableTrending) {
      trendingState = LoadingState<SearchTrendingData>.loading().obs;
      queryTrendingList();
    }
  }

  // 获取热搜关键词
  Future<void> queryTrendingList() async {
    trendingState.value = await SearchHttp.searchTrending(limit: 10);
  }
}

class SSearchController extends GetxController
    with DebounceStreamMixin<String> {
  SSearchController(this.tag);
  final String tag;

  final searchFocusNode = FocusNode();
  final controller = TextEditingController();
  final _baseCtr = Get.putOrFind(BaseSearchController.new);

  String? hintText;

  int initIndex = 0;

  // uid
  final RxBool showUidBtn = false.obs;

  // history
  RxBool get recordSearchHistory => _baseCtr.recordSearchHistory;
  RxList<String> get historyList => _baseCtr.historyList;

  // suggestion
  bool get searchSuggestion => _baseCtr.searchSuggestion;
  late final RxList<SearchSuggestItem> searchSuggestList;

  // trending
  bool get enableTrending => _baseCtr.enableTrending;
  Rx<LoadingState<SearchTrendingData>> get trendingState =>
      _baseCtr.trendingState;

  // rcmd
  bool get enableSearchRcmd => _baseCtr.enableSearchRcmd;
  late final Rx<LoadingState<SearchRcmdData>> recommendData;

  Future<void> Function() get queryTrendingList => _baseCtr.queryTrendingList;

  @override
  void onInit() {
    super.onInit();
    final params = Get.parameters;
    hintText = params['hintText'];
    final text = params['text'];
    if (text != null) {
      controller.text = text;
    }

    if (searchSuggestion) {
      subInit();
      searchSuggestList = <SearchSuggestItem>[].obs;
    }

    if (enableSearchRcmd) {
      recommendData = LoadingState<SearchRcmdData>.loading().obs;
      queryRecommendList();
    }
  }

  void validateUid() {
    showUidBtn.value = IdUtils.digitOnlyRegExp.hasMatch(controller.text);
  }

  void onChange(String value) {
    validateUid();
    if (searchSuggestion) {
      if (value.isEmpty) {
        searchSuggestList.clear();
      } else {
        ctr!.add(value);
      }
    }
  }

  void onClear() {
    if (controller.value.text != '') {
      controller.clear();
      if (searchSuggestion) searchSuggestList.clear();
      searchFocusNode.requestFocus();
      showUidBtn.value = false;
    } else {
      Get.back();
    }
  }

  // 搜索
  Future<void> submit() async {
    if (controller.text.isEmpty) {
      if (hintText.isNullOrEmpty) {
        return;
      }
      controller.text = hintText!;
      validateUid();
    }

    if (recordSearchHistory.value) {
      historyList
        ..remove(controller.text)
        ..insert(0, controller.text);
      GStorage.historyWord.put('cacheList', historyList);
    }

    searchFocusNode.unfocus();
    await Get.toNamed(
      '/searchResult',
      parameters: {
        'tag': tag,
        'keyword': controller.text,
      },
      arguments: {
        'initIndex': initIndex,
        'fromSearch': true,
      },
    );
    searchFocusNode.requestFocus();
    if (Utils.isDesktop) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controller.selection = TextSelection.collapsed(
          offset: controller.text.length,
        );
      });
    }
  }

  Future<void> queryRecommendList() async {
    recommendData.value = await SearchHttp.searchRecommend();
  }

  void onClickKeyword(String keyword) {
    controller.text = keyword;
    validateUid();

    if (searchSuggestion) searchSuggestList.clear();
    submit();
  }

  @override
  Future<void> onValueChanged(String value) async {
    var res = await SearchHttp.searchSuggest(term: value);
    if (res['status']) {
      SearchSuggestModel data = res['data'];
      if (data.tag?.isNotEmpty == true) {
        searchSuggestList.value = data.tag!;
      }
    }
  }

  void onLongSelect(String word) {
    historyList.remove(word);
    GStorage.historyWord.put('cacheList', historyList);
  }

  void onClearHistory() {
    showConfirmDialog(
      context: Get.context!,
      title: '确定清空搜索历史？',
      onConfirm: () {
        historyList.clear();
        GStorage.historyWord.delete('cacheList');
      },
    );
  }

  @override
  void onClose() {
    subDispose();
    searchFocusNode.dispose();
    controller.dispose();
    super.onClose();
  }
}
