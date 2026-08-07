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
  String get navDialpad => 'Dial';

  @override
  String get navCurrentCalls => 'Calls';

  @override
  String get navContacts => 'Contacts';

  @override
  String get navCallHistory => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsGeneralDescription => 'Language and app preferences';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsDisplayLanguage => 'Display language';

  @override
  String get settingsDisplayLanguageDescription =>
      'Changes apply now and are saved';

  @override
  String get languageFollowSystem => 'Follow system';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文（香港）';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsStartupSection => 'Startup & window';

  @override
  String get settingsLaunchAtLogin => 'Launch at login';

  @override
  String get settingsLaunchAtLoginDescription => 'Start VPhone at sign-in';

  @override
  String get settingsStartMinimized => 'Start minimized';

  @override
  String get settingsStartMinimizedDescription =>
      'Run in the background and keep phone service online';

  @override
  String get settingsNotificationsSection => 'Calls & notifications';

  @override
  String get settingsShowWindowForIncomingCall =>
      'Show window for incoming calls';

  @override
  String get settingsShowWindowForIncomingCallDescription =>
      'Open Calls when a call arrives';

  @override
  String get settingsAppBadge => 'App badge';

  @override
  String get settingsAppBadgeDescription =>
      'Show active incoming calls and unread missed calls';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String get settingsAccount => 'Accounts';

  @override
  String get settingsAccountDescription =>
      'Manage SIP lines, default outbound line, and registration';

  @override
  String get settingsAudio => 'Audio';

  @override
  String get settingsAudioDescription => 'Select devices and test call audio';

  @override
  String get settingsCalls => 'Calls';

  @override
  String get settingsCallsDescription =>
      'Call behavior, shortcuts, and conferencing';

  @override
  String get settingsDiagnostics => 'Diagnostics';

  @override
  String get settingsDiagnosticsDescription =>
      'Device, registration, and call logs';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutDescription => 'Version and support information';

  @override
  String get phoneServiceStarted => 'Phone service running';

  @override
  String get phoneServiceStopped => 'Phone service stopped';
}
