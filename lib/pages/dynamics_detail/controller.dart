import 'package:bili_plus/http/dynamics.dart';
import 'package:bili_plus/models/dynamics/result.dart';
import 'package:bili_plus/pages/common/dyn/common_dyn_controller.dart';
import 'package:bili_plus/utils/id_utils.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:get/get.dart';

class DynamicDetailController extends CommonDynController {
  @override
  late int oid;
  @override
  late int replyType;
  late DynamicItemModel dynItem;

  late final showDynActionBar = Pref.showDynActionBar;

  @override
  dynamic get sourceId => replyType == 1 ? IdUtils.av2bv(oid) : oid;

  @override
  void onInit() {
    super.onInit();
    dynItem = Get.arguments['item'];
    var commentType = dynItem.basic?.commentType;
    var commentIdStr = dynItem.basic?.commentIdStr;
    if (commentType != null &&
        commentType != 0 &&
        commentIdStr?.isNotEmpty == true) {
      _init(commentIdStr!, commentType);
    } else {
      DynamicsHttp.dynamicDetail(id: dynItem.idStr).then((res) {
        if (res.isSuccess) {
          final data = res.data;
          _init(data.basic!.commentIdStr!, data.basic!.commentType!);
        } else {
          res.toast();
        }
      });
    }
  }

  void _init(String commentIdStr, int commentType) {
    oid = int.parse(commentIdStr);
    replyType = commentType;
    queryData();
  }
}
