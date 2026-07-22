import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'src/services/app_window_controller.dart';
import 'src/services/pjsip_service.dart';
import 'src/ui/core/app_colors.dart';
import 'utils/toast_util.dart';

part 'src/ui/core/app_theme.dart';
part 'src/ui/home/home_page.dart';
part 'src/ui/home/home_sidebar.dart';
part 'src/ui/home/home_workspace.dart';
part 'src/ui/home/home_calls.dart';
part 'src/ui/home/home_call_audio_meters.dart';
part 'src/ui/home/home_helpers.dart';
part 'src/ui/settings/home_settings.dart';
part 'src/ui/settings/home_settings_account.dart';
part 'src/ui/settings/add_account_dialog.dart';
part 'src/ui/settings/home_settings_audio.dart';
part 'src/ui/settings/home_settings_call.dart';
part 'src/ui/settings/home_settings_diagnostics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppWindowController.initializeMainWindow();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(
      seedColor: _brandGreen,
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'VPhone',
      navigatorKey: ToastUtil.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: base.copyWith(
          primary: _brandGreen,
          onPrimary: Colors.white,
          surface: _panelBackground,
          surfaceContainerLowest: _panelBackground,
          surfaceContainerLow: _subtlePanel,
          surfaceContainer: _appBackground,
          surfaceContainerHigh: _hoverPanel,
          outline: _softBorder,
        ),
        scaffoldBackgroundColor: _appBackground,
        useMaterial3: true,
        dividerTheme: const DividerThemeData(color: _softBorder, thickness: 1),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: _softBorder),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: _panelBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: _softBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: _softBorder),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _textPrimary,
            side: const BorderSide(color: _softBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _textPrimary),
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: _textPrimary,
          displayColor: _textPrimary,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}
