import 'package:bili_plus/common/widgets/custom_icon.dart';
import 'package:bili_plus/models_new/dynamic/dyn_topic_top/topic_item.dart';
import 'package:bili_plus/utils/num_utils.dart';
import 'package:flutter/material.dart';

class DynTopicItem extends StatelessWidget {
  const DynTopicItem({super.key, required this.item, required this.onTap});

  final TopicItem item;
  final ValueChanged<TopicItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        dense: true,
        onTap: () => onTap(item),
        title: Text.rich(
          TextSpan(
            children: [
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Icon(CustomIcons.topic_tag, size: 18),
                ),
              ),
              TextSpan(text: item.name, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 23),
          child: Text(
            '${NumUtils.numFormat(item.view)}浏览 · ${NumUtils.numFormat(item.discuss)}讨论',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      ),
    );
  }
}
