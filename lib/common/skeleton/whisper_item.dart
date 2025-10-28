import 'package:bili_plus/common/skeleton/skeleton.dart';
import 'package:flutter/material.dart';

class WhisperItemSkeleton extends StatelessWidget {
  const WhisperItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onInverseSurface;
    return Skeleton(
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        title: UnconstrainedBox(
          alignment: Alignment.centerLeft,
          child: Container(width: 100, height: 11, color: color),
        ),
        subtitle: Container(color: color, width: 125, height: 11),
        trailing: Container(color: color, width: 50, height: 11),
      ),
    );
  }
}
