import 'package:bili_plus/common/widgets/color_palette.dart';
import 'package:bili_plus/models/common/nav_bar_config.dart';
import 'package:bili_plus/models/common/theme/theme_color_type.dart';
import 'package:bili_plus/models/common/theme/theme_type.dart';
import 'package:bili_plus/pages/home/view.dart';
import 'package:bili_plus/pages/mine/controller.dart';
import 'package:bili_plus/pages/setting/widgets/select_dialog.dart';
import 'package:bili_plus/utils/storage.dart';
import 'package:bili_plus/utils/storage_key.dart';
import 'package:bili_plus/utils/storage_pref.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ColorSelectPage extends StatefulWidget {
  const ColorSelectPage({super.key});

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int count) {
  return List<Item>.generate(count, (int index) {
    return Item(
      headerValue: 'Panel $index',
      expandedValue: 'This is item number $index',
    );
  });
}

class _ColorSelectPageState extends State<ColorSelectPage> {
  final ColorSelectController ctr = Get.put(ColorSelectController());
  FlexSchemeVariant _dynamicSchemeVariant =
      FlexSchemeVariant.values[Pref.schemeVariant];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle titleStyle = theme.textTheme.titleMedium!;
    TextStyle subTitleStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.outline,
    );
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.viewPaddingOf(
      context,
    ).copyWith(top: 0, bottom: 0);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('选择应用主题')),
      body: ListView(
        children: [
          ListTile(
            onTap: () async {
              ThemeType? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<ThemeType>(
                    title: '主题模式',
                    value: ctr.themeType.value,
                    values: ThemeType.values.map((e) => (e, e.desc)).toList(),
                  );
                },
              );
              if (result != null) {
                try {
                  Get.find<MineController>().themeType.value = result;
                } catch (_) {}
                ctr.themeType.value = result;
                GStorage.setting.put(SettingBoxKey.themeMode, result.index);
                Get.changeThemeMode(result.toThemeMode);
              }
            },
            leading: Container(
              width: 40,
              alignment: Alignment.center,
              child: const Icon(Icons.flashlight_on_outlined),
            ),
            title: Text('主题模式', style: titleStyle),
            subtitle: Obx(
              () => Text(
                '当前模式：${ctr.themeType.value.desc}',
                style: subTitleStyle,
              ),
            ),
          ),
          Obx(
            () => ListTile(
              enabled: !ctr.dynamicColor.value,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('调色板风格'),
                  PopupMenuButton(
                    enabled: !ctr.dynamicColor.value,
                    initialValue: _dynamicSchemeVariant,
                    onSelected: (item) {
                      _dynamicSchemeVariant = item;
                      GStorage.setting.put(
                        SettingBoxKey.schemeVariant,
                        item.index,
                      );
                      Get.forceAppUpdate();
                    },
                    itemBuilder: (context) => FlexSchemeVariant.values
                        .map(
                          (item) => PopupMenuItem<FlexSchemeVariant>(
                            value: item,
                            child: Text(item.variantName),
                          ),
                        )
                        .toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dynamicSchemeVariant.variantName,
                          style: TextStyle(
                            height: 1,
                            fontSize: 13,
                            color: ctr.dynamicColor.value
                                ? theme.colorScheme.outline.withValues(
                                    alpha: 0.8,
                                  )
                                : theme.colorScheme.secondary,
                          ),
                          strutStyle: const StrutStyle(leading: 0, height: 1),
                        ),
                        Icon(
                          size: 20,
                          Icons.keyboard_arrow_right,
                          color: ctr.dynamicColor.value
                              ? theme.colorScheme.outline.withValues(alpha: 0.8)
                              : theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              leading: Container(
                width: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.palette_outlined),
              ),
              subtitle: Text(
                _dynamicSchemeVariant.description,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          Obx(
            () => CheckboxListTile(
              title: const Text('动态取色'),
              controlAffinity: ListTileControlAffinity.leading,
              value: ctr.dynamicColor.value,
              onChanged: (val) {
                ctr
                  ..dynamicColor.value = val!
                  ..setting.put(SettingBoxKey.dynamicColor, val);
                Get.forceAppUpdate();
              },
            ),
          ),
          Padding(
            padding: padding,
            child: AnimatedSize(
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 200),
              child: Obx(
                () => ctr.dynamicColor.value
                    ? const SizedBox.shrink(key: ValueKey(false))
                    : Padding(
                        key: const ValueKey(true),
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 22,
                          runSpacing: 18,
                          children: colorThemeTypes.indexed.map((e) {
                            final index = e.$1;
                            final item = e.$2;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                ctr
                                  ..currentColor.value = index
                                  ..setting.put(
                                    SettingBoxKey.customColor,
                                    index,
                                  );
                                Get.forceAppUpdate();
                              },
                              child: Column(
                                spacing: 3,
                                children: [
                                  ColorPalette(
                                    color: item.color,
                                    selected: ctr.currentColor.value == index,
                                  ),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ctr.currentColor.value != index
                                          ? theme.colorScheme.outline
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: IgnorePointer(
              child: Container(
                height: size.height / 2,
                width: size.width,
                color: theme.colorScheme.surface,
                child: const HomePage(),
              ),
            ),
          ),
          IgnorePointer(
            child: NavigationBar(
              destinations: NavigationBarType.values
                  .map(
                    (item) => NavigationDestination(
                      icon: item.icon,
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorSelectController extends GetxController {
  final RxBool dynamicColor = Pref.dynamicColor.obs;
  final RxInt currentColor = Pref.customColor.obs;
  final RxDouble currentTextScale = Pref.defaultTextScale.obs;
  final Rx<ThemeType> themeType = Pref.themeType.obs;

  Box setting = GStorage.setting;
}
