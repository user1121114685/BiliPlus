import 'package:bili_plus/common/widgets/list_tile.dart';
import 'package:bili_plus/common/widgets/view_safe_area.dart';
import 'package:bili_plus/http/login.dart';
import 'package:bili_plus/models/common/setting_type.dart';
import 'package:bili_plus/pages/about/view.dart';
import 'package:bili_plus/pages/login/controller.dart';
import 'package:bili_plus/pages/setting/extra_setting.dart';
import 'package:bili_plus/pages/setting/play_setting.dart';
import 'package:bili_plus/pages/setting/privacy_setting.dart';
import 'package:bili_plus/pages/setting/recommend_setting.dart';
import 'package:bili_plus/pages/setting/style_setting.dart';
import 'package:bili_plus/pages/setting/video_setting.dart';
import 'package:bili_plus/pages/setting/widgets/multi_select_dialog.dart';
import 'package:bili_plus/pages/webdav/view.dart';
import 'package:bili_plus/utils/accounts.dart';
import 'package:bili_plus/utils/accounts/account.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide ContextExtensionss;

class _SettingsModel {
  final SettingType type;
  final String? subtitle;
  final Icon icon;

  const _SettingsModel({required this.type, this.subtitle, required this.icon});
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SettingType _type = SettingType.privacySetting;
  final RxBool _noAccount = Accounts.account.isEmpty.obs;
  late bool _isPortrait;

  final List<_SettingsModel> _items = [
    _SettingsModel(
      type: SettingType.privacySetting,
      subtitle: '黑名单、无痕模式',
      icon: Icon(Icons.privacy_tip_outlined),
    ),
    _SettingsModel(
      type: SettingType.recommendSetting,
      subtitle: '推荐来源（web/app）、刷新保留内容、过滤器',
      icon: Icon(Icons.explore_outlined),
    ),
    _SettingsModel(
      type: SettingType.videoSetting,
      subtitle: '画质、音质、解码、缓冲、音频输出等',
      icon: Icon(Icons.video_settings_outlined),
    ),
    _SettingsModel(
      type: SettingType.playSetting,
      subtitle: '双击/长按、全屏、后台播放、弹幕、字幕、底部进度条等',
      icon: Icon(Icons.touch_app_outlined),
    ),
    _SettingsModel(
      type: SettingType.styleSetting,
      subtitle: '横屏适配（平板）、侧栏、列宽、首页、动态红点、主题、字号、图片、帧率等',
      icon: Icon(Icons.style_outlined),
    ),
    _SettingsModel(
      type: SettingType.extraSetting,
      subtitle: '震动、搜索、收藏、ai、评论、动态、代理、更新检查等',
      icon: Icon(Icons.extension_outlined),
    ),
    _SettingsModel(
      type: SettingType.webdavSetting,
      icon: Icon(Icons.phonelink_ring_outlined),
    ),
    _SettingsModel(type: SettingType.about, icon: Icon(Icons.info_outline)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _isPortrait = MediaQuery.sizeOf(context).isPortrait;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: _isPortrait ? const Text('设置') : Text(_type.title)),
      body: ViewSafeArea(
        child: _isPortrait
            ? _buildList(theme)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: _buildList(theme)),
                  VerticalDivider(
                    width: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  Expanded(
                    flex: 6,
                    child: switch (_type) {
                      SettingType.privacySetting => const PrivacySetting(
                        showAppBar: false,
                      ),
                      SettingType.recommendSetting => const RecommendSetting(
                        showAppBar: false,
                      ),
                      SettingType.videoSetting => const VideoSetting(
                        showAppBar: false,
                      ),
                      SettingType.playSetting => const PlaySetting(
                        showAppBar: false,
                      ),
                      SettingType.styleSetting => const StyleSetting(
                        showAppBar: false,
                      ),
                      SettingType.extraSetting => const ExtraSetting(
                        showAppBar: false,
                      ),
                      SettingType.webdavSetting => const WebDavSettingPage(
                        showAppBar: false,
                      ),
                      SettingType.about => const AboutPage(showAppBar: false),
                    },
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _noAccount.close();
    super.dispose();
  }

  void _toPage(SettingType type) {
    if (_isPortrait) {
      Get.toNamed('/${type.name}');
    } else {
      _type = type;
      setState(() {});
    }
  }

  Color? _getTileColor(ThemeData theme, SettingType type) {
    if (_isPortrait) {
      return null;
    } else {
      return type == _type ? theme.colorScheme.onInverseSurface : null;
    }
  }

  Widget _buildList(ThemeData theme) {
    final padding = MediaQuery.viewPaddingOf(context);
    TextStyle titleStyle = theme.textTheme.titleMedium!;
    TextStyle subTitleStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.outline,
    );
    return ListView(
      padding: EdgeInsets.only(bottom: padding.bottom + 100),
      children: [
        _buildSearchItem(theme),
        ..._items
            .sublist(0, _items.length - 1)
            .map(
              (item) => ListTile(
                tileColor: _getTileColor(theme, item.type),
                onTap: () => _toPage(item.type),
                leading: item.icon,
                title: Text(item.type.title, style: titleStyle),
                subtitle: item.subtitle == null
                    ? null
                    : Text(item.subtitle!, style: subTitleStyle),
              ),
            ),
        ListTile(
          onTap: () => LoginPageController.switchAccountDialog(context),
          leading: const Icon(Icons.switch_account_outlined),
          title: Text('设置账号模式', style: titleStyle),
        ),
        Obx(
          () => _noAccount.value
              ? const SizedBox.shrink()
              : ListTile(
                  leading: const Icon(Icons.logout_outlined),
                  onTap: () => _logoutDialog(context),
                  title: Text('退出登录', style: titleStyle),
                ),
        ),
        ListTile(
          tileColor: _getTileColor(theme, _items.last.type),
          onTap: () => _toPage(_items.last.type),
          leading: _items.last.icon,
          title: Text(_items.last.type.title, style: titleStyle),
        ),
      ],
    );
  }

  Future<void> _logoutDialog(BuildContext context) async {
    final result = await showDialog<Set<LoginAccount>>(
      context: context,
      builder: (context) {
        return MultiSelectDialog<LoginAccount>(
          title: '选择要登出的账号uid',
          initValues: const Iterable.empty(),
          values: {for (var i in Accounts.account.values) i: i.mid.toString()},
        );
      },
    );
    if (!context.mounted || result.isNullOrEmpty) return;
    Future<void> logout() {
      _noAccount.value = result!.length == Accounts.account.length;
      return Accounts.deleteAll(result);
    }

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('提示'),
          content: Text(
            "确认要退出以下账号登录吗\n\n${result!.map((i) => i.mid.toString()).join('\n')}",
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text(
                '点错了',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                logout();
              },
              child: Text(
                '仅登出',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () async {
                SmartDialog.showLoading();
                final res = await LoginHttp.logout(Accounts.main);
                if (res['status']) {
                  SmartDialog.dismiss();
                  logout();
                  Get.back();
                } else {
                  SmartDialog.dismiss();
                  SmartDialog.showToast(res['msg'].toString());
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchItem(ThemeData theme) => Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => Get.toNamed('/settingsSearch'),
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            color: theme.colorScheme.onInverseSurface,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  size: MediaQuery.textScalerOf(context).scale(18),
                  Icons.search,
                ),
                const Text(' 搜索'),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
