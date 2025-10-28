import 'package:bili_plus/http/init.dart';
import 'package:bili_plus/http/search.dart';
import 'package:bili_plus/utils/accounts/account.dart';
import 'package:bili_plus/utils/id_utils.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

abstract class UrlUtils {
  // 302重定向路由截取
  static Future<String?> parseRedirectUrl(
    String url, [
    bool returnOri = false,
  ]) async {
    String? redirectUrl;
    try {
      final response = await Request.dio.head(
        url,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return 200 <= status! && status < 400;
          },
          extra: {'account': AnonymousAccount()},
        ),
      );
      redirectUrl = response.headers['location']?.firstOrNull;
      if (kDebugMode) debugPrint('redirectUrl: $redirectUrl');
      if (redirectUrl != null && !redirectUrl.startsWith('http')) {
        redirectUrl = Uri.parse(url).resolve(redirectUrl).toString();
      }
    } catch (_) {}
    if (returnOri && redirectUrl == null) redirectUrl = url;
    if (redirectUrl?.endsWith('/') == true) {
      redirectUrl = redirectUrl!.substring(0, redirectUrl.length - 1);
    }
    return redirectUrl;
  }

  // 匹配url路由跳转
  static Future<void> matchUrlPush(
    String pathSegment,
    String redirectUrl,
  ) async {
    final matchRes = IdUtils.matchAvorBv(input: pathSegment);
    if (matchRes.isNotEmpty) {
      final aid = matchRes.av;
      String? bvid = matchRes.bv;
      bvid ??= IdUtils.av2bv(aid!);
      final int? cid = await SearchHttp.ab2c(aid: aid, bvid: bvid);
      if (cid != null) {
        PageUtils.toVideoPage(aid: aid, bvid: bvid, cid: cid);
      }
    } else {
      if (redirectUrl.isNotEmpty) {
        PageUtils.handleWebview(redirectUrl);
      } else {
        SmartDialog.showToast('matchUrlPush: $pathSegment');
      }
    }
  }
}
