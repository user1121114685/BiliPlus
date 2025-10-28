import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/member.dart';
import 'package:bili_plus/models_new/space/space_article/data.dart';
import 'package:bili_plus/models_new/space/space_article/item.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';

class MemberArticleCtr
    extends CommonListController<SpaceArticleData, SpaceArticleItem> {
  MemberArticleCtr({
    required this.mid,
  });

  final int mid;

  int count = -1;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<SpaceArticleItem>? getDataList(SpaceArticleData response) {
    count = response.count ?? -1;
    return response.item;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= count) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<SpaceArticleData>> customGetData() =>
      MemberHttp.spaceArticle(mid: mid, page: page);
}
