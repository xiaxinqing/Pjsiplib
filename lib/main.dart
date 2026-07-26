import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'src/services/app_window_controller.dart';
import 'src/services/call_history_database.dart';
import 'src/services/contact_service.dart';
import 'src/services/pjsip_service.dart';
import 'src/ui/core/app_colors.dart';
import 'utils/toast_util.dart';

part 'src/ui/core/app_theme.dart';
part 'src/ui/home/home_page.dart';
part 'src/ui/home/home_sidebar.dart';
part 'src/ui/home/home_workspace.dart';
part 'src/ui/home/home_calls.dart';
part 'src/ui/home/home_contacts.dart';
part 'src/ui/home/contact/contact_preview_dialog.dart';
part 'src/ui/home/contact/contact_editor_dialog.dart';
part 'src/ui/home/home_history.dart';
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
    return MaterialApp(
      title: 'VPhone',
      navigatorKey: ToastUtil.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: const MyHomePage(),
    );
  }
}
