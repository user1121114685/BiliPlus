import 'dart:io';

import 'package:bili_plus/build_config.dart';
import 'package:bili_plus/common/constants.dart';
import 'package:bili_plus/common/widgets/custom_toast.dart';
import 'package:bili_plus/common/widgets/mouse_back.dart';
import 'package:bili_plus/http/init.dart';
import 'package:bili_plus/models/common/theme/theme_color_type.dart';
import 'package:bili_plus/plugin/pl_player/controller.dart';
import 'package:bili_plus/router/app_pages.dart';
import 'package:bili_plus/services/account_service.dart';
import 'package:bili_plus/services/logger.dart';
import 'package:bili_plus/services/service_locator.dart';
import 'package:bili_plus/utils/app_scheme.dart';
import 'package:bili_plus/utils/cache_manage.dart';
import 'package:bili_plus/utils/calc_window_position.dart';
import 'package:bili_plus/utils/date_utils.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:bili_plus/utils/request_utils.dart';
import 'package:bili_plus/utils/storage.dart';
import 'package:bili_plus/utils/storage_key.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:bili_plus/utils/theme_utils.dart';
import 'package:bili_plus/utils/utils.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart' hide calcWindowPosition;

WebViewEnvironment? webViewEnvironment;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  try {
    await GStorage.init();
  } catch (e) {
    await Utils.copyText(e.toString());
    if (kDebugMode) debugPrint('GStorage init error: $e');
    exit(0);
  }
  Get.lazyPut(AccountService.new);
  HttpOverrides.global = _CustomHttpOverrides();

  CacheManage.autoClearCache();

  if (Utils.isMobile) {
    await Future.wait([
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        if (Pref.horizontalScreen) ...[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      ]),
      setupServiceLocator(),
    ]);
  }

  if (Platform.isWindows) {
    if (await WebViewEnvironment.getAvailableVersion() != null) {
      final dir = await getApplicationSupportDirectory();
      webViewEnvironment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(
          userDataFolder: path.join(dir.path, 'flutter_inappwebview'),
        ),
      );
    }
  }

  Request();
  Request.setCookie();
  RequestUtils.syncHistoryStatus();
  if (Utils.isMobile) {
    PiliScheme.init();
  }

  SmartDialog.config.toast = SmartConfigToast(
    displayType: SmartToastType.onlyRefresh,
  );

  if (Utils.isMobile) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  } else if (Utils.isDesktop) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      minimumSize: const Size(400, 720),
      skipTaskbar: false,
      titleBarStyle: Pref.showWindowTitleBar
          ? TitleBarStyle.normal
          : TitleBarStyle.hidden,
      title: Constants.appName,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      final windowSize = Pref.windowSize;
      await windowManager.setBounds(
        await calcWindowPosition(windowSize) & windowSize,
      );
      if (Pref.isWindowMaximized) await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    });
  }

  if (Pref.enableLog) {
    // 异常捕获 logo记录
    String buildConfig =
        '''\n
Build Time: ${DateFormatUtils.format(BuildConfig.buildTime, format: DateFormatUtils.longFormatDs)}
Commit Hash: ${BuildConfig.commitHash}''';
    final Catcher2Options debugConfig = Catcher2Options(
      SilentReportMode(),
      [
        FileHandler(await LoggerUtils.getLogsPath()),
        ConsoleHandler(
          enableDeviceParameters: false,
          enableApplicationParameters: false,
          enableCustomParameters: true,
        ),
      ],
      customParameters: {'BuildConfig': buildConfig},
    );

    final Catcher2Options releaseConfig = Catcher2Options(
      SilentReportMode(),
      [
        FileHandler(await LoggerUtils.getLogsPath()),
        ConsoleHandler(enableCustomParameters: true),
      ],
      customParameters: {'BuildConfig': buildConfig},
    );

    Catcher2(
      debugConfig: debugConfig,
      releaseConfig: releaseConfig,
      runAppFunction: () {
        runApp(const MyApp());
      },
    );
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData? darkThemeData;

  @override
  Widget build(BuildContext context) {
    Color brandColor = colorThemeTypes[Pref.customColor].color;
    bool isDynamicColor = Pref.dynamicColor;
    FlexSchemeVariant variant = FlexSchemeVariant.values[Pref.schemeVariant];

    // 强制设置高帧率
    if (Platform.isAndroid) {
      late List<DisplayMode> modes;
      FlutterDisplayMode.supported.then((value) {
        modes = value;
        final String? storageDisplay = GStorage.setting.get(
          SettingBoxKey.displayMode,
        );
        DisplayMode? displayMode;
        if (storageDisplay != null) {
          displayMode = modes.firstWhereOrNull(
            (e) => e.toString() == storageDisplay,
          );
        }
        displayMode ??= DisplayMode.auto;
        FlutterDisplayMode.setPreferredMode(displayMode);
      });
    }

    return DynamicColorBuilder(
      builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        if (lightDynamic != null && darkDynamic != null && isDynamicColor) {
          // dynamic取色成功
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // dynamic取色失败，采用品牌色
          lightColorScheme = SeedColorScheme.fromSeeds(
            primaryKey: brandColor,
            brightness: Brightness.light,
            variant: variant,
            // dynamicSchemeVariant: dynamicSchemeVariant,
            // tones: FlexTones.soft(Brightness.light),
          );
          darkColorScheme = SeedColorScheme.fromSeeds(
            primaryKey: brandColor,
            brightness: Brightness.dark,
            variant: variant,
            // dynamicSchemeVariant: dynamicSchemeVariant,
            // tones: FlexTones.soft(Brightness.dark),
          );
        }

        // 图片缓存
        // PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 << 20;
        return GetMaterialApp(
          title: Constants.appName,
          theme: ThemeUtils.getThemeData(
            colorScheme: lightColorScheme,
            isDynamic: lightDynamic != null && isDynamicColor,
            variant: variant,
          ),
          darkTheme: ThemeUtils.getThemeData(
            colorScheme: darkColorScheme,
            isDynamic: darkDynamic != null && isDynamicColor,
            isDark: true,
            variant: variant,
          ),
          themeMode: Pref.themeMode,
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: const Locale("zh", "CN"),
          supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
          fallbackLocale: const Locale("zh", "CN"),
          getPages: Routes.getPages,
          initialRoute: '/',
          builder: FlutterSmartDialog.init(
            toastBuilder: (String msg) => CustomToast(msg: msg),
            loadingBuilder: (msg) => LoadingWidget(msg: msg),
            builder: (context, child) {
              child = MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(Pref.defaultTextScale),
                ),
                child: child!,
              );
              if (Utils.isDesktop) {
                void onBack() {
                  if (SmartDialog.checkExist()) {
                    SmartDialog.dismiss();
                    return;
                  }

                  if (Get.isDialogOpen ?? Get.isBottomSheetOpen ?? false) {
                    Get.back();
                    return;
                  }

                  final plCtr = PlPlayerController.instance;
                  if (plCtr != null) {
                    if (plCtr.isFullScreen.value) {
                      plCtr
                        ..triggerFullScreen(status: false)
                        ..controlsLock.value = false;
                      return;
                    }

                    if (plCtr.isDesktopPip) {
                      plCtr.exitDesktopPip().whenComplete(
                        () => plCtr.initialFocalPoint = Offset.zero,
                      );
                      return;
                    }
                  }

                  Get.back();
                }

                return Focus(
                  canRequestFocus: false,
                  onKeyEvent: (_, event) {
                    if (event.logicalKey == LogicalKeyboardKey.escape &&
                        event is KeyDownEvent) {
                      onBack();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: MouseBackDetector(onTapDown: onBack, child: child),
                );
              }
              return child;
            },
          ),
          navigatorObservers: [
            FlutterSmartDialog.observer,
            PageUtils.routeObserver,
          ],
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: false,
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.invertedStylus,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.unknown,
              if (Utils.isDesktop) PointerDeviceKind.mouse,
            },
          ),
        );
      }),
    );
  }
}

class _CustomHttpOverrides extends HttpOverrides {
  final badCertificateCallback = kDebugMode || Pref.badCertificateCallback;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)
      // ..maxConnectionsPerHost = 32
      ..idleTimeout = const Duration(seconds: 15);
    if (badCertificateCallback) {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    return client;
  }
}
