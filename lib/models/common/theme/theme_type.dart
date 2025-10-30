import 'package:flutter/material.dart';

enum ThemeType {
  light('浅色'),
  dark('深色'),
  system('跟随系统');

  final String desc;
  const ThemeType(this.desc);

  ThemeMode get toThemeMode => switch (this) {
    ThemeType.light => ThemeMode.light,
    ThemeType.dark => ThemeMode.dark,
    ThemeType.system => ThemeMode.system,
  };

  Icon get icon => switch (this) {
    ThemeType.light => const Icon(Icons.light_mode),
    ThemeType.dark => const Icon(Icons.dark_mode),
    ThemeType.system => const Icon(Icons.brightness_auto_rounded),
  };
}
