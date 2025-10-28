import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/loading_widget/loading_widget.dart';
import 'package:bili_plus/common/widgets/refresh_indicator.dart';
import 'package:bili_plus/common/widgets/view_sliver_safe_area.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/dynamic/dyn_topic_top/topic_item.dart';
import 'package:bili_plus/pages/dynamics_select_topic/widgets/item.dart';
import 'package:bili_plus/pages/dynamics_topic_rcmd/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynTopicRcmdPage extends StatefulWidget {
  const DynTopicRcmdPage({super.key});

  @override
  State<DynTopicRcmdPage> createState() => _DynTopicRcmdPageState();
}

class _DynTopicRcmdPageState extends State<DynTopicRcmdPage> {
  final DynTopicRcmdController _controller = Get.put(DynTopicRcmdController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('话题')),
      body: refreshIndicator(
        onRefresh: _controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: Obx(() => _buildBody(_controller.loadingState.value)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<TopicItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => linearLoading,
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverList.builder(
                itemCount: response!.length,
                itemBuilder: (context, index) {
                  return DynTopicItem(
                    item: response[index],
                    onTap: (item) => Get.toNamed(
                      '/dynTopic',
                      parameters: {'id': item.id.toString(), 'name': item.name},
                    ),
                  );
                },
              )
            : HttpError(onReload: _controller.onReload),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}
