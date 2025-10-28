import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/user.dart';
import 'package:bili_plus/models_new/login_log/data.dart';
import 'package:bili_plus/models_new/login_log/list.dart';
import 'package:bili_plus/pages/log_table/controller.dart';

class LoginLogController extends LogController<LoginLogData, LoginLogItem> {
  @override
  List<LoginLogItem>? getDataList(LoginLogData response) {
    return response.list;
  }

  @override
  Future<LoadingState<LoginLogData>> customGetData() => UserHttp.loginLog();

  @override
  List<(int, String)> getFlexAndText(LoginLogItem item) {
    return [(3, item.timeAt), (2, item.ip), (3, item.geo)];
  }

  @override
  final LoginLogItem header = const LoginLogItem(
    timeAt: '时间',
    ip: '变化',
    geo: '地理位置',
  );

  @override
  final String title = '登录记录';
}
