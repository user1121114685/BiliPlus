import 'package:bili_plus/http/api.dart';
import 'package:bili_plus/http/init.dart';
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/models_new/follow/data.dart';

class FanHttp {
  static Future<LoadingState<FollowData>> fans({
    int? vmid,
    int? pn,
    int ps = 20,
    String? orderType,
  }) async {
    var res = await Request().get(
      Api.fans,
      queryParameters: {
        'vmid': vmid,
        'pn': pn,
        'ps': ps,
        'order': 'desc',
        'order_type': orderType,
      },
    );
    if (res.data['code'] == 0) {
      return Success(FollowData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }
}
