import 'package:bili_plus/models/model_owner.dart';

class FavFolderInfo {
  int id;
  int? fid;
  int mid;
  int attr;
  String? attrDesc;
  String title;
  String cover;
  Owner? upper;
  int? coverType;
  String? intro;
  int? ctime;
  int? mtime;
  int? state;
  int? favState;
  int mediaCount;
  int? viewCount;
  int? vt;
  bool? isTop;
  dynamic recentFav;
  int? playSwitch;
  int? type;
  String? link;
  String? bvid;

  FavFolderInfo({
    this.id = 0,
    this.fid,
    this.mid = 0,
    this.attr = -1,
    this.attrDesc,
    this.title = '',
    this.cover = '',
    this.upper,
    this.coverType,
    this.intro,
    this.ctime,
    this.mtime,
    this.state,
    this.favState,
    this.mediaCount = 0,
    this.viewCount,
    this.vt,
    this.isTop,
    this.recentFav,
    this.playSwitch,
    this.type,
    this.link,
    this.bvid,
  });

  factory FavFolderInfo.fromJson(Map<String, dynamic> json) => FavFolderInfo(
    id: json['id'] as int? ?? 0,
    fid: json['fid'] as int?,
    mid: json['mid'] as int? ?? 0,
    attr: json['attr'] as int? ?? 0,
    attrDesc: json['attr_desc'] as String?,
    title: json['title'] as String? ?? '',
    cover: json['cover'] as String? ?? '',
    upper: json['upper'] == null
        ? null
        : Owner.fromJson(json['upper'] as Map<String, dynamic>),
    coverType: json['cover_type'] as int?,
    intro: json['intro'] as String?,
    ctime: json['ctime'] as int?,
    mtime: json['mtime'] as int?,
    state: json['state'] as int?,
    favState: json['fav_state'] as int?,
    mediaCount: json['media_count'] as int? ?? 0,
    viewCount: json['view_count'] as int?,
    vt: json['vt'] as int?,
    isTop: json['is_top'] as bool?,
    recentFav: json['recent_fav'] as dynamic,
    playSwitch: json['play_switch'] as int?,
    type: json['type'] as int?,
    link: json['link'] as String?,
    bvid: json['bvid'] as String?,
  );
}
