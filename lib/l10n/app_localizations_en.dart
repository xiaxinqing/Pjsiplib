// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VPhone';

  @override
  String get navDialpad => 'Dialpad';

  @override
  String get navCurrentCalls => 'Current calls';

  @override
  String get navContacts => 'Contacts';

  @override
  String get navCallHistory => 'Call history';

  @override
  String get settings => 'Settings';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsGeneralDescription =>
      'Configure language and app preferences';

  @override
  String get settingsLanguageSection => 'Language & region';

  @override
  String get settingsDisplayLanguage => 'Display language';

  @override
  String get settingsDisplayLanguageDescription =>
      'Changes apply immediately and are remembered for the next launch';

  @override
  String get languageFollowSystem => 'Use system language';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsStartupSection => 'Startup & window';

  @override
  String get settingsLaunchAtLogin => 'Launch at login';

  @override
  String get settingsLaunchAtLoginDescription =>
      'Start VPhone automatically after signing in';

  @override
  String get settingsStartMinimized => 'Start minimized';

  @override
  String get settingsStartMinimizedDescription =>
      'Keep the phone service available in the background after launch';

  @override
  String get settingsNotificationsSection => 'Calls & alerts';

  @override
  String get settingsShowWindowForIncomingCall =>
      'Show window for incoming calls';

  @override
  String get settingsShowWindowForIncomingCallDescription =>
      'Open the current calls view when a new call arrives';

  @override
  String get settingsAppBadge => 'App badge';

  @override
  String get settingsAppBadgeDescription =>
      'Show pending calls and unread missed-call counts';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String get settingsAccount => 'Accounts';

  @override
  String get settingsAccountDescription =>
      'Manage SIP lines, the default outgoing line, and registration status';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsAudioDescription =>
      'Choose input and output devices and test call audio';

  @override
  String get settingsCalls => 'Calls';

  @override
  String get settingsCallsDescription =>
      'Configure call behavior, shortcuts, and conference status';

  @override
  String get settingsDiagnostics => 'Diagnostics';

  @override
  String get settingsDiagnosticsDescription =>
      'Review device, registration, and call event logs';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutDescription =>
      'Version, application identity, and support information';

  @override
  String get phoneServiceStarted => 'Phone service is running';

  @override
  String get phoneServiceStopped => 'Phone service is stopped';
}
