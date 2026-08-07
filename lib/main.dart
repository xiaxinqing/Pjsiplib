import 'dart:async';
import 'dart:io' show Platform, Process;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'l10n/app_localizations.dart';
import 'src/app_identity.dart';
import 'src/localization/build_context_l10n.dart';
import 'src/localization/active_call_localizer.dart';
import 'src/localization/call_history_localizer.dart';
import 'src/localization/locale_controller.dart';
import 'src/services/app_shutdown_coordinator.dart';
import 'src/services/call_history_database.dart';
import 'src/services/contact_service.dart';
import 'src/services/native_bridge/native_bridge.dart';
import 'src/services/pjsip_service.dart';
import 'src/services/sip_call_end_reason_mapper.dart';
import 'src/ui/core/app_colors.dart';
import 'utils/toast_util.dart';

part 'src/ui/core/app_theme.dart';
part 'src/ui/home/home_page.dart';
part 'src/ui/home/shell/home_page_coordinator.dart';
part 'src/ui/home/shell/home_call_coordinator.dart';
part 'src/ui/home/shell/home_contact_coordinator.dart';
part 'src/ui/home/shell/home_history_coordinator.dart';
part 'src/ui/home/shell/home_app_badge_coordinator.dart';
part 'src/ui/home/shell/home_dialogs.dart';
part 'src/ui/home/sidebar/home_sidebar.dart';
part 'src/ui/home/sidebar/sidebar_navigation.dart';
part 'src/ui/home/sidebar/sidebar_connection.dart';
part 'src/ui/home/sidebar/sidebar_lines.dart';
part 'src/ui/home/sidebar/sidebar_line_actions.dart';
part 'src/ui/home/sidebar/sidebar_audio.dart';
part 'src/ui/home/sidebar/sidebar_shared.dart';
part 'src/ui/home/shared/call_action_button.dart';
part 'src/ui/home/home_workspace.dart';
part 'src/ui/home/dialpad/dialpad_page.dart';
part 'src/ui/home/dialpad/dialpad_card.dart';
part 'src/ui/home/dialpad/dialpad_line_selector.dart';
part 'src/ui/home/dialpad/dialpad_standby_panel.dart';
part 'src/ui/home/dialpad/dialpad_contact_match.dart';
part 'src/ui/home/dialpad/dialpad_keypad.dart';
part 'src/ui/home/dialpad/dialpad_helpers.dart';
part 'src/ui/home/dialpad/dialpad_models.dart';
part 'src/ui/home/calls/calls_page.dart';
part 'src/ui/home/calls/stage/call_stage.dart';
part 'src/ui/home/calls/stage/call_stage_identity.dart';
part 'src/ui/home/calls/stage/call_stage_metrics.dart';
part 'src/ui/home/calls/stage/call_stage_controls.dart';
part 'src/ui/home/calls/stage/call_stage_dtmf.dart';
part 'src/ui/home/calls/side/call_side_panel.dart';
part 'src/ui/home/calls/side/call_side_context.dart';
part 'src/ui/home/calls/side/call_side_customer.dart';
part 'src/ui/home/calls/side/call_side_notes.dart';
part 'src/ui/home/calls/side/call_side_history.dart';
part 'src/ui/home/calls/side/call_side_list.dart';
part 'src/ui/home/calls/shared/call_audio_meters.dart';
part 'src/ui/home/home_contacts.dart';
part 'src/ui/home/contact/contact_detail_section.dart';
part 'src/ui/home/contact/contact_list_section.dart';
part 'src/ui/home/contact/contact_actions.dart';
part 'src/ui/home/contact/contact_preview_dialog.dart';
part 'src/ui/home/contact/contact_editor_dialog.dart';
part 'src/ui/home/home_history.dart';
part 'src/ui/home/history/history_toolbar.dart';
part 'src/ui/home/history/history_list.dart';
part 'src/ui/home/history/history_detail.dart';
part 'src/ui/home/history/history_actions.dart';
part 'src/ui/home/history/history_reason_formatter.dart';
part 'src/ui/home/history/history_models.dart';
part 'src/ui/home/home_helpers.dart';
part 'src/ui/settings/home_settings.dart';
part 'src/ui/settings/home_settings_general.dart';
part 'src/ui/settings/home_settings_account.dart';
part 'src/ui/settings/add_account_dialog.dart';
part 'src/ui/settings/home_settings_audio.dart';
part 'src/ui/settings/home_settings_call.dart';
part 'src/ui/settings/home_settings_diagnostics.dart';
part 'src/ui/settings/home_settings_about.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppWindowController.initializeMainWindow();
  runApp(const ProviderScope(child: MyApp()));
  AppLaunchSplashController.hideAfterFirstFrame();
  unawaited(AppTrayController.instance.initialize());
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localePreference = ref.watch(localeControllerProvider);
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      navigatorKey: ToastUtil.navigatorKey,
      debugShowCheckedModeBanner: false,
      color: AppColors.appBackground,
      theme: _buildAppTheme(),
      locale: localePreference.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: resolveAppLocale,
      home: const MyHomePage(),
    );
  }
}
