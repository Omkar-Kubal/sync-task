import 'package:flutter/material.dart';

@immutable
class SyncTaskColorScheme extends ThemeExtension<SyncTaskColorScheme> {
  const SyncTaskColorScheme({
    required this.scaffold,
    required this.surface,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.controlPrimary,
    required this.controlForeground,
    required this.destructive,
    required this.activityIntensity,
  });

  final Color scaffold;
  final Color surface;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color controlPrimary;
  final Color controlForeground;
  final Color destructive;
  final List<Color> activityIntensity;

  static const light = SyncTaskColorScheme(
    scaffold: Color(0xFFF2F2F7),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF7F7FA),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF8E8E93),
    divider: Color(0xFFE5E5EA),
    controlPrimary: Color(0xFF000000),
    controlForeground: Color(0xFFFFFFFF),
    destructive: Color(0xFFD92D20),
    activityIntensity: [
      Color(0xFFE5E5EA),
      Color(0xFFC7C7CC),
      Color(0xFF8E8E93),
      Color(0xFF3A3A3C),
      Color(0xFF000000),
    ],
  );

  static const dark = SyncTaskColorScheme(
    scaffold: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    surfaceSecondary: Color(0xFF2C2C2E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8E8E93),
    divider: Color(0xFF3A3A3C),
    controlPrimary: Color(0xFFFFFFFF),
    controlForeground: Color(0xFF000000),
    destructive: Color(0xFFFF453A),
    activityIntensity: [
      Color(0xFF2C2C2E),
      Color(0xFF48484A),
      Color(0xFF8E8E93),
      Color(0xFFC7C7CC),
      Color(0xFFFFFFFF),
    ],
  );

  static SyncTaskColorScheme of(BuildContext context) {
    return Theme.of(context).extension<SyncTaskColorScheme>()!;
  }

  @override
  SyncTaskColorScheme copyWith({
    Color? scaffold,
    Color? surface,
    Color? surfaceSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? controlPrimary,
    Color? controlForeground,
    Color? destructive,
    List<Color>? activityIntensity,
  }) {
    return SyncTaskColorScheme(
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      controlPrimary: controlPrimary ?? this.controlPrimary,
      controlForeground: controlForeground ?? this.controlForeground,
      destructive: destructive ?? this.destructive,
      activityIntensity: activityIntensity ?? this.activityIntensity,
    );
  }

  @override
  SyncTaskColorScheme lerp(ThemeExtension<SyncTaskColorScheme>? other, double t) {
    if (other is! SyncTaskColorScheme) {
      return this;
    }

    return SyncTaskColorScheme(
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      controlPrimary: Color.lerp(controlPrimary, other.controlPrimary, t)!,
      controlForeground: Color.lerp(controlForeground, other.controlForeground, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      activityIntensity: [
        for (var i = 0; i < activityIntensity.length; i++)
          Color.lerp(activityIntensity[i], other.activityIntensity[i], t)!,
      ],
    );
  }
}
