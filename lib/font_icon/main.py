from bs4 import BeautifulSoup

# 项目开始于 https://kekee000.github.io/fonteditor/#
# 读取 HTML 文件
# fontPackage: _kFontPkg 设置为 null 是为了处理不同的字体加载场景。具体来说：

# 项目内字体：
# 如果你的自定义字体文件直接包含在项目中，而不是通过 Dart 包引入，那么 fontPackage 可以设置为 null。这样，Flutter 会在项目的根目录下查找字体文件。
# 包内字体：
# 如果你的字体文件是通过 Dart 包引入的（例如，你创建了一个 Dart 包并在其中包含了字体文件），那么 fontPackage 应该设置为该包的名称。这样，Flutter 会在指定的包中查找字体文件。
# 可以先从 https://www.iconfont.cn/ 我的项目 中下载字体【1.先加入购物车，再添加到项目，然后再下载】
# 然后从 https://kekee000.github.io/fonteditor/# 中添加原来的字体，最后再导入刚才从https://www.iconfont.cn/ 下载的字体，然后使用 选中刚才导入的图标 使用设置代码点 现在最新是f915 设置取消字体名称
# 同时 你也可以在  https://kekee000.github.io/fonteditor/#  中编辑字体大小，居中调整，让字体图标更加统一

with open('I:/bilibili/fonteditor/example.html', 'r', encoding='utf-8') as file:
    html_content = file.read()

soup = BeautifulSoup(html_content, 'html.parser')
icons = soup.find_all('li')

flutter_icon_template = '''
import 'package:flutter/material.dart';

class BiliBiliIcons {{
  BiliBiliIcons._();

  static const _kFontFam = 'BiliBiliIcons';
  static const String? _kFontPkg = null;

  {icon_definitions}
}}
'''

icon_definitions = []

for icon in icons:
    name = icon.find('div', class_='name').text
    codes = icon.find('div', class_='code').text.split(',')
    for index, code in enumerate(codes):
        icon_name = f"{name}{index + 1}" if len(codes) > 1 else name
        code_value = code.strip().replace('\\', '')
        icon_name=icon_name.replace('@','').replace('-','_')
        icon_definitions.append(
            f"/// {name} 图标\nstatic IconData {icon_name} = const IconData(0x{code_value}, fontFamily: _kFontFam, fontPackage: _kFontPkg);")

icon_definitions_str = '\n  '.join(icon_definitions)
flutter_icon_code = flutter_icon_template.format(icon_definitions=icon_definitions_str)

# 将生成的代码写入文件
with open('bilibili_icons.dart', 'w', encoding='utf-8') as file:
    file.write(flutter_icon_code)

print("Flutter 自定义图标代码已生成并保存到 bilibili_icons.dart 文件中。")