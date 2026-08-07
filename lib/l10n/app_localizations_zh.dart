// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'VPhone';

  @override
  String get navDialpad => '拨号';

  @override
  String get navCurrentCalls => '当前通话';

  @override
  String get navContacts => '联系人';

  @override
  String get navCallHistory => '通话记录';

  @override
  String get settings => '设置';

  @override
  String get settingsClose => '关闭';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsGeneralDescription => '设置语言和应用偏好';

  @override
  String get settingsLanguageSection => '语言与地区';

  @override
  String get settingsDisplayLanguage => '显示语言';

  @override
  String get settingsDisplayLanguageDescription => '更改立即生效，并在下次启动时保留';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文（香港）';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsStartupSection => '启动与窗口';

  @override
  String get settingsLaunchAtLogin => '开机自动启动';

  @override
  String get settingsLaunchAtLoginDescription => '登录系统后自动启动 VPhone';

  @override
  String get settingsStartMinimized => '启动后最小化';

  @override
  String get settingsStartMinimizedDescription => '在后台启动，并保持电话服务在线';

  @override
  String get settingsNotificationsSection => '来电与通知';

  @override
  String get settingsShowWindowForIncomingCall => '来电时显示主窗口';

  @override
  String get settingsShowWindowForIncomingCallDescription => '收到来电时打开当前通话页面';

  @override
  String get settingsAppBadge => '应用角标';

  @override
  String get settingsAppBadgeDescription => '显示正在来电和未读未接来电数量';

  @override
  String get settingsComingSoon => '即将推出';

  @override
  String get settingsAccount => '账号';

  @override
  String get settingsAccountDescription => '管理 SIP 线路、默认外呼线路和注册状态';

  @override
  String get settingsAudio => '音频';

  @override
  String get settingsAudioDescription => '选择输入和输出设备，测试通话音频';

  @override
  String get settingsCalls => '通话';

  @override
  String get settingsCallsDescription => '设置通话行为、快捷操作和会议功能';

  @override
  String get settingsDiagnostics => '诊断';

  @override
  String get settingsDiagnosticsDescription => '查看设备、注册和通话日志';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutDescription => '查看版本、应用标识和支持信息';

  @override
  String get phoneServiceStarted => '电话服务运行中';

  @override
  String get phoneServiceStopped => '电话服务未启动';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'VPhone';

  @override
  String get navDialpad => '撥號';

  @override
  String get navCurrentCalls => '目前通話';

  @override
  String get navContacts => '聯絡人';

  @override
  String get navCallHistory => '通話記錄';

  @override
  String get settings => '設定';

  @override
  String get settingsClose => '關閉';

  @override
  String get settingsGeneral => '一般';

  @override
  String get settingsGeneralDescription => '設定語言及應用程式偏好';

  @override
  String get settingsLanguageSection => '語言及地區';

  @override
  String get settingsDisplayLanguage => '顯示語言';

  @override
  String get settingsDisplayLanguageDescription => '變更會即時生效，並於下次啟動時沿用';

  @override
  String get languageFollowSystem => '跟隨系統';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文（香港）';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsStartupSection => '啟動及視窗';

  @override
  String get settingsLaunchAtLogin => '登入時自動啟動';

  @override
  String get settingsLaunchAtLoginDescription => '登入系統後自動啟動 VPhone';

  @override
  String get settingsStartMinimized => '啟動後縮至最小';

  @override
  String get settingsStartMinimizedDescription => '在背景啟動，並保持電話服務連線';

  @override
  String get settingsNotificationsSection => '來電及通知';

  @override
  String get settingsShowWindowForIncomingCall => '來電時顯示主視窗';

  @override
  String get settingsShowWindowForIncomingCallDescription => '收到來電時開啟目前通話頁面';

  @override
  String get settingsAppBadge => 'App 圖示標記';

  @override
  String get settingsAppBadgeDescription => '顯示正在來電及未讀的未接來電數目';

  @override
  String get settingsComingSoon => '即將推出';

  @override
  String get settingsAccount => '帳戶';

  @override
  String get settingsAccountDescription => '管理 SIP 線路、預設外撥線路及註冊狀態';

  @override
  String get settingsAudio => '音訊';

  @override
  String get settingsAudioDescription => '選擇輸入及輸出裝置，並測試通話音訊';

  @override
  String get settingsCalls => '通話';

  @override
  String get settingsCallsDescription => '設定通話行為、快速操作及會議功能';

  @override
  String get settingsDiagnostics => '診斷';

  @override
  String get settingsDiagnosticsDescription => '查看裝置、註冊及通話日誌';

  @override
  String get settingsAbout => '關於';

  @override
  String get settingsAboutDescription => '查看版本、應用程式資料及支援資訊';

  @override
  String get phoneServiceStarted => '電話服務運作中';

  @override
  String get phoneServiceStopped => '電話服務未啟動';
}
