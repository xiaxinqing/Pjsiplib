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

  /// 通用保存操作
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// 通用关闭操作
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

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
  /// **'新建'**
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
  /// **'新建'**
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

  /// No description provided for @historySearchPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'搜索通话'**
  String get historySearchPlaceholder;

  /// No description provided for @historySearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索号码、客户、线路、备注'**
  String get historySearchHint;

  /// No description provided for @historyClearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清除搜索'**
  String get historyClearSearch;

  /// No description provided for @historyFilterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get historyFilterAll;

  /// No description provided for @historyFilterOutbound.
  ///
  /// In zh, this message translates to:
  /// **'呼出'**
  String get historyFilterOutbound;

  /// No description provided for @historyFilterInbound.
  ///
  /// In zh, this message translates to:
  /// **'来电'**
  String get historyFilterInbound;

  /// No description provided for @historyFilterMissed.
  ///
  /// In zh, this message translates to:
  /// **'未接'**
  String get historyFilterMissed;

  /// No description provided for @historyFilterByDate.
  ///
  /// In zh, this message translates to:
  /// **'按时间筛选'**
  String get historyFilterByDate;

  /// No description provided for @historyDateAll.
  ///
  /// In zh, this message translates to:
  /// **'全部时间'**
  String get historyDateAll;

  /// No description provided for @historyDateToday.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get historyDateToday;

  /// No description provided for @historyDateLast7Days.
  ///
  /// In zh, this message translates to:
  /// **'近 7 天'**
  String get historyDateLast7Days;

  /// No description provided for @historyDateThisMonth.
  ///
  /// In zh, this message translates to:
  /// **'本月'**
  String get historyDateThisMonth;

  /// No description provided for @historyMarkAllReadCount.
  ///
  /// In zh, this message translates to:
  /// **'全部已读 ({count})'**
  String historyMarkAllReadCount(int count);

  /// No description provided for @historyRecordCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条'**
  String historyRecordCount(int count);

  /// No description provided for @historyClearRecords.
  ///
  /// In zh, this message translates to:
  /// **'清空通话记录'**
  String get historyClearRecords;

  /// No description provided for @historyEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无通话记录'**
  String get historyEmpty;

  /// No description provided for @historyNoMatches.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的通话记录'**
  String get historyNoMatches;

  /// No description provided for @historyColumnCustomer.
  ///
  /// In zh, this message translates to:
  /// **'客户'**
  String get historyColumnCustomer;

  /// No description provided for @historyColumnLine.
  ///
  /// In zh, this message translates to:
  /// **'线路'**
  String get historyColumnLine;

  /// No description provided for @historyColumnStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get historyColumnStatus;

  /// No description provided for @historyColumnDuration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get historyColumnDuration;

  /// No description provided for @historyColumnTime.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get historyColumnTime;

  /// No description provided for @historyColumnActions.
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get historyColumnActions;

  /// No description provided for @historyUnknownLine.
  ///
  /// In zh, this message translates to:
  /// **'未知线路'**
  String get historyUnknownLine;

  /// No description provided for @historyDeleteRecord.
  ///
  /// In zh, this message translates to:
  /// **'删除记录'**
  String get historyDeleteRecord;

  /// No description provided for @historyCannotDeleteActive.
  ///
  /// In zh, this message translates to:
  /// **'进行中的通话不能删除'**
  String get historyCannotDeleteActive;

  /// No description provided for @historyCannotCallBackActive.
  ///
  /// In zh, this message translates to:
  /// **'进行中的通话不能回拨'**
  String get historyCannotCallBackActive;

  /// No description provided for @historyCallBack.
  ///
  /// In zh, this message translates to:
  /// **'回拨'**
  String get historyCallBack;

  /// No description provided for @historyLive.
  ///
  /// In zh, this message translates to:
  /// **'实时'**
  String get historyLive;

  /// No description provided for @historyHasNoteTooltip.
  ///
  /// In zh, this message translates to:
  /// **'有备注，点击记录查看'**
  String get historyHasNoteTooltip;

  /// No description provided for @historyLoadingMore.
  ///
  /// In zh, this message translates to:
  /// **'正在加载更多'**
  String get historyLoadingMore;

  /// No description provided for @historyLoadMoreCount.
  ///
  /// In zh, this message translates to:
  /// **'加载更多 · 已显示 {count} 条'**
  String historyLoadMoreCount(int count);

  /// No description provided for @historyNoMore.
  ///
  /// In zh, this message translates to:
  /// **'没有更多历史记录'**
  String get historyNoMore;

  /// No description provided for @historyAllShownCount.
  ///
  /// In zh, this message translates to:
  /// **'已显示全部 {count} 条历史记录'**
  String historyAllShownCount(int count);

  /// No description provided for @historyStatusOnHold.
  ///
  /// In zh, this message translates to:
  /// **'保持中'**
  String get historyStatusOnHold;

  /// No description provided for @historyStatusRemoteOnHold.
  ///
  /// In zh, this message translates to:
  /// **'对方保持'**
  String get historyStatusRemoteOnHold;

  /// No description provided for @historyStatusInCall.
  ///
  /// In zh, this message translates to:
  /// **'通话中'**
  String get historyStatusInCall;

  /// No description provided for @historyStatusRinging.
  ///
  /// In zh, this message translates to:
  /// **'响铃中'**
  String get historyStatusRinging;

  /// No description provided for @historyStatusRemoteRinging.
  ///
  /// In zh, this message translates to:
  /// **'对方振铃'**
  String get historyStatusRemoteRinging;

  /// No description provided for @historyStatusCalling.
  ///
  /// In zh, this message translates to:
  /// **'呼叫中'**
  String get historyStatusCalling;

  /// No description provided for @historyStatusTiming.
  ///
  /// In zh, this message translates to:
  /// **'计时中'**
  String get historyStatusTiming;

  /// No description provided for @historyGroupToday.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get historyGroupToday;

  /// No description provided for @historyGroupYesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get historyGroupYesterday;

  /// No description provided for @historyMarkAllReadTitle.
  ///
  /// In zh, this message translates to:
  /// **'将未接来电标记为已读？'**
  String get historyMarkAllReadTitle;

  /// No description provided for @historyMarkAllReadBody.
  ///
  /// In zh, this message translates to:
  /// **'将 {count} 条未读未接来电标记为已读。'**
  String historyMarkAllReadBody(int count);

  /// No description provided for @historyMarkAllReadConfirm.
  ///
  /// In zh, this message translates to:
  /// **'全部标记为已读'**
  String get historyMarkAllReadConfirm;

  /// No description provided for @historyConfirmCallbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'回拨此号码？'**
  String get historyConfirmCallbackTitle;

  /// No description provided for @historyDialLine.
  ///
  /// In zh, this message translates to:
  /// **'拨号线路'**
  String get historyDialLine;

  /// No description provided for @historyConfirmCallback.
  ///
  /// In zh, this message translates to:
  /// **'回拨'**
  String get historyConfirmCallback;

  /// No description provided for @historyDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除这条通话记录？'**
  String get historyDeleteTitle;

  /// No description provided for @historyFieldNumber.
  ///
  /// In zh, this message translates to:
  /// **'号码'**
  String get historyFieldNumber;

  /// No description provided for @historyFieldLine.
  ///
  /// In zh, this message translates to:
  /// **'线路'**
  String get historyFieldLine;

  /// No description provided for @historyDeleteBody.
  ///
  /// In zh, this message translates to:
  /// **'删除后无法恢复。'**
  String get historyDeleteBody;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get historyDeleteConfirm;

  /// No description provided for @historyClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空通话记录？'**
  String get historyClearTitle;

  /// No description provided for @historyClearBody.
  ///
  /// In zh, this message translates to:
  /// **'此操作无法撤销。进行中的通话不会被清除。'**
  String get historyClearBody;

  /// No description provided for @historyClearConfirm.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get historyClearConfirm;

  /// No description provided for @historyClearError.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法清空通话记录，请稍后重试。'**
  String get historyClearError;

  /// No description provided for @historyCannotRedialActive.
  ///
  /// In zh, this message translates to:
  /// **'通话正在进行，无需重复回拨。'**
  String get historyCannotRedialActive;

  /// No description provided for @historyNoCallbackNumber.
  ///
  /// In zh, this message translates to:
  /// **'此记录没有可回拨的号码。'**
  String get historyNoCallbackNumber;

  /// No description provided for @historyNetworkUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'网络不可用，请恢复连接后重试。'**
  String get historyNetworkUnavailable;

  /// No description provided for @historyAddLineFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先添加电话线路。'**
  String get historyAddLineFirst;

  /// No description provided for @historyCallLimitReached.
  ///
  /// In zh, this message translates to:
  /// **'已达到 4 路通话上限。'**
  String get historyCallLimitReached;

  /// No description provided for @historySplitConferenceFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先结束或拆分会议通话。'**
  String get historySplitConferenceFirst;

  /// No description provided for @historyNoRegisteredLine.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的已注册线路。'**
  String get historyNoRegisteredLine;

  /// No description provided for @historySwitchDetailHint.
  ///
  /// In zh, this message translates to:
  /// **'选择左侧其他记录切换详情'**
  String get historySwitchDetailHint;

  /// No description provided for @historyContactDeleted.
  ///
  /// In zh, this message translates to:
  /// **'原联系人已删除，可重新添加'**
  String get historyContactDeleted;

  /// No description provided for @historyFieldContact.
  ///
  /// In zh, this message translates to:
  /// **'联系人'**
  String get historyFieldContact;

  /// No description provided for @historyFieldDirection.
  ///
  /// In zh, this message translates to:
  /// **'方向'**
  String get historyFieldDirection;

  /// No description provided for @historyFieldStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get historyFieldStatus;

  /// No description provided for @historyFieldCalledAt.
  ///
  /// In zh, this message translates to:
  /// **'呼叫时间'**
  String get historyFieldCalledAt;

  /// No description provided for @historyFieldAnsweredAt.
  ///
  /// In zh, this message translates to:
  /// **'接通时间'**
  String get historyFieldAnsweredAt;

  /// No description provided for @historyFieldEndedAt.
  ///
  /// In zh, this message translates to:
  /// **'挂断时间'**
  String get historyFieldEndedAt;

  /// No description provided for @historyFieldDuration.
  ///
  /// In zh, this message translates to:
  /// **'通话时长'**
  String get historyFieldDuration;

  /// No description provided for @historyFieldEndReason.
  ///
  /// In zh, this message translates to:
  /// **'结束原因'**
  String get historyFieldEndReason;

  /// No description provided for @historyNotAnswered.
  ///
  /// In zh, this message translates to:
  /// **'未接通'**
  String get historyNotAnswered;

  /// No description provided for @historyInProgress.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get historyInProgress;

  /// No description provided for @historyStatsTitle.
  ///
  /// In zh, this message translates to:
  /// **'通话统计'**
  String get historyStatsTitle;

  /// No description provided for @historyMetricDialToRing.
  ///
  /// In zh, this message translates to:
  /// **'拨号到响铃'**
  String get historyMetricDialToRing;

  /// No description provided for @historyMetricRingingDuration.
  ///
  /// In zh, this message translates to:
  /// **'响铃时长'**
  String get historyMetricRingingDuration;

  /// No description provided for @historyMetricRingToAnswer.
  ///
  /// In zh, this message translates to:
  /// **'响铃到接听'**
  String get historyMetricRingToAnswer;

  /// No description provided for @historyMetricMediaReady.
  ///
  /// In zh, this message translates to:
  /// **'语音建立'**
  String get historyMetricMediaReady;

  /// No description provided for @historyMetricHoldCount.
  ///
  /// In zh, this message translates to:
  /// **'保持次数'**
  String get historyMetricHoldCount;

  /// No description provided for @historyMetricHoldDuration.
  ///
  /// In zh, this message translates to:
  /// **'累计保持'**
  String get historyMetricHoldDuration;

  /// No description provided for @historyTimes.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次'**
  String historyTimes(int count);

  /// No description provided for @historyImmediate.
  ///
  /// In zh, this message translates to:
  /// **'即时'**
  String get historyImmediate;

  /// No description provided for @historySeconds.
  ///
  /// In zh, this message translates to:
  /// **'{value} 秒'**
  String historySeconds(String value);

  /// No description provided for @historyAddNote.
  ///
  /// In zh, this message translates to:
  /// **'添加备注'**
  String get historyAddNote;

  /// No description provided for @historyNote.
  ///
  /// In zh, this message translates to:
  /// **'通话备注'**
  String get historyNote;

  /// No description provided for @historyEditNote.
  ///
  /// In zh, this message translates to:
  /// **'编辑备注'**
  String get historyEditNote;

  /// No description provided for @historyEditNoteTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑通话备注'**
  String get historyEditNoteTitle;

  /// No description provided for @historyNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'记录本次沟通重点'**
  String get historyNoteHint;

  /// No description provided for @historyNoteSaveError.
  ///
  /// In zh, this message translates to:
  /// **'保存通话备注失败，请稍后重试'**
  String get historyNoteSaveError;

  /// No description provided for @historyNoteBlindTransferTo.
  ///
  /// In zh, this message translates to:
  /// **'盲转至：{target}'**
  String historyNoteBlindTransferTo(String target);

  /// No description provided for @historyNoteConference.
  ///
  /// In zh, this message translates to:
  /// **'会议备注：{note}'**
  String historyNoteConference(String note);

  /// No description provided for @historyNoteCustomer.
  ///
  /// In zh, this message translates to:
  /// **'客户备注：{note}'**
  String historyNoteCustomer(String note);

  /// No description provided for @historyDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'通话详情'**
  String get historyDetailTitle;

  /// No description provided for @historyViewContact.
  ///
  /// In zh, this message translates to:
  /// **'查看联系人'**
  String get historyViewContact;

  /// No description provided for @historyReAddContact.
  ///
  /// In zh, this message translates to:
  /// **'重新添加联系人'**
  String get historyReAddContact;

  /// No description provided for @historyAddContact.
  ///
  /// In zh, this message translates to:
  /// **'添加联系人'**
  String get historyAddContact;

  /// No description provided for @historyRecentCalls.
  ///
  /// In zh, this message translates to:
  /// **'最近通话'**
  String get historyRecentCalls;

  /// No description provided for @historyNoRecentCalls.
  ///
  /// In zh, this message translates to:
  /// **'暂无最近通话'**
  String get historyNoRecentCalls;

  /// No description provided for @historyCallbackNumber.
  ///
  /// In zh, this message translates to:
  /// **'回拨 {number}'**
  String historyCallbackNumber(String number);

  /// No description provided for @historyYesterdayAt.
  ///
  /// In zh, this message translates to:
  /// **'昨天 {time}'**
  String historyYesterdayAt(String time);

  /// No description provided for @historyLoadMoreError.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法加载更多通话记录，请稍后重试。'**
  String get historyLoadMoreError;

  /// No description provided for @historyStatusPeerRejected.
  ///
  /// In zh, this message translates to:
  /// **'对方拒接'**
  String get historyStatusPeerRejected;

  /// No description provided for @historyReasonCallEnded.
  ///
  /// In zh, this message translates to:
  /// **'通话已结束'**
  String get historyReasonCallEnded;

  /// No description provided for @historyReasonIncomingEnded.
  ///
  /// In zh, this message translates to:
  /// **'来电已结束'**
  String get historyReasonIncomingEnded;

  /// No description provided for @historyReasonAuthenticationFailed.
  ///
  /// In zh, this message translates to:
  /// **'账号认证失败'**
  String get historyReasonAuthenticationFailed;

  /// No description provided for @historyReasonRemoteRejected.
  ///
  /// In zh, this message translates to:
  /// **'对方已拒接'**
  String get historyReasonRemoteRejected;

  /// No description provided for @historyReasonCallRejected.
  ///
  /// In zh, this message translates to:
  /// **'呼叫被拒绝'**
  String get historyReasonCallRejected;

  /// No description provided for @historyReasonInvalidNumber.
  ///
  /// In zh, this message translates to:
  /// **'号码不存在或无法接通'**
  String get historyReasonInvalidNumber;

  /// No description provided for @historyReasonNoAnswer.
  ///
  /// In zh, this message translates to:
  /// **'无人接听'**
  String get historyReasonNoAnswer;

  /// No description provided for @historyReasonTimeout.
  ///
  /// In zh, this message translates to:
  /// **'呼叫超时'**
  String get historyReasonTimeout;

  /// No description provided for @historyReasonRemoteUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'对方无法接通'**
  String get historyReasonRemoteUnavailable;

  /// No description provided for @historyReasonRingingUnanswered.
  ///
  /// In zh, this message translates to:
  /// **'响铃未接'**
  String get historyReasonRingingUnanswered;

  /// No description provided for @historyReasonRemoteBusy.
  ///
  /// In zh, this message translates to:
  /// **'对方忙线'**
  String get historyReasonRemoteBusy;

  /// No description provided for @historyReasonCanceled.
  ///
  /// In zh, this message translates to:
  /// **'呼叫已取消'**
  String get historyReasonCanceled;

  /// No description provided for @historyReasonUnsupportedMedia.
  ///
  /// In zh, this message translates to:
  /// **'对方不支持本次通话'**
  String get historyReasonUnsupportedMedia;

  /// No description provided for @historyReasonServiceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'电话服务暂时不可用'**
  String get historyReasonServiceUnavailable;

  /// No description provided for @historyReasonRedirected.
  ///
  /// In zh, this message translates to:
  /// **'呼叫已转移或重定向'**
  String get historyReasonRedirected;

  /// No description provided for @historyReasonCallIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'呼叫未完成'**
  String get historyReasonCallIncomplete;

  /// No description provided for @historyReasonServiceError.
  ///
  /// In zh, this message translates to:
  /// **'电话服务异常'**
  String get historyReasonServiceError;

  /// No description provided for @historyReasonRemoteCannotAnswer.
  ///
  /// In zh, this message translates to:
  /// **'对方无法接听'**
  String get historyReasonRemoteCannotAnswer;

  /// No description provided for @historyReasonNotConnected.
  ///
  /// In zh, this message translates to:
  /// **'未接通'**
  String get historyReasonNotConnected;

  /// No description provided for @historyReasonMediaFailed.
  ///
  /// In zh, this message translates to:
  /// **'媒体协商失败'**
  String get historyReasonMediaFailed;

  /// No description provided for @historyReasonBlindTransfer.
  ///
  /// In zh, this message translates to:
  /// **'已盲转'**
  String get historyReasonBlindTransfer;

  /// No description provided for @historyReasonShortAuthenticationFailed.
  ///
  /// In zh, this message translates to:
  /// **'认证失败'**
  String get historyReasonShortAuthenticationFailed;

  /// No description provided for @historyReasonShortRemoteRejected.
  ///
  /// In zh, this message translates to:
  /// **'对方拒接'**
  String get historyReasonShortRemoteRejected;

  /// No description provided for @historyReasonShortInvalidNumber.
  ///
  /// In zh, this message translates to:
  /// **'号码无效'**
  String get historyReasonShortInvalidNumber;

  /// No description provided for @historyReasonShortServiceError.
  ///
  /// In zh, this message translates to:
  /// **'服务异常'**
  String get historyReasonShortServiceError;

  /// No description provided for @historyReasonShortRedirected.
  ///
  /// In zh, this message translates to:
  /// **'已转移'**
  String get historyReasonShortRedirected;

  /// No description provided for @historyReasonShortMediaFailed.
  ///
  /// In zh, this message translates to:
  /// **'媒体失败'**
  String get historyReasonShortMediaFailed;

  /// No description provided for @historyReasonShortBlindTransfer.
  ///
  /// In zh, this message translates to:
  /// **'已盲转'**
  String get historyReasonShortBlindTransfer;

  /// No description provided for @historyReasonWithSipCode.
  ///
  /// In zh, this message translates to:
  /// **'{reason}（SIP {code}）'**
  String historyReasonWithSipCode(String reason, int code);

  /// No description provided for @activeCallEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无进行中的通话'**
  String get activeCallEmpty;

  /// No description provided for @activeCallGoToDialpad.
  ///
  /// In zh, this message translates to:
  /// **'前往拨号'**
  String get activeCallGoToDialpad;

  /// No description provided for @activeCallAnswer.
  ///
  /// In zh, this message translates to:
  /// **'接听'**
  String get activeCallAnswer;

  /// No description provided for @activeCallReject.
  ///
  /// In zh, this message translates to:
  /// **'拒接'**
  String get activeCallReject;

  /// No description provided for @activeCallMute.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get activeCallMute;

  /// No description provided for @activeCallUnmute.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get activeCallUnmute;

  /// No description provided for @activeCallKeypad.
  ///
  /// In zh, this message translates to:
  /// **'键盘'**
  String get activeCallKeypad;

  /// No description provided for @activeCallHold.
  ///
  /// In zh, this message translates to:
  /// **'保持'**
  String get activeCallHold;

  /// No description provided for @activeCallResume.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get activeCallResume;

  /// No description provided for @activeCallTransfer.
  ///
  /// In zh, this message translates to:
  /// **'转接'**
  String get activeCallTransfer;

  /// No description provided for @activeCallMuteRemoteAudio.
  ///
  /// In zh, this message translates to:
  /// **'静音对方'**
  String get activeCallMuteRemoteAudio;

  /// No description provided for @activeCallRestoreRemoteAudio.
  ///
  /// In zh, this message translates to:
  /// **'恢复对方'**
  String get activeCallRestoreRemoteAudio;

  /// No description provided for @activeCallAudio.
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get activeCallAudio;

  /// No description provided for @activeCallHangUp.
  ///
  /// In zh, this message translates to:
  /// **'挂断'**
  String get activeCallHangUp;

  /// No description provided for @activeCallHangUpAll.
  ///
  /// In zh, this message translates to:
  /// **'全部挂断'**
  String get activeCallHangUpAll;

  /// No description provided for @activeCallMerge.
  ///
  /// In zh, this message translates to:
  /// **'合并'**
  String get activeCallMerge;

  /// No description provided for @activeCallSplit.
  ///
  /// In zh, this message translates to:
  /// **'拆分'**
  String get activeCallSplit;

  /// No description provided for @activeCallResumeConference.
  ///
  /// In zh, this message translates to:
  /// **'恢复会议'**
  String get activeCallResumeConference;

  /// No description provided for @activeCallOperationAnswering.
  ///
  /// In zh, this message translates to:
  /// **'正在接听'**
  String get activeCallOperationAnswering;

  /// No description provided for @activeCallOperationRejecting.
  ///
  /// In zh, this message translates to:
  /// **'正在拒接'**
  String get activeCallOperationRejecting;

  /// No description provided for @activeCallOperationEnding.
  ///
  /// In zh, this message translates to:
  /// **'正在挂断'**
  String get activeCallOperationEnding;

  /// No description provided for @activeCallOperationHolding.
  ///
  /// In zh, this message translates to:
  /// **'正在保持'**
  String get activeCallOperationHolding;

  /// No description provided for @activeCallOperationResuming.
  ///
  /// In zh, this message translates to:
  /// **'正在恢复'**
  String get activeCallOperationResuming;

  /// No description provided for @activeCallOperationSplitting.
  ///
  /// In zh, this message translates to:
  /// **'正在拆分'**
  String get activeCallOperationSplitting;

  /// No description provided for @activeCallOperationMerging.
  ///
  /// In zh, this message translates to:
  /// **'正在合并'**
  String get activeCallOperationMerging;

  /// No description provided for @activeCallOperationTransferring.
  ///
  /// In zh, this message translates to:
  /// **'正在转接'**
  String get activeCallOperationTransferring;

  /// No description provided for @activeCallStatusLocalHold.
  ///
  /// In zh, this message translates to:
  /// **'保持中'**
  String get activeCallStatusLocalHold;

  /// No description provided for @activeCallStatusRemoteHold.
  ///
  /// In zh, this message translates to:
  /// **'对方保持'**
  String get activeCallStatusRemoteHold;

  /// No description provided for @activeCallStatusCalling.
  ///
  /// In zh, this message translates to:
  /// **'正在呼叫'**
  String get activeCallStatusCalling;

  /// No description provided for @activeCallStatusIncoming.
  ///
  /// In zh, this message translates to:
  /// **'来电'**
  String get activeCallStatusIncoming;

  /// No description provided for @activeCallStatusWaitingAnswer.
  ///
  /// In zh, this message translates to:
  /// **'等待接听'**
  String get activeCallStatusWaitingAnswer;

  /// No description provided for @activeCallStatusRemoteRinging.
  ///
  /// In zh, this message translates to:
  /// **'对方振铃'**
  String get activeCallStatusRemoteRinging;

  /// No description provided for @activeCallStatusConnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在接通'**
  String get activeCallStatusConnecting;

  /// No description provided for @activeCallStatusInCall.
  ///
  /// In zh, this message translates to:
  /// **'通话中'**
  String get activeCallStatusInCall;

  /// No description provided for @activeCallStatusEnded.
  ///
  /// In zh, this message translates to:
  /// **'通话已结束'**
  String get activeCallStatusEnded;

  /// No description provided for @activeCallStatusUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知状态 ({state})'**
  String activeCallStatusUnknown(int state);

  /// No description provided for @activeCallHeldLocallyFor.
  ///
  /// In zh, this message translates to:
  /// **'本机保持 · {duration}'**
  String activeCallHeldLocallyFor(String duration);

  /// No description provided for @activeCallHeldByRemoteFor.
  ///
  /// In zh, this message translates to:
  /// **'对方保持 · {duration}'**
  String activeCallHeldByRemoteFor(String duration);

  /// No description provided for @activeCallPriorityContact.
  ///
  /// In zh, this message translates to:
  /// **'重点客户'**
  String get activeCallPriorityContact;

  /// No description provided for @activeCallOperationInProgress.
  ///
  /// In zh, this message translates to:
  /// **'操作进行中'**
  String get activeCallOperationInProgress;

  /// No description provided for @activeCallDuration.
  ///
  /// In zh, this message translates to:
  /// **'通话时长'**
  String get activeCallDuration;

  /// No description provided for @activeCallCurrentStatus.
  ///
  /// In zh, this message translates to:
  /// **'当前状态'**
  String get activeCallCurrentStatus;

  /// No description provided for @activeCallMediaConnected.
  ///
  /// In zh, this message translates to:
  /// **'媒体已连接'**
  String get activeCallMediaConnected;

  /// No description provided for @activeCallMediaLocalHold.
  ///
  /// In zh, this message translates to:
  /// **'本地保持'**
  String get activeCallMediaLocalHold;

  /// No description provided for @activeCallMediaRemoteHold.
  ///
  /// In zh, this message translates to:
  /// **'对方保持'**
  String get activeCallMediaRemoteHold;

  /// No description provided for @activeCallMediaError.
  ///
  /// In zh, this message translates to:
  /// **'媒体异常'**
  String get activeCallMediaError;

  /// No description provided for @activeCallMediaNotReady.
  ///
  /// In zh, this message translates to:
  /// **'媒体未建立'**
  String get activeCallMediaNotReady;

  /// No description provided for @activeCallMediaPending.
  ///
  /// In zh, this message translates to:
  /// **'媒体待建立'**
  String get activeCallMediaPending;

  /// No description provided for @activeCallMediaUnconfirmed.
  ///
  /// In zh, this message translates to:
  /// **'媒体未确认'**
  String get activeCallMediaUnconfirmed;

  /// No description provided for @activeCallMediaUnknown.
  ///
  /// In zh, this message translates to:
  /// **'媒体状态 {status}'**
  String activeCallMediaUnknown(int status);

  /// No description provided for @activeCallSignalingUnknown.
  ///
  /// In zh, this message translates to:
  /// **'信令未知'**
  String get activeCallSignalingUnknown;

  /// No description provided for @activeCallConfiguredMode.
  ///
  /// In zh, this message translates to:
  /// **'{mode} 配置'**
  String activeCallConfiguredMode(String mode);

  /// No description provided for @activeCallMedia.
  ///
  /// In zh, this message translates to:
  /// **'媒体'**
  String get activeCallMedia;

  /// No description provided for @activeCallSignaling.
  ///
  /// In zh, this message translates to:
  /// **'信令'**
  String get activeCallSignaling;

  /// No description provided for @activeCallMediaEncryption.
  ///
  /// In zh, this message translates to:
  /// **'媒体加密'**
  String get activeCallMediaEncryption;

  /// No description provided for @activeCallTlsEncrypted.
  ///
  /// In zh, this message translates to:
  /// **'TLS 加密'**
  String get activeCallTlsEncrypted;

  /// No description provided for @activeCallSrtpNegotiated.
  ///
  /// In zh, this message translates to:
  /// **'SRTP 已协商'**
  String get activeCallSrtpNegotiated;

  /// No description provided for @activeCallSrtpNotDetected.
  ///
  /// In zh, this message translates to:
  /// **'未检测到 SRTP'**
  String get activeCallSrtpNotDetected;

  /// No description provided for @activeCallMediaNegotiating.
  ///
  /// In zh, this message translates to:
  /// **'等待媒体协商'**
  String get activeCallMediaNegotiating;

  /// No description provided for @activeCallEncryptedCall.
  ///
  /// In zh, this message translates to:
  /// **'通话已加密'**
  String get activeCallEncryptedCall;

  /// No description provided for @activeCallEncryptedAudio.
  ///
  /// In zh, this message translates to:
  /// **'语音已加密'**
  String get activeCallEncryptedAudio;

  /// No description provided for @activeCallStandardCall.
  ///
  /// In zh, this message translates to:
  /// **'标准通话'**
  String get activeCallStandardCall;

  /// No description provided for @activeCallVerifyingEncryption.
  ///
  /// In zh, this message translates to:
  /// **'正在确认加密'**
  String get activeCallVerifyingEncryption;

  /// No description provided for @activeCallLabeledValue.
  ///
  /// In zh, this message translates to:
  /// **'{label}：{value}'**
  String activeCallLabeledValue(String label, String value);

  /// No description provided for @activeCallValueDetail.
  ///
  /// In zh, this message translates to:
  /// **'{value}（{detail}）'**
  String activeCallValueDetail(String value, String detail);

  /// No description provided for @activeCallTransport.
  ///
  /// In zh, this message translates to:
  /// **'传输协议'**
  String get activeCallTransport;

  /// No description provided for @activeCallTransferTitle.
  ///
  /// In zh, this message translates to:
  /// **'直接转接通话'**
  String get activeCallTransferTitle;

  /// No description provided for @activeCallTransferDescription.
  ///
  /// In zh, this message translates to:
  /// **'通话将立即转接到目标号码，你将退出本次通话。'**
  String get activeCallTransferDescription;

  /// No description provided for @activeCallCurrentLineUnknown.
  ///
  /// In zh, this message translates to:
  /// **'当前线路未知'**
  String get activeCallCurrentLineUnknown;

  /// No description provided for @activeCallTransferTargetHint.
  ///
  /// In zh, this message translates to:
  /// **'输入号码或 SIP URI'**
  String get activeCallTransferTargetHint;

  /// No description provided for @activeCallTransferTargetExample.
  ///
  /// In zh, this message translates to:
  /// **'例如 6545 或 sip:6545@{host}'**
  String activeCallTransferTargetExample(String host);

  /// No description provided for @activeCallChooseContact.
  ///
  /// In zh, this message translates to:
  /// **'从联系人选择'**
  String get activeCallChooseContact;

  /// No description provided for @activeCallNumberCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个号码'**
  String activeCallNumberCount(int count);

  /// No description provided for @activeCallTransferSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索联系人、号码或公司'**
  String get activeCallTransferSearchHint;

  /// No description provided for @activeCallEnterTransferNumber.
  ///
  /// In zh, this message translates to:
  /// **'输入转接号码'**
  String get activeCallEnterTransferNumber;

  /// No description provided for @activeCallConfirmTransfer.
  ///
  /// In zh, this message translates to:
  /// **'确认转接'**
  String get activeCallConfirmTransfer;

  /// No description provided for @activeCallNoContacts.
  ///
  /// In zh, this message translates to:
  /// **'暂无联系人'**
  String get activeCallNoContacts;

  /// No description provided for @activeCallNoContactMatches.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的联系人'**
  String get activeCallNoContactMatches;

  /// No description provided for @activeCallUnnamedContact.
  ///
  /// In zh, this message translates to:
  /// **'未命名联系人'**
  String get activeCallUnnamedContact;

  /// No description provided for @activeCallViewingConferenceMember.
  ///
  /// In zh, this message translates to:
  /// **'正在查看会议成员'**
  String get activeCallViewingConferenceMember;

  /// No description provided for @activeCallCurrentActiveCall.
  ///
  /// In zh, this message translates to:
  /// **'当前活动通话'**
  String get activeCallCurrentActiveCall;

  /// No description provided for @activeCallViewingCall.
  ///
  /// In zh, this message translates to:
  /// **'正在查看此通话'**
  String get activeCallViewingCall;

  /// No description provided for @activeCallResumeForAudio.
  ///
  /// In zh, this message translates to:
  /// **'{name} · 点击恢复以接入声音'**
  String activeCallResumeForAudio(String name);

  /// No description provided for @activeCallConferenceInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'会议已自动保持。处理完当前通话后，可恢复 {count} 位会议成员。'**
  String activeCallConferenceInterrupted(int count);

  /// No description provided for @activeCallConferenceTitle.
  ///
  /// In zh, this message translates to:
  /// **'会议通话'**
  String get activeCallConferenceTitle;

  /// No description provided for @activeCallConferencePaused.
  ///
  /// In zh, this message translates to:
  /// **'会议已暂停'**
  String get activeCallConferencePaused;

  /// No description provided for @activeCallConferenceInProgress.
  ///
  /// In zh, this message translates to:
  /// **'会议中'**
  String get activeCallConferenceInProgress;

  /// No description provided for @activeCallConferenceStatus.
  ///
  /// In zh, this message translates to:
  /// **'会议状态'**
  String get activeCallConferenceStatus;

  /// No description provided for @activeCallConferenceDuration.
  ///
  /// In zh, this message translates to:
  /// **'会议时长'**
  String get activeCallConferenceDuration;

  /// No description provided for @activeCallPaused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get activeCallPaused;

  /// No description provided for @activeCallMemberCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 位成员'**
  String activeCallMemberCount(int count);

  /// No description provided for @activeCallCustomerCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 位客户'**
  String activeCallCustomerCount(int count);

  /// No description provided for @activeCallLineCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条线路'**
  String activeCallLineCount(int count);

  /// No description provided for @activeCallPanelConferenceMembers.
  ///
  /// In zh, this message translates to:
  /// **'会议成员'**
  String get activeCallPanelConferenceMembers;

  /// No description provided for @activeCallPanelCurrentCalls.
  ///
  /// In zh, this message translates to:
  /// **'当前通话'**
  String get activeCallPanelCurrentCalls;

  /// No description provided for @activeCallPanelCount.
  ///
  /// In zh, this message translates to:
  /// **'{current}/{total} 路'**
  String activeCallPanelCount(int current, int total);

  /// No description provided for @activeCallNewIncomingAndOthers.
  ///
  /// In zh, this message translates to:
  /// **'新来电与其他通话'**
  String get activeCallNewIncomingAndOthers;

  /// No description provided for @activeCallOtherCalls.
  ///
  /// In zh, this message translates to:
  /// **'其他通话'**
  String get activeCallOtherCalls;

  /// No description provided for @activeCallNoActiveCalls.
  ///
  /// In zh, this message translates to:
  /// **'没有活动通话'**
  String get activeCallNoActiveCalls;

  /// No description provided for @activeCallCustomerInfo.
  ///
  /// In zh, this message translates to:
  /// **'客户信息'**
  String get activeCallCustomerInfo;

  /// No description provided for @activeCallConferenceCustomers.
  ///
  /// In zh, this message translates to:
  /// **'会议客户'**
  String get activeCallConferenceCustomers;

  /// No description provided for @activeCallConferenceCustomersDescription.
  ///
  /// In zh, this message translates to:
  /// **'已加入会议的客户'**
  String get activeCallConferenceCustomersDescription;

  /// No description provided for @activeCallUnmatchedContact.
  ///
  /// In zh, this message translates to:
  /// **'未匹配联系人'**
  String get activeCallUnmatchedContact;

  /// No description provided for @activeCallUnknownNumber.
  ///
  /// In zh, this message translates to:
  /// **'未知号码'**
  String get activeCallUnknownNumber;

  /// No description provided for @activeCallAddContact.
  ///
  /// In zh, this message translates to:
  /// **'添加到联系人'**
  String get activeCallAddContact;

  /// No description provided for @activeCallViewContact.
  ///
  /// In zh, this message translates to:
  /// **'查看联系人'**
  String get activeCallViewContact;

  /// No description provided for @activeCallDefaultNumber.
  ///
  /// In zh, this message translates to:
  /// **'默认号码'**
  String get activeCallDefaultNumber;

  /// No description provided for @activeCallCustomer.
  ///
  /// In zh, this message translates to:
  /// **'通话客户'**
  String get activeCallCustomer;

  /// No description provided for @activeCallViewContactDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看联系人详情'**
  String get activeCallViewContactDetails;

  /// No description provided for @activeCallCurrentNumber.
  ///
  /// In zh, this message translates to:
  /// **'当前号码'**
  String get activeCallCurrentNumber;

  /// No description provided for @activeCallCurrentNote.
  ///
  /// In zh, this message translates to:
  /// **'当前通话备注'**
  String get activeCallCurrentNote;

  /// No description provided for @activeCallNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'记录沟通重点，挂断后将保存到通话记录'**
  String get activeCallNoteHint;

  /// No description provided for @activeCallConferenceNote.
  ///
  /// In zh, this message translates to:
  /// **'本次会议备注'**
  String get activeCallConferenceNote;

  /// No description provided for @activeCallNoteSyncMembers.
  ///
  /// In zh, this message translates to:
  /// **'同步到 {count} 位会议成员'**
  String activeCallNoteSyncMembers(int count);

  /// No description provided for @activeCallNoteSavePrimary.
  ///
  /// In zh, this message translates to:
  /// **'仅保存到会议主记录：{name}'**
  String activeCallNoteSavePrimary(String name);

  /// No description provided for @activeCallCustomerNote.
  ///
  /// In zh, this message translates to:
  /// **'当前客户备注'**
  String get activeCallCustomerNote;

  /// No description provided for @activeCallSharedConferenceNote.
  ///
  /// In zh, this message translates to:
  /// **'会议共享备注'**
  String get activeCallSharedConferenceNote;

  /// No description provided for @activeCallSharedNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'记录会议结论，并保存到每位成员的通话记录'**
  String get activeCallSharedNoteHint;

  /// No description provided for @activeCallCustomerNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'记录当前客户重点，仅保存到会议主记录'**
  String get activeCallCustomerNoteHint;

  /// No description provided for @activeCallNoteStaged.
  ///
  /// In zh, this message translates to:
  /// **'已暂存'**
  String get activeCallNoteStaged;

  /// No description provided for @activeCallNoteEmpty.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get activeCallNoteEmpty;

  /// No description provided for @activeCallNoteStagedTooltip.
  ///
  /// In zh, this message translates to:
  /// **'备注已暂存，挂断后将写入通话记录'**
  String get activeCallNoteStagedTooltip;

  /// No description provided for @activeCallNoteEmptyTooltip.
  ///
  /// In zh, this message translates to:
  /// **'填写后自动暂存，挂断后写入通话记录'**
  String get activeCallNoteEmptyTooltip;

  /// No description provided for @activeCallViewing.
  ///
  /// In zh, this message translates to:
  /// **'查看中'**
  String get activeCallViewing;

  /// No description provided for @activeCallRemoteAudioMuted.
  ///
  /// In zh, this message translates to:
  /// **'声音已关闭'**
  String get activeCallRemoteAudioMuted;

  /// No description provided for @activeCallDtmfWaiting.
  ///
  /// In zh, this message translates to:
  /// **'等待输入'**
  String get activeCallDtmfWaiting;

  /// No description provided for @activeCallDtmfTitle.
  ///
  /// In zh, this message translates to:
  /// **'DTMF 键盘'**
  String get activeCallDtmfTitle;

  /// No description provided for @activeCallDtmfClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭键盘'**
  String get activeCallDtmfClose;

  /// No description provided for @activeCallDtmfSending.
  ///
  /// In zh, this message translates to:
  /// **'正在发送 {digit}'**
  String activeCallDtmfSending(String digit);

  /// No description provided for @activeCallDtmfSent.
  ///
  /// In zh, this message translates to:
  /// **'已发送 {digit}'**
  String activeCallDtmfSent(String digit);

  /// No description provided for @activeCallDtmfFailed.
  ///
  /// In zh, this message translates to:
  /// **'{digit} 发送失败'**
  String activeCallDtmfFailed(String digit);

  /// No description provided for @activeCallMyAudio.
  ///
  /// In zh, this message translates to:
  /// **'麦克风'**
  String get activeCallMyAudio;

  /// No description provided for @activeCallRemoteAudio.
  ///
  /// In zh, this message translates to:
  /// **'扬声器'**
  String get activeCallRemoteAudio;

  /// No description provided for @activeCallMutedValue.
  ///
  /// In zh, this message translates to:
  /// **'{label}：已静音'**
  String activeCallMutedValue(String label);

  /// No description provided for @activeCallVolumeValue.
  ///
  /// In zh, this message translates to:
  /// **'，音量 {volume}%'**
  String activeCallVolumeValue(int volume);

  /// No description provided for @activeCallMeterMuted.
  ///
  /// In zh, this message translates to:
  /// **'{label}：已静音{volume}'**
  String activeCallMeterMuted(String label, String volume);

  /// No description provided for @activeCallMeterValues.
  ///
  /// In zh, this message translates to:
  /// **'{label}：当前 {current}%，峰值 {peak}%{volume}'**
  String activeCallMeterValues(
    String label,
    int current,
    int peak,
    String volume,
  );

  /// No description provided for @audioAddLine.
  ///
  /// In zh, this message translates to:
  /// **'添加线路'**
  String get audioAddLine;

  /// No description provided for @audioSoundAlerts.
  ///
  /// In zh, this message translates to:
  /// **'声音提示'**
  String get audioSoundAlerts;

  /// No description provided for @audioIncomingRingtone.
  ///
  /// In zh, this message translates to:
  /// **'来电铃声'**
  String get audioIncomingRingtone;

  /// No description provided for @audioIncomingRingtoneDescription.
  ///
  /// In zh, this message translates to:
  /// **'有新来电时播放铃声'**
  String get audioIncomingRingtoneDescription;

  /// No description provided for @audioOutgoingRingback.
  ///
  /// In zh, this message translates to:
  /// **'外呼回铃音'**
  String get audioOutgoingRingback;

  /// No description provided for @audioOutgoingRingbackDescription.
  ///
  /// In zh, this message translates to:
  /// **'拨号后等待对方接听时播放'**
  String get audioOutgoingRingbackDescription;

  /// No description provided for @audioCallEndedTone.
  ///
  /// In zh, this message translates to:
  /// **'通话结束提示音'**
  String get audioCallEndedTone;

  /// No description provided for @audioCallEndedToneDescription.
  ///
  /// In zh, this message translates to:
  /// **'已接通的通话结束时播放'**
  String get audioCallEndedToneDescription;

  /// No description provided for @audioDialpadTones.
  ///
  /// In zh, this message translates to:
  /// **'拨号按键音'**
  String get audioDialpadTones;

  /// No description provided for @audioDialpadTonesDescription.
  ///
  /// In zh, this message translates to:
  /// **'拨号盘输入时播放按键音，默认关闭'**
  String get audioDialpadTonesDescription;

  /// No description provided for @audioRouting.
  ///
  /// In zh, this message translates to:
  /// **'音频路由'**
  String get audioRouting;

  /// No description provided for @audioFollowSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get audioFollowSystem;

  /// No description provided for @audioChooseDevices.
  ///
  /// In zh, this message translates to:
  /// **'指定设备'**
  String get audioChooseDevices;

  /// No description provided for @audioFollowSystemDescription.
  ///
  /// In zh, this message translates to:
  /// **'推荐使用。插拔耳机时自动跟随系统声音设置'**
  String get audioFollowSystemDescription;

  /// No description provided for @audioChooseDevicesDescription.
  ///
  /// In zh, this message translates to:
  /// **'选择应用使用的设备；系统限制可能影响实际音频路由'**
  String get audioChooseDevicesDescription;

  /// No description provided for @audioAutoSwitch.
  ///
  /// In zh, this message translates to:
  /// **'设备变化时自动切换'**
  String get audioAutoSwitch;

  /// No description provided for @audioAutoSwitchDescription.
  ///
  /// In zh, this message translates to:
  /// **'通话中插拔耳机时，自动恢复可用的音频路径'**
  String get audioAutoSwitchDescription;

  /// No description provided for @audioInputOutput.
  ///
  /// In zh, this message translates to:
  /// **'输入与输出'**
  String get audioInputOutput;

  /// No description provided for @audioMicrophone.
  ///
  /// In zh, this message translates to:
  /// **'麦克风'**
  String get audioMicrophone;

  /// No description provided for @audioInputDevice.
  ///
  /// In zh, this message translates to:
  /// **'输入设备'**
  String get audioInputDevice;

  /// No description provided for @audioSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'扬声器'**
  String get audioSpeaker;

  /// No description provided for @audioOutputDevice.
  ///
  /// In zh, this message translates to:
  /// **'输出设备'**
  String get audioOutputDevice;

  /// No description provided for @audioSystemDefaultInput.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统输入'**
  String get audioSystemDefaultInput;

  /// No description provided for @audioSystemDefaultOutput.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统输出'**
  String get audioSystemDefaultOutput;

  /// No description provided for @audioDeviceNotSelected.
  ///
  /// In zh, this message translates to:
  /// **'未选择'**
  String get audioDeviceNotSelected;

  /// No description provided for @audioDeviceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'设备不可用'**
  String get audioDeviceUnavailable;

  /// No description provided for @audioRecordingRemaining.
  ///
  /// In zh, this message translates to:
  /// **'录音中 {seconds} 秒'**
  String audioRecordingRemaining(int seconds);

  /// No description provided for @audioRecording.
  ///
  /// In zh, this message translates to:
  /// **'录音中'**
  String get audioRecording;

  /// No description provided for @audioPreparingPlayback.
  ///
  /// In zh, this message translates to:
  /// **'准备播放'**
  String get audioPreparingPlayback;

  /// No description provided for @audioPlaying.
  ///
  /// In zh, this message translates to:
  /// **'播放中'**
  String get audioPlaying;

  /// No description provided for @audioRecordingTest.
  ///
  /// In zh, this message translates to:
  /// **'录音测试'**
  String get audioRecordingTest;

  /// No description provided for @audioTestOutput.
  ///
  /// In zh, this message translates to:
  /// **'测试扬声器'**
  String get audioTestOutput;

  /// No description provided for @audioMute.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get audioMute;

  /// No description provided for @audioUnmute.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get audioUnmute;

  /// No description provided for @audioTesting.
  ///
  /// In zh, this message translates to:
  /// **'测试中'**
  String get audioTesting;

  /// No description provided for @audioReady.
  ///
  /// In zh, this message translates to:
  /// **'就绪'**
  String get audioReady;

  /// No description provided for @audioDeviceNeedsAttention.
  ///
  /// In zh, this message translates to:
  /// **'音频设备需要处理'**
  String get audioDeviceNeedsAttention;

  /// No description provided for @audioFollowingSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统声音'**
  String get audioFollowingSystem;

  /// No description provided for @audioUsingSelectedDevices.
  ///
  /// In zh, this message translates to:
  /// **'使用指定设备'**
  String get audioUsingSelectedDevices;

  /// No description provided for @audioFollowingSystemStatus.
  ///
  /// In zh, this message translates to:
  /// **'输入和输出跟随系统声音设置'**
  String get audioFollowingSystemStatus;

  /// No description provided for @audioUsingSelectedDevicesStatus.
  ///
  /// In zh, this message translates to:
  /// **'使用所选的麦克风和扬声器'**
  String get audioUsingSelectedDevicesStatus;

  /// No description provided for @audioRefreshDevices.
  ///
  /// In zh, this message translates to:
  /// **'刷新音频设备'**
  String get audioRefreshDevices;

  /// No description provided for @audioOpenSystemSoundSettings.
  ///
  /// In zh, this message translates to:
  /// **'打开系统声音设置'**
  String get audioOpenSystemSoundSettings;

  /// No description provided for @audioReconnectDevices.
  ///
  /// In zh, this message translates to:
  /// **'重新连接音频设备'**
  String get audioReconnectDevices;

  /// No description provided for @audioOpenSystemSoundSettingsHint.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中打开声音设置'**
  String get audioOpenSystemSoundSettingsHint;

  /// No description provided for @audioFollowSystemDeviceHint.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统声音设置'**
  String get audioFollowSystemDeviceHint;

  /// No description provided for @audioSelectedDeviceHint.
  ///
  /// In zh, this message translates to:
  /// **'优先使用此设备，实际路由可能受系统设置影响'**
  String get audioSelectedDeviceHint;

  /// No description provided for @audioChangeDevicesInSystemHint.
  ///
  /// In zh, this message translates to:
  /// **'当前为跟随系统模式，请在系统声音设置中切换输入和输出设备'**
  String get audioChangeDevicesInSystemHint;

  /// No description provided for @audioPermissionEnabled.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限已开启'**
  String get audioPermissionEnabled;

  /// No description provided for @audioPermissionDisabled.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限未开启'**
  String get audioPermissionDisabled;

  /// No description provided for @audioPermissionRestricted.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限受限制'**
  String get audioPermissionRestricted;

  /// No description provided for @audioPermissionPending.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限待授权'**
  String get audioPermissionPending;

  /// No description provided for @audioPermissionSystemManaged.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限由系统管理'**
  String get audioPermissionSystemManaged;

  /// No description provided for @audioPermissionUnknown.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限未检查'**
  String get audioPermissionUnknown;

  /// No description provided for @audioPermissionEnabledDescription.
  ///
  /// In zh, this message translates to:
  /// **'VPhone 可以使用麦克风'**
  String get audioPermissionEnabledDescription;

  /// No description provided for @audioPermissionDisabledDescription.
  ///
  /// In zh, this message translates to:
  /// **'请前往系统设置允许 VPhone 使用麦克风'**
  String get audioPermissionDisabledDescription;

  /// No description provided for @audioPermissionRestrictedDescription.
  ///
  /// In zh, this message translates to:
  /// **'系统或管理员限制了麦克风访问'**
  String get audioPermissionRestrictedDescription;

  /// No description provided for @audioPermissionPendingDescription.
  ///
  /// In zh, this message translates to:
  /// **'点击向系统申请麦克风权限'**
  String get audioPermissionPendingDescription;

  /// No description provided for @audioPermissionSystemManagedDescription.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限由当前操作系统统一管理'**
  String get audioPermissionSystemManagedDescription;

  /// No description provided for @audioPermissionUnknownDescription.
  ///
  /// In zh, this message translates to:
  /// **'点击检查当前麦克风权限状态'**
  String get audioPermissionUnknownDescription;

  /// No description provided for @audioPermissionOpenSettings.
  ///
  /// In zh, this message translates to:
  /// **'打开系统设置'**
  String get audioPermissionOpenSettings;

  /// No description provided for @audioPermissionRequest.
  ///
  /// In zh, this message translates to:
  /// **'申请麦克风权限'**
  String get audioPermissionRequest;

  /// No description provided for @audioPermissionCheck.
  ///
  /// In zh, this message translates to:
  /// **'检查麦克风权限'**
  String get audioPermissionCheck;

  /// No description provided for @audioPermissionAvailableToast.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限已开启'**
  String get audioPermissionAvailableToast;

  /// No description provided for @audioPermissionRequiredToast.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中允许 VPhone 使用麦克风'**
  String get audioPermissionRequiredToast;

  /// No description provided for @audioPermissionPendingToast.
  ///
  /// In zh, this message translates to:
  /// **'开始通话时，系统将请求麦克风权限'**
  String get audioPermissionPendingToast;

  /// No description provided for @audioPermissionSystemManagedToast.
  ///
  /// In zh, this message translates to:
  /// **'麦克风权限由当前操作系统统一管理'**
  String get audioPermissionSystemManagedToast;

  /// No description provided for @audioPermissionUnknownToast.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法确认麦克风权限状态'**
  String get audioPermissionUnknownToast;

  /// No description provided for @audioIssueMicrophonePermission.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中允许 VPhone 使用麦克风'**
  String get audioIssueMicrophonePermission;

  /// No description provided for @audioIssueNoMicrophone.
  ///
  /// In zh, this message translates to:
  /// **'没有检测到可用麦克风，请连接耳机或输入设备'**
  String get audioIssueNoMicrophone;

  /// No description provided for @audioIssueNoSpeaker.
  ///
  /// In zh, this message translates to:
  /// **'没有检测到可用扬声器，请连接耳机或输出设备'**
  String get audioIssueNoSpeaker;

  /// No description provided for @audioIssueNoInputOutput.
  ///
  /// In zh, this message translates to:
  /// **'没有检测到可用麦克风或扬声器，请连接音频设备'**
  String get audioIssueNoInputOutput;

  /// No description provided for @audioIssueInvalidDevice.
  ///
  /// In zh, this message translates to:
  /// **'当前音频设备已失效，请刷新或重新选择设备'**
  String get audioIssueInvalidDevice;

  /// No description provided for @audioIssueNoDevice.
  ///
  /// In zh, this message translates to:
  /// **'没有检测到可用麦克风或扬声器'**
  String get audioIssueNoDevice;

  /// No description provided for @audioIssueNoDefaultDevice.
  ///
  /// In zh, this message translates to:
  /// **'系统默认麦克风或扬声器不可用'**
  String get audioIssueNoDefaultDevice;

  /// No description provided for @audioIssueNotReady.
  ///
  /// In zh, this message translates to:
  /// **'音频设备暂未就绪，请稍后重试'**
  String get audioIssueNotReady;

  /// No description provided for @audioIssueUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'音频设备暂不可用（错误码 {code}），请重新连接设备后重试'**
  String audioIssueUnavailable(int code);

  /// No description provided for @audioIssueSpeakerOnly.
  ///
  /// In zh, this message translates to:
  /// **'麦克风暂不可用，当前仅使用扬声器，请检查输入设备'**
  String get audioIssueSpeakerOnly;

  /// No description provided for @aboutLoading.
  ///
  /// In zh, this message translates to:
  /// **'读取中'**
  String get aboutLoading;

  /// No description provided for @aboutTagline.
  ///
  /// In zh, this message translates to:
  /// **'VeServe 桌面软电话'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get aboutVersion;

  /// No description provided for @aboutRuntime.
  ///
  /// In zh, this message translates to:
  /// **'运行环境'**
  String get aboutRuntime;

  /// No description provided for @aboutAppId.
  ///
  /// In zh, this message translates to:
  /// **'应用标识'**
  String get aboutAppId;

  /// No description provided for @aboutCompany.
  ///
  /// In zh, this message translates to:
  /// **'公司'**
  String get aboutCompany;

  /// No description provided for @aboutContact.
  ///
  /// In zh, this message translates to:
  /// **'联系我们'**
  String get aboutContact;

  /// No description provided for @aboutPhoneService.
  ///
  /// In zh, this message translates to:
  /// **'电话服务'**
  String get aboutPhoneService;

  /// No description provided for @aboutServiceRunning.
  ///
  /// In zh, this message translates to:
  /// **'已启动'**
  String get aboutServiceRunning;

  /// No description provided for @aboutServiceStopped.
  ///
  /// In zh, this message translates to:
  /// **'未启动'**
  String get aboutServiceStopped;

  /// No description provided for @aboutEmailCopied.
  ///
  /// In zh, this message translates to:
  /// **'邮箱已复制'**
  String get aboutEmailCopied;

  /// No description provided for @diagnosticsShowLogs.
  ///
  /// In zh, this message translates to:
  /// **'显示日志'**
  String get diagnosticsShowLogs;

  /// No description provided for @diagnosticsEventTypes.
  ///
  /// In zh, this message translates to:
  /// **'设备、注册与通话事件'**
  String get diagnosticsEventTypes;

  /// No description provided for @diagnosticsClearLogs.
  ///
  /// In zh, this message translates to:
  /// **'清空日志'**
  String get diagnosticsClearLogs;

  /// No description provided for @diagnosticsExporting.
  ///
  /// In zh, this message translates to:
  /// **'导出中'**
  String get diagnosticsExporting;

  /// No description provided for @diagnosticsExportLogs.
  ///
  /// In zh, this message translates to:
  /// **'导出日志'**
  String get diagnosticsExportLogs;

  /// No description provided for @diagnosticsPrivacyNotice.
  ///
  /// In zh, this message translates to:
  /// **'日志可能包含电话号码、服务器地址和网络信息，请仅发送给可信人员。'**
  String get diagnosticsPrivacyNotice;

  /// No description provided for @diagnosticsLogsHidden.
  ///
  /// In zh, this message translates to:
  /// **'日志已隐藏'**
  String get diagnosticsLogsHidden;

  /// No description provided for @diagnosticsExported.
  ///
  /// In zh, this message translates to:
  /// **'诊断日志已导出'**
  String get diagnosticsExported;

  /// No description provided for @diagnosticsExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，请稍后重试'**
  String get diagnosticsExportFailed;

  /// No description provided for @callSettingsControls.
  ///
  /// In zh, this message translates to:
  /// **'通话控制'**
  String get callSettingsControls;

  /// No description provided for @callSettingsMaxCalls.
  ///
  /// In zh, this message translates to:
  /// **'最大同时通话'**
  String get callSettingsMaxCalls;

  /// No description provided for @callSettingsMaxCallsValue.
  ///
  /// In zh, this message translates to:
  /// **'{count} 路'**
  String callSettingsMaxCallsValue(int count);

  /// No description provided for @callSettingsDtmfMethod.
  ///
  /// In zh, this message translates to:
  /// **'DTMF 方式'**
  String get callSettingsDtmfMethod;

  /// No description provided for @callSettingsAutoHold.
  ///
  /// In zh, this message translates to:
  /// **'自动保持其他通话'**
  String get callSettingsAutoHold;

  /// No description provided for @callSettingsAutoHoldDescription.
  ///
  /// In zh, this message translates to:
  /// **'接听、外呼或恢复通话时，自动保持其他通话'**
  String get callSettingsAutoHoldDescription;

  /// No description provided for @callSettingsShortcuts.
  ///
  /// In zh, this message translates to:
  /// **'快捷操作'**
  String get callSettingsShortcuts;

  /// No description provided for @callSettingsDefaultMute.
  ///
  /// In zh, this message translates to:
  /// **'默认静音'**
  String get callSettingsDefaultMute;

  /// No description provided for @callSettingsOff.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get callSettingsOff;

  /// No description provided for @callSettingsConference.
  ///
  /// In zh, this message translates to:
  /// **'会议通话'**
  String get callSettingsConference;

  /// No description provided for @callSettingsActive.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get callSettingsActive;

  /// No description provided for @accountSettingsSummary.
  ///
  /// In zh, this message translates to:
  /// **'{total} 条线路 · {online} 条在线'**
  String accountSettingsSummary(int total, int online);

  /// No description provided for @accountSettingsDisconnectAll.
  ///
  /// In zh, this message translates to:
  /// **'断开全部'**
  String get accountSettingsDisconnectAll;

  /// No description provided for @accountSettingsRestarting.
  ///
  /// In zh, this message translates to:
  /// **'重启中'**
  String get accountSettingsRestarting;

  /// No description provided for @accountSettingsRestartApp.
  ///
  /// In zh, this message translates to:
  /// **'重启应用'**
  String get accountSettingsRestartApp;

  /// No description provided for @accountSettingsAddLine.
  ///
  /// In zh, this message translates to:
  /// **'添加线路'**
  String get accountSettingsAddLine;

  /// No description provided for @accountSettingsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'尚未接入线路'**
  String get accountSettingsEmpty;

  /// No description provided for @accountSettingsEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'添加线路后即可开始使用'**
  String get accountSettingsEmptyHint;

  /// No description provided for @accountSettingsDefaultPinned.
  ///
  /// In zh, this message translates to:
  /// **'默认外呼线路固定置顶'**
  String get accountSettingsDefaultPinned;

  /// No description provided for @accountSettingsDragToReorder.
  ///
  /// In zh, this message translates to:
  /// **'拖动调整线路顺序'**
  String get accountSettingsDragToReorder;

  /// No description provided for @accountSettingsReorderUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'当前无法调整顺序'**
  String get accountSettingsReorderUnavailable;

  /// No description provided for @accountSettingsDefaultOutgoing.
  ///
  /// In zh, this message translates to:
  /// **'默认外呼'**
  String get accountSettingsDefaultOutgoing;

  /// No description provided for @accountSettingsSetDefault.
  ///
  /// In zh, this message translates to:
  /// **'设为默认'**
  String get accountSettingsSetDefault;

  /// No description provided for @accountSettingsRestartDescription.
  ///
  /// In zh, this message translates to:
  /// **'应用将关闭后自动重新打开，账号配置不会删除。'**
  String get accountSettingsRestartDescription;

  /// No description provided for @accountSettingsRestartStepSave.
  ///
  /// In zh, this message translates to:
  /// **'保存本地配置和通话记录'**
  String get accountSettingsRestartStepSave;

  /// No description provided for @accountSettingsRestartStepClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭并重新打开应用'**
  String get accountSettingsRestartStepClose;

  /// No description provided for @accountSettingsRestartStepRestore.
  ///
  /// In zh, this message translates to:
  /// **'恢复已保存线路'**
  String get accountSettingsRestartStepRestore;

  /// No description provided for @accountSettingsRestartRecommended.
  ///
  /// In zh, this message translates to:
  /// **'适用于休眠、网络切换或线路状态异常后的恢复。'**
  String get accountSettingsRestartRecommended;

  /// No description provided for @accountSettingsRestartCallWarning.
  ///
  /// In zh, this message translates to:
  /// **'当前仍有通话，重启会中断通话和线路连接。'**
  String get accountSettingsRestartCallWarning;

  /// No description provided for @accountStatusOnline.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get accountStatusOnline;

  /// No description provided for @accountStatusConnecting.
  ///
  /// In zh, this message translates to:
  /// **'连接中'**
  String get accountStatusConnecting;

  /// No description provided for @accountStatusUpdating.
  ///
  /// In zh, this message translates to:
  /// **'处理中'**
  String get accountStatusUpdating;

  /// No description provided for @accountStatusDisabled.
  ///
  /// In zh, this message translates to:
  /// **'已停用'**
  String get accountStatusDisabled;

  /// No description provided for @accountStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get accountStatusFailed;

  /// No description provided for @accountStatusOffline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get accountStatusOffline;

  /// No description provided for @accountStatusRestoring.
  ///
  /// In zh, this message translates to:
  /// **'恢复中'**
  String get accountStatusRestoring;

  /// No description provided for @accountDialogAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加线路'**
  String get accountDialogAddTitle;

  /// No description provided for @accountDialogEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑线路'**
  String get accountDialogEditTitle;

  /// No description provided for @accountDialogAccountInfo.
  ///
  /// In zh, this message translates to:
  /// **'账号信息'**
  String get accountDialogAccountInfo;

  /// No description provided for @accountDialogLineName.
  ///
  /// In zh, this message translates to:
  /// **'线路名称（可选）'**
  String get accountDialogLineName;

  /// No description provided for @accountDialogLineNameHint.
  ///
  /// In zh, this message translates to:
  /// **'仅用于本地显示，例如“客服一线”'**
  String get accountDialogLineNameHint;

  /// No description provided for @accountDialogUsername.
  ///
  /// In zh, this message translates to:
  /// **'线路账号'**
  String get accountDialogUsername;

  /// No description provided for @accountDialogPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get accountDialogPassword;

  /// No description provided for @accountDialogShowPassword.
  ///
  /// In zh, this message translates to:
  /// **'显示密码'**
  String get accountDialogShowPassword;

  /// No description provided for @accountDialogHidePassword.
  ///
  /// In zh, this message translates to:
  /// **'隐藏密码'**
  String get accountDialogHidePassword;

  /// No description provided for @accountDialogServer.
  ///
  /// In zh, this message translates to:
  /// **'服务器地址'**
  String get accountDialogServer;

  /// No description provided for @accountDialogPort.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get accountDialogPort;

  /// No description provided for @accountDialogDefaultPortHint.
  ///
  /// In zh, this message translates to:
  /// **'可留空 · {transport} 默认端口 {port}'**
  String accountDialogDefaultPortHint(String transport, int port);

  /// No description provided for @accountDialogConnection.
  ///
  /// In zh, this message translates to:
  /// **'连接方式'**
  String get accountDialogConnection;

  /// No description provided for @accountDialogNetworkUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'网络不可用，暂时无法添加线路'**
  String get accountDialogNetworkUnavailable;

  /// No description provided for @accountDialogSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get accountDialogSave;

  /// No description provided for @accountDialogAddAndRegister.
  ///
  /// In zh, this message translates to:
  /// **'添加并注册'**
  String get accountDialogAddAndRegister;

  /// No description provided for @accountDialogTransport.
  ///
  /// In zh, this message translates to:
  /// **'传输协议'**
  String get accountDialogTransport;

  /// No description provided for @accountDialogDefaultPort.
  ///
  /// In zh, this message translates to:
  /// **'默认端口 {port}'**
  String accountDialogDefaultPort(int port);

  /// No description provided for @accountDialogTransportStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get accountDialogTransportStandard;

  /// No description provided for @accountDialogTransportCompatible.
  ///
  /// In zh, this message translates to:
  /// **'兼容'**
  String get accountDialogTransportCompatible;

  /// No description provided for @accountDialogTransportSecure.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get accountDialogTransportSecure;

  /// No description provided for @accountDialogMediaEncryption.
  ///
  /// In zh, this message translates to:
  /// **'媒体加密'**
  String get accountDialogMediaEncryption;

  /// No description provided for @accountDialogSrtpWithoutTlsWarning.
  ///
  /// In zh, this message translates to:
  /// **'当前未使用 TLS。SRTP 将关闭安全信令要求；SDES 密钥会写入 SDP，建议配合 TLS。'**
  String get accountDialogSrtpWithoutTlsWarning;

  /// No description provided for @accountDialogMediaNone.
  ///
  /// In zh, this message translates to:
  /// **'RTP 不加密'**
  String get accountDialogMediaNone;

  /// No description provided for @accountDialogMediaSdes.
  ///
  /// In zh, this message translates to:
  /// **'SDES-SRTP'**
  String get accountDialogMediaSdes;

  /// No description provided for @accountDialogMediaDtls.
  ///
  /// In zh, this message translates to:
  /// **'DTLS-SRTP'**
  String get accountDialogMediaDtls;

  /// No description provided for @accountDialogMediaOptionalDtls.
  ///
  /// In zh, this message translates to:
  /// **'可选 SRTP（优先 DTLS）'**
  String get accountDialogMediaOptionalDtls;

  /// No description provided for @accountDialogMediaOptionalSdes.
  ///
  /// In zh, this message translates to:
  /// **'可选 SRTP（优先 SDES）'**
  String get accountDialogMediaOptionalSdes;

  /// No description provided for @accountDialogMediaBestCompatibility.
  ///
  /// In zh, this message translates to:
  /// **'兼容性最好'**
  String get accountDialogMediaBestCompatibility;

  /// No description provided for @accountDialogMediaUseTls.
  ///
  /// In zh, this message translates to:
  /// **'建议配合 TLS'**
  String get accountDialogMediaUseTls;

  /// No description provided for @accountDialogMediaAsteriskDtls.
  ///
  /// In zh, this message translates to:
  /// **'适用于 Asterisk DTLS'**
  String get accountDialogMediaAsteriskDtls;

  /// No description provided for @accountDialogMediaAllowsFallback.
  ///
  /// In zh, this message translates to:
  /// **'允许非加密回退'**
  String get accountDialogMediaAllowsFallback;

  /// No description provided for @accountDialogMediaLegacySrtp.
  ///
  /// In zh, this message translates to:
  /// **'兼容旧版 SRTP'**
  String get accountDialogMediaLegacySrtp;

  /// No description provided for @accountDialogAdvanced.
  ///
  /// In zh, this message translates to:
  /// **'高级设置'**
  String get accountDialogAdvanced;

  /// No description provided for @accountDialogAdvancedAccount.
  ///
  /// In zh, this message translates to:
  /// **'高级账号'**
  String get accountDialogAdvancedAccount;

  /// No description provided for @accountDialogAuthUsername.
  ///
  /// In zh, this message translates to:
  /// **'认证用户名（可选）'**
  String get accountDialogAuthUsername;

  /// No description provided for @accountDialogAuthUsernameHint.
  ///
  /// In zh, this message translates to:
  /// **'留空时使用线路账号，仅用于 SIP 鉴权'**
  String get accountDialogAuthUsernameHint;

  /// No description provided for @accountDialogSipDisplayName.
  ///
  /// In zh, this message translates to:
  /// **'SIP 显示名称（可选）'**
  String get accountDialogSipDisplayName;

  /// No description provided for @accountDialogSipDisplayNameHint.
  ///
  /// In zh, this message translates to:
  /// **'可能显示给对端；本地名称请填写线路名称'**
  String get accountDialogSipDisplayNameHint;

  /// No description provided for @accountDialogAdvancedNetwork.
  ///
  /// In zh, this message translates to:
  /// **'高级网络'**
  String get accountDialogAdvancedNetwork;

  /// No description provided for @accountDialogOutboundProxy.
  ///
  /// In zh, this message translates to:
  /// **'SIP 出站代理（可选）'**
  String get accountDialogOutboundProxy;

  /// No description provided for @accountDialogOutboundProxyHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 sip:proxy.example.com:5060；留空时直连服务器'**
  String get accountDialogOutboundProxyHint;

  /// No description provided for @accountDialogEnableIpv6.
  ///
  /// In zh, this message translates to:
  /// **'启用 IPv6'**
  String get accountDialogEnableIpv6;

  /// No description provided for @accountDialogEnableIpv6Hint.
  ///
  /// In zh, this message translates to:
  /// **'默认关闭，以减少 SIP 和媒体候选'**
  String get accountDialogEnableIpv6Hint;

  /// No description provided for @accountDialogEnableIce.
  ///
  /// In zh, this message translates to:
  /// **'启用 ICE'**
  String get accountDialogEnableIce;

  /// No description provided for @accountDialogEnableIceHint.
  ///
  /// In zh, this message translates to:
  /// **'用于复杂 NAT 网络下的媒体协商'**
  String get accountDialogEnableIceHint;

  /// No description provided for @accountDialogEnableStun.
  ///
  /// In zh, this message translates to:
  /// **'启用 STUN'**
  String get accountDialogEnableStun;

  /// No description provided for @accountDialogEnableStunHint.
  ///
  /// In zh, this message translates to:
  /// **'发现公网映射地址，用于 NAT 穿透'**
  String get accountDialogEnableStunHint;

  /// No description provided for @accountDialogStunServer.
  ///
  /// In zh, this message translates to:
  /// **'STUN 服务器'**
  String get accountDialogStunServer;

  /// No description provided for @accountDialogStunServerHint.
  ///
  /// In zh, this message translates to:
  /// **'留空时使用默认 STUN；多个地址用逗号或空格分隔'**
  String get accountDialogStunServerHint;

  /// No description provided for @accountDialogEnableTurn.
  ///
  /// In zh, this message translates to:
  /// **'启用 TURN'**
  String get accountDialogEnableTurn;

  /// No description provided for @accountDialogTurnHint.
  ///
  /// In zh, this message translates to:
  /// **'直连失败时使用中继服务器'**
  String get accountDialogTurnHint;

  /// No description provided for @accountDialogTurnNeedsIce.
  ///
  /// In zh, this message translates to:
  /// **'请先启用 ICE'**
  String get accountDialogTurnNeedsIce;

  /// No description provided for @accountDialogTurnServer.
  ///
  /// In zh, this message translates to:
  /// **'TURN 服务器'**
  String get accountDialogTurnServer;

  /// No description provided for @accountDialogTurnUsername.
  ///
  /// In zh, this message translates to:
  /// **'TURN 用户名'**
  String get accountDialogTurnUsername;

  /// No description provided for @accountDialogTurnTransport.
  ///
  /// In zh, this message translates to:
  /// **'TURN 协议'**
  String get accountDialogTurnTransport;

  /// No description provided for @accountDialogTurnPassword.
  ///
  /// In zh, this message translates to:
  /// **'TURN 密码'**
  String get accountDialogTurnPassword;

  /// No description provided for @accountDialogTurnUdp.
  ///
  /// In zh, this message translates to:
  /// **'默认中继'**
  String get accountDialogTurnUdp;

  /// No description provided for @accountDialogTurnTcp.
  ///
  /// In zh, this message translates to:
  /// **'受限网络更稳定'**
  String get accountDialogTurnTcp;

  /// No description provided for @accountDialogTurnTls.
  ///
  /// In zh, this message translates to:
  /// **'适合企业网络'**
  String get accountDialogTurnTls;

  /// No description provided for @accountDialogAdvancedAuth.
  ///
  /// In zh, this message translates to:
  /// **'认证用户名'**
  String get accountDialogAdvancedAuth;

  /// No description provided for @accountDialogAdvancedDisplayName.
  ///
  /// In zh, this message translates to:
  /// **'SIP 显示名'**
  String get accountDialogAdvancedDisplayName;

  /// No description provided for @accountDialogAdvancedProxy.
  ///
  /// In zh, this message translates to:
  /// **'出站代理'**
  String get accountDialogAdvancedProxy;

  /// No description provided for @accountDialogAdvancedDefaults.
  ///
  /// In zh, this message translates to:
  /// **'账号默认'**
  String get accountDialogAdvancedDefaults;

  /// No description provided for @accountDialogIceOff.
  ///
  /// In zh, this message translates to:
  /// **'ICE 关闭'**
  String get accountDialogIceOff;

  /// No description provided for @accountDialogStunOff.
  ///
  /// In zh, this message translates to:
  /// **'STUN 关闭'**
  String get accountDialogStunOff;

  /// No description provided for @accountDialogStunDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认 STUN'**
  String get accountDialogStunDefault;

  /// No description provided for @accountDialogStunCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义 STUN'**
  String get accountDialogStunCustom;

  /// No description provided for @accountDialogIpv4Only.
  ///
  /// In zh, this message translates to:
  /// **'仅 IPv4'**
  String get accountDialogIpv4Only;

  /// No description provided for @accountDialogUdpIceWarning.
  ///
  /// In zh, this message translates to:
  /// **'UDP + ICE 可能增大 SIP 报文，部分网络会丢弃分片。建议使用 TCP/TLS，或关闭 ICE。'**
  String get accountDialogUdpIceWarning;

  /// No description provided for @accountDialogRequired.
  ///
  /// In zh, this message translates to:
  /// **'必填'**
  String get accountDialogRequired;

  /// No description provided for @accountDialogInvalidPort.
  ///
  /// In zh, this message translates to:
  /// **'请输入 1–65535 之间的端口'**
  String get accountDialogInvalidPort;

  /// No description provided for @accountDialogConfirmUdpIce.
  ///
  /// In zh, this message translates to:
  /// **'确认使用 UDP + ICE？'**
  String get accountDialogConfirmUdpIce;

  /// No description provided for @accountDialogConfirmUdpIceBody.
  ///
  /// In zh, this message translates to:
  /// **'UDP + ICE 可能导致部分网络无法外呼。建议使用 TCP/TLS，或关闭 ICE。'**
  String get accountDialogConfirmUdpIceBody;

  /// No description provided for @accountDialogReview.
  ///
  /// In zh, this message translates to:
  /// **'返回检查'**
  String get accountDialogReview;

  /// No description provided for @accountDialogSaveAnyway.
  ///
  /// In zh, this message translates to:
  /// **'仍然保存'**
  String get accountDialogSaveAnyway;

  /// No description provided for @accountLimitReached.
  ///
  /// In zh, this message translates to:
  /// **'最多支持 {count} 条线路，请删除不再使用的线路后重试'**
  String accountLimitReached(int count);
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
