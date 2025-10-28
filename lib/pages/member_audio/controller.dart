import 'package:bili_plus/grpc/bilibili/app/listener/v1.pbenum.dart'
    show PlaylistSource;
import 'package:bili_plus/http/loading_state.dart';
import 'package:bili_plus/http/member.dart';
import 'package:bili_plus/models_new/space/space_audio/data.dart';
import 'package:bili_plus/models_new/space/space_audio/item.dart';
import 'package:bili_plus/pages/audio/view.dart';
import 'package:bili_plus/pages/common/common_list_controller.dart';

class MemberAudioController
    extends CommonListController<SpaceAudioData, SpaceAudioItem> {
  MemberAudioController(this.mid);

  final int mid;
  int? totalSize;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  void checkIsEnd(int length) {
    if (totalSize != null && length >= totalSize!) {
      isEnd = true;
    }
  }

  @override
  List<SpaceAudioItem>? getDataList(SpaceAudioData response) {
    totalSize = response.totalSize;
    return response.items;
  }

  @override
  Future<LoadingState<SpaceAudioData>> customGetData() =>
      MemberHttp.spaceAudio(page: page, mid: mid);

  void toViewPlayAll() {
    final item = loadingState.value.data!.first;
    AudioPage.toAudioPage(
      itemType: 3,
      id: item.uid!,
      oid: item.id!,
      from: PlaylistSource.MEM_SPACE,
    );
  }
}
