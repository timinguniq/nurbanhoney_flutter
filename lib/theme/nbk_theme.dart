import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'nbk_colors.dart';
import 'nbk_spacing.dart';
import 'nbk_typography.dart';

/// 토큰으로 조립한 [ThemeData]. 다크 모드는 [darkColorScheme] 만 정의하고 적용하지 않는다.
abstract class NbkTheme {
  /// 흰 상단바에 맞춘 상태 바(어두운 아이콘)
  static const overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: NbkColors.bg,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const lightColorScheme = ColorScheme.light(
    primary: NbkColors.honey,
    onPrimary: NbkColors.onHoney,
    primaryContainer: NbkColors.honeyTint,
    onPrimaryContainer: NbkColors.honeyDeep,
    secondary: NbkColors.honeyDeep,
    onSecondary: NbkColors.onDark,
    tertiary: NbkColors.loss,
    onTertiary: NbkColors.onDark,
    tertiaryContainer: NbkColors.lossTint,
    onTertiaryContainer: NbkColors.loss,
    error: NbkColors.danger,
    onError: NbkColors.onDark,
    errorContainer: NbkColors.dangerTint,
    onErrorContainer: NbkColors.dangerText,
    surface: NbkColors.bg,
    onSurface: NbkColors.text1,
    onSurfaceVariant: NbkColors.text2,
    surfaceContainerLowest: NbkColors.bg,
    surfaceContainerLow: NbkColors.surface,
    surfaceContainer: NbkColors.surface,
    surfaceContainerHigh: NbkColors.surface,
    surfaceContainerHighest: NbkColors.surface,
    outline: NbkColors.line,
    outlineVariant: NbkColors.line,
    inverseSurface: NbkColors.text1,
    onInverseSurface: NbkColors.onDark,
  );

  /// 다크 값. 아직 MaterialApp 에 연결하지 않는다.
  static const darkColorScheme = ColorScheme.dark(
    primary: NbkColorsDark.honey,
    onPrimary: NbkColorsDark.onHoney,
    primaryContainer: NbkColorsDark.honeyTint,
    onPrimaryContainer: NbkColorsDark.honeyDeep,
    secondary: NbkColorsDark.honeyDeep,
    onSecondary: NbkColorsDark.bg,
    tertiary: NbkColorsDark.loss,
    onTertiary: NbkColorsDark.bg,
    tertiaryContainer: NbkColorsDark.lossTint,
    onTertiaryContainer: NbkColorsDark.loss,
    error: NbkColorsDark.danger,
    onError: NbkColorsDark.bg,
    errorContainer: NbkColorsDark.dangerTint,
    onErrorContainer: NbkColorsDark.dangerText,
    surface: NbkColorsDark.bg,
    onSurface: NbkColorsDark.text1,
    onSurfaceVariant: NbkColorsDark.text2,
    surfaceContainerLowest: NbkColorsDark.bg,
    surfaceContainerLow: NbkColorsDark.surface,
    surfaceContainer: NbkColorsDark.surface,
    surfaceContainerHigh: NbkColorsDark.surface,
    surfaceContainerHighest: NbkColorsDark.surface,
    outline: NbkColorsDark.line,
    outlineVariant: NbkColorsDark.line,
    inverseSurface: NbkColorsDark.text1,
    onInverseSurface: NbkColorsDark.bg,
  );

  static const _textTheme = TextTheme(
    displaySmall: NbkTypography.display,
    headlineMedium: NbkTypography.display,
    headlineSmall: NbkTypography.title,
    titleLarge: NbkTypography.title,
    titleMedium: NbkTypography.heading,
    titleSmall: NbkTypography.listTitle,
    bodyLarge: NbkTypography.body,
    bodyMedium: NbkTypography.body,
    bodySmall: NbkTypography.caption,
    labelLarge: NbkTypography.buttonSmall,
    labelMedium: NbkTypography.label,
    labelSmall: NbkTypography.tabLabel,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: NbkTypography.fontFamily,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: NbkColors.bg,
      canvasColor: NbkColors.bg,
      dividerColor: NbkColors.line,
      textTheme: _textTheme,
      iconTheme: const IconThemeData(color: NbkColors.text1, size: NbkSize.icon),
      dividerTheme: const DividerThemeData(
        color: NbkColors.line,
        thickness: NbkSpacing.divider,
        space: NbkSpacing.divider,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NbkColors.bg,
        foregroundColor: NbkColors.text1,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: NbkSize.appBar,
        centerTitle: true,
        titleTextStyle: NbkTypography.heading,
        iconTheme: IconThemeData(color: NbkColors.text1, size: NbkSize.icon),
        systemOverlayStyle: overlayStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _filledButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: _filledButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NbkColors.text1,
          disabledForegroundColor: NbkColors.hint,
          side: const BorderSide(color: NbkColors.line),
          shape: const StadiumBorder(),
          minimumSize: const Size(NbkSize.tapMin, NbkSize.pillButton),
          padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.lg),
          textStyle: NbkTypography.buttonSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NbkColors.honeyDeep,
          disabledForegroundColor: NbkColors.hint,
          minimumSize: const Size(NbkSize.tapMin, NbkSize.tapMin),
          padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.sm),
          textStyle: NbkTypography.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NbkColors.bg,
        hintStyle: NbkTypography.inputText.copyWith(color: NbkColors.hint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NbkSpacing.lg,
          vertical: NbkSpacing.md,
        ),
        border: _inputBorder(NbkColors.line),
        enabledBorder: _inputBorder(NbkColors.line),
        focusedBorder: _inputBorder(NbkColors.honey),
        errorBorder: _inputBorder(NbkColors.danger),
        focusedErrorBorder: _inputBorder(NbkColors.danger),
        disabledBorder: _inputBorder(NbkColors.line),
        errorStyle: NbkTypography.caption.copyWith(color: NbkColors.dangerText),
        counterStyle: NbkTypography.caption,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: NbkColors.bg,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: NbkColors.bg,
        showDragHandle: true,
        dragHandleColor: NbkColors.line,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(NbkRadius.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NbkColors.bg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NbkRadius.dialog),
        ),
        titleTextStyle: NbkTypography.title,
        contentTextStyle: NbkTypography.body.copyWith(color: NbkColors.text2),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: NbkColors.honey,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: NbkColors.text1,
        unselectedLabelColor: NbkColors.text3,
        labelStyle: NbkTypography.segment,
        unselectedLabelStyle: NbkTypography.segmentInactive,
        dividerColor: NbkColors.line,
        dividerHeight: NbkSpacing.divider,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? NbkColors.text1
              : NbkColors.bg,
        ),
        checkColor: const WidgetStatePropertyAll(NbkColors.onDark),
        side: const BorderSide(color: NbkColors.text2, width: NbkSize.inputBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NbkRadius.avatarSm),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NbkColors.honey,
        linearTrackColor: NbkColors.line,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: NbkColors.honey,
        foregroundColor: NbkColors.onHoney,
        elevation: 2,
        shape: StadiumBorder(),
        extendedTextStyle: NbkTypography.buttonLarge,
        extendedSizeConstraints: BoxConstraints.tightFor(height: NbkSize.fab),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
        titleTextStyle: NbkTypography.body,
        iconColor: NbkColors.text3,
      ),
    );
  }

  static final ButtonStyle _filledButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: NbkColors.honey,
    foregroundColor: NbkColors.onHoney,
    disabledBackgroundColor: NbkColors.line,
    disabledForegroundColor: NbkColors.hint,
    elevation: 0,
    shadowColor: Colors.transparent,
    minimumSize: const Size(NbkSize.tapMin, NbkSize.button),
    padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.xl),
    textStyle: NbkTypography.buttonLarge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(NbkRadius.button),
    ),
  );

  static OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(NbkRadius.input),
      borderSide: BorderSide(color: color, width: NbkSize.inputBorder),
    );
  }
}
