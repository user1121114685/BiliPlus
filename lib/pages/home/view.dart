import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/image/network_img_layer.dart';
import 'package:bili_plus/common/widgets/scroll_physics.dart';
import 'package:bili_plus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:bili_plus/models/common/image_type.dart';
import 'package:bili_plus/pages/home/controller.dart';
import 'package:bili_plus/pages/main/controller.dart';
import 'package:bili_plus/pages/mine/controller.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:bili_plus/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final HomeController _homeController = Get.put(HomeController());
  final MainController _mainController = Get.put(MainController());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        if (!_homeController.useSideBar &&
            MediaQuery.sizeOf(context).isPortrait)
          customAppBar(theme),
        if (_homeController.tabs.length > 1)
          Material(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                height: 42,
                width: double.infinity,
                child: TabBar(
                  controller: _homeController.tabController,
                  tabs: [
                    for (var i in _homeController.tabs) Tab(text: i.label),
                  ],
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  splashBorderRadius: StyleString.mdRadius,
                  tabAlignment: TabAlignment.center,
                  onTap: (_) {
                    feedBack();
                    if (!_homeController.tabController.indexIsChanging) {
                      _homeController.animateToTop();
                    }
                  },
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 6),
        Expanded(
          child: tabBarView(
            controller: _homeController.tabController,
            children: _homeController.tabs.map((e) => e.page).toList(),
          ),
        ),
      ],
    );
  }

  Widget searchBarAndUser(ThemeData theme) {
    return Row(
      children: [
        searchBar(theme),
        const SizedBox(width: 4),
        Obx(
          () => _homeController.accountService.isLogin.value
              ? msgBadge(_mainController)
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: "我的",
          child: Obx(
            () => _homeController.accountService.isLogin.value
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NetworkImgLayer(
                        type: ImageType.avatar,
                        width: 34,
                        height: 34,
                        src: _homeController.accountService.face.value,
                      ),
                      Positioned.fill(
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: _mainController.toMinePage,
                            splashColor: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            customBorder: const CircleBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -6,
                        bottom: -6,
                        child: Obx(
                          () => MineController.anonymity.value
                              ? IgnorePointer(
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.colorScheme.secondaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      size: 16,
                                      MdiIcons.incognito,
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  )
                : defaultUser(
                    theme: theme,
                    onPressed: _mainController.toMinePage,
                  ),
          ),
        ),
      ],
    );
  }

  Widget customAppBar(ThemeData theme) {
    if (!_homeController.hideSearchBar) {
      return Container(
        height: 52,
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
        child: searchBarAndUser(theme),
      );
    }
    return StreamBuilder(
      stream: _homeController.searchBarStream?.stream.distinct(),
      initialData: true,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.data ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            curve: Curves.easeInOutCubicEmphasized,
            duration: const Duration(milliseconds: 500),
            height: snapshot.data ? 52 : 0,
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: searchBarAndUser(theme),
          ),
        );
      },
    );
  }

  Widget searchBar(ThemeData theme) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.05),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            splashColor: theme.colorScheme.primaryContainer.withValues(
              alpha: 0.3,
            ),
            onTap: () => Get.toNamed(
              '/search',
              parameters: {
                if (_homeController.enableSearchWord)
                  'hintText': _homeController.defaultSearch.value,
              },
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  Icons.search_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                  semanticLabel: '搜索',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => Text(
                      _homeController.defaultSearch.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget defaultUser({
  required ThemeData theme,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: 38,
    height: 38,
    child: IconButton(
      tooltip: '点击登录',
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        backgroundColor: WidgetStatePropertyAll(
          theme.colorScheme.onInverseSurface,
        ),
      ),
      onPressed: onPressed,
      icon: Icon(
        Icons.person_rounded,
        size: 22,
        color: theme.colorScheme.primary,
      ),
    ),
  );
}

Widget msgBadge(MainController mainController) {
  void toWhisper() {
    mainController.msgUnReadCount.value = '';
    mainController.lastCheckUnreadAt = DateTime.now().millisecondsSinceEpoch;
    Get.toNamed('/whisper');
  }

  final msgUnReadCount = mainController.msgUnReadCount.value;
  return GestureDetector(
    onTap: toWhisper,
    child: Badge(
      isLabelVisible:
          mainController.msgBadgeMode != DynamicBadgeMode.hidden &&
          msgUnReadCount.isNotEmpty,
      alignment: mainController.msgBadgeMode == DynamicBadgeMode.number
          ? const Alignment(0, -0.5)
          : const Alignment(0.5, -0.5),
      label:
          mainController.msgBadgeMode == DynamicBadgeMode.number &&
              msgUnReadCount.isNotEmpty
          ? Text(msgUnReadCount)
          : null,
      child: IconButton(
        tooltip: '消息',
        onPressed: toWhisper,
        icon: const Icon(
          Icons.notifications_none,
        ),
      ),
    ),
  );
}
