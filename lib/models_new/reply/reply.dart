import 'package:bili_plus/models_new/reply/content.dart';
import 'package:bili_plus/models_new/reply/folder.dart';
import 'package:bili_plus/models_new/reply/member.dart';
import 'package:bili_plus/models_new/reply/reply_control.dart';
import 'package:bili_plus/models_new/reply/up_action.dart';

class ReplyItemModel {
  int? rpid;
  int? oid;
  int? type;
  int? mid;
  int? root;
  int? parent;
  int? dialog;
  int? count;
  int? rcount;
  int? state;
  int? fansgrade;
  int? attr;
  int? ctime;
  String? midStr;
  String? oidStr;
  String? rpidStr;
  String? rootStr;
  String? parentStr;
  String? dialogStr;
  int? like;
  int? action;
  ReplyMember? member;
  ReplyContent? content;
  List<ReplyItemModel>? replies;
  int? assist;
  UpAction? upAction;
  bool? invisible;
  ReplyControl? replyControl;
  ReplyFolder? folder;
  int? dynamicId;
  String? dynamicIdStr;
  String? noteCvidStr;
  String? trackInfo;

  ReplyItemModel({
    this.rpid,
    this.oid,
    this.type,
    this.mid,
    this.root,
    this.parent,
    this.dialog,
    this.count,
    this.rcount,
    this.state,
    this.fansgrade,
    this.attr,
    this.ctime,
    this.midStr,
    this.oidStr,
    this.rpidStr,
    this.rootStr,
    this.parentStr,
    this.dialogStr,
    this.like,
    this.action,
    this.member,
    this.content,
    this.replies,
    this.assist,
    this.upAction,
    this.invisible,
    this.replyControl,
    this.folder,
    this.dynamicId,
    this.dynamicIdStr,
    this.noteCvidStr,
    this.trackInfo,
  });

  factory ReplyItemModel.fromJson(Map<String, dynamic> json) => ReplyItemModel(
    rpid: json['rpid'] as int?,
    oid: json['oid'] as int?,
    type: json['type'] as int?,
    mid: json['mid'] as int?,
    root: json['root'] as int?,
    parent: json['parent'] as int?,
    dialog: json['dialog'] as int?,
    count: json['count'] as int?,
    rcount: json['rcount'] as int?,
    state: json['state'] as int?,
    fansgrade: json['fansgrade'] as int?,
    attr: json['attr'] as int?,
    ctime: json['ctime'] as int?,
    midStr: json['mid_str'] as String?,
    oidStr: json['oid_str'] as String?,
    rpidStr: json['rpid_str'] as String?,
    rootStr: json['root_str'] as String?,
    parentStr: json['parent_str'] as String?,
    dialogStr: json['dialog_str'] as String?,
    like: json['like'] as int?,
    action: json['action'] as int?,
    member: json['member'] == null
        ? null
        : ReplyMember.fromJson(json['member'] as Map<String, dynamic>),
    content: json['content'] == null
        ? null
        : ReplyContent.fromJson(json['content'] as Map<String, dynamic>),
    replies: (json['replies'] as List<dynamic>?)
        ?.map((e) => ReplyItemModel.fromJson(e))
        .toList(),
    assist: json['assist'] as int?,
    upAction: json['up_action'] == null
        ? null
        : UpAction.fromJson(json['up_action'] as Map<String, dynamic>),
    invisible: json['invisible'] as bool?,
    replyControl: json['reply_control'] == null
        ? null
        : ReplyControl.fromJson(json['reply_control'] as Map<String, dynamic>),
    folder: json['folder'] == null
        ? null
        : ReplyFolder.fromJson(json['folder'] as Map<String, dynamic>),
    dynamicId: json['dynamic_id'] as int?,
    dynamicIdStr: json['dynamic_id_str'] as String?,
    noteCvidStr: json['note_cvid_str'] as String?,
    trackInfo: json['track_info'] as String?,
  );
}
