import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/view_sliver_safe_area.dart';
import 'package:bili_plus/pages/search/controller.dart'
    show DebounceStreamState;
import 'package:bili_plus/pages/setting/models/extra_settings.dart';
import 'package:bili_plus/pages/setting/models/model.dart';
import 'package:bili_plus/pages/setting/models/play_settings.dart';
import 'package:bili_plus/pages/setting/models/privacy_settings.dart';
import 'package:bili_plus/pages/setting/models/recommend_settings.dart';
import 'package:bili_plus/pages/setting/models/style_settings.dart';
import 'package:bili_plus/pages/setting/models/video_settings.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:bili_plus/utils/waterfall.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart'
    hide SliverWaterfallFlowDelegateWithMaxCrossAxisExtent;

class SettingsSearchPage extends StatefulWidget {
  const SettingsSearchPage({super.key});

  @override
  State<SettingsSearchPage> createState() => _SettingsSearchPageState();
}

class _SettingsSearchPageState
    extends DebounceStreamState<SettingsSearchPage, String> {
  final _textEditingController = TextEditingController();
  final RxList<SettingsModel> _list = <SettingsModel>[].obs;
  late final _settings = [
    ...extraSettings,
    ...privacySettings,
    ...recommendSettings,
    ...videoSettings,
    ...playSettings,
    ...styleSettings,
  ];

  @override
  void onValueChanged(String value) {
    if (value.isEmpty) {
      _list.clear();
    } else {
      value = value.toLowerCase();
      _list.value = _settings
          .where(
            (item) =>
                (item.title ?? item.getTitle!()).toLowerCase().contains(
                  value,
                ) ||
                (item.subtitle ?? item.getSubtitle?.call())
                        ?.toLowerCase()
                        .contains(value) ==
                    true,
          )
          .toList();
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                _textEditingController.clear();
                _list.value = <SettingsModel>[];
              } else {
                Get.back();
              }
            },
            icon: const Icon(Icons.clear),
          ),
          const SizedBox(width: 10),
        ],
        title: TextField(
          autofocus: true,
          controller: _textEditingController,
          textAlignVertical: TextAlignVertical.center,
          onChanged: ctr!.add,
          decoration: const InputDecoration(
            isDense: true,
            hintText: '搜索',
            border: InputBorder.none,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          ViewSliverSafeArea(
            sliver: Obx(
              () => _list.isEmpty
                  ? const HttpError()
                  : SliverWaterfallFlow(
                      gridDelegate:
                          SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: Grid.smallCardWidth * 2,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (_, index) => _list[index].widget,
                        childCount: _list.length,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
