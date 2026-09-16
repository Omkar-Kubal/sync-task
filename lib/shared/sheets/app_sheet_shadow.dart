import 'package:flutter/material.dart';

class AppSheetShadow {
  const AppSheetShadow._();

  static List<BoxShadow> get topEdge => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, -8),
    ),
  ];

  static BoxDecoration decoration({
    required Color color,
    BorderRadiusGeometry borderRadius = const BorderRadius.vertical(
      top: Radius.circular(28),
    ),
    BoxBorder? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: border,
      boxShadow: topEdge,
    );
  }
}
