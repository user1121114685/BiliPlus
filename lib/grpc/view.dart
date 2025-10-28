import 'package:bili_plus/grpc/bilibili/app/viewunite/v1.pb.dart'
    show ViewReq, ViewReply;
import 'package:bili_plus/grpc/grpc_req.dart';
import 'package:bili_plus/grpc/url.dart';
import 'package:bili_plus/http/loading_state.dart';

class ViewGrpc {
  static Future<LoadingState<ViewReply>> view({required String bvid}) {
    return GrpcReq.request(
      GrpcUrl.view,
      ViewReq(bvid: bvid),
      ViewReply.fromBuffer,
    );
  }
}
