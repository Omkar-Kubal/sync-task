import 'package:flutter/material.dart';

/// The six font sizes used by SyncTasks' mobile interface.
abstract final class SyncFontScale {
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double xxl = 32;
}

/// Semantic typography roles shared by the app theme and individual widgets.
@immutable
class SyncTypography extends ThemeExtension<SyncTypography> {
  const SyncTypography({
    required this.pageTitle,
    required this.cardTitle,
    required this.sectionLabel,
    required this.bodyTitle,
    required this.rowTitle,
    required this.supporting,
    required this.button,
    required this.action,
    required this.heroMetric,
    required this.amountInput,
    required this.inlineAmount,
    required this.chartLabel,
  });

  static const String fontFamily = 'Google Sans';

  final TextStyle pageTitle;
  final TextStyle cardTitle;
  final TextStyle sectionLabel;
  final TextStyle bodyTitle;
  final TextStyle rowTitle;
  final TextStyle supporting;
  final TextStyle button;
  final TextStyle action;
  final TextStyle heroMetric;
  final TextStyle amountInput;
  final TextStyle inlineAmount;
  final TextStyle chartLabel;

  factory SyncTypography.forColors({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    TextStyle style({
      required double size,
      required FontWeight weight,
      required double lineHeight,
      Color? color,
    }) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: lineHeight / size,
      letterSpacing: 0,
      color: color ?? textPrimary,
    );

    return SyncTypography(
      pageTitle: style(
        size: SyncFontScale.lg,
        weight: FontWeight.w600,
        lineHeight: 28,
      ),
      cardTitle: style(
        size: SyncFontScale.md,
        weight: FontWeight.w600,
        lineHeight: 22,
      ),
      sectionLabel: style(
        size: SyncFontScale.xs,
        weight: FontWeight.w500,
        lineHeight: 16,
        color: textSecondary,
      ),
      bodyTitle: style(
        size: SyncFontScale.md,
        weight: FontWeight.w500,
        lineHeight: 22,
      ),
      rowTitle: style(
        size: SyncFontScale.sm,
        weight: FontWeight.w500,
        lineHeight: 20,
      ),
      supporting: style(
        size: SyncFontScale.xs,
        weight: FontWeight.w400,
        lineHeight: 16,
        color: textSecondary,
      ),
      button: style(
        size: SyncFontScale.sm,
        weight: FontWeight.w600,
        lineHeight: 20,
      ),
      action: style(
        size: SyncFontScale.sm,
        weight: FontWeight.w500,
        lineHeight: 20,
      ),
      heroMetric: style(
        size: SyncFontScale.xxl,
        weight: FontWeight.w600,
        lineHeight: 38,
      ),
      amountInput: style(
        size: SyncFontScale.xl,
        weight: FontWeight.w600,
        lineHeight: 34,
      ),
      inlineAmount: style(
        size: SyncFontScale.sm,
        weight: FontWeight.w600,
        lineHeight: 20,
      ),
      chartLabel: style(
        size: SyncFontScale.xs,
        weight: FontWeight.w400,
        lineHeight: 16,
        color: textSecondary,
      ),
    );
  }

  static SyncTypography of(BuildContext context) =>
      Theme.of(context).extension<SyncTypography>()!;

  @override
  SyncTypography copyWith({
    TextStyle? pageTitle,
    TextStyle? cardTitle,
    TextStyle? sectionLabel,
    TextStyle? bodyTitle,
    TextStyle? rowTitle,
    TextStyle? supporting,
    TextStyle? button,
    TextStyle? action,
    TextStyle? heroMetric,
    TextStyle? amountInput,
    TextStyle? inlineAmount,
    TextStyle? chartLabel,
  }) => SyncTypography(
    pageTitle: pageTitle ?? this.pageTitle,
    cardTitle: cardTitle ?? this.cardTitle,
    sectionLabel: sectionLabel ?? this.sectionLabel,
    bodyTitle: bodyTitle ?? this.bodyTitle,
    rowTitle: rowTitle ?? this.rowTitle,
    supporting: supporting ?? this.supporting,
    button: button ?? this.button,
    action: action ?? this.action,
    heroMetric: heroMetric ?? this.heroMetric,
    amountInput: amountInput ?? this.amountInput,
    inlineAmount: inlineAmount ?? this.inlineAmount,
    chartLabel: chartLabel ?? this.chartLabel,
  );

  @override
  SyncTypography lerp(
    covariant ThemeExtension<SyncTypography>? other,
    double t,
  ) {
    if (other is! SyncTypography) return this;
    return SyncTypography(
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
      bodyTitle: TextStyle.lerp(bodyTitle, other.bodyTitle, t)!,
      rowTitle: TextStyle.lerp(rowTitle, other.rowTitle, t)!,
      supporting: TextStyle.lerp(supporting, other.supporting, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      action: TextStyle.lerp(action, other.action, t)!,
      heroMetric: TextStyle.lerp(heroMetric, other.heroMetric, t)!,
      amountInput: TextStyle.lerp(amountInput, other.amountInput, t)!,
      inlineAmount: TextStyle.lerp(inlineAmount, other.inlineAmount, t)!,
      chartLabel: TextStyle.lerp(chartLabel, other.chartLabel, t)!,
    );
  }
}
