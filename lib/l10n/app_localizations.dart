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
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
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
  /// **'设置语言和应用偏好'**
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
  /// **'更改立即生效，并在下次启动时保留'**
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
  /// **'繁體中文（香港）'**
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
  /// **'在后台启动，并保持电话服务在线'**
  String get settingsStartMinimizedDescription;

  /// 来电和提醒设置区块标题
  ///
  /// In zh, this message translates to:
  /// **'来电与通知'**
  String get settingsNotificationsSection;

  /// 收到来电时显示应用窗口的设置名称
  ///
  /// In zh, this message translates to:
  /// **'来电时显示主窗口'**
  String get settingsShowWindowForIncomingCall;

  /// 来电显示窗口设置说明
  ///
  /// In zh, this message translates to:
  /// **'收到来电时打开当前通话页面'**
  String get settingsShowWindowForIncomingCallDescription;

  /// 显示应用未读角标的设置名称
  ///
  /// In zh, this message translates to:
  /// **'应用角标'**
  String get settingsAppBadge;

  /// 应用角标设置说明
  ///
  /// In zh, this message translates to:
  /// **'显示正在来电和未读未接来电数量'**
  String get settingsAppBadgeDescription;

  /// 尚未接入业务逻辑的设置状态
  ///
  /// In zh, this message translates to:
  /// **'即将推出'**
  String get settingsComingSoon;

  /// 账号设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get settingsAccount;

  /// 账号设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'管理 SIP 线路、默认外呼线路和注册状态'**
  String get settingsAccountDescription;

  /// 音频设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get settingsAudio;

  /// 音频设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'选择输入和输出设备，测试通话音频'**
  String get settingsAudioDescription;

  /// 通话设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'通话'**
  String get settingsCalls;

  /// 通话设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'设置通话行为、快捷操作和会议功能'**
  String get settingsCallsDescription;

  /// 诊断设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'诊断'**
  String get settingsDiagnostics;

  /// 诊断设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'查看设备、注册和通话日志'**
  String get settingsDiagnosticsDescription;

  /// 关于设置分组名称
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// 关于设置分组说明
  ///
  /// In zh, this message translates to:
  /// **'查看版本、应用标识和支持信息'**
  String get settingsAboutDescription;

  /// 电话服务运行状态
  ///
  /// In zh, this message translates to:
  /// **'电话服务运行中'**
  String get phoneServiceStarted;

  /// 电话服务停止状态
  ///
  /// In zh, this message translates to:
  /// **'电话服务未启动'**
  String get phoneServiceStopped;

  /// 通用取消操作
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// 通用添加操作
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get commonAdd;

  /// 查看全部内容
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get commonAll;

  /// 功能或网络可用状态
  ///
  /// In zh, this message translates to:
  /// **'可用'**
  String get commonAvailable;

  /// 功能或网络不可用状态
  ///
  /// In zh, this message translates to:
  /// **'不可用'**
  String get commonUnavailable;

  /// 清空输入内容
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get commonClear;

  /// 存在通话时禁用断开线路的提示
  ///
  /// In zh, this message translates to:
  /// **'请先结束当前通话'**
  String get headerEndCallsFirst;

  /// 电话服务尚未初始化的提示
  ///
  /// In zh, this message translates to:
  /// **'电话服务未初始化'**
  String get headerPhoneServiceUnavailable;

  /// 全部线路已断开的提示
  ///
  /// In zh, this message translates to:
  /// **'线路已全部断开'**
  String get headerAllLinesDisconnected;

  /// 断开全部线路操作
  ///
  /// In zh, this message translates to:
  /// **'断开全部线路'**
  String get headerDisconnectAllLines;

  /// 添加 SIP 线路操作
  ///
  /// In zh, this message translates to:
  /// **'添加线路'**
  String get headerAddLine;

  /// 断开全部线路确认说明
  ///
  /// In zh, this message translates to:
  /// **'所有线路将停止注册，之后可在线路菜单中重新启用。'**
  String get disconnectAllDescription;

  /// 断开线路前的线路数量摘要
  ///
  /// In zh, this message translates to:
  /// **'已接入 {total} 条线路，{online} 条在线'**
  String disconnectAllSummary(int total, int online);

  /// 断开全部线路确认问题
  ///
  /// In zh, this message translates to:
  /// **'确定断开全部线路吗？'**
  String get disconnectAllQuestion;

  /// 确认断开全部线路按钮
  ///
  /// In zh, this message translates to:
  /// **'断开全部'**
  String get disconnectAllAction;

  /// 顶部网络不可用状态
  ///
  /// In zh, this message translates to:
  /// **'当前网络不可用'**
  String get statusNetworkUnavailable;

  /// 顶部坐席环境检查状态
  ///
  /// In zh, this message translates to:
  /// **'正在检查上次坐席环境'**
  String get statusCheckingSeatEnvironment;

  /// 顶部线路恢复状态
  ///
  /// In zh, this message translates to:
  /// **'正在恢复上次线路配置'**
  String get statusRestoringLines;

  /// 已添加线路但无可用拨号线路
  ///
  /// In zh, this message translates to:
  /// **'已接入 {total} 条线路，暂无可用拨号线路'**
  String statusConnectedNoOutgoing(int total);

  /// 正在临时使用的拨号线路
  ///
  /// In zh, this message translates to:
  /// **'已接入 {total} 条线路，当前拨号线路：{line}'**
  String statusConnectedCurrentOutgoing(int total, String line);

  /// 当前默认拨号线路
  ///
  /// In zh, this message translates to:
  /// **'已接入 {total} 条线路，默认拨号线路：{line}'**
  String statusConnectedDefaultOutgoing(int total, String line);

  /// 服务已启动但没有线路的状态
  ///
  /// In zh, this message translates to:
  /// **'电话服务已启动，尚未添加线路'**
  String get statusInitializedNoAccounts;

  /// 电话服务未启动时的提示
  ///
  /// In zh, this message translates to:
  /// **'启动电话服务后即可发起和接听通话'**
  String get statusConnectServiceHint;

  /// 拨号页线路选择标题
  ///
  /// In zh, this message translates to:
  /// **'拨号线路'**
  String get dialOutgoingLine;

  /// 没有 SIP 线路时的状态
  ///
  /// In zh, this message translates to:
  /// **'尚未添加线路'**
  String get dialNoLinesAdded;

  /// 进入线路设置的提示
  ///
  /// In zh, this message translates to:
  /// **'打开线路设置'**
  String get dialOpenLineSettings;

  /// 没有可用拨号线路时的提示
  ///
  /// In zh, this message translates to:
  /// **'暂无可用拨号线路，请检查注册状态'**
  String get dialNoAvailableOutgoing;

  /// 默认线路不可用时的临时线路提示
  ///
  /// In zh, this message translates to:
  /// **'默认线路 {line} 不可用，当前临时使用此线路'**
  String dialFallbackOutgoing(String line);

  /// 没有可用线路的简短提示
  ///
  /// In zh, this message translates to:
  /// **'暂无可用线路'**
  String get dialNoAvailableLine;

  /// 网络不可用时的拨号说明
  ///
  /// In zh, this message translates to:
  /// **'恢复网络后即可拨打电话'**
  String get dialNetworkUnavailableDescription;

  /// 没有线路时的拨号说明
  ///
  /// In zh, this message translates to:
  /// **'添加 SIP 线路后即可拨打电话'**
  String get dialNoLinesDescription;

  /// 没有可用拨号线路时的说明
  ///
  /// In zh, this message translates to:
  /// **'请检查线路注册状态'**
  String get dialNoOutgoingDescription;

  /// 会议期间的拨号状态
  ///
  /// In zh, this message translates to:
  /// **'会议通话中'**
  String get dialConferenceActive;

  /// 会议期间不可拨号的说明
  ///
  /// In zh, this message translates to:
  /// **'请先拆分会议，再发起新呼叫'**
  String get dialConferenceActiveDescription;

  /// 通话数量达到上限的状态
  ///
  /// In zh, this message translates to:
  /// **'通话已达上限'**
  String get dialCapacityReached;

  /// 通话容量上限说明
  ///
  /// In zh, this message translates to:
  /// **'最多同时保持 {max} 路通话'**
  String dialCapacityDescription(int max);

  /// 拨号准备就绪状态
  ///
  /// In zh, this message translates to:
  /// **'可以发起外呼'**
  String get dialReady;

  /// 拨号准备就绪说明
  ///
  /// In zh, this message translates to:
  /// **'输入号码后点击呼叫'**
  String get dialReadyDescription;

  /// 暂时无法拨号的状态
  ///
  /// In zh, this message translates to:
  /// **'暂不可外呼'**
  String get dialUnavailable;

  /// 暂时无法拨号的说明
  ///
  /// In zh, this message translates to:
  /// **'请检查号码或线路状态'**
  String get dialUnavailableDescription;

  /// 未输入号码时的按钮提示
  ///
  /// In zh, this message translates to:
  /// **'输入号码后呼叫'**
  String get dialEnterNumberToCall;

  /// 没有线路时的操作提示
  ///
  /// In zh, this message translates to:
  /// **'请先添加线路'**
  String get dialAddLineFirst;

  /// 会议期间禁用外呼的提示
  ///
  /// In zh, this message translates to:
  /// **'会议中不可外呼'**
  String get dialUnavailableDuringConference;

  /// 拨号输入框提示
  ///
  /// In zh, this message translates to:
  /// **'输入号码'**
  String get dialNumberHint;

  /// 发起外呼操作提示
  ///
  /// In zh, this message translates to:
  /// **'发起外呼'**
  String get dialStartCall;

  /// 拨号按钮文字
  ///
  /// In zh, this message translates to:
  /// **'呼叫'**
  String get dialCall;

  /// 当前临时拨号线路标签
  ///
  /// In zh, this message translates to:
  /// **'当前拨号线路'**
  String get dialCurrentOutgoingLine;

  /// 默认拨号线路标签
  ///
  /// In zh, this message translates to:
  /// **'默认拨号线路'**
  String get dialDefaultOutgoingLine;

  /// 当前通话容量标签
  ///
  /// In zh, this message translates to:
  /// **'通话容量'**
  String get dialCallCapacity;

  /// 当前通话数量与上限
  ///
  /// In zh, this message translates to:
  /// **'{current}/{max} 路'**
  String dialCallCapacityValue(int current, int max);

  /// 网络状态标签
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get dialNetwork;

  /// 最近通话为空时的提示
  ///
  /// In zh, this message translates to:
  /// **'暂无最近通话'**
  String get dialNoRecentCalls;

  /// 最近通话区块标题
  ///
  /// In zh, this message translates to:
  /// **'最近通话'**
  String get dialRecentCalls;

  /// 通话记录缺少号码时的提示
  ///
  /// In zh, this message translates to:
  /// **'没有可回拨号码'**
  String get dialNoCallbackNumber;

  /// 回拨指定号码的提示
  ///
  /// In zh, this message translates to:
  /// **'回拨 {number}'**
  String dialCallbackNumber(String number);

  /// 昨天的通话时间
  ///
  /// In zh, this message translates to:
  /// **'昨天 {time}'**
  String dialYesterdayAt(String time);

  /// 联系人的默认号码标签
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get contactDefaultNumber;

  /// 号码完整匹配联系人
  ///
  /// In zh, this message translates to:
  /// **'已匹配'**
  String get contactExactMatch;

  /// 号码尾号匹配联系人
  ///
  /// In zh, this message translates to:
  /// **'尾号匹配'**
  String get contactSuffixMatch;

  /// No description provided for @weekdayMonday.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get weekdaySunday;

  /// No description provided for @sidebarConnectedTemporary.
  ///
  /// In zh, this message translates to:
  /// **'临时拨号线路 · {line}'**
  String sidebarConnectedTemporary(String line);

  /// No description provided for @sidebarConnectedDefault.
  ///
  /// In zh, this message translates to:
  /// **'拨号线路 · {line}'**
  String sidebarConnectedDefault(String line);

  /// No description provided for @sidebarWaitingAccounts.
  ///
  /// In zh, this message translates to:
  /// **'等待账号连接'**
  String get sidebarWaitingAccounts;

  /// No description provided for @sidebarDisconnected.
  ///
  /// In zh, this message translates to:
  /// **'未连接'**
  String get sidebarDisconnected;

  /// No description provided for @sidebarConnectionStatus.
  ///
  /// In zh, this message translates to:
  /// **'连接状态'**
  String get sidebarConnectionStatus;

  /// No description provided for @sidebarPhoneService.
  ///
  /// In zh, this message translates to:
  /// **'电话服务'**
  String get sidebarPhoneService;

  /// No description provided for @sidebarServiceStarted.
  ///
  /// In zh, this message translates to:
  /// **'已启动'**
  String get sidebarServiceStarted;

  /// No description provided for @sidebarServiceStopped.
  ///
  /// In zh, this message translates to:
  /// **'未启动'**
  String get sidebarServiceStopped;

  /// No description provided for @sidebarDefaultDialLine.
  ///
  /// In zh, this message translates to:
  /// **'默认拨号线路'**
  String get sidebarDefaultDialLine;

  /// No description provided for @sidebarNone.
  ///
  /// In zh, this message translates to:
  /// **'暂无'**
  String get sidebarNone;

  /// No description provided for @sidebarCurrentDialLine.
  ///
  /// In zh, this message translates to:
  /// **'当前拨号线路'**
  String get sidebarCurrentDialLine;

  /// No description provided for @sidebarTemporaryUse.
  ///
  /// In zh, this message translates to:
  /// **'临时使用'**
  String get sidebarTemporaryUse;

  /// No description provided for @sidebarLines.
  ///
  /// In zh, this message translates to:
  /// **'线路'**
  String get sidebarLines;

  /// No description provided for @sidebarOnlineCount.
  ///
  /// In zh, this message translates to:
  /// **'{online}/{total} 在线'**
  String sidebarOnlineCount(int online, int total);

  /// No description provided for @sidebarRetryFailedLines.
  ///
  /// In zh, this message translates to:
  /// **'重新注册异常线路'**
  String get sidebarRetryFailedLines;

  /// No description provided for @sidebarOpenLineSettings.
  ///
  /// In zh, this message translates to:
  /// **'打开线路设置'**
  String get sidebarOpenLineSettings;

  /// No description provided for @sidebarDefaultDial.
  ///
  /// In zh, this message translates to:
  /// **'默认拨号'**
  String get sidebarDefaultDial;

  /// No description provided for @sidebarManageLines.
  ///
  /// In zh, this message translates to:
  /// **'管理 {count} 条线路'**
  String sidebarManageLines(int count);

  /// No description provided for @sidebarAudio.
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get sidebarAudio;

  /// No description provided for @sidebarAudioIssue.
  ///
  /// In zh, this message translates to:
  /// **'异常'**
  String get sidebarAudioIssue;

  /// No description provided for @sidebarAudioDevices.
  ///
  /// In zh, this message translates to:
  /// **'音频设备'**
  String get sidebarAudioDevices;

  /// No description provided for @sidebarAudioInput.
  ///
  /// In zh, this message translates to:
  /// **'输入'**
  String get sidebarAudioInput;

  /// No description provided for @sidebarAudioOutput.
  ///
  /// In zh, this message translates to:
  /// **'输出'**
  String get sidebarAudioOutput;

  /// No description provided for @sidebarAudioMode.
  ///
  /// In zh, this message translates to:
  /// **'模式'**
  String get sidebarAudioMode;

  /// No description provided for @sidebarAudioStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get sidebarAudioStatus;

  /// No description provided for @sidebarAudioAutomatic.
  ///
  /// In zh, this message translates to:
  /// **'自动选择'**
  String get sidebarAudioAutomatic;

  /// No description provided for @sidebarAudioManual.
  ///
  /// In zh, this message translates to:
  /// **'手动选择'**
  String get sidebarAudioManual;

  /// No description provided for @sidebarAudioSwitchToManual.
  ///
  /// In zh, this message translates to:
  /// **'切换为手动选择'**
  String get sidebarAudioSwitchToManual;

  /// No description provided for @sidebarAudioSwitchToAutomatic.
  ///
  /// In zh, this message translates to:
  /// **'切换为自动选择'**
  String get sidebarAudioSwitchToAutomatic;

  /// No description provided for @sidebarAudioRefreshDevices.
  ///
  /// In zh, this message translates to:
  /// **'刷新设备'**
  String get sidebarAudioRefreshDevices;

  /// No description provided for @sidebarOpenAudioSettings.
  ///
  /// In zh, this message translates to:
  /// **'打开音频设置'**
  String get sidebarOpenAudioSettings;

  /// No description provided for @sidebarSetDefaultDial.
  ///
  /// In zh, this message translates to:
  /// **'设为默认拨号线路'**
  String get sidebarSetDefaultDial;

  /// No description provided for @sidebarDefaultDialStatus.
  ///
  /// In zh, this message translates to:
  /// **'默认拨号 · {status} · {transport}'**
  String sidebarDefaultDialStatus(String status, String transport);

  /// No description provided for @sidebarRefreshLine.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get sidebarRefreshLine;

  /// No description provided for @sidebarRestartLine.
  ///
  /// In zh, this message translates to:
  /// **'重启'**
  String get sidebarRestartLine;

  /// No description provided for @sidebarDisableLine.
  ///
  /// In zh, this message translates to:
  /// **'停用'**
  String get sidebarDisableLine;

  /// No description provided for @sidebarEnableLine.
  ///
  /// In zh, this message translates to:
  /// **'启用'**
  String get sidebarEnableLine;

  /// No description provided for @sidebarEditLine.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get sidebarEditLine;

  /// No description provided for @sidebarDeleteLine.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get sidebarDeleteLine;

  /// No description provided for @sidebarRestartLineTitle.
  ///
  /// In zh, this message translates to:
  /// **'重启线路'**
  String get sidebarRestartLineTitle;

  /// No description provided for @sidebarRestartLineDescription.
  ///
  /// In zh, this message translates to:
  /// **'会短暂注销后重新注册，不会删除这条线路。'**
  String get sidebarRestartLineDescription;

  /// No description provided for @sidebarRestartLineHint.
  ///
  /// In zh, this message translates to:
  /// **'适合网络恢复或电脑休眠唤醒后线路状态异常的情况。'**
  String get sidebarRestartLineHint;

  /// No description provided for @sidebarDeleteLineTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除线路'**
  String get sidebarDeleteLineTitle;

  /// No description provided for @sidebarDeleteLineDescription.
  ///
  /// In zh, this message translates to:
  /// **'删除后需要重新添加账号才能恢复。'**
  String get sidebarDeleteLineDescription;

  /// No description provided for @sidebarDeleteLineQuestion.
  ///
  /// In zh, this message translates to:
  /// **'确定删除这条线路吗？'**
  String get sidebarDeleteLineQuestion;

  /// No description provided for @callDirectionInbound.
  ///
  /// In zh, this message translates to:
  /// **'来电'**
  String get callDirectionInbound;

  /// No description provided for @callDirectionOutbound.
  ///
  /// In zh, this message translates to:
  /// **'呼出'**
  String get callDirectionOutbound;

  /// No description provided for @callStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已接通'**
  String get callStatusCompleted;

  /// No description provided for @callStatusMissed.
  ///
  /// In zh, this message translates to:
  /// **'未接来电'**
  String get callStatusMissed;

  /// No description provided for @callStatusRejected.
  ///
  /// In zh, this message translates to:
  /// **'已拒接'**
  String get callStatusRejected;

  /// No description provided for @callStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'呼叫失败'**
  String get callStatusFailed;

  /// No description provided for @callStatusCanceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get callStatusCanceled;

  /// No description provided for @contactNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新建联系人'**
  String get contactNewTitle;

  /// No description provided for @contactEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑联系人'**
  String get contactEditTitle;

  /// No description provided for @contactDetailsTitle.
  ///
  /// In zh, this message translates to:
  /// **'客户资料'**
  String get contactDetailsTitle;

  /// No description provided for @contactName.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get contactName;

  /// No description provided for @contactNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入姓名'**
  String get contactNameRequired;

  /// No description provided for @contactCompany.
  ///
  /// In zh, this message translates to:
  /// **'公司'**
  String get contactCompany;

  /// No description provided for @contactDepartment.
  ///
  /// In zh, this message translates to:
  /// **'部门'**
  String get contactDepartment;

  /// No description provided for @contactNotes.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get contactNotes;

  /// No description provided for @contactPriority.
  ///
  /// In zh, this message translates to:
  /// **'设为重点联系人'**
  String get contactPriority;

  /// No description provided for @contactPrioritySet.
  ///
  /// In zh, this message translates to:
  /// **'设为重点'**
  String get contactPrioritySet;

  /// No description provided for @contactPriorityUnset.
  ///
  /// In zh, this message translates to:
  /// **'取消重点'**
  String get contactPriorityUnset;

  /// No description provided for @contactPriorityBadge.
  ///
  /// In zh, this message translates to:
  /// **'重点'**
  String get contactPriorityBadge;

  /// No description provided for @contactSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get contactSave;

  /// No description provided for @contactDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get contactDelete;

  /// No description provided for @contactEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get contactEdit;

  /// No description provided for @contactCall.
  ///
  /// In zh, this message translates to:
  /// **'呼叫'**
  String get contactCall;

  /// No description provided for @contactClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get contactClose;

  /// No description provided for @contactPhone.
  ///
  /// In zh, this message translates to:
  /// **'号码'**
  String get contactPhone;

  /// No description provided for @contactPhones.
  ///
  /// In zh, this message translates to:
  /// **'电话号码'**
  String get contactPhones;

  /// No description provided for @contactAddPhone.
  ///
  /// In zh, this message translates to:
  /// **'添加号码'**
  String get contactAddPhone;

  /// No description provided for @contactPhoneLabel.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get contactPhoneLabel;

  /// No description provided for @contactPhoneRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入号码'**
  String get contactPhoneRequired;

  /// No description provided for @contactPhoneInvalid.
  ///
  /// In zh, this message translates to:
  /// **'号码只能包含数字和常用电话符号'**
  String get contactPhoneInvalid;

  /// No description provided for @contactPhoneDuplicate.
  ///
  /// In zh, this message translates to:
  /// **'号码重复'**
  String get contactPhoneDuplicate;

  /// No description provided for @contactDeletePhone.
  ///
  /// In zh, this message translates to:
  /// **'删除号码'**
  String get contactDeletePhone;

  /// No description provided for @contactAlternateLabel.
  ///
  /// In zh, this message translates to:
  /// **'备用'**
  String get contactAlternateLabel;

  /// No description provided for @contactsSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {selected} / {total}'**
  String contactsSelectedCount(int selected, int total);

  /// No description provided for @contactsClearSelection.
  ///
  /// In zh, this message translates to:
  /// **'取消选择'**
  String get contactsClearSelection;

  /// No description provided for @contactsSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索姓名、号码、公司或备注'**
  String get contactsSearchHint;

  /// No description provided for @contactsClearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索'**
  String get contactsClearSearch;

  /// No description provided for @contactsAdd.
  ///
  /// In zh, this message translates to:
  /// **'新建联系人'**
  String get contactsAdd;

  /// No description provided for @contactsVisibleCount.
  ///
  /// In zh, this message translates to:
  /// **'当前 {visible} / 共 {total} 位'**
  String contactsVisibleCount(int visible, int total);

  /// No description provided for @contactsTotalCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {total} 位联系人'**
  String contactsTotalCount(int total);

  /// No description provided for @contactsNoMatches.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的联系人'**
  String get contactsNoMatches;

  /// No description provided for @contactsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无联系人'**
  String get contactsEmpty;

  /// No description provided for @contactsNoMatchesHint.
  ///
  /// In zh, this message translates to:
  /// **'换个关键词再试试'**
  String get contactsNoMatchesHint;

  /// No description provided for @contactsEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'创建联系人后即可快速外呼'**
  String get contactsEmptyHint;

  /// No description provided for @contactsResetSearch.
  ///
  /// In zh, this message translates to:
  /// **'重置搜索'**
  String get contactsResetSearch;

  /// No description provided for @contactsColumnContact.
  ///
  /// In zh, this message translates to:
  /// **'联系人'**
  String get contactsColumnContact;

  /// No description provided for @contactsColumnOrganization.
  ///
  /// In zh, this message translates to:
  /// **'公司'**
  String get contactsColumnOrganization;

  /// No description provided for @contactsColumnUpdated.
  ///
  /// In zh, this message translates to:
  /// **'更新时间'**
  String get contactsColumnUpdated;

  /// No description provided for @contactsColumnActions.
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get contactsColumnActions;

  /// No description provided for @contactsMoreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get contactsMoreActions;

  /// No description provided for @contactNoAvailableDialLine.
  ///
  /// In zh, this message translates to:
  /// **'没有可用拨号线路，请先注册线路'**
  String get contactNoAvailableDialLine;

  /// No description provided for @contactNoCallableNumber.
  ///
  /// In zh, this message translates to:
  /// **'联系人没有可呼叫号码'**
  String get contactNoCallableNumber;

  /// No description provided for @contactAddLineFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先添加电话线路'**
  String get contactAddLineFirst;

  /// No description provided for @contactNetworkUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'当前网络不可用，暂时无法呼叫'**
  String get contactNetworkUnavailable;

  /// No description provided for @contactConferenceCallBlocked.
  ///
  /// In zh, this message translates to:
  /// **'会议通话中，暂时无法呼叫联系人'**
  String get contactConferenceCallBlocked;

  /// No description provided for @contactCallLimitReached.
  ///
  /// In zh, this message translates to:
  /// **'当前通话已达 4 路上限'**
  String get contactCallLimitReached;

  /// No description provided for @contactNotProvided.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get contactNotProvided;

  /// No description provided for @contactConfirmCallTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认呼叫'**
  String get contactConfirmCallTitle;

  /// No description provided for @contactDialLine.
  ///
  /// In zh, this message translates to:
  /// **'拨号线路'**
  String get contactDialLine;

  /// No description provided for @contactCreatedToast.
  ///
  /// In zh, this message translates to:
  /// **'联系人已创建'**
  String get contactCreatedToast;

  /// No description provided for @contactUpdatedToast.
  ///
  /// In zh, this message translates to:
  /// **'联系人已更新'**
  String get contactUpdatedToast;

  /// No description provided for @contactDuplicateTitle.
  ///
  /// In zh, this message translates to:
  /// **'号码重复'**
  String get contactDuplicateTitle;

  /// No description provided for @contactDuplicateNumberMessage.
  ///
  /// In zh, this message translates to:
  /// **'号码 {number} 已属于现有联系人。'**
  String contactDuplicateNumberMessage(String number);

  /// No description provided for @contactDuplicateExplanation.
  ///
  /// In zh, this message translates to:
  /// **'为避免通话归属混乱，联系人号码需要保持唯一。请查看已有联系人后再编辑。'**
  String get contactDuplicateExplanation;

  /// No description provided for @contactViewExisting.
  ///
  /// In zh, this message translates to:
  /// **'查看已有联系人'**
  String get contactViewExisting;

  /// No description provided for @contactExistingLocated.
  ///
  /// In zh, this message translates to:
  /// **'已定位到已有联系人'**
  String get contactExistingLocated;

  /// No description provided for @contactDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除联系人'**
  String get contactDeleteTitle;

  /// No description provided for @contactDeleteQuestion.
  ///
  /// In zh, this message translates to:
  /// **'确定删除 {name}？此操作不可撤销。'**
  String contactDeleteQuestion(String name);

  /// No description provided for @contactDeletedToast.
  ///
  /// In zh, this message translates to:
  /// **'联系人已删除'**
  String get contactDeletedToast;

  /// No description provided for @contactBulkDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'批量删除'**
  String get contactBulkDeleteTitle;

  /// No description provided for @contactBulkDeleteQuestion.
  ///
  /// In zh, this message translates to:
  /// **'确定删除已选的 {count} 位联系人？此操作不可撤销。'**
  String contactBulkDeleteQuestion(int count);

  /// No description provided for @contactBulkDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除 {count} 位'**
  String contactBulkDeleteConfirm(int count);

  /// No description provided for @contactBulkDeletedToast.
  ///
  /// In zh, this message translates to:
  /// **'已删除 {count} 位联系人'**
  String contactBulkDeletedToast(int count);

  /// No description provided for @contactSelectForDetails.
  ///
  /// In zh, this message translates to:
  /// **'选择联系人查看详情'**
  String get contactSelectForDetails;

  /// No description provided for @contactDefaultPhone.
  ///
  /// In zh, this message translates to:
  /// **'默认号码'**
  String get contactDefaultPhone;

  /// No description provided for @contactCreatedAt.
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get contactCreatedAt;

  /// No description provided for @contactUpdatedAt.
  ///
  /// In zh, this message translates to:
  /// **'更新时间'**
  String get contactUpdatedAt;

  /// No description provided for @contactRecentCalls.
  ///
  /// In zh, this message translates to:
  /// **'最近通话'**
  String get contactRecentCalls;

  /// No description provided for @contactNoCallHistory.
  ///
  /// In zh, this message translates to:
  /// **'暂无通话记录'**
  String get contactNoCallHistory;

  /// No description provided for @contactOpenPage.
  ///
  /// In zh, this message translates to:
  /// **'打开联系人页'**
  String get contactOpenPage;
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
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
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
