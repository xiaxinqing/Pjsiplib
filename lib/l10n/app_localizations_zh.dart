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

  @override
  String get commonCancel => '取消';

  @override
  String get commonAdd => '添加';

  @override
  String get commonAll => '全部';

  @override
  String get commonAvailable => '可用';

  @override
  String get commonUnavailable => '不可用';

  @override
  String get commonClear => '清空';

  @override
  String get headerEndCallsFirst => '请先结束当前通话';

  @override
  String get headerPhoneServiceUnavailable => '电话服务未初始化';

  @override
  String get headerAllLinesDisconnected => '线路已全部断开';

  @override
  String get headerDisconnectAllLines => '断开全部线路';

  @override
  String get headerAddLine => '添加线路';

  @override
  String get disconnectAllDescription => '所有线路将停止注册，之后可在线路菜单中重新启用。';

  @override
  String disconnectAllSummary(int total, int online) {
    return '已接入 $total 条线路，$online 条在线';
  }

  @override
  String get disconnectAllQuestion => '确定断开全部线路吗？';

  @override
  String get disconnectAllAction => '断开全部';

  @override
  String get statusNetworkUnavailable => '当前网络不可用';

  @override
  String get statusCheckingSeatEnvironment => '正在检查上次坐席环境';

  @override
  String get statusRestoringLines => '正在恢复上次线路配置';

  @override
  String statusConnectedNoOutgoing(int total) {
    return '已接入 $total 条线路，暂无可用拨号线路';
  }

  @override
  String statusConnectedCurrentOutgoing(int total, String line) {
    return '已接入 $total 条线路，当前拨号线路：$line';
  }

  @override
  String statusConnectedDefaultOutgoing(int total, String line) {
    return '已接入 $total 条线路，默认拨号线路：$line';
  }

  @override
  String get statusInitializedNoAccounts => '电话服务已启动，尚未添加线路';

  @override
  String get statusConnectServiceHint => '启动电话服务后即可发起和接听通话';

  @override
  String get dialOutgoingLine => '拨号线路';

  @override
  String get dialNoLinesAdded => '尚未添加线路';

  @override
  String get dialOpenLineSettings => '打开线路设置';

  @override
  String get dialNoAvailableOutgoing => '暂无可用拨号线路，请检查注册状态';

  @override
  String dialFallbackOutgoing(String line) {
    return '默认线路 $line 不可用，当前临时使用此线路';
  }

  @override
  String get dialNoAvailableLine => '暂无可用线路';

  @override
  String get dialNetworkUnavailableDescription => '恢复网络后即可拨打电话';

  @override
  String get dialNoLinesDescription => '添加 SIP 线路后即可拨打电话';

  @override
  String get dialNoOutgoingDescription => '请检查线路注册状态';

  @override
  String get dialConferenceActive => '会议通话中';

  @override
  String get dialConferenceActiveDescription => '请先拆分会议，再发起新呼叫';

  @override
  String get dialCapacityReached => '通话已达上限';

  @override
  String dialCapacityDescription(int max) {
    return '最多同时保持 $max 路通话';
  }

  @override
  String get dialReady => '可以发起外呼';

  @override
  String get dialReadyDescription => '输入号码后点击呼叫';

  @override
  String get dialUnavailable => '暂不可外呼';

  @override
  String get dialUnavailableDescription => '请检查号码或线路状态';

  @override
  String get dialEnterNumberToCall => '输入号码后呼叫';

  @override
  String get dialAddLineFirst => '请先添加线路';

  @override
  String get dialUnavailableDuringConference => '会议中不可外呼';

  @override
  String get dialNumberHint => '输入号码';

  @override
  String get dialStartCall => '发起外呼';

  @override
  String get dialCall => '呼叫';

  @override
  String get dialCurrentOutgoingLine => '当前拨号线路';

  @override
  String get dialDefaultOutgoingLine => '默认拨号线路';

  @override
  String get dialCallCapacity => '通话容量';

  @override
  String dialCallCapacityValue(int current, int max) {
    return '$current/$max 路';
  }

  @override
  String get dialNetwork => '网络';

  @override
  String get dialNoRecentCalls => '暂无最近通话';

  @override
  String get dialRecentCalls => '最近通话';

  @override
  String get dialNoCallbackNumber => '没有可回拨号码';

  @override
  String dialCallbackNumber(String number) {
    return '回拨 $number';
  }

  @override
  String dialYesterdayAt(String time) {
    return '昨天 $time';
  }

  @override
  String get contactDefaultNumber => '默认';

  @override
  String get contactExactMatch => '已匹配';

  @override
  String get contactSuffixMatch => '尾号匹配';

  @override
  String get weekdayMonday => '周一';

  @override
  String get weekdayTuesday => '周二';

  @override
  String get weekdayWednesday => '周三';

  @override
  String get weekdayThursday => '周四';

  @override
  String get weekdayFriday => '周五';

  @override
  String get weekdaySaturday => '周六';

  @override
  String get weekdaySunday => '周日';

  @override
  String sidebarConnectedTemporary(String line) {
    return '临时拨号线路 · $line';
  }

  @override
  String sidebarConnectedDefault(String line) {
    return '拨号线路 · $line';
  }

  @override
  String get sidebarWaitingAccounts => '等待账号连接';

  @override
  String get sidebarDisconnected => '未连接';

  @override
  String get sidebarConnectionStatus => '连接状态';

  @override
  String get sidebarPhoneService => '电话服务';

  @override
  String get sidebarServiceStarted => '已启动';

  @override
  String get sidebarServiceStopped => '未启动';

  @override
  String get sidebarDefaultDialLine => '默认拨号线路';

  @override
  String get sidebarNone => '暂无';

  @override
  String get sidebarCurrentDialLine => '当前拨号线路';

  @override
  String get sidebarTemporaryUse => '临时使用';

  @override
  String get sidebarLines => '线路';

  @override
  String sidebarOnlineCount(int online, int total) {
    return '$online/$total 在线';
  }

  @override
  String get sidebarRetryFailedLines => '重新注册异常线路';

  @override
  String get sidebarOpenLineSettings => '打开线路设置';

  @override
  String get sidebarDefaultDial => '默认拨号';

  @override
  String sidebarManageLines(int count) {
    return '管理 $count 条线路';
  }

  @override
  String get sidebarAudio => '音频';

  @override
  String get sidebarAudioIssue => '异常';

  @override
  String get sidebarAudioDevices => '音频设备';

  @override
  String get sidebarAudioInput => '输入';

  @override
  String get sidebarAudioOutput => '输出';

  @override
  String get sidebarAudioMode => '模式';

  @override
  String get sidebarAudioStatus => '状态';

  @override
  String get sidebarAudioAutomatic => '自动选择';

  @override
  String get sidebarAudioManual => '手动选择';

  @override
  String get sidebarAudioSwitchToManual => '切换为手动选择';

  @override
  String get sidebarAudioSwitchToAutomatic => '切换为自动选择';

  @override
  String get sidebarAudioRefreshDevices => '刷新设备';

  @override
  String get sidebarOpenAudioSettings => '打开音频设置';

  @override
  String get sidebarSetDefaultDial => '设为默认拨号线路';

  @override
  String sidebarDefaultDialStatus(String status, String transport) {
    return '默认拨号 · $status · $transport';
  }

  @override
  String get sidebarRefreshLine => '刷新';

  @override
  String get sidebarRestartLine => '重启';

  @override
  String get sidebarDisableLine => '停用';

  @override
  String get sidebarEnableLine => '启用';

  @override
  String get sidebarEditLine => '编辑';

  @override
  String get sidebarDeleteLine => '删除';

  @override
  String get sidebarRestartLineTitle => '重启线路';

  @override
  String get sidebarRestartLineDescription => '会短暂注销后重新注册，不会删除这条线路。';

  @override
  String get sidebarRestartLineHint => '适合网络恢复或电脑休眠唤醒后线路状态异常的情况。';

  @override
  String get sidebarDeleteLineTitle => '删除线路';

  @override
  String get sidebarDeleteLineDescription => '删除后需要重新添加账号才能恢复。';

  @override
  String get sidebarDeleteLineQuestion => '确定删除这条线路吗？';

  @override
  String get callDirectionInbound => '来电';

  @override
  String get callDirectionOutbound => '呼出';

  @override
  String get callStatusCompleted => '已接通';

  @override
  String get callStatusMissed => '未接来电';

  @override
  String get callStatusRejected => '已拒接';

  @override
  String get callStatusFailed => '呼叫失败';

  @override
  String get callStatusCanceled => '已取消';
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

  @override
  String get commonCancel => '取消';

  @override
  String get commonAdd => '新增';

  @override
  String get commonAll => '全部';

  @override
  String get commonAvailable => '可用';

  @override
  String get commonUnavailable => '不可用';

  @override
  String get commonClear => '清除';

  @override
  String get headerEndCallsFirst => '請先結束目前通話';

  @override
  String get headerPhoneServiceUnavailable => '電話服務尚未初始化';

  @override
  String get headerAllLinesDisconnected => '所有線路已中斷';

  @override
  String get headerDisconnectAllLines => '中斷所有線路';

  @override
  String get headerAddLine => '新增線路';

  @override
  String get disconnectAllDescription => '所有線路將停止註冊，之後可在線路選單中重新啟用。';

  @override
  String disconnectAllSummary(int total, int online) {
    return '已接入 $total 條線路，$online 條在線';
  }

  @override
  String get disconnectAllQuestion => '確定中斷所有線路嗎？';

  @override
  String get disconnectAllAction => '全部中斷';

  @override
  String get statusNetworkUnavailable => '目前網絡不可用';

  @override
  String get statusCheckingSeatEnvironment => '正在檢查上次客服環境';

  @override
  String get statusRestoringLines => '正在恢復上次線路設定';

  @override
  String statusConnectedNoOutgoing(int total) {
    return '已接入 $total 條線路，暫無可用撥號線路';
  }

  @override
  String statusConnectedCurrentOutgoing(int total, String line) {
    return '已接入 $total 條線路，目前撥號線路：$line';
  }

  @override
  String statusConnectedDefaultOutgoing(int total, String line) {
    return '已接入 $total 條線路，預設撥號線路：$line';
  }

  @override
  String get statusInitializedNoAccounts => '電話服務已啟動，尚未新增線路';

  @override
  String get statusConnectServiceHint => '啟動電話服務後即可撥打及接聽電話';

  @override
  String get dialOutgoingLine => '撥號線路';

  @override
  String get dialNoLinesAdded => '尚未新增線路';

  @override
  String get dialOpenLineSettings => '開啟線路設定';

  @override
  String get dialNoAvailableOutgoing => '暫無可用撥號線路，請檢查註冊狀態';

  @override
  String dialFallbackOutgoing(String line) {
    return '預設線路 $line 不可用，目前暫時使用此線路';
  }

  @override
  String get dialNoAvailableLine => '暫無可用線路';

  @override
  String get dialNetworkUnavailableDescription => '恢復網絡後即可撥打電話';

  @override
  String get dialNoLinesDescription => '新增 SIP 線路後即可撥打電話';

  @override
  String get dialNoOutgoingDescription => '請檢查線路註冊狀態';

  @override
  String get dialConferenceActive => '會議通話中';

  @override
  String get dialConferenceActiveDescription => '請先拆分會議，再撥打新電話';

  @override
  String get dialCapacityReached => '通話已達上限';

  @override
  String dialCapacityDescription(int max) {
    return '最多可同時保持 $max 路通話';
  }

  @override
  String get dialReady => '可以撥打電話';

  @override
  String get dialReadyDescription => '輸入號碼後按下撥號';

  @override
  String get dialUnavailable => '暫時無法撥號';

  @override
  String get dialUnavailableDescription => '請檢查號碼或線路狀態';

  @override
  String get dialEnterNumberToCall => '輸入號碼後撥號';

  @override
  String get dialAddLineFirst => '請先新增線路';

  @override
  String get dialUnavailableDuringConference => '會議中無法撥號';

  @override
  String get dialNumberHint => '輸入號碼';

  @override
  String get dialStartCall => '撥打電話';

  @override
  String get dialCall => '撥號';

  @override
  String get dialCurrentOutgoingLine => '目前撥號線路';

  @override
  String get dialDefaultOutgoingLine => '預設撥號線路';

  @override
  String get dialCallCapacity => '通話容量';

  @override
  String dialCallCapacityValue(int current, int max) {
    return '$current/$max 路';
  }

  @override
  String get dialNetwork => '網絡';

  @override
  String get dialNoRecentCalls => '暫無最近通話';

  @override
  String get dialRecentCalls => '最近通話';

  @override
  String get dialNoCallbackNumber => '沒有可回撥號碼';

  @override
  String dialCallbackNumber(String number) {
    return '回撥 $number';
  }

  @override
  String dialYesterdayAt(String time) {
    return '昨天 $time';
  }

  @override
  String get contactDefaultNumber => '預設';

  @override
  String get contactExactMatch => '已配對';

  @override
  String get contactSuffixMatch => '尾號配對';

  @override
  String get weekdayMonday => '星期一';

  @override
  String get weekdayTuesday => '星期二';

  @override
  String get weekdayWednesday => '星期三';

  @override
  String get weekdayThursday => '星期四';

  @override
  String get weekdayFriday => '星期五';

  @override
  String get weekdaySaturday => '星期六';

  @override
  String get weekdaySunday => '星期日';

  @override
  String sidebarConnectedTemporary(String line) {
    return '臨時撥號線路 · $line';
  }

  @override
  String sidebarConnectedDefault(String line) {
    return '撥號線路 · $line';
  }

  @override
  String get sidebarWaitingAccounts => '等待線路連接';

  @override
  String get sidebarDisconnected => '未連接';

  @override
  String get sidebarConnectionStatus => '連接狀態';

  @override
  String get sidebarPhoneService => '電話服務';

  @override
  String get sidebarServiceStarted => '已啟動';

  @override
  String get sidebarServiceStopped => '未啟動';

  @override
  String get sidebarDefaultDialLine => '預設撥號線路';

  @override
  String get sidebarNone => '暫無';

  @override
  String get sidebarCurrentDialLine => '目前撥號線路';

  @override
  String get sidebarTemporaryUse => '臨時使用';

  @override
  String get sidebarLines => '線路';

  @override
  String sidebarOnlineCount(int online, int total) {
    return '$online/$total 在線';
  }

  @override
  String get sidebarRetryFailedLines => '重新註冊異常線路';

  @override
  String get sidebarOpenLineSettings => '開啟線路設定';

  @override
  String get sidebarDefaultDial => '預設撥號';

  @override
  String sidebarManageLines(int count) {
    return '管理 $count 條線路';
  }

  @override
  String get sidebarAudio => '音訊';

  @override
  String get sidebarAudioIssue => '異常';

  @override
  String get sidebarAudioDevices => '音訊裝置';

  @override
  String get sidebarAudioInput => '輸入';

  @override
  String get sidebarAudioOutput => '輸出';

  @override
  String get sidebarAudioMode => '模式';

  @override
  String get sidebarAudioStatus => '狀態';

  @override
  String get sidebarAudioAutomatic => '自動選擇';

  @override
  String get sidebarAudioManual => '手動選擇';

  @override
  String get sidebarAudioSwitchToManual => '切換為手動選擇';

  @override
  String get sidebarAudioSwitchToAutomatic => '切換為自動選擇';

  @override
  String get sidebarAudioRefreshDevices => '重新整理裝置';

  @override
  String get sidebarOpenAudioSettings => '開啟音訊設定';

  @override
  String get sidebarSetDefaultDial => '設為預設撥號線路';

  @override
  String sidebarDefaultDialStatus(String status, String transport) {
    return '預設撥號 · $status · $transport';
  }

  @override
  String get sidebarRefreshLine => '重新整理';

  @override
  String get sidebarRestartLine => '重新啟動';

  @override
  String get sidebarDisableLine => '停用';

  @override
  String get sidebarEnableLine => '啟用';

  @override
  String get sidebarEditLine => '編輯';

  @override
  String get sidebarDeleteLine => '刪除';

  @override
  String get sidebarRestartLineTitle => '重新啟動線路';

  @override
  String get sidebarRestartLineDescription => '系統會短暫登出後重新註冊，不會刪除這條線路。';

  @override
  String get sidebarRestartLineHint => '適用於網絡恢復或電腦喚醒後線路狀態異常的情況。';

  @override
  String get sidebarDeleteLineTitle => '刪除線路';

  @override
  String get sidebarDeleteLineDescription => '刪除後需要重新加入帳戶才能恢復。';

  @override
  String get sidebarDeleteLineQuestion => '確定要刪除這條線路嗎？';

  @override
  String get callDirectionInbound => '來電';

  @override
  String get callDirectionOutbound => '撥出';

  @override
  String get callStatusCompleted => '已接通';

  @override
  String get callStatusMissed => '未接來電';

  @override
  String get callStatusRejected => '已拒接';

  @override
  String get callStatusFailed => '撥號失敗';

  @override
  String get callStatusCanceled => '已取消';
}
