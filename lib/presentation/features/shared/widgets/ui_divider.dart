import 'package:flutter/material.dart';

/// UI Divider Widget
///
/// A common divider used across multiple screens.
class UiDivider extends StatelessWidget {
  final Color color;
  final EdgeInsetsGeometry margin;
  final double height;

  const UiDivider({
    super.key,
    this.color = const Color(0xFF979797),
    this.margin = const EdgeInsets.symmetric(horizontal: 12),
    this.height = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color,
      margin: margin,
    );
  }
}
