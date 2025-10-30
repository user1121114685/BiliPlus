import 'package:bili_plus/font_icon/bilibili_icons.dart';
import 'package:flutter/material.dart';

enum ReplyOptionType {
  allow('允许评论'),
  close('关闭评论'),
  choose('精选评论');

  final String title;
  const ReplyOptionType(this.title);

  IconData get iconData => switch (this) {
    ReplyOptionType.allow => BiliBiliIcons.bubble_comment_line500,
    ReplyOptionType.close => BiliBiliIcons.bubble_comment_off_line500,
    ReplyOptionType.choose => BiliBiliIcons.bubble_comment_setting_line500,
  };
}
