import 'package:flutter/material.dart';

class SyncMotion {
  const SyncMotion._();

  static const microDuration = Duration(milliseconds: 110);
  static const shortDuration = Duration(milliseconds: 180);
  static const pageDuration = Duration(milliseconds: 260);
  static const pageReverseDuration = Duration(milliseconds: 220);
  static const sheetDuration = Duration(milliseconds: 240);
  static const sheetReverseDuration = Duration(milliseconds: 180);
  static const themeDuration = shortDuration;

  static const pageSlideDistance = 0.12;

  static const Curve standardCurve = Curves.easeInOutCubic;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
}


