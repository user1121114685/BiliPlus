import 'package:bili_plus/http/fav.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/fav/fav_folder/data.dart';
import 'package:bili_plus/models_new/fav/fav_folder/list.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';
import 'package:bili_plus/services/account_service.dart';
import 'package:get/get.dart';

class FavController extends CommonListController<FavFolderData, FavFolderInfo> {
  AccountService accountService = Get.find<AccountService>();

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    if (!accountService.isLogin.value) {
      loadingState.value = const Error('账号未登录');
      return Future.value();
    }
    return super.queryData(isRefresh);
  }

  @override
  List<FavFolderInfo>? getDataList(FavFolderData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.list;
  }

  @override
  Future<LoadingState<FavFolderData>> customGetData() =>
      FavHttp.userfavFolder(pn: page, ps: 20, mid: accountService.mid);
}
