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
  String get commonSave => '保存';

  @override
  String get commonClose => '关闭';

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

  @override
  String get contactNewTitle => '新建联系人';

  @override
  String get contactEditTitle => '编辑联系人';

  @override
  String get contactDetailsTitle => '客户资料';

  @override
  String get contactName => '姓名';

  @override
  String get contactNameRequired => '请输入姓名';

  @override
  String get contactCompany => '公司';

  @override
  String get contactDepartment => '部门';

  @override
  String get contactNotes => '备注';

  @override
  String get contactPriority => '设为重点联系人';

  @override
  String get contactPrioritySet => '设为重点';

  @override
  String get contactPriorityUnset => '取消重点';

  @override
  String get contactPriorityBadge => '重点';

  @override
  String get contactSave => '保存';

  @override
  String get contactDelete => '删除';

  @override
  String get contactEdit => '编辑';

  @override
  String get contactCall => '呼叫';

  @override
  String get contactClose => '关闭';

  @override
  String get contactPhone => '号码';

  @override
  String get contactPhones => '电话号码';

  @override
  String get contactAddPhone => '添加号码';

  @override
  String get contactPhoneLabel => '标签';

  @override
  String get contactPhoneRequired => '请输入号码';

  @override
  String get contactPhoneInvalid => '号码只能包含数字和常用电话符号';

  @override
  String get contactPhoneDuplicate => '号码重复';

  @override
  String get contactDeletePhone => '删除号码';

  @override
  String get contactAlternateLabel => '备用';

  @override
  String contactsSelectedCount(int selected, int total) {
    return '已选择 $selected / $total';
  }

  @override
  String get contactsClearSelection => '取消选择';

  @override
  String get contactsSearchHint => '搜索姓名、号码、公司或备注';

  @override
  String get contactsClearSearch => '清空搜索';

  @override
  String get contactsAdd => '新建联系人';

  @override
  String contactsVisibleCount(int visible, int total) {
    return '当前 $visible / 共 $total 位';
  }

  @override
  String contactsTotalCount(int total) {
    return '共 $total 位联系人';
  }

  @override
  String get contactsNoMatches => '没有匹配的联系人';

  @override
  String get contactsEmpty => '暂无联系人';

  @override
  String get contactsNoMatchesHint => '换个关键词再试试';

  @override
  String get contactsEmptyHint => '创建联系人后即可快速外呼';

  @override
  String get contactsResetSearch => '重置搜索';

  @override
  String get contactsColumnContact => '联系人';

  @override
  String get contactsColumnOrganization => '公司';

  @override
  String get contactsColumnUpdated => '更新时间';

  @override
  String get contactsColumnActions => '操作';

  @override
  String get contactsMoreActions => '更多操作';

  @override
  String get contactNoAvailableDialLine => '没有可用拨号线路，请先注册线路';

  @override
  String get contactNoCallableNumber => '联系人没有可呼叫号码';

  @override
  String get contactAddLineFirst => '请先添加电话线路';

  @override
  String get contactNetworkUnavailable => '当前网络不可用，暂时无法呼叫';

  @override
  String get contactConferenceCallBlocked => '会议通话中，暂时无法呼叫联系人';

  @override
  String get contactCallLimitReached => '当前通话已达 4 路上限';

  @override
  String get contactNotProvided => '未填写';

  @override
  String get contactConfirmCallTitle => '确认呼叫';

  @override
  String get contactDialLine => '拨号线路';

  @override
  String get contactCreatedToast => '联系人已创建';

  @override
  String get contactUpdatedToast => '联系人已更新';

  @override
  String get contactDuplicateTitle => '号码重复';

  @override
  String contactDuplicateNumberMessage(String number) {
    return '号码 $number 已属于现有联系人。';
  }

  @override
  String get contactDuplicateExplanation =>
      '为避免通话归属混乱，联系人号码需要保持唯一。请查看已有联系人后再编辑。';

  @override
  String get contactViewExisting => '查看已有联系人';

  @override
  String get contactExistingLocated => '已定位到已有联系人';

  @override
  String get contactDeleteTitle => '删除联系人';

  @override
  String contactDeleteQuestion(String name) {
    return '确定删除 $name？此操作不可撤销。';
  }

  @override
  String get contactDeletedToast => '联系人已删除';

  @override
  String get contactBulkDeleteTitle => '批量删除';

  @override
  String contactBulkDeleteQuestion(int count) {
    return '确定删除已选的 $count 位联系人？此操作不可撤销。';
  }

  @override
  String contactBulkDeleteConfirm(int count) {
    return '删除 $count 位';
  }

  @override
  String contactBulkDeletedToast(int count) {
    return '已删除 $count 位联系人';
  }

  @override
  String get contactSelectForDetails => '选择联系人查看详情';

  @override
  String get contactDefaultPhone => '默认号码';

  @override
  String get contactCreatedAt => '创建时间';

  @override
  String get contactUpdatedAt => '更新时间';

  @override
  String get contactRecentCalls => '最近通话';

  @override
  String get contactNoCallHistory => '暂无通话记录';

  @override
  String get contactOpenPage => '打开联系人页';

  @override
  String get historySearchPlaceholder => '搜索通话';

  @override
  String get historySearchHint => '搜索号码、客户、线路、备注';

  @override
  String get historyClearSearch => '清除搜索';

  @override
  String get historyFilterAll => '全部';

  @override
  String get historyFilterOutbound => '呼出';

  @override
  String get historyFilterInbound => '来电';

  @override
  String get historyFilterMissed => '未接';

  @override
  String get historyFilterByDate => '按时间筛选';

  @override
  String get historyDateAll => '全部时间';

  @override
  String get historyDateToday => '今天';

  @override
  String get historyDateLast7Days => '近 7 天';

  @override
  String get historyDateThisMonth => '本月';

  @override
  String historyMarkAllReadCount(int count) {
    return '全部已读 ($count)';
  }

  @override
  String historyRecordCount(int count) {
    return '$count 条';
  }

  @override
  String get historyClearRecords => '清空通话记录';

  @override
  String get historyEmpty => '暂无通话记录';

  @override
  String get historyNoMatches => '没有匹配的通话记录';

  @override
  String get historyColumnCustomer => '客户';

  @override
  String get historyColumnLine => '线路';

  @override
  String get historyColumnStatus => '状态';

  @override
  String get historyColumnDuration => '时长';

  @override
  String get historyColumnTime => '时间';

  @override
  String get historyColumnActions => '操作';

  @override
  String get historyUnknownLine => '未知线路';

  @override
  String get historyDeleteRecord => '删除记录';

  @override
  String get historyCannotDeleteActive => '进行中的通话不能删除';

  @override
  String get historyCannotCallBackActive => '进行中的通话不能回拨';

  @override
  String get historyCallBack => '回拨';

  @override
  String get historyLive => '实时';

  @override
  String get historyHasNoteTooltip => '有备注，点击记录查看';

  @override
  String get historyLoadingMore => '正在加载更多';

  @override
  String historyLoadMoreCount(int count) {
    return '加载更多 · 已显示 $count 条';
  }

  @override
  String get historyNoMore => '没有更多历史记录';

  @override
  String historyAllShownCount(int count) {
    return '已显示全部 $count 条历史记录';
  }

  @override
  String get historyStatusOnHold => '保持中';

  @override
  String get historyStatusRemoteOnHold => '对方保持';

  @override
  String get historyStatusInCall => '通话中';

  @override
  String get historyStatusRinging => '响铃中';

  @override
  String get historyStatusRemoteRinging => '对方振铃';

  @override
  String get historyStatusCalling => '呼叫中';

  @override
  String get historyStatusTiming => '计时中';

  @override
  String get historyGroupToday => '今天';

  @override
  String get historyGroupYesterday => '昨天';

  @override
  String get historyMarkAllReadTitle => '将未接来电标记为已读？';

  @override
  String historyMarkAllReadBody(int count) {
    return '将 $count 条未读未接来电标记为已读。';
  }

  @override
  String get historyMarkAllReadConfirm => '全部标记为已读';

  @override
  String get historyConfirmCallbackTitle => '回拨此号码？';

  @override
  String get historyDialLine => '拨号线路';

  @override
  String get historyConfirmCallback => '回拨';

  @override
  String get historyDeleteTitle => '删除这条通话记录？';

  @override
  String get historyFieldNumber => '号码';

  @override
  String get historyFieldLine => '线路';

  @override
  String get historyDeleteBody => '删除后无法恢复。';

  @override
  String get historyDeleteConfirm => '删除';

  @override
  String get historyClearTitle => '清空通话记录？';

  @override
  String get historyClearBody => '此操作无法撤销。进行中的通话不会被清除。';

  @override
  String get historyClearConfirm => '清空';

  @override
  String get historyClearError => '暂时无法清空通话记录，请稍后重试。';

  @override
  String get historyCannotRedialActive => '通话正在进行，无需重复回拨。';

  @override
  String get historyNoCallbackNumber => '此记录没有可回拨的号码。';

  @override
  String get historyNetworkUnavailable => '网络不可用，请恢复连接后重试。';

  @override
  String get historyAddLineFirst => '请先添加电话线路。';

  @override
  String get historyCallLimitReached => '已达到 4 路通话上限。';

  @override
  String get historySplitConferenceFirst => '请先结束或拆分会议通话。';

  @override
  String get historyNoRegisteredLine => '没有可用的已注册线路。';

  @override
  String get historySwitchDetailHint => '选择左侧其他记录切换详情';

  @override
  String get historyContactDeleted => '原联系人已删除，可重新添加';

  @override
  String get historyFieldContact => '联系人';

  @override
  String get historyFieldDirection => '方向';

  @override
  String get historyFieldStatus => '状态';

  @override
  String get historyFieldCalledAt => '呼叫时间';

  @override
  String get historyFieldAnsweredAt => '接通时间';

  @override
  String get historyFieldEndedAt => '挂断时间';

  @override
  String get historyFieldDuration => '通话时长';

  @override
  String get historyFieldEndReason => '结束原因';

  @override
  String get historyNotAnswered => '未接通';

  @override
  String get historyInProgress => '进行中';

  @override
  String get historyStatsTitle => '通话统计';

  @override
  String get historyMetricDialToRing => '拨号到响铃';

  @override
  String get historyMetricRingingDuration => '响铃时长';

  @override
  String get historyMetricRingToAnswer => '响铃到接听';

  @override
  String get historyMetricMediaReady => '语音建立';

  @override
  String get historyMetricHoldCount => '保持次数';

  @override
  String get historyMetricHoldDuration => '累计保持';

  @override
  String historyTimes(int count) {
    return '$count 次';
  }

  @override
  String get historyImmediate => '即时';

  @override
  String historySeconds(String value) {
    return '$value 秒';
  }

  @override
  String get historyAddNote => '添加备注';

  @override
  String get historyNote => '通话备注';

  @override
  String get historyEditNote => '编辑备注';

  @override
  String get historyEditNoteTitle => '编辑通话备注';

  @override
  String get historyNoteHint => '记录本次沟通重点';

  @override
  String get historyNoteSaveError => '保存通话备注失败，请稍后重试';

  @override
  String historyNoteBlindTransferTo(String target) {
    return '盲转至：$target';
  }

  @override
  String historyNoteConference(String note) {
    return '会议备注：$note';
  }

  @override
  String historyNoteCustomer(String note) {
    return '客户备注：$note';
  }

  @override
  String get historyDetailTitle => '通话详情';

  @override
  String get historyViewContact => '查看联系人';

  @override
  String get historyReAddContact => '重新添加联系人';

  @override
  String get historyAddContact => '添加联系人';

  @override
  String get historyRecentCalls => '最近通话';

  @override
  String get historyNoRecentCalls => '暂无最近通话';

  @override
  String historyCallbackNumber(String number) {
    return '回拨 $number';
  }

  @override
  String historyYesterdayAt(String time) {
    return '昨天 $time';
  }

  @override
  String get historyLoadMoreError => '暂时无法加载更多通话记录，请稍后重试。';

  @override
  String get historyStatusPeerRejected => '对方拒接';

  @override
  String get historyReasonCallEnded => '通话已结束';

  @override
  String get historyReasonIncomingEnded => '来电已结束';

  @override
  String get historyReasonAuthenticationFailed => '账号认证失败';

  @override
  String get historyReasonRemoteRejected => '对方已拒接';

  @override
  String get historyReasonCallRejected => '呼叫被拒绝';

  @override
  String get historyReasonInvalidNumber => '号码不存在或无法接通';

  @override
  String get historyReasonNoAnswer => '无人接听';

  @override
  String get historyReasonTimeout => '呼叫超时';

  @override
  String get historyReasonRemoteUnavailable => '对方无法接通';

  @override
  String get historyReasonRingingUnanswered => '响铃未接';

  @override
  String get historyReasonRemoteBusy => '对方忙线';

  @override
  String get historyReasonCanceled => '呼叫已取消';

  @override
  String get historyReasonUnsupportedMedia => '对方不支持本次通话';

  @override
  String get historyReasonServiceUnavailable => '电话服务暂时不可用';

  @override
  String get historyReasonRedirected => '呼叫已转移或重定向';

  @override
  String get historyReasonCallIncomplete => '呼叫未完成';

  @override
  String get historyReasonServiceError => '电话服务异常';

  @override
  String get historyReasonRemoteCannotAnswer => '对方无法接听';

  @override
  String get historyReasonNotConnected => '未接通';

  @override
  String get historyReasonMediaFailed => '媒体协商失败';

  @override
  String get historyReasonBlindTransfer => '已盲转';

  @override
  String get historyReasonShortAuthenticationFailed => '认证失败';

  @override
  String get historyReasonShortRemoteRejected => '对方拒接';

  @override
  String get historyReasonShortInvalidNumber => '号码无效';

  @override
  String get historyReasonShortServiceError => '服务异常';

  @override
  String get historyReasonShortRedirected => '已转移';

  @override
  String get historyReasonShortMediaFailed => '媒体失败';

  @override
  String get historyReasonShortBlindTransfer => '已盲转';

  @override
  String historyReasonWithSipCode(String reason, int code) {
    return '$reason（SIP $code）';
  }
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
  String get commonSave => '儲存';

  @override
  String get commonClose => '關閉';

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

  @override
  String get contactNewTitle => '新增聯絡人';

  @override
  String get contactEditTitle => '編輯聯絡人';

  @override
  String get contactDetailsTitle => '客戶資料';

  @override
  String get contactName => '姓名';

  @override
  String get contactNameRequired => '請輸入姓名';

  @override
  String get contactCompany => '公司';

  @override
  String get contactDepartment => '部門';

  @override
  String get contactNotes => '備註';

  @override
  String get contactPriority => '設為重點聯絡人';

  @override
  String get contactPrioritySet => '設為重點';

  @override
  String get contactPriorityUnset => '取消重點';

  @override
  String get contactPriorityBadge => '重點';

  @override
  String get contactSave => '儲存';

  @override
  String get contactDelete => '刪除';

  @override
  String get contactEdit => '編輯';

  @override
  String get contactCall => '致電';

  @override
  String get contactClose => '關閉';

  @override
  String get contactPhone => '號碼';

  @override
  String get contactPhones => '電話號碼';

  @override
  String get contactAddPhone => '新增號碼';

  @override
  String get contactPhoneLabel => '標籤';

  @override
  String get contactPhoneRequired => '請輸入號碼';

  @override
  String get contactPhoneInvalid => '號碼只可包含數字及常用電話符號';

  @override
  String get contactPhoneDuplicate => '號碼重複';

  @override
  String get contactDeletePhone => '刪除號碼';

  @override
  String get contactAlternateLabel => '備用';

  @override
  String contactsSelectedCount(int selected, int total) {
    return '已選取 $selected / $total';
  }

  @override
  String get contactsClearSelection => '取消選取';

  @override
  String get contactsSearchHint => '搜尋姓名、號碼、公司或備註';

  @override
  String get contactsClearSearch => '清除搜尋';

  @override
  String get contactsAdd => '新增聯絡人';

  @override
  String contactsVisibleCount(int visible, int total) {
    return '目前 $visible / 共 $total 位';
  }

  @override
  String contactsTotalCount(int total) {
    return '共 $total 位聯絡人';
  }

  @override
  String get contactsNoMatches => '找不到相符的聯絡人';

  @override
  String get contactsEmpty => '暫無聯絡人';

  @override
  String get contactsNoMatchesHint => '請嘗試其他關鍵字';

  @override
  String get contactsEmptyHint => '新增聯絡人後即可快速致電';

  @override
  String get contactsResetSearch => '重設搜尋';

  @override
  String get contactsColumnContact => '聯絡人';

  @override
  String get contactsColumnOrganization => '公司';

  @override
  String get contactsColumnUpdated => '更新時間';

  @override
  String get contactsColumnActions => '操作';

  @override
  String get contactsMoreActions => '更多操作';

  @override
  String get contactNoAvailableDialLine => '沒有可用撥號線路，請先註冊線路';

  @override
  String get contactNoCallableNumber => '聯絡人沒有可致電號碼';

  @override
  String get contactAddLineFirst => '請先新增電話線路';

  @override
  String get contactNetworkUnavailable => '目前網絡不可用，暫時無法致電';

  @override
  String get contactConferenceCallBlocked => '會議通話中，暫時無法致電聯絡人';

  @override
  String get contactCallLimitReached => '目前通話已達 4 路上限';

  @override
  String get contactNotProvided => '未填寫';

  @override
  String get contactConfirmCallTitle => '確認致電';

  @override
  String get contactDialLine => '撥號線路';

  @override
  String get contactCreatedToast => '聯絡人已建立';

  @override
  String get contactUpdatedToast => '聯絡人已更新';

  @override
  String get contactDuplicateTitle => '號碼重複';

  @override
  String contactDuplicateNumberMessage(String number) {
    return '號碼 $number 已屬於現有聯絡人。';
  }

  @override
  String get contactDuplicateExplanation =>
      '為免通話歸屬混亂，聯絡人號碼必須保持唯一。請先查看現有聯絡人再作編輯。';

  @override
  String get contactViewExisting => '查看現有聯絡人';

  @override
  String get contactExistingLocated => '已找到現有聯絡人';

  @override
  String get contactDeleteTitle => '刪除聯絡人';

  @override
  String contactDeleteQuestion(String name) {
    return '確定要刪除 $name？此操作無法復原。';
  }

  @override
  String get contactDeletedToast => '聯絡人已刪除';

  @override
  String get contactBulkDeleteTitle => '批量刪除';

  @override
  String contactBulkDeleteQuestion(int count) {
    return '確定要刪除已選取的 $count 位聯絡人？此操作無法復原。';
  }

  @override
  String contactBulkDeleteConfirm(int count) {
    return '刪除 $count 位';
  }

  @override
  String contactBulkDeletedToast(int count) {
    return '已刪除 $count 位聯絡人';
  }

  @override
  String get contactSelectForDetails => '選擇聯絡人以查看詳情';

  @override
  String get contactDefaultPhone => '預設號碼';

  @override
  String get contactCreatedAt => '建立時間';

  @override
  String get contactUpdatedAt => '更新時間';

  @override
  String get contactRecentCalls => '最近通話';

  @override
  String get contactNoCallHistory => '暫無通話記錄';

  @override
  String get contactOpenPage => '開啟聯絡人頁面';

  @override
  String get historySearchPlaceholder => '搜尋通話';

  @override
  String get historySearchHint => '搜尋號碼、客戶、線路、備註';

  @override
  String get historyClearSearch => '清除搜尋';

  @override
  String get historyFilterAll => '全部';

  @override
  String get historyFilterOutbound => '撥出';

  @override
  String get historyFilterInbound => '來電';

  @override
  String get historyFilterMissed => '未接';

  @override
  String get historyFilterByDate => '按時間篩選';

  @override
  String get historyDateAll => '全部時間';

  @override
  String get historyDateToday => '今日';

  @override
  String get historyDateLast7Days => '近 7 日';

  @override
  String get historyDateThisMonth => '本月';

  @override
  String historyMarkAllReadCount(int count) {
    return '全部已讀 ($count)';
  }

  @override
  String historyRecordCount(int count) {
    return '$count 條';
  }

  @override
  String get historyClearRecords => '清除通話記錄';

  @override
  String get historyEmpty => '暫無通話記錄';

  @override
  String get historyNoMatches => '沒有相符的通話記錄';

  @override
  String get historyColumnCustomer => '客戶';

  @override
  String get historyColumnLine => '線路';

  @override
  String get historyColumnStatus => '狀態';

  @override
  String get historyColumnDuration => '時長';

  @override
  String get historyColumnTime => '時間';

  @override
  String get historyColumnActions => '操作';

  @override
  String get historyUnknownLine => '未知線路';

  @override
  String get historyDeleteRecord => '刪除記錄';

  @override
  String get historyCannotDeleteActive => '進行中的通話不能刪除';

  @override
  String get historyCannotCallBackActive => '進行中的通話不能回撥';

  @override
  String get historyCallBack => '回撥';

  @override
  String get historyLive => '即時';

  @override
  String get historyHasNoteTooltip => '已有備註，按一下記錄查看';

  @override
  String get historyLoadingMore => '正在載入更多';

  @override
  String historyLoadMoreCount(int count) {
    return '載入更多 · 已顯示 $count 條';
  }

  @override
  String get historyNoMore => '沒有更多通話記錄';

  @override
  String historyAllShownCount(int count) {
    return '已顯示全部 $count 條通話記錄';
  }

  @override
  String get historyStatusOnHold => '保持中';

  @override
  String get historyStatusRemoteOnHold => '對方保持';

  @override
  String get historyStatusInCall => '通話中';

  @override
  String get historyStatusRinging => '響鈴中';

  @override
  String get historyStatusRemoteRinging => '對方響鈴';

  @override
  String get historyStatusCalling => '撥號中';

  @override
  String get historyStatusTiming => '計時中';

  @override
  String get historyGroupToday => '今日';

  @override
  String get historyGroupYesterday => '昨日';

  @override
  String get historyMarkAllReadTitle => '將未接來電標示為已讀？';

  @override
  String historyMarkAllReadBody(int count) {
    return '將 $count 條未讀未接來電標示為已讀。';
  }

  @override
  String get historyMarkAllReadConfirm => '全部標示為已讀';

  @override
  String get historyConfirmCallbackTitle => '回撥此號碼？';

  @override
  String get historyDialLine => '撥號線路';

  @override
  String get historyConfirmCallback => '回撥';

  @override
  String get historyDeleteTitle => '刪除此通話記錄？';

  @override
  String get historyFieldNumber => '號碼';

  @override
  String get historyFieldLine => '線路';

  @override
  String get historyDeleteBody => '刪除後無法復原。';

  @override
  String get historyDeleteConfirm => '刪除';

  @override
  String get historyClearTitle => '清除通話記錄？';

  @override
  String get historyClearBody => '此操作無法復原。進行中的通話不會被清除。';

  @override
  String get historyClearConfirm => '清除';

  @override
  String get historyClearError => '暫時無法清除通話記錄，請稍後再試。';

  @override
  String get historyCannotRedialActive => '通話正在進行，無需重複回撥。';

  @override
  String get historyNoCallbackNumber => '此記錄沒有可回撥的號碼。';

  @override
  String get historyNetworkUnavailable => '網絡不可用，請恢復連線後再試。';

  @override
  String get historyAddLineFirst => '請先新增電話線路。';

  @override
  String get historyCallLimitReached => '已達 4 路通話上限。';

  @override
  String get historySplitConferenceFirst => '請先結束或拆分會議通話。';

  @override
  String get historyNoRegisteredLine => '沒有可用的已註冊線路。';

  @override
  String get historySwitchDetailHint => '選擇左側其他記錄以切換詳情';

  @override
  String get historyContactDeleted => '原聯絡人已刪除，可重新新增';

  @override
  String get historyFieldContact => '聯絡人';

  @override
  String get historyFieldDirection => '方向';

  @override
  String get historyFieldStatus => '狀態';

  @override
  String get historyFieldCalledAt => '撥號時間';

  @override
  String get historyFieldAnsweredAt => '接聽時間';

  @override
  String get historyFieldEndedAt => '結束時間';

  @override
  String get historyFieldDuration => '通話時長';

  @override
  String get historyFieldEndReason => '結束原因';

  @override
  String get historyNotAnswered => '未接通';

  @override
  String get historyInProgress => '進行中';

  @override
  String get historyStatsTitle => '通話統計';

  @override
  String get historyMetricDialToRing => '撥號至響鈴';

  @override
  String get historyMetricRingingDuration => '響鈴時長';

  @override
  String get historyMetricRingToAnswer => '響鈴至接聽';

  @override
  String get historyMetricMediaReady => '語音建立';

  @override
  String get historyMetricHoldCount => '保持次數';

  @override
  String get historyMetricHoldDuration => '累計保持';

  @override
  String historyTimes(int count) {
    return '$count 次';
  }

  @override
  String get historyImmediate => '即時';

  @override
  String historySeconds(String value) {
    return '$value 秒';
  }

  @override
  String get historyAddNote => '新增備註';

  @override
  String get historyNote => '通話備註';

  @override
  String get historyEditNote => '編輯備註';

  @override
  String get historyEditNoteTitle => '編輯通話備註';

  @override
  String get historyNoteHint => '記錄本次溝通重點';

  @override
  String get historyNoteSaveError => '無法儲存通話備註，請稍後再試';

  @override
  String historyNoteBlindTransferTo(String target) {
    return '盲轉至：$target';
  }

  @override
  String historyNoteConference(String note) {
    return '會議備註：$note';
  }

  @override
  String historyNoteCustomer(String note) {
    return '客戶備註：$note';
  }

  @override
  String get historyDetailTitle => '通話詳情';

  @override
  String get historyViewContact => '查看聯絡人';

  @override
  String get historyReAddContact => '重新新增聯絡人';

  @override
  String get historyAddContact => '新增聯絡人';

  @override
  String get historyRecentCalls => '最近通話';

  @override
  String get historyNoRecentCalls => '暫無最近通話';

  @override
  String historyCallbackNumber(String number) {
    return '回撥 $number';
  }

  @override
  String historyYesterdayAt(String time) {
    return '昨日 $time';
  }

  @override
  String get historyLoadMoreError => '暫時無法載入更多通話記錄，請稍後再試。';

  @override
  String get historyStatusPeerRejected => '對方拒接';

  @override
  String get historyReasonCallEnded => '通話已結束';

  @override
  String get historyReasonIncomingEnded => '來電已結束';

  @override
  String get historyReasonAuthenticationFailed => '帳戶認證失敗';

  @override
  String get historyReasonRemoteRejected => '對方已拒接';

  @override
  String get historyReasonCallRejected => '通話被拒絕';

  @override
  String get historyReasonInvalidNumber => '號碼不存在或無法接通';

  @override
  String get historyReasonNoAnswer => '無人接聽';

  @override
  String get historyReasonTimeout => '通話逾時';

  @override
  String get historyReasonRemoteUnavailable => '對方無法接通';

  @override
  String get historyReasonRingingUnanswered => '響鈴未接';

  @override
  String get historyReasonRemoteBusy => '對方忙線';

  @override
  String get historyReasonCanceled => '通話已取消';

  @override
  String get historyReasonUnsupportedMedia => '對方不支援本次通話';

  @override
  String get historyReasonServiceUnavailable => '電話服務暫時不可用';

  @override
  String get historyReasonRedirected => '通話已轉駁或重新導向';

  @override
  String get historyReasonCallIncomplete => '通話未完成';

  @override
  String get historyReasonServiceError => '電話服務異常';

  @override
  String get historyReasonRemoteCannotAnswer => '對方無法接聽';

  @override
  String get historyReasonNotConnected => '未接通';

  @override
  String get historyReasonMediaFailed => '媒體協商失敗';

  @override
  String get historyReasonBlindTransfer => '已盲轉';

  @override
  String get historyReasonShortAuthenticationFailed => '認證失敗';

  @override
  String get historyReasonShortRemoteRejected => '對方拒接';

  @override
  String get historyReasonShortInvalidNumber => '號碼無效';

  @override
  String get historyReasonShortServiceError => '服務異常';

  @override
  String get historyReasonShortRedirected => '已轉駁';

  @override
  String get historyReasonShortMediaFailed => '媒體失敗';

  @override
  String get historyReasonShortBlindTransfer => '已盲轉';

  @override
  String historyReasonWithSipCode(String reason, int code) {
    return '$reason（SIP $code）';
  }
}
