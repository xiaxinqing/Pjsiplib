import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  /// 应用名称
  ///
  /// In zh, this message translates to:
  /// **'VPhone'**
  String get appTitle;

  /// 拨号页面导航名称
  ///
  /// In zh, this message translates to:
  /// **'拨号'**
  String get navDialpad;

  /// 当前通话页面导航名称
  ///
  /// In zh, this message translates to:
  /// **'当前通话'**
  String get navCurrentCalls;

  /// 联系人页面导航名称
  ///
  /// In zh, this message translates to:
  /// **'联系人'**
  String get navContacts;

  /// 通话记录页面导航名称
  ///
  /// In zh, this message translates to:
  /// **'通话记录'**
  String get navCallHistory;

  /// 设置入口及弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 关闭设置弹窗的提示
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get settingsClose;

  /// 通用设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsGeneral;

  /// 通用设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'配置显示语言和应用偏好'**
  String get settingsGeneralDescription;

  /// 语言设置区块标题
  ///
  /// In zh, this message translates to:
  /// **'语言与地区'**
  String get settingsLanguageSection;

  /// 应用显示语言设置名称
  ///
  /// In zh, this message translates to:
  /// **'显示语言'**
  String get settingsDisplayLanguage;

  /// 应用显示语言设置说明
  ///
  /// In zh, this message translates to:
  /// **'更改后立即生效，并在下次启动时继续使用'**
  String get settingsDisplayLanguageDescription;

  /// 使用操作系统语言
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageFollowSystem;

  /// 简体中文语言选项
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get languageSimplifiedChinese;

  /// 繁体中文语言选项
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get languageTraditionalChinese;

  /// 英文语言选项
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// 应用启动及窗口行为设置区块标题
  ///
  /// In zh, this message translates to:
  /// **'启动与窗口'**
  String get settingsStartupSection;

  /// 登录系统后自动启动应用的设置名称
  ///
  /// In zh, this message translates to:
  /// **'开机自动启动'**
  String get settingsLaunchAtLogin;

  /// 开机自动启动设置说明
  ///
  /// In zh, this message translates to:
  /// **'登录系统后自动启动 VPhone'**
  String get settingsLaunchAtLoginDescription;

  /// 应用启动后最小化到托盘的设置名称
  ///
  /// In zh, this message translates to:
  /// **'启动后最小化'**
  String get settingsStartMinimized;

  /// 启动后最小化设置说明
  ///
  /// In zh, this message translates to:
  /// **'启动后在后台保持电话服务在线'**
  String get settingsStartMinimizedDescription;

  /// 来电和提醒设置区块标题
  ///
  /// In zh, this message translates to:
  /// **'来电与提醒'**
  String get settingsNotificationsSection;

  /// 收到来电时显示应用窗口的设置名称
  ///
  /// In zh, this message translates to:
  /// **'来电时显示主窗口'**
  String get settingsShowWindowForIncomingCall;

  /// 来电显示窗口设置说明
  ///
  /// In zh, this message translates to:
  /// **'收到新来电时切换到当前通话页面'**
  String get settingsShowWindowForIncomingCallDescription;

  /// 显示应用未读角标的设置名称
  ///
  /// In zh, this message translates to:
  /// **'应用角标'**
  String get settingsAppBadge;

  /// 应用角标设置说明
  ///
  /// In zh, this message translates to:
  /// **'显示未处理来电和未读未接来电数量'**
  String get settingsAppBadgeDescription;

  /// 尚未接入业务逻辑的设置状态
  ///
  /// In zh, this message translates to:
  /// **'暂未开放'**
  String get settingsComingSoon;

  /// 账号设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get settingsAccount;

  /// 账号设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'管理 SIP 线路、默认外呼和注册状态'**
  String get settingsAccountDescription;

  /// 音频设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get settingsAudio;

  /// 音频设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'选择输入输出设备，并测试通话音频'**
  String get settingsAudioDescription;

  /// 通话设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'通话'**
  String get settingsCalls;

  /// 通话设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'配置通话行为、快捷操作和会议状态'**
  String get settingsCallsDescription;

  /// 诊断设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'诊断'**
  String get settingsDiagnostics;

  /// 诊断设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'查看设备、注册和通话事件日志'**
  String get settingsDiagnosticsDescription;

  /// 关于设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// 关于设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'版本信息、应用标识和支持信息'**
  String get settingsAboutDescription;

  /// 电话服务运行状态
  ///
  /// In zh, this message translates to:
  /// **'电话服务已启动'**
  String get phoneServiceStarted;

  /// 电话服务停止状态
  ///
  /// In zh, this message translates to:
  /// **'电话服务未启动'**
  String get phoneServiceStopped;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
