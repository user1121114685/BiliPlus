import 'package:bili_plus/models/common/image_preview_type.dart';
import 'package:bili_plus/utils/image_utils.dart';
import 'package:bili_plus/utils/page_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

Widget htmlRender({
  required BuildContext context,
  dom.Element? element,
  String? html,
  int? imgCount,
  List<String>? imgList,
  required double maxWidth,
}) {
  // if (kDebugMode) debugPrint('htmlRender');
  final extensions = [
    TagExtension(
      tagsToExtend: <String>{'img'},
      builder: (ExtensionContext extensionContext) {
        try {
          final Map<String, dynamic> attributes = extensionContext.attributes;
          final List<dynamic> key = attributes.keys.toList();
          String imgUrl = key.contains('src')
              ? attributes['src'] as String
              : attributes['data-src'] as String;
          imgUrl = imgUrl.contains('@') ? imgUrl.split('@').first : imgUrl;
          final bool isEmote = imgUrl.contains('/emote/');
          final bool isMall = imgUrl.contains('/mall/');
          if (isMall) {
            return const SizedBox.shrink();
          }

          String? clazz = attributes['class'];
          String? height = RegExp(
            r'max-height:(\d+)px',
          ).firstMatch('${attributes['style']}')?.group(1);
          if (clazz?.contains('cut-off') == true || height != null) {
            return CachedNetworkImage(
              width: maxWidth,
              height: height != null ? double.parse(height) : null,
              imageUrl: ImageUtils.thumbnailUrl(imgUrl),
              fit: BoxFit.contain,
            );
          }
          final size = isEmote ? 22.0 : null;
          return Hero(
            tag: imgUrl,
            child: GestureDetector(
              onTap: () {
                PageUtils.imageView(
                  imgList: [SourceModel(url: imgUrl)],
                  quality: 60,
                );
              },
              child: CachedNetworkImage(
                width: size,
                height: size,
                imageUrl: ImageUtils.thumbnailUrl(imgUrl, 60),
                fadeInDuration: const Duration(milliseconds: 120),
                fadeOutDuration: const Duration(milliseconds: 120),
                placeholder: (context, url) =>
                    Image.asset('assets/images/loading.png'),
              ),
            ),
          );
        } catch (err) {
          if (kDebugMode) debugPrint('错误的HTML: $element');
          return const SizedBox.shrink();
        }
      },
    ),
  ];
  final style = {
    'html': Style(
      fontSize: FontSize(16),
      lineHeight: LineHeight.percent(160),
      letterSpacing: 0.3,
    ),
    'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
    'a': Style(
      color: Theme.of(context).colorScheme.primary,
      textDecoration: TextDecoration.none,
    ),
    'br': Style(lineHeight: LineHeight.percent(-1)),
    'p': Style(margin: Margins.only(bottom: 4)),
    'span': Style(fontSize: FontSize.large, height: Height(1.8)),
    'div': Style(height: Height.auto()),
    'li > p': Style(display: Display.inline),
    'li': Style(
      padding: HtmlPaddings.only(bottom: 4),
      textAlign: TextAlign.justify,
    ),
    'img': Style(margin: Margins.only(top: 4, bottom: 4)),
    'h1,h2': Style(
      fontSize: FontSize.xLarge,
      fontWeight: FontWeight.bold,
      margin: Margins.only(bottom: 8),
    ),
    'h3,h4,h5': Style(
      fontSize: FontSize(16),
      fontWeight: FontWeight.bold,
      margin: Margins.only(bottom: 4),
    ),
    'figcaption': Style(fontSize: FontSize.large, textAlign: TextAlign.center),
    'strong': Style(fontWeight: FontWeight.bold),
    'figure': Style(margin: Margins.zero),
  };
  return SelectionArea(
    child: element != null
        ? Html.fromElement(
            documentElement: element,
            extensions: extensions,
            style: style,
          )
        : Html(data: html, extensions: extensions, style: style),
  );
}
