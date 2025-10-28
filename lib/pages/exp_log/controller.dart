import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/user.dart';
import 'package:bili_plus/models_new/coin_log/data.dart';
import 'package:bili_plus/models_new/coin_log/list.dart';
import 'package:bili_plus/pages/log_table/controller.dart';

class ExpLogController extends LogController<CoinLogData, CoinLogItem> {
  @override
  List<CoinLogItem>? getDataList(CoinLogData response) {
    return response.list;
  }

  @override
  Future<LoadingState<CoinLogData>> customGetData() => UserHttp.expLog();

  @override
  List<(int, String)> getFlexAndText(CoinLogItem item) {
    return [(2, item.time), (1, item.delta), (2, item.reason)];
  }

  @override
  final CoinLogItem header = const CoinLogItem(
    time: '时间',
    delta: '变化',
    reason: '原因',
  );

  @override
  final String title = '经验记录';
}
