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
  String get contactNewTitle => '新建';

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
  String get contactsAdd => '新建';

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

  @override
  String get activeCallEmpty => '暂无进行中的通话';

  @override
  String get activeCallGoToDialpad => '前往拨号';

  @override
  String get activeCallAnswer => '接听';

  @override
  String get activeCallReject => '拒接';

  @override
  String get activeCallMute => '静音';

  @override
  String get activeCallUnmute => '取消静音';

  @override
  String get activeCallKeypad => '键盘';

  @override
  String get activeCallHold => '保持';

  @override
  String get activeCallResume => '恢复';

  @override
  String get activeCallTransfer => '转接';

  @override
  String get activeCallMuteRemoteAudio => '静音对方';

  @override
  String get activeCallRestoreRemoteAudio => '恢复对方';

  @override
  String get activeCallAudio => '音频';

  @override
  String get activeCallHangUp => '挂断';

  @override
  String get activeCallHangUpAll => '全部挂断';

  @override
  String get activeCallMerge => '合并';

  @override
  String get activeCallSplit => '拆分';

  @override
  String get activeCallResumeConference => '恢复会议';

  @override
  String get activeCallOperationAnswering => '正在接听';

  @override
  String get activeCallOperationRejecting => '正在拒接';

  @override
  String get activeCallOperationEnding => '正在挂断';

  @override
  String get activeCallOperationHolding => '正在保持';

  @override
  String get activeCallOperationResuming => '正在恢复';

  @override
  String get activeCallOperationSplitting => '正在拆分';

  @override
  String get activeCallOperationMerging => '正在合并';

  @override
  String get activeCallOperationTransferring => '正在转接';

  @override
  String get activeCallStatusLocalHold => '保持中';

  @override
  String get activeCallStatusRemoteHold => '对方保持';

  @override
  String get activeCallStatusCalling => '正在呼叫';

  @override
  String get activeCallStatusIncoming => '来电';

  @override
  String get activeCallStatusWaitingAnswer => '等待接听';

  @override
  String get activeCallStatusRemoteRinging => '对方振铃';

  @override
  String get activeCallStatusConnecting => '正在接通';

  @override
  String get activeCallStatusInCall => '通话中';

  @override
  String get activeCallStatusEnded => '通话已结束';

  @override
  String activeCallStatusUnknown(int state) {
    return '未知状态 ($state)';
  }

  @override
  String activeCallHeldLocallyFor(String duration) {
    return '本机保持 · $duration';
  }

  @override
  String activeCallHeldByRemoteFor(String duration) {
    return '对方保持 · $duration';
  }

  @override
  String get activeCallPriorityContact => '重点客户';

  @override
  String get activeCallOperationInProgress => '操作进行中';

  @override
  String get activeCallDuration => '通话时长';

  @override
  String get activeCallCurrentStatus => '当前状态';

  @override
  String get activeCallMediaConnected => '媒体已连接';

  @override
  String get activeCallMediaLocalHold => '本地保持';

  @override
  String get activeCallMediaRemoteHold => '对方保持';

  @override
  String get activeCallMediaError => '媒体异常';

  @override
  String get activeCallMediaNotReady => '媒体未建立';

  @override
  String get activeCallMediaPending => '媒体待建立';

  @override
  String get activeCallMediaUnconfirmed => '媒体未确认';

  @override
  String activeCallMediaUnknown(int status) {
    return '媒体状态 $status';
  }

  @override
  String get activeCallSignalingUnknown => '信令未知';

  @override
  String activeCallConfiguredMode(String mode) {
    return '$mode 配置';
  }

  @override
  String get activeCallMedia => '媒体';

  @override
  String get activeCallSignaling => '信令';

  @override
  String get activeCallMediaEncryption => '媒体加密';

  @override
  String get activeCallTlsEncrypted => 'TLS 加密';

  @override
  String get activeCallSrtpNegotiated => 'SRTP 已协商';

  @override
  String get activeCallSrtpNotDetected => '未检测到 SRTP';

  @override
  String get activeCallMediaNegotiating => '等待媒体协商';

  @override
  String get activeCallEncryptedCall => '通话已加密';

  @override
  String get activeCallEncryptedAudio => '语音已加密';

  @override
  String get activeCallStandardCall => '标准通话';

  @override
  String get activeCallVerifyingEncryption => '正在确认加密';

  @override
  String activeCallLabeledValue(String label, String value) {
    return '$label：$value';
  }

  @override
  String activeCallValueDetail(String value, String detail) {
    return '$value（$detail）';
  }

  @override
  String get activeCallTransport => '传输协议';

  @override
  String get activeCallTransferTitle => '直接转接通话';

  @override
  String get activeCallTransferDescription => '通话将立即转接到目标号码，你将退出本次通话。';

  @override
  String get activeCallCurrentLineUnknown => '当前线路未知';

  @override
  String get activeCallTransferTargetHint => '输入号码或 SIP URI';

  @override
  String activeCallTransferTargetExample(String host) {
    return '例如 6545 或 sip:6545@$host';
  }

  @override
  String get activeCallChooseContact => '从联系人选择';

  @override
  String activeCallNumberCount(int count) {
    return '$count 个号码';
  }

  @override
  String get activeCallTransferSearchHint => '搜索联系人、号码或公司';

  @override
  String get activeCallEnterTransferNumber => '输入转接号码';

  @override
  String get activeCallConfirmTransfer => '确认转接';

  @override
  String get activeCallNoContacts => '暂无联系人';

  @override
  String get activeCallNoContactMatches => '没有匹配的联系人';

  @override
  String get activeCallUnnamedContact => '未命名联系人';

  @override
  String get activeCallViewingConferenceMember => '正在查看会议成员';

  @override
  String get activeCallCurrentActiveCall => '当前活动通话';

  @override
  String get activeCallViewingCall => '正在查看此通话';

  @override
  String activeCallResumeForAudio(String name) {
    return '$name · 点击恢复以接入声音';
  }

  @override
  String activeCallConferenceInterrupted(int count) {
    return '会议已自动保持。处理完当前通话后，可恢复 $count 位会议成员。';
  }

  @override
  String get activeCallConferenceTitle => '会议通话';

  @override
  String get activeCallConferencePaused => '会议已暂停';

  @override
  String get activeCallConferenceInProgress => '会议中';

  @override
  String get activeCallConferenceStatus => '会议状态';

  @override
  String get activeCallConferenceDuration => '会议时长';

  @override
  String get activeCallPaused => '已暂停';

  @override
  String activeCallMemberCount(int count) {
    return '$count 位成员';
  }

  @override
  String activeCallCustomerCount(int count) {
    return '$count 位客户';
  }

  @override
  String activeCallLineCount(int count) {
    return '$count 条线路';
  }

  @override
  String get activeCallPanelConferenceMembers => '会议成员';

  @override
  String get activeCallPanelCurrentCalls => '当前通话';

  @override
  String activeCallPanelCount(int current, int total) {
    return '$current/$total 路';
  }

  @override
  String get activeCallNewIncomingAndOthers => '新来电与其他通话';

  @override
  String get activeCallOtherCalls => '其他通话';

  @override
  String get activeCallNoActiveCalls => '没有活动通话';

  @override
  String get activeCallCustomerInfo => '客户信息';

  @override
  String get activeCallConferenceCustomers => '会议客户';

  @override
  String get activeCallConferenceCustomersDescription => '已加入会议的客户';

  @override
  String get activeCallUnmatchedContact => '未匹配联系人';

  @override
  String get activeCallUnknownNumber => '未知号码';

  @override
  String get activeCallAddContact => '添加到联系人';

  @override
  String get activeCallViewContact => '查看联系人';

  @override
  String get activeCallDefaultNumber => '默认号码';

  @override
  String get activeCallCustomer => '通话客户';

  @override
  String get activeCallViewContactDetails => '查看联系人详情';

  @override
  String get activeCallCurrentNumber => '当前号码';

  @override
  String get activeCallCurrentNote => '当前通话备注';

  @override
  String get activeCallNoteHint => '记录沟通重点，挂断后将保存到通话记录';

  @override
  String get activeCallConferenceNote => '本次会议备注';

  @override
  String activeCallNoteSyncMembers(int count) {
    return '同步到 $count 位会议成员';
  }

  @override
  String activeCallNoteSavePrimary(String name) {
    return '仅保存到会议主记录：$name';
  }

  @override
  String get activeCallCustomerNote => '当前客户备注';

  @override
  String get activeCallSharedConferenceNote => '会议共享备注';

  @override
  String get activeCallSharedNoteHint => '记录会议结论，并保存到每位成员的通话记录';

  @override
  String get activeCallCustomerNoteHint => '记录当前客户重点，仅保存到会议主记录';

  @override
  String get activeCallNoteStaged => '已暂存';

  @override
  String get activeCallNoteEmpty => '未填写';

  @override
  String get activeCallNoteStagedTooltip => '备注已暂存，挂断后将写入通话记录';

  @override
  String get activeCallNoteEmptyTooltip => '填写后自动暂存，挂断后写入通话记录';

  @override
  String get activeCallViewing => '查看中';

  @override
  String get activeCallRemoteAudioMuted => '声音已关闭';

  @override
  String get activeCallDtmfWaiting => '等待输入';

  @override
  String get activeCallDtmfTitle => 'DTMF 键盘';

  @override
  String get activeCallDtmfClose => '关闭键盘';

  @override
  String activeCallDtmfSending(String digit) {
    return '正在发送 $digit';
  }

  @override
  String activeCallDtmfSent(String digit) {
    return '已发送 $digit';
  }

  @override
  String activeCallDtmfFailed(String digit) {
    return '$digit 发送失败';
  }

  @override
  String get activeCallMyAudio => '麦克风';

  @override
  String get activeCallRemoteAudio => '扬声器';

  @override
  String activeCallMutedValue(String label) {
    return '$label：已静音';
  }

  @override
  String activeCallVolumeValue(int volume) {
    return '，音量 $volume%';
  }

  @override
  String activeCallMeterMuted(String label, String volume) {
    return '$label：已静音$volume';
  }

  @override
  String activeCallMeterValues(
    String label,
    int current,
    int peak,
    String volume,
  ) {
    return '$label：当前 $current%，峰值 $peak%$volume';
  }

  @override
  String get audioAddLine => '添加线路';

  @override
  String get audioSoundAlerts => '声音提示';

  @override
  String get audioIncomingRingtone => '来电铃声';

  @override
  String get audioIncomingRingtoneDescription => '有新来电时播放铃声';

  @override
  String get audioOutgoingRingback => '外呼回铃音';

  @override
  String get audioOutgoingRingbackDescription => '拨号后等待对方接听时播放';

  @override
  String get audioCallEndedTone => '通话结束提示音';

  @override
  String get audioCallEndedToneDescription => '已接通的通话结束时播放';

  @override
  String get audioDialpadTones => '拨号按键音';

  @override
  String get audioDialpadTonesDescription => '拨号盘输入时播放按键音，默认关闭';

  @override
  String get audioRouting => '音频路由';

  @override
  String get audioFollowSystem => '跟随系统';

  @override
  String get audioChooseDevices => '指定设备';

  @override
  String get audioFollowSystemDescription => '推荐使用。插拔耳机时自动跟随系统声音设置';

  @override
  String get audioChooseDevicesDescription => '选择应用使用的设备；系统限制可能影响实际音频路由';

  @override
  String get audioAutoSwitch => '设备变化时自动切换';

  @override
  String get audioAutoSwitchDescription => '通话中插拔耳机时，自动恢复可用的音频路径';

  @override
  String get audioInputOutput => '输入与输出';

  @override
  String get audioMicrophone => '麦克风';

  @override
  String get audioInputDevice => '输入设备';

  @override
  String get audioSpeaker => '扬声器';

  @override
  String get audioOutputDevice => '输出设备';

  @override
  String get audioSystemDefaultInput => '跟随系统输入';

  @override
  String get audioSystemDefaultOutput => '跟随系统输出';

  @override
  String get audioDeviceNotSelected => '未选择';

  @override
  String get audioDeviceUnavailable => '设备不可用';

  @override
  String audioRecordingRemaining(int seconds) {
    return '录音中 $seconds 秒';
  }

  @override
  String get audioRecording => '录音中';

  @override
  String get audioPreparingPlayback => '准备播放';

  @override
  String get audioPlaying => '播放中';

  @override
  String get audioRecordingTest => '录音测试';

  @override
  String get audioTestOutput => '测试扬声器';

  @override
  String get audioMute => '静音';

  @override
  String get audioUnmute => '取消静音';

  @override
  String get audioTesting => '测试中';

  @override
  String get audioReady => '就绪';

  @override
  String get audioDeviceNeedsAttention => '音频设备需要处理';

  @override
  String get audioFollowingSystem => '跟随系统声音';

  @override
  String get audioUsingSelectedDevices => '使用指定设备';

  @override
  String get audioFollowingSystemStatus => '输入和输出跟随系统声音设置';

  @override
  String get audioUsingSelectedDevicesStatus => '使用所选的麦克风和扬声器';

  @override
  String get audioRefreshDevices => '刷新音频设备';

  @override
  String get audioOpenSystemSoundSettings => '打开系统声音设置';

  @override
  String get audioReconnectDevices => '重新连接音频设备';

  @override
  String get audioOpenSystemSoundSettingsHint => '请在系统设置中打开声音设置';

  @override
  String get audioFollowSystemDeviceHint => '跟随系统声音设置';

  @override
  String get audioSelectedDeviceHint => '优先使用此设备，实际路由可能受系统设置影响';

  @override
  String get audioChangeDevicesInSystemHint => '当前为跟随系统模式，请在系统声音设置中切换输入和输出设备';

  @override
  String get audioPermissionEnabled => '麦克风权限已开启';

  @override
  String get audioPermissionDisabled => '麦克风权限未开启';

  @override
  String get audioPermissionRestricted => '麦克风权限受限制';

  @override
  String get audioPermissionPending => '麦克风权限待授权';

  @override
  String get audioPermissionSystemManaged => '麦克风权限由系统管理';

  @override
  String get audioPermissionUnknown => '麦克风权限未检查';

  @override
  String get audioPermissionEnabledDescription => 'VPhone 可以使用麦克风';

  @override
  String get audioPermissionDisabledDescription => '请前往系统设置允许 VPhone 使用麦克风';

  @override
  String get audioPermissionRestrictedDescription => '系统或管理员限制了麦克风访问';

  @override
  String get audioPermissionPendingDescription => '点击向系统申请麦克风权限';

  @override
  String get audioPermissionSystemManagedDescription => '麦克风权限由当前操作系统统一管理';

  @override
  String get audioPermissionUnknownDescription => '点击检查当前麦克风权限状态';

  @override
  String get audioPermissionOpenSettings => '打开系统设置';

  @override
  String get audioPermissionRequest => '申请麦克风权限';

  @override
  String get audioPermissionCheck => '检查麦克风权限';

  @override
  String get audioPermissionAvailableToast => '麦克风权限已开启';

  @override
  String get audioPermissionRequiredToast => '请在系统设置中允许 VPhone 使用麦克风';

  @override
  String get audioPermissionPendingToast => '开始通话时，系统将请求麦克风权限';

  @override
  String get audioPermissionSystemManagedToast => '麦克风权限由当前操作系统统一管理';

  @override
  String get audioPermissionUnknownToast => '暂时无法确认麦克风权限状态';

  @override
  String get audioIssueMicrophonePermission => '请在系统设置中允许 VPhone 使用麦克风';

  @override
  String get audioIssueNoMicrophone => '没有检测到可用麦克风，请连接耳机或输入设备';

  @override
  String get audioIssueNoSpeaker => '没有检测到可用扬声器，请连接耳机或输出设备';

  @override
  String get audioIssueNoInputOutput => '没有检测到可用麦克风或扬声器，请连接音频设备';

  @override
  String get audioIssueInvalidDevice => '当前音频设备已失效，请刷新或重新选择设备';

  @override
  String get audioIssueNoDevice => '没有检测到可用麦克风或扬声器';

  @override
  String get audioIssueNoDefaultDevice => '系统默认麦克风或扬声器不可用';

  @override
  String get audioIssueNotReady => '音频设备暂未就绪，请稍后重试';

  @override
  String audioIssueUnavailable(int code) {
    return '音频设备暂不可用（错误码 $code），请重新连接设备后重试';
  }

  @override
  String get audioIssueSpeakerOnly => '麦克风暂不可用，当前仅使用扬声器，请检查输入设备';

  @override
  String get aboutLoading => '读取中';

  @override
  String get aboutTagline => 'VeServe 桌面软电话';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutRuntime => '运行环境';

  @override
  String get aboutAppId => '应用标识';

  @override
  String get aboutCompany => '公司';

  @override
  String get aboutContact => '联系我们';

  @override
  String get aboutPhoneService => '电话服务';

  @override
  String get aboutServiceRunning => '已启动';

  @override
  String get aboutServiceStopped => '未启动';

  @override
  String get aboutEmailCopied => '邮箱已复制';

  @override
  String get diagnosticsShowLogs => '显示日志';

  @override
  String get diagnosticsEventTypes => '设备、注册与通话事件';

  @override
  String get diagnosticsClearLogs => '清空日志';

  @override
  String get diagnosticsExporting => '导出中';

  @override
  String get diagnosticsExportLogs => '导出日志';

  @override
  String get diagnosticsPrivacyNotice => '日志可能包含电话号码、服务器地址和网络信息，请仅发送给可信人员。';

  @override
  String get diagnosticsLogsHidden => '日志已隐藏';

  @override
  String get diagnosticsExported => '诊断日志已导出';

  @override
  String get diagnosticsExportFailed => '导出失败，请稍后重试';

  @override
  String get callSettingsControls => '通话控制';

  @override
  String get callSettingsMaxCalls => '最大同时通话';

  @override
  String callSettingsMaxCallsValue(int count) {
    return '$count 路';
  }

  @override
  String get callSettingsDtmfMethod => 'DTMF 方式';

  @override
  String get callSettingsAutoHold => '自动保持其他通话';

  @override
  String get callSettingsAutoHoldDescription => '接听、外呼或恢复通话时，自动保持其他通话';

  @override
  String get callSettingsShortcuts => '快捷操作';

  @override
  String get callSettingsDefaultMute => '默认静音';

  @override
  String get callSettingsOff => '关闭';

  @override
  String get callSettingsConference => '会议通话';

  @override
  String get callSettingsActive => '进行中';

  @override
  String accountSettingsSummary(int total, int online) {
    return '$total 条线路 · $online 条在线';
  }

  @override
  String get accountSettingsDisconnectAll => '断开全部';

  @override
  String get accountSettingsRestarting => '重启中';

  @override
  String get accountSettingsRestartApp => '重启应用';

  @override
  String get accountSettingsAddLine => '添加线路';

  @override
  String get accountSettingsEmpty => '尚未接入线路';

  @override
  String get accountSettingsEmptyHint => '添加线路后即可开始使用';

  @override
  String get accountSettingsDefaultPinned => '默认外呼线路固定置顶';

  @override
  String get accountSettingsDragToReorder => '拖动调整线路顺序';

  @override
  String get accountSettingsReorderUnavailable => '当前无法调整顺序';

  @override
  String get accountSettingsDefaultOutgoing => '默认外呼';

  @override
  String get accountSettingsSetDefault => '设为默认';

  @override
  String get accountSettingsRestartDescription => '应用将关闭后自动重新打开，账号配置不会删除。';

  @override
  String get accountSettingsRestartStepSave => '保存本地配置和通话记录';

  @override
  String get accountSettingsRestartStepClose => '关闭并重新打开应用';

  @override
  String get accountSettingsRestartStepRestore => '恢复已保存线路';

  @override
  String get accountSettingsRestartRecommended => '适用于休眠、网络切换或线路状态异常后的恢复。';

  @override
  String get accountSettingsRestartCallWarning => '当前仍有通话，重启会中断通话和线路连接。';

  @override
  String get accountStatusOnline => '在线';

  @override
  String get accountStatusConnecting => '连接中';

  @override
  String get accountStatusUpdating => '处理中';

  @override
  String get accountStatusDisabled => '已停用';

  @override
  String get accountStatusFailed => '连接失败';

  @override
  String get accountStatusOffline => '离线';

  @override
  String get accountStatusRestoring => '恢复中';

  @override
  String get accountDialogAddTitle => '添加线路';

  @override
  String get accountDialogEditTitle => '编辑线路';

  @override
  String get accountDialogAccountInfo => '账号信息';

  @override
  String get accountDialogLineName => '线路名称（可选）';

  @override
  String get accountDialogLineNameHint => '仅用于本地显示，例如“客服一线”';

  @override
  String get accountDialogUsername => '线路账号';

  @override
  String get accountDialogPassword => '密码';

  @override
  String get accountDialogShowPassword => '显示密码';

  @override
  String get accountDialogHidePassword => '隐藏密码';

  @override
  String get accountDialogServer => '服务器地址';

  @override
  String get accountDialogPort => '端口';

  @override
  String accountDialogDefaultPortHint(String transport, int port) {
    return '可留空 · $transport 默认端口 $port';
  }

  @override
  String get accountDialogConnection => '连接方式';

  @override
  String get accountDialogNetworkUnavailable => '网络不可用，暂时无法添加线路';

  @override
  String get accountDialogSave => '保存';

  @override
  String get accountDialogAddAndRegister => '添加并注册';

  @override
  String get accountDialogTransport => '传输协议';

  @override
  String accountDialogDefaultPort(int port) {
    return '默认端口 $port';
  }

  @override
  String get accountDialogTransportStandard => '标准';

  @override
  String get accountDialogTransportCompatible => '兼容';

  @override
  String get accountDialogTransportSecure => '安全';

  @override
  String get accountDialogMediaEncryption => '媒体加密';

  @override
  String get accountDialogSrtpWithoutTlsWarning =>
      '当前未使用 TLS。SRTP 将关闭安全信令要求；SDES 密钥会写入 SDP，建议配合 TLS。';

  @override
  String get accountDialogMediaNone => 'RTP 不加密';

  @override
  String get accountDialogMediaSdes => 'SDES-SRTP';

  @override
  String get accountDialogMediaDtls => 'DTLS-SRTP';

  @override
  String get accountDialogMediaOptionalDtls => '可选 SRTP（优先 DTLS）';

  @override
  String get accountDialogMediaOptionalSdes => '可选 SRTP（优先 SDES）';

  @override
  String get accountDialogMediaBestCompatibility => '兼容性最好';

  @override
  String get accountDialogMediaUseTls => '建议配合 TLS';

  @override
  String get accountDialogMediaAsteriskDtls => '适用于 Asterisk DTLS';

  @override
  String get accountDialogMediaAllowsFallback => '允许非加密回退';

  @override
  String get accountDialogMediaLegacySrtp => '兼容旧版 SRTP';

  @override
  String get accountDialogAdvanced => '高级设置';

  @override
  String get accountDialogAdvancedAccount => '高级账号';

  @override
  String get accountDialogAuthUsername => '认证用户名（可选）';

  @override
  String get accountDialogAuthUsernameHint => '留空时使用线路账号，仅用于 SIP 鉴权';

  @override
  String get accountDialogSipDisplayName => 'SIP 显示名称（可选）';

  @override
  String get accountDialogSipDisplayNameHint => '可能显示给对端；本地名称请填写线路名称';

  @override
  String get accountDialogAdvancedNetwork => '高级网络';

  @override
  String get accountDialogOutboundProxy => 'SIP 出站代理（可选）';

  @override
  String get accountDialogOutboundProxyHint =>
      '例如 sip:proxy.example.com:5060；留空时直连服务器';

  @override
  String get accountDialogEnableIpv6 => '启用 IPv6';

  @override
  String get accountDialogEnableIpv6Hint => '默认关闭，以减少 SIP 和媒体候选';

  @override
  String get accountDialogEnableIce => '启用 ICE';

  @override
  String get accountDialogEnableIceHint => '用于复杂 NAT 网络下的媒体协商';

  @override
  String get accountDialogEnableStun => '启用 STUN';

  @override
  String get accountDialogEnableStunHint => '发现公网映射地址，用于 NAT 穿透';

  @override
  String get accountDialogStunServer => 'STUN 服务器';

  @override
  String get accountDialogStunServerHint => '留空时使用默认 STUN；多个地址用逗号或空格分隔';

  @override
  String get accountDialogEnableTurn => '启用 TURN';

  @override
  String get accountDialogTurnHint => '直连失败时使用中继服务器';

  @override
  String get accountDialogTurnNeedsIce => '请先启用 ICE';

  @override
  String get accountDialogTurnServer => 'TURN 服务器';

  @override
  String get accountDialogTurnUsername => 'TURN 用户名';

  @override
  String get accountDialogTurnTransport => 'TURN 协议';

  @override
  String get accountDialogTurnPassword => 'TURN 密码';

  @override
  String get accountDialogTurnUdp => '默认中继';

  @override
  String get accountDialogTurnTcp => '受限网络更稳定';

  @override
  String get accountDialogTurnTls => '适合企业网络';

  @override
  String get accountDialogAdvancedAuth => '认证用户名';

  @override
  String get accountDialogAdvancedDisplayName => 'SIP 显示名';

  @override
  String get accountDialogAdvancedProxy => '出站代理';

  @override
  String get accountDialogAdvancedDefaults => '账号默认';

  @override
  String get accountDialogIceOff => 'ICE 关闭';

  @override
  String get accountDialogStunOff => 'STUN 关闭';

  @override
  String get accountDialogStunDefault => '默认 STUN';

  @override
  String get accountDialogStunCustom => '自定义 STUN';

  @override
  String get accountDialogIpv4Only => '仅 IPv4';

  @override
  String get accountDialogUdpIceWarning =>
      'UDP + ICE 可能增大 SIP 报文，部分网络会丢弃分片。建议使用 TCP/TLS，或关闭 ICE。';

  @override
  String get accountDialogRequired => '必填';

  @override
  String get accountDialogInvalidPort => '请输入 1–65535 之间的端口';

  @override
  String get accountDialogConfirmUdpIce => '确认使用 UDP + ICE？';

  @override
  String get accountDialogConfirmUdpIceBody =>
      'UDP + ICE 可能导致部分网络无法外呼。建议使用 TCP/TLS，或关闭 ICE。';

  @override
  String get accountDialogReview => '返回检查';

  @override
  String get accountDialogSaveAnyway => '仍然保存';

  @override
  String accountLimitReached(int count) {
    return '最多支持 $count 条线路，请删除不再使用的线路后重试';
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
  String get contactNewTitle => '新增';

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
  String get contactsAdd => '新增';

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

  @override
  String get activeCallEmpty => '暫無進行中的通話';

  @override
  String get activeCallGoToDialpad => '前往撥號';

  @override
  String get activeCallAnswer => '接聽';

  @override
  String get activeCallReject => '拒接';

  @override
  String get activeCallMute => '靜音';

  @override
  String get activeCallUnmute => '取消靜音';

  @override
  String get activeCallKeypad => '鍵盤';

  @override
  String get activeCallHold => '保持';

  @override
  String get activeCallResume => '恢復';

  @override
  String get activeCallTransfer => '轉駁';

  @override
  String get activeCallMuteRemoteAudio => '靜音對方';

  @override
  String get activeCallRestoreRemoteAudio => '恢復對方';

  @override
  String get activeCallAudio => '音訊';

  @override
  String get activeCallHangUp => '結束通話';

  @override
  String get activeCallHangUpAll => '全部結束';

  @override
  String get activeCallMerge => '合併';

  @override
  String get activeCallSplit => '拆分';

  @override
  String get activeCallResumeConference => '恢復會議';

  @override
  String get activeCallOperationAnswering => '正在接聽';

  @override
  String get activeCallOperationRejecting => '正在拒接';

  @override
  String get activeCallOperationEnding => '正在結束通話';

  @override
  String get activeCallOperationHolding => '正在保持';

  @override
  String get activeCallOperationResuming => '正在恢復';

  @override
  String get activeCallOperationSplitting => '正在拆分';

  @override
  String get activeCallOperationMerging => '正在合併';

  @override
  String get activeCallOperationTransferring => '正在轉駁';

  @override
  String get activeCallStatusLocalHold => '保持中';

  @override
  String get activeCallStatusRemoteHold => '對方保持';

  @override
  String get activeCallStatusCalling => '正在撥號';

  @override
  String get activeCallStatusIncoming => '來電';

  @override
  String get activeCallStatusWaitingAnswer => '等待接聽';

  @override
  String get activeCallStatusRemoteRinging => '對方響鈴';

  @override
  String get activeCallStatusConnecting => '正在接通';

  @override
  String get activeCallStatusInCall => '通話中';

  @override
  String get activeCallStatusEnded => '通話已結束';

  @override
  String activeCallStatusUnknown(int state) {
    return '未知狀態 ($state)';
  }

  @override
  String activeCallHeldLocallyFor(String duration) {
    return '本機保持 · $duration';
  }

  @override
  String activeCallHeldByRemoteFor(String duration) {
    return '對方保持 · $duration';
  }

  @override
  String get activeCallPriorityContact => '重點客戶';

  @override
  String get activeCallOperationInProgress => '操作進行中';

  @override
  String get activeCallDuration => '通話時長';

  @override
  String get activeCallCurrentStatus => '目前狀態';

  @override
  String get activeCallMediaConnected => '媒體已連線';

  @override
  String get activeCallMediaLocalHold => '本機保持';

  @override
  String get activeCallMediaRemoteHold => '對方保持';

  @override
  String get activeCallMediaError => '媒體異常';

  @override
  String get activeCallMediaNotReady => '媒體尚未建立';

  @override
  String get activeCallMediaPending => '等待建立媒體';

  @override
  String get activeCallMediaUnconfirmed => '媒體尚未確認';

  @override
  String activeCallMediaUnknown(int status) {
    return '媒體狀態 $status';
  }

  @override
  String get activeCallSignalingUnknown => '信令未知';

  @override
  String activeCallConfiguredMode(String mode) {
    return '$mode 設定';
  }

  @override
  String get activeCallMedia => '媒體';

  @override
  String get activeCallSignaling => '信令';

  @override
  String get activeCallMediaEncryption => '媒體加密';

  @override
  String get activeCallTlsEncrypted => 'TLS 加密';

  @override
  String get activeCallSrtpNegotiated => '已協商 SRTP';

  @override
  String get activeCallSrtpNotDetected => '未偵測到 SRTP';

  @override
  String get activeCallMediaNegotiating => '等待媒體協商';

  @override
  String get activeCallEncryptedCall => '通話已加密';

  @override
  String get activeCallEncryptedAudio => '語音已加密';

  @override
  String get activeCallStandardCall => '標準通話';

  @override
  String get activeCallVerifyingEncryption => '正在確認加密';

  @override
  String activeCallLabeledValue(String label, String value) {
    return '$label：$value';
  }

  @override
  String activeCallValueDetail(String value, String detail) {
    return '$value（$detail）';
  }

  @override
  String get activeCallTransport => '傳輸協定';

  @override
  String get activeCallTransferTitle => '直接轉駁通話';

  @override
  String get activeCallTransferDescription => '通話將立即轉駁至目標號碼，你將退出本次通話。';

  @override
  String get activeCallCurrentLineUnknown => '目前線路未知';

  @override
  String get activeCallTransferTargetHint => '輸入號碼或 SIP URI';

  @override
  String activeCallTransferTargetExample(String host) {
    return '例如 6545 或 sip:6545@$host';
  }

  @override
  String get activeCallChooseContact => '從聯絡人選擇';

  @override
  String activeCallNumberCount(int count) {
    return '$count 個號碼';
  }

  @override
  String get activeCallTransferSearchHint => '搜尋聯絡人、號碼或公司';

  @override
  String get activeCallEnterTransferNumber => '輸入轉駁號碼';

  @override
  String get activeCallConfirmTransfer => '確認轉駁';

  @override
  String get activeCallNoContacts => '暫無聯絡人';

  @override
  String get activeCallNoContactMatches => '沒有相符的聯絡人';

  @override
  String get activeCallUnnamedContact => '未命名聯絡人';

  @override
  String get activeCallViewingConferenceMember => '正在查看會議成員';

  @override
  String get activeCallCurrentActiveCall => '目前活動通話';

  @override
  String get activeCallViewingCall => '正在查看此通話';

  @override
  String activeCallResumeForAudio(String name) {
    return '$name · 按一下恢復以接入聲音';
  }

  @override
  String activeCallConferenceInterrupted(int count) {
    return '會議已自動保持。處理目前通話後，可恢復 $count 位會議成員。';
  }

  @override
  String get activeCallConferenceTitle => '會議通話';

  @override
  String get activeCallConferencePaused => '會議已暫停';

  @override
  String get activeCallConferenceInProgress => '會議中';

  @override
  String get activeCallConferenceStatus => '會議狀態';

  @override
  String get activeCallConferenceDuration => '會議時長';

  @override
  String get activeCallPaused => '已暫停';

  @override
  String activeCallMemberCount(int count) {
    return '$count 位成員';
  }

  @override
  String activeCallCustomerCount(int count) {
    return '$count 位客戶';
  }

  @override
  String activeCallLineCount(int count) {
    return '$count 條線路';
  }

  @override
  String get activeCallPanelConferenceMembers => '會議成員';

  @override
  String get activeCallPanelCurrentCalls => '目前通話';

  @override
  String activeCallPanelCount(int current, int total) {
    return '$current/$total 路';
  }

  @override
  String get activeCallNewIncomingAndOthers => '新來電及其他通話';

  @override
  String get activeCallOtherCalls => '其他通話';

  @override
  String get activeCallNoActiveCalls => '沒有活動通話';

  @override
  String get activeCallCustomerInfo => '客戶資料';

  @override
  String get activeCallConferenceCustomers => '會議客戶';

  @override
  String get activeCallConferenceCustomersDescription => '已加入會議的客戶';

  @override
  String get activeCallUnmatchedContact => '未配對聯絡人';

  @override
  String get activeCallUnknownNumber => '未知號碼';

  @override
  String get activeCallAddContact => '新增至聯絡人';

  @override
  String get activeCallViewContact => '查看聯絡人';

  @override
  String get activeCallDefaultNumber => '預設號碼';

  @override
  String get activeCallCustomer => '通話客戶';

  @override
  String get activeCallViewContactDetails => '查看聯絡人詳情';

  @override
  String get activeCallCurrentNumber => '目前號碼';

  @override
  String get activeCallCurrentNote => '目前通話備註';

  @override
  String get activeCallNoteHint => '記錄溝通重點，結束通話後將儲存至通話記錄';

  @override
  String get activeCallConferenceNote => '本次會議備註';

  @override
  String activeCallNoteSyncMembers(int count) {
    return '同步至 $count 位會議成員';
  }

  @override
  String activeCallNoteSavePrimary(String name) {
    return '僅儲存至會議主記錄：$name';
  }

  @override
  String get activeCallCustomerNote => '目前客戶備註';

  @override
  String get activeCallSharedConferenceNote => '會議共享備註';

  @override
  String get activeCallSharedNoteHint => '記錄會議結論，並儲存至每位成員的通話記錄';

  @override
  String get activeCallCustomerNoteHint => '記錄目前客戶重點，僅儲存至會議主記錄';

  @override
  String get activeCallNoteStaged => '已暫存';

  @override
  String get activeCallNoteEmpty => '未填寫';

  @override
  String get activeCallNoteStagedTooltip => '備註已暫存，結束通話後將寫入通話記錄';

  @override
  String get activeCallNoteEmptyTooltip => '填寫後自動暫存，結束通話後寫入通話記錄';

  @override
  String get activeCallViewing => '查看中';

  @override
  String get activeCallRemoteAudioMuted => '聲音已關閉';

  @override
  String get activeCallDtmfWaiting => '等待輸入';

  @override
  String get activeCallDtmfTitle => 'DTMF 鍵盤';

  @override
  String get activeCallDtmfClose => '關閉鍵盤';

  @override
  String activeCallDtmfSending(String digit) {
    return '正在傳送 $digit';
  }

  @override
  String activeCallDtmfSent(String digit) {
    return '已傳送 $digit';
  }

  @override
  String activeCallDtmfFailed(String digit) {
    return '無法傳送 $digit';
  }

  @override
  String get activeCallMyAudio => '麥克風';

  @override
  String get activeCallRemoteAudio => '揚聲器';

  @override
  String activeCallMutedValue(String label) {
    return '$label：已靜音';
  }

  @override
  String activeCallVolumeValue(int volume) {
    return '，音量 $volume%';
  }

  @override
  String activeCallMeterMuted(String label, String volume) {
    return '$label：已靜音$volume';
  }

  @override
  String activeCallMeterValues(
    String label,
    int current,
    int peak,
    String volume,
  ) {
    return '$label：目前 $current%，峰值 $peak%$volume';
  }

  @override
  String get audioAddLine => '新增線路';

  @override
  String get audioSoundAlerts => '聲音提示';

  @override
  String get audioIncomingRingtone => '來電鈴聲';

  @override
  String get audioIncomingRingtoneDescription => '有新來電時播放鈴聲';

  @override
  String get audioOutgoingRingback => '外撥回鈴音';

  @override
  String get audioOutgoingRingbackDescription => '撥號後等待對方接聽時播放';

  @override
  String get audioCallEndedTone => '通話結束提示音';

  @override
  String get audioCallEndedToneDescription => '已接通的通話結束時播放';

  @override
  String get audioDialpadTones => '撥號按鍵音';

  @override
  String get audioDialpadTonesDescription => '在撥號鍵盤輸入時播放按鍵音，預設關閉';

  @override
  String get audioRouting => '音訊路由';

  @override
  String get audioFollowSystem => '跟隨系統';

  @override
  String get audioChooseDevices => '指定裝置';

  @override
  String get audioFollowSystemDescription => '建議使用。插拔耳機時自動跟隨系統聲音設定';

  @override
  String get audioChooseDevicesDescription => '選擇應用程式使用的裝置；系統限制可能影響實際音訊路由';

  @override
  String get audioAutoSwitch => '裝置變更時自動切換';

  @override
  String get audioAutoSwitchDescription => '通話中插拔耳機時，自動恢復可用的音訊路徑';

  @override
  String get audioInputOutput => '輸入與輸出';

  @override
  String get audioMicrophone => '麥克風';

  @override
  String get audioInputDevice => '輸入裝置';

  @override
  String get audioSpeaker => '揚聲器';

  @override
  String get audioOutputDevice => '輸出裝置';

  @override
  String get audioSystemDefaultInput => '跟隨系統輸入';

  @override
  String get audioSystemDefaultOutput => '跟隨系統輸出';

  @override
  String get audioDeviceNotSelected => '未選擇';

  @override
  String get audioDeviceUnavailable => '裝置不可用';

  @override
  String audioRecordingRemaining(int seconds) {
    return '錄音中 $seconds 秒';
  }

  @override
  String get audioRecording => '錄音中';

  @override
  String get audioPreparingPlayback => '準備播放';

  @override
  String get audioPlaying => '播放中';

  @override
  String get audioRecordingTest => '錄音測試';

  @override
  String get audioTestOutput => '測試揚聲器';

  @override
  String get audioMute => '靜音';

  @override
  String get audioUnmute => '取消靜音';

  @override
  String get audioTesting => '測試中';

  @override
  String get audioReady => '就緒';

  @override
  String get audioDeviceNeedsAttention => '音訊裝置需要處理';

  @override
  String get audioFollowingSystem => '跟隨系統聲音';

  @override
  String get audioUsingSelectedDevices => '使用指定裝置';

  @override
  String get audioFollowingSystemStatus => '輸入及輸出跟隨系統聲音設定';

  @override
  String get audioUsingSelectedDevicesStatus => '使用所選的麥克風及揚聲器';

  @override
  String get audioRefreshDevices => '重新整理音訊裝置';

  @override
  String get audioOpenSystemSoundSettings => '開啟系統聲音設定';

  @override
  String get audioReconnectDevices => '重新連接音訊裝置';

  @override
  String get audioOpenSystemSoundSettingsHint => '請在系統設定中開啟聲音設定';

  @override
  String get audioFollowSystemDeviceHint => '跟隨系統聲音設定';

  @override
  String get audioSelectedDeviceHint => '優先使用此裝置，實際路由可能受系統設定影響';

  @override
  String get audioChangeDevicesInSystemHint => '目前為跟隨系統模式，請在系統聲音設定中切換輸入及輸出裝置';

  @override
  String get audioPermissionEnabled => '麥克風權限已開啟';

  @override
  String get audioPermissionDisabled => '麥克風權限未開啟';

  @override
  String get audioPermissionRestricted => '麥克風權限受限制';

  @override
  String get audioPermissionPending => '麥克風權限待授權';

  @override
  String get audioPermissionSystemManaged => '麥克風權限由系統管理';

  @override
  String get audioPermissionUnknown => '麥克風權限未檢查';

  @override
  String get audioPermissionEnabledDescription => 'VPhone 可以使用麥克風';

  @override
  String get audioPermissionDisabledDescription => '請前往系統設定允許 VPhone 使用麥克風';

  @override
  String get audioPermissionRestrictedDescription => '系統或管理員限制了麥克風存取';

  @override
  String get audioPermissionPendingDescription => '點擊向系統申請麥克風權限';

  @override
  String get audioPermissionSystemManagedDescription => '麥克風權限由目前作業系統統一管理';

  @override
  String get audioPermissionUnknownDescription => '點擊檢查目前麥克風權限狀態';

  @override
  String get audioPermissionOpenSettings => '開啟系統設定';

  @override
  String get audioPermissionRequest => '申請麥克風權限';

  @override
  String get audioPermissionCheck => '檢查麥克風權限';

  @override
  String get audioPermissionAvailableToast => '麥克風權限已開啟';

  @override
  String get audioPermissionRequiredToast => '請在系統設定中允許 VPhone 使用麥克風';

  @override
  String get audioPermissionPendingToast => '開始通話時，系統將要求麥克風權限';

  @override
  String get audioPermissionSystemManagedToast => '麥克風權限由目前作業系統統一管理';

  @override
  String get audioPermissionUnknownToast => '暫時無法確認麥克風權限狀態';

  @override
  String get audioIssueMicrophonePermission => '請在系統設定中允許 VPhone 使用麥克風';

  @override
  String get audioIssueNoMicrophone => '未偵測到可用麥克風，請連接耳機或輸入裝置';

  @override
  String get audioIssueNoSpeaker => '未偵測到可用揚聲器，請連接耳機或輸出裝置';

  @override
  String get audioIssueNoInputOutput => '未偵測到可用麥克風或揚聲器，請連接音訊裝置';

  @override
  String get audioIssueInvalidDevice => '目前的音訊裝置已失效，請重新整理或重新選擇裝置';

  @override
  String get audioIssueNoDevice => '未偵測到可用麥克風或揚聲器';

  @override
  String get audioIssueNoDefaultDevice => '系統預設麥克風或揚聲器不可用';

  @override
  String get audioIssueNotReady => '音訊裝置尚未就緒，請稍後再試';

  @override
  String audioIssueUnavailable(int code) {
    return '音訊裝置暫時不可用（錯誤碼 $code），請重新連接裝置後再試';
  }

  @override
  String get audioIssueSpeakerOnly => '麥克風暫時不可用，目前僅使用揚聲器，請檢查輸入裝置';

  @override
  String get aboutLoading => '讀取中';

  @override
  String get aboutTagline => 'VeServe 桌面軟電話';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutRuntime => '執行環境';

  @override
  String get aboutAppId => '應用程式識別碼';

  @override
  String get aboutCompany => '公司';

  @override
  String get aboutContact => '聯絡我們';

  @override
  String get aboutPhoneService => '電話服務';

  @override
  String get aboutServiceRunning => '已啟動';

  @override
  String get aboutServiceStopped => '未啟動';

  @override
  String get aboutEmailCopied => '電郵地址已複製';

  @override
  String get diagnosticsShowLogs => '顯示日誌';

  @override
  String get diagnosticsEventTypes => '裝置、註冊及通話事件';

  @override
  String get diagnosticsClearLogs => '清除日誌';

  @override
  String get diagnosticsExporting => '匯出中';

  @override
  String get diagnosticsExportLogs => '匯出日誌';

  @override
  String get diagnosticsPrivacyNotice => '日誌可能包含電話號碼、伺服器地址及網絡資料，請只傳送給可信任的人員。';

  @override
  String get diagnosticsLogsHidden => '日誌已隱藏';

  @override
  String get diagnosticsExported => '診斷日誌已匯出';

  @override
  String get diagnosticsExportFailed => '匯出失敗，請稍後再試';

  @override
  String get callSettingsControls => '通話控制';

  @override
  String get callSettingsMaxCalls => '同時通話上限';

  @override
  String callSettingsMaxCallsValue(int count) {
    return '$count 路';
  }

  @override
  String get callSettingsDtmfMethod => 'DTMF 方式';

  @override
  String get callSettingsAutoHold => '自動保留其他通話';

  @override
  String get callSettingsAutoHoldDescription => '接聽、外撥或恢復通話時，自動保留其他通話';

  @override
  String get callSettingsShortcuts => '快捷設定';

  @override
  String get callSettingsDefaultMute => '預設靜音';

  @override
  String get callSettingsOff => '關閉';

  @override
  String get callSettingsConference => '會議通話';

  @override
  String get callSettingsActive => '進行中';

  @override
  String accountSettingsSummary(int total, int online) {
    return '$total 條線路 · $online 條在線';
  }

  @override
  String get accountSettingsDisconnectAll => '全部斷線';

  @override
  String get accountSettingsRestarting => '重新啟動中';

  @override
  String get accountSettingsRestartApp => '重新啟動應用程式';

  @override
  String get accountSettingsAddLine => '新增線路';

  @override
  String get accountSettingsEmpty => '尚未加入線路';

  @override
  String get accountSettingsEmptyHint => '新增線路後即可開始使用';

  @override
  String get accountSettingsDefaultPinned => '預設外撥線路固定置頂';

  @override
  String get accountSettingsDragToReorder => '拖動以調整線路次序';

  @override
  String get accountSettingsReorderUnavailable => '目前無法調整次序';

  @override
  String get accountSettingsDefaultOutgoing => '預設外撥';

  @override
  String get accountSettingsSetDefault => '設為預設';

  @override
  String get accountSettingsRestartDescription => '應用程式將關閉後自動重新開啟，帳戶設定不會刪除。';

  @override
  String get accountSettingsRestartStepSave => '儲存本機設定及通話記錄';

  @override
  String get accountSettingsRestartStepClose => '關閉並重新開啟應用程式';

  @override
  String get accountSettingsRestartStepRestore => '恢復已儲存的線路';

  @override
  String get accountSettingsRestartRecommended => '適用於睡眠、網絡切換或線路狀態異常後的恢復。';

  @override
  String get accountSettingsRestartCallWarning => '目前仍有通話，重新啟動會中斷通話及線路連線。';

  @override
  String get accountStatusOnline => '在線';

  @override
  String get accountStatusConnecting => '連線中';

  @override
  String get accountStatusUpdating => '處理中';

  @override
  String get accountStatusDisabled => '已停用';

  @override
  String get accountStatusFailed => '連線失敗';

  @override
  String get accountStatusOffline => '離線';

  @override
  String get accountStatusRestoring => '恢復中';

  @override
  String get accountDialogAddTitle => '新增線路';

  @override
  String get accountDialogEditTitle => '編輯線路';

  @override
  String get accountDialogAccountInfo => '帳戶資料';

  @override
  String get accountDialogLineName => '線路名稱（選填）';

  @override
  String get accountDialogLineNameHint => '只在本機顯示，例如「客服一線」';

  @override
  String get accountDialogUsername => '線路帳戶';

  @override
  String get accountDialogPassword => '密碼';

  @override
  String get accountDialogShowPassword => '顯示密碼';

  @override
  String get accountDialogHidePassword => '隱藏密碼';

  @override
  String get accountDialogServer => '伺服器地址';

  @override
  String get accountDialogPort => '連接埠';

  @override
  String accountDialogDefaultPortHint(String transport, int port) {
    return '可留空 · $transport 預設連接埠 $port';
  }

  @override
  String get accountDialogConnection => '連線方式';

  @override
  String get accountDialogNetworkUnavailable => '網絡不可用，暫時無法新增線路';

  @override
  String get accountDialogSave => '儲存';

  @override
  String get accountDialogAddAndRegister => '新增並註冊';

  @override
  String get accountDialogTransport => '傳輸協定';

  @override
  String accountDialogDefaultPort(int port) {
    return '預設連接埠 $port';
  }

  @override
  String get accountDialogTransportStandard => '標準';

  @override
  String get accountDialogTransportCompatible => '兼容';

  @override
  String get accountDialogTransportSecure => '安全';

  @override
  String get accountDialogMediaEncryption => '媒體加密';

  @override
  String get accountDialogSrtpWithoutTlsWarning =>
      '目前未使用 TLS。SRTP 將關閉安全信令要求；SDES 密鑰會寫入 SDP，建議配合 TLS。';

  @override
  String get accountDialogMediaNone => 'RTP 不加密';

  @override
  String get accountDialogMediaSdes => 'SDES-SRTP';

  @override
  String get accountDialogMediaDtls => 'DTLS-SRTP';

  @override
  String get accountDialogMediaOptionalDtls => '可選 SRTP（優先 DTLS）';

  @override
  String get accountDialogMediaOptionalSdes => '可選 SRTP（優先 SDES）';

  @override
  String get accountDialogMediaBestCompatibility => '兼容性最佳';

  @override
  String get accountDialogMediaUseTls => '建議配合 TLS';

  @override
  String get accountDialogMediaAsteriskDtls => '適用於 Asterisk DTLS';

  @override
  String get accountDialogMediaAllowsFallback => '允許非加密回退';

  @override
  String get accountDialogMediaLegacySrtp => '兼容舊版 SRTP';

  @override
  String get accountDialogAdvanced => '進階設定';

  @override
  String get accountDialogAdvancedAccount => '進階帳戶';

  @override
  String get accountDialogAuthUsername => '認證用戶名稱（選填）';

  @override
  String get accountDialogAuthUsernameHint => '留空時使用線路帳戶，只用於 SIP 認證';

  @override
  String get accountDialogSipDisplayName => 'SIP 顯示名稱（選填）';

  @override
  String get accountDialogSipDisplayNameHint => '可能顯示給對方；本機名稱請填寫線路名稱';

  @override
  String get accountDialogAdvancedNetwork => '進階網絡';

  @override
  String get accountDialogOutboundProxy => 'SIP 外送代理（選填）';

  @override
  String get accountDialogOutboundProxyHint =>
      '例如 sip:proxy.example.com:5060；留空時直接連接伺服器';

  @override
  String get accountDialogEnableIpv6 => '啟用 IPv6';

  @override
  String get accountDialogEnableIpv6Hint => '預設關閉，以減少 SIP 及媒體候選';

  @override
  String get accountDialogEnableIce => '啟用 ICE';

  @override
  String get accountDialogEnableIceHint => '用於複雜 NAT 網絡下的媒體協商';

  @override
  String get accountDialogEnableStun => '啟用 STUN';

  @override
  String get accountDialogEnableStunHint => '找出公網映射地址，用於 NAT 穿透';

  @override
  String get accountDialogStunServer => 'STUN 伺服器';

  @override
  String get accountDialogStunServerHint => '留空時使用預設 STUN；多個地址以逗號或空格分隔';

  @override
  String get accountDialogEnableTurn => '啟用 TURN';

  @override
  String get accountDialogTurnHint => '直接連線失敗時使用中繼伺服器';

  @override
  String get accountDialogTurnNeedsIce => '請先啟用 ICE';

  @override
  String get accountDialogTurnServer => 'TURN 伺服器';

  @override
  String get accountDialogTurnUsername => 'TURN 用戶名稱';

  @override
  String get accountDialogTurnTransport => 'TURN 傳輸協定';

  @override
  String get accountDialogTurnPassword => 'TURN 密碼';

  @override
  String get accountDialogTurnUdp => '預設中繼';

  @override
  String get accountDialogTurnTcp => '受限網絡較穩定';

  @override
  String get accountDialogTurnTls => '適合企業網絡';

  @override
  String get accountDialogAdvancedAuth => '認證用戶名稱';

  @override
  String get accountDialogAdvancedDisplayName => 'SIP 顯示名稱';

  @override
  String get accountDialogAdvancedProxy => '外送代理';

  @override
  String get accountDialogAdvancedDefaults => '帳戶預設';

  @override
  String get accountDialogIceOff => 'ICE 已關閉';

  @override
  String get accountDialogStunOff => 'STUN 已關閉';

  @override
  String get accountDialogStunDefault => '預設 STUN';

  @override
  String get accountDialogStunCustom => '自訂 STUN';

  @override
  String get accountDialogIpv4Only => '只使用 IPv4';

  @override
  String get accountDialogUdpIceWarning =>
      'UDP + ICE 可能增大 SIP 訊息，部分網絡會丟棄分片。建議使用 TCP/TLS，或關閉 ICE。';

  @override
  String get accountDialogRequired => '必填';

  @override
  String get accountDialogInvalidPort => '請輸入 1–65535 之間的連接埠';

  @override
  String get accountDialogConfirmUdpIce => '確認使用 UDP + ICE？';

  @override
  String get accountDialogConfirmUdpIceBody =>
      'UDP + ICE 可能導致部分網絡無法外撥。建議使用 TCP/TLS，或關閉 ICE。';

  @override
  String get accountDialogReview => '返回檢查';

  @override
  String get accountDialogSaveAnyway => '仍然儲存';

  @override
  String accountLimitReached(int count) {
    return '最多支援 $count 條線路，請刪除不再使用的線路後再試';
  }
}
