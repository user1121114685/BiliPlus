import 'package:bili_plus/common/widgets/loading_widget/http_error.dart';
import 'package:bili_plus/common/widgets/view_safe_area.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models/common/member/contribute_type.dart';
import 'package:bili_plus/models_new/space/space_season_series/season.dart'
    show SpaceSsModel;
import 'package:bili_plus/pages/member_season_series/controller.dart';
import 'package:bili_plus/pages/member_season_series/widget/season_series_card.dart';
import 'package:bili_plus/pages/member_video/view.dart';
import 'package:bili_plus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeasonSeriesPage extends StatefulWidget {
  const SeasonSeriesPage({
    super.key,
    required this.mid,
    this.heroTag,
  });

  final int mid;
  final String? heroTag;

  @override
  State<SeasonSeriesPage> createState() => _SeasonSeriesPageState();
}

class _SeasonSeriesPageState extends State<SeasonSeriesPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  late final _controller = Get.put(
    SeasonSeriesController(widget.mid),
    tag: widget.heroTag,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
          ),
          sliver: Obx(
            () => _buildBody(_controller.loadingState.value),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(LoadingState<List<SpaceSsModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:var response) =>
        response?.isNotEmpty == true
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  SpaceSsModel item = response[index];
                  return SeasonSeriesCard(
                    item: item,
                    onTap: () {
                      bool isSeason = item.meta!.seasonId != null;
                      dynamic id = isSeason
                          ? item.meta!.seasonId
                          : item.meta!.seriesId;
                      Get.to(
                        Scaffold(
                          resizeToAvoidBottomInset: false,
                          appBar: AppBar(title: Text(item.meta!.name!)),
                          body: ViewSafeArea(
                            child: MemberVideo(
                              type: isSeason
                                  ? ContributeType.season
                                  : ContributeType.series,
                              heroTag: widget.heroTag,
                              mid: widget.mid,
                              seasonId: isSeason ? id : null,
                              seriesId: isSeason ? null : id,
                              title: item.meta!.name,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                itemCount: response!.length,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:var errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}
