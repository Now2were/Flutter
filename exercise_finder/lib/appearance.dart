import 'package:flutter/material.dart';

const ink = Color(0xff0e1116);
const panel = Color(0xff161a21);
const line = Color(0xff2a303b);
const volt = Color(0xffd4f53c);
const steel = Color(0xffc9ced6);

ThemeData atlasTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: volt,
        brightness: Brightness.dark,
      ).copyWith(
        primary: volt,
        onPrimary: ink,
        surface: panel,
        onSurface: const Color(0xfff5f7fa),
        onSurfaceVariant: steel,
        secondaryContainer: volt,
        onSecondaryContainer: ink,
        outline: const Color(0xff747d8c),
        outlineVariant: line,
      );
  final base = ThemeData(colorScheme: scheme);
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: line),
  );
  return base.copyWith(
    scaffoldBackgroundColor: ink,
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w900,
        height: 1.04,
        letterSpacing: -1.2,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ink,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: base.textTheme.titleMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
      shape: const Border(bottom: BorderSide(color: line)),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: panel,
      surfaceTintColor: Colors.transparent,
      height: 68,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: ink,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: const BorderSide(color: volt)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    cardTheme: CardThemeData(
      color: panel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: line),
      ),
    ),
  );
}

class AtlasPanel extends StatelessWidget {
  const AtlasPanel({super.key, required this.child, this.padding = 20});
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: panel,
      border: Border.all(color: line),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(padding: EdgeInsets.all(padding), child: child),
  );
}

class AtlasMark extends StatelessWidget {
  const AtlasMark(this.icon, {super.key, this.size = 44});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: volt.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: size * .51, color: volt),
  );
}
