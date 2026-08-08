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

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonAll => 'All';

  @override
  String get commonAvailable => 'Available';

  @override
  String get commonUnavailable => 'Unavailable';

  @override
  String get commonClear => 'Clear';

  @override
  String get headerEndCallsFirst => 'End active calls first';

  @override
  String get headerPhoneServiceUnavailable =>
      'Phone service is not initialized';

  @override
  String get headerAllLinesDisconnected => 'All lines are disconnected';

  @override
  String get headerDisconnectAllLines => 'Disconnect all lines';

  @override
  String get headerAddLine => 'Add line';

  @override
  String get disconnectAllDescription =>
      'Registration will stop for every line. You can enable them again from the line menu.';

  @override
  String disconnectAllSummary(int total, int online) {
    return '$total lines added, $online online';
  }

  @override
  String get disconnectAllQuestion => 'Disconnect all lines?';

  @override
  String get disconnectAllAction => 'Disconnect all';

  @override
  String get statusNetworkUnavailable => 'Network unavailable';

  @override
  String get statusCheckingSeatEnvironment =>
      'Checking your previous workspace';

  @override
  String get statusRestoringLines => 'Restoring previous line settings';

  @override
  String statusConnectedNoOutgoing(int total) {
    return '$total lines added, no dial line available';
  }

  @override
  String statusConnectedCurrentOutgoing(int total, String line) {
    return '$total lines added, current dial line: $line';
  }

  @override
  String statusConnectedDefaultOutgoing(int total, String line) {
    return '$total lines added, default dial line: $line';
  }

  @override
  String get statusInitializedNoAccounts =>
      'Phone service is running. No lines added';

  @override
  String get statusConnectServiceHint =>
      'Start phone service to make and receive calls';

  @override
  String get dialOutgoingLine => 'Dial line';

  @override
  String get dialNoLinesAdded => 'No lines added';

  @override
  String get dialOpenLineSettings => 'Open line settings';

  @override
  String get dialNoAvailableOutgoing =>
      'No dial line available. Check registration status';

  @override
  String dialFallbackOutgoing(String line) {
    return 'Default line $line is unavailable. This line is being used temporarily';
  }

  @override
  String get dialNoAvailableLine => 'No line available';

  @override
  String get dialNetworkUnavailableDescription =>
      'Restore the network to place calls';

  @override
  String get dialNoLinesDescription => 'Add a SIP line to place calls';

  @override
  String get dialNoOutgoingDescription => 'Check line registration status';

  @override
  String get dialConferenceActive => 'Conference in progress';

  @override
  String get dialConferenceActiveDescription =>
      'Split the conference before placing another call';

  @override
  String get dialCapacityReached => 'Call limit reached';

  @override
  String dialCapacityDescription(int max) {
    return 'Up to $max calls can be held at once';
  }

  @override
  String get dialReady => 'Ready to call';

  @override
  String get dialReadyDescription => 'Enter a number, then select Call';

  @override
  String get dialUnavailable => 'Calling unavailable';

  @override
  String get dialUnavailableDescription => 'Check the number or line status';

  @override
  String get dialEnterNumberToCall => 'Enter a number to call';

  @override
  String get dialAddLineFirst => 'Add a line first';

  @override
  String get dialUnavailableDuringConference =>
      'Calling is unavailable during a conference';

  @override
  String get dialNumberHint => 'Enter number';

  @override
  String get dialStartCall => 'Place call';

  @override
  String get dialCall => 'Call';

  @override
  String get dialCurrentOutgoingLine => 'Current dial line';

  @override
  String get dialDefaultOutgoingLine => 'Default dial line';

  @override
  String get dialCallCapacity => 'Call capacity';

  @override
  String dialCallCapacityValue(int current, int max) {
    return '$current/$max';
  }

  @override
  String get dialNetwork => 'Network';

  @override
  String get dialNoRecentCalls => 'No recent calls';

  @override
  String get dialRecentCalls => 'Recent calls';

  @override
  String get dialNoCallbackNumber => 'No callback number';

  @override
  String dialCallbackNumber(String number) {
    return 'Call back $number';
  }

  @override
  String dialYesterdayAt(String time) {
    return 'Yesterday $time';
  }

  @override
  String get contactDefaultNumber => 'Default';

  @override
  String get contactExactMatch => 'Matched';

  @override
  String get contactSuffixMatch => 'Suffix match';

  @override
  String get weekdayMonday => 'Mon';

  @override
  String get weekdayTuesday => 'Tue';

  @override
  String get weekdayWednesday => 'Wed';

  @override
  String get weekdayThursday => 'Thu';

  @override
  String get weekdayFriday => 'Fri';

  @override
  String get weekdaySaturday => 'Sat';

  @override
  String get weekdaySunday => 'Sun';

  @override
  String sidebarConnectedTemporary(String line) {
    return 'Temporary dial line · $line';
  }

  @override
  String sidebarConnectedDefault(String line) {
    return 'Dial line · $line';
  }

  @override
  String get sidebarWaitingAccounts => 'Waiting for lines';

  @override
  String get sidebarDisconnected => 'Disconnected';

  @override
  String get sidebarConnectionStatus => 'Connection status';

  @override
  String get sidebarPhoneService => 'Phone service';

  @override
  String get sidebarServiceStarted => 'Running';

  @override
  String get sidebarServiceStopped => 'Stopped';

  @override
  String get sidebarDefaultDialLine => 'Default dial line';

  @override
  String get sidebarNone => 'None';

  @override
  String get sidebarCurrentDialLine => 'Current dial line';

  @override
  String get sidebarTemporaryUse => 'Temporary';

  @override
  String get sidebarLines => 'Lines';

  @override
  String sidebarOnlineCount(int online, int total) {
    return '$online/$total online';
  }

  @override
  String get sidebarRetryFailedLines => 'Retry unavailable lines';

  @override
  String get sidebarOpenLineSettings => 'Open line settings';

  @override
  String get sidebarDefaultDial => 'Default dial';

  @override
  String sidebarManageLines(int count) {
    return 'Manage $count lines';
  }

  @override
  String get sidebarAudio => 'Audio';

  @override
  String get sidebarAudioIssue => 'Issue';

  @override
  String get sidebarAudioDevices => 'Audio devices';

  @override
  String get sidebarAudioInput => 'Input';

  @override
  String get sidebarAudioOutput => 'Output';

  @override
  String get sidebarAudioMode => 'Mode';

  @override
  String get sidebarAudioStatus => 'Status';

  @override
  String get sidebarAudioAutomatic => 'Automatic';

  @override
  String get sidebarAudioManual => 'Manual';

  @override
  String get sidebarAudioSwitchToManual => 'Switch to manual';

  @override
  String get sidebarAudioSwitchToAutomatic => 'Switch to automatic';

  @override
  String get sidebarAudioRefreshDevices => 'Refresh devices';

  @override
  String get sidebarOpenAudioSettings => 'Open audio settings';

  @override
  String get sidebarSetDefaultDial => 'Set as default dial line';

  @override
  String sidebarDefaultDialStatus(String status, String transport) {
    return 'Default dial · $status · $transport';
  }

  @override
  String get sidebarRefreshLine => 'Refresh';

  @override
  String get sidebarRestartLine => 'Restart';

  @override
  String get sidebarDisableLine => 'Disable';

  @override
  String get sidebarEnableLine => 'Enable';

  @override
  String get sidebarEditLine => 'Edit';

  @override
  String get sidebarDeleteLine => 'Delete';

  @override
  String get sidebarRestartLineTitle => 'Restart line';

  @override
  String get sidebarRestartLineDescription =>
      'The line will briefly unregister and then register again. Its settings will not be deleted.';

  @override
  String get sidebarRestartLineHint =>
      'Use this after network recovery or when the line status is incorrect after the computer wakes.';

  @override
  String get sidebarDeleteLineTitle => 'Delete line';

  @override
  String get sidebarDeleteLineDescription =>
      'You will need to add the account again to restore this line.';

  @override
  String get sidebarDeleteLineQuestion => 'Delete this line?';

  @override
  String get callDirectionInbound => 'Incoming';

  @override
  String get callDirectionOutbound => 'Outgoing';

  @override
  String get callStatusCompleted => 'Connected';

  @override
  String get callStatusMissed => 'Missed';

  @override
  String get callStatusRejected => 'Rejected';

  @override
  String get callStatusFailed => 'Failed';

  @override
  String get callStatusCanceled => 'Canceled';

  @override
  String get contactNewTitle => 'Add';

  @override
  String get contactEditTitle => 'Edit contact';

  @override
  String get contactDetailsTitle => 'Contact details';

  @override
  String get contactName => 'Name';

  @override
  String get contactNameRequired => 'Enter a name';

  @override
  String get contactCompany => 'Company';

  @override
  String get contactDepartment => 'Department';

  @override
  String get contactNotes => 'Notes';

  @override
  String get contactPriority => 'Priority contact';

  @override
  String get contactPrioritySet => 'Mark as priority';

  @override
  String get contactPriorityUnset => 'Remove priority';

  @override
  String get contactPriorityBadge => 'Priority';

  @override
  String get contactSave => 'Save';

  @override
  String get contactDelete => 'Delete';

  @override
  String get contactEdit => 'Edit';

  @override
  String get contactCall => 'Call';

  @override
  String get contactClose => 'Close';

  @override
  String get contactPhone => 'Number';

  @override
  String get contactPhones => 'Phone numbers';

  @override
  String get contactAddPhone => 'Add number';

  @override
  String get contactPhoneLabel => 'Label';

  @override
  String get contactPhoneRequired => 'Enter a number';

  @override
  String get contactPhoneInvalid =>
      'Use digits and standard phone symbols only';

  @override
  String get contactPhoneDuplicate => 'Number already used';

  @override
  String get contactDeletePhone => 'Delete number';

  @override
  String get contactAlternateLabel => 'Alternate';

  @override
  String contactsSelectedCount(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get contactsClearSelection => 'Clear selection';

  @override
  String get contactsSearchHint => 'Search name, number, company, or notes';

  @override
  String get contactsClearSearch => 'Clear search';

  @override
  String get contactsAdd => 'Add';

  @override
  String contactsVisibleCount(int visible, int total) {
    return '$visible of $total';
  }

  @override
  String contactsTotalCount(int total) {
    return '$total contacts';
  }

  @override
  String get contactsNoMatches => 'No matches';

  @override
  String get contactsEmpty => 'No contacts';

  @override
  String get contactsNoMatchesHint => 'Try another search';

  @override
  String get contactsEmptyHint => 'Add a contact for faster calling';

  @override
  String get contactsResetSearch => 'Reset search';

  @override
  String get contactsColumnContact => 'Contact';

  @override
  String get contactsColumnOrganization => 'Company';

  @override
  String get contactsColumnUpdated => 'Updated';

  @override
  String get contactsColumnActions => 'Actions';

  @override
  String get contactsMoreActions => 'More actions';

  @override
  String get contactNoAvailableDialLine =>
      'No dial line available. Register a line first.';

  @override
  String get contactNoCallableNumber => 'This contact has no callable number';

  @override
  String get contactAddLineFirst => 'Add a phone line first';

  @override
  String get contactNetworkUnavailable =>
      'Network unavailable. Calls are temporarily disabled.';

  @override
  String get contactConferenceCallBlocked =>
      'You cannot call a contact during a conference';

  @override
  String get contactCallLimitReached => 'The 4-call limit has been reached';

  @override
  String get contactNotProvided => 'Not provided';

  @override
  String get contactConfirmCallTitle => 'Confirm call';

  @override
  String get contactDialLine => 'Dial line';

  @override
  String get contactCreatedToast => 'Contact added';

  @override
  String get contactUpdatedToast => 'Contact updated';

  @override
  String get contactDuplicateTitle => 'Number already used';

  @override
  String contactDuplicateNumberMessage(String number) {
    return '$number belongs to an existing contact.';
  }

  @override
  String get contactDuplicateExplanation =>
      'Contact numbers must be unique to keep call history accurate. Open the existing contact to make changes.';

  @override
  String get contactViewExisting => 'View contact';

  @override
  String get contactExistingLocated => 'Existing contact selected';

  @override
  String get contactDeleteTitle => 'Delete contact';

  @override
  String contactDeleteQuestion(String name) {
    return 'Delete $name? This cannot be undone.';
  }

  @override
  String get contactDeletedToast => 'Contact deleted';

  @override
  String get contactBulkDeleteTitle => 'Delete contacts';

  @override
  String contactBulkDeleteQuestion(int count) {
    return 'Delete $count selected contacts? This cannot be undone.';
  }

  @override
  String contactBulkDeleteConfirm(int count) {
    return 'Delete $count';
  }

  @override
  String contactBulkDeletedToast(int count) {
    return 'Deleted $count contacts';
  }

  @override
  String get contactSelectForDetails => 'Select a contact to view details';

  @override
  String get contactDefaultPhone => 'Default number';

  @override
  String get contactCreatedAt => 'Created';

  @override
  String get contactUpdatedAt => 'Updated';

  @override
  String get contactRecentCalls => 'Recent calls';

  @override
  String get contactNoCallHistory => 'No call history';

  @override
  String get contactOpenPage => 'Open contacts';

  @override
  String get historySearchPlaceholder => 'Search calls';

  @override
  String get historySearchHint => 'Search number, customer, line, or notes';

  @override
  String get historyClearSearch => 'Clear search';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterOutbound => 'Outgoing';

  @override
  String get historyFilterInbound => 'Incoming';

  @override
  String get historyFilterMissed => 'Missed';

  @override
  String get historyFilterByDate => 'Filter by date';

  @override
  String get historyDateAll => 'All time';

  @override
  String get historyDateToday => 'Today';

  @override
  String get historyDateLast7Days => 'Last 7 days';

  @override
  String get historyDateThisMonth => 'This month';

  @override
  String historyMarkAllReadCount(int count) {
    return 'Mark read ($count)';
  }

  @override
  String historyRecordCount(int count) {
    return '$count calls';
  }

  @override
  String get historyClearRecords => 'Clear history';

  @override
  String get historyEmpty => 'No call history';

  @override
  String get historyNoMatches => 'No matching calls';

  @override
  String get historyColumnCustomer => 'Customer';

  @override
  String get historyColumnLine => 'Line';

  @override
  String get historyColumnStatus => 'Status';

  @override
  String get historyColumnDuration => 'Duration';

  @override
  String get historyColumnTime => 'Time';

  @override
  String get historyColumnActions => 'Actions';

  @override
  String get historyUnknownLine => 'Unknown line';

  @override
  String get historyDeleteRecord => 'Delete call';

  @override
  String get historyCannotDeleteActive => 'Active calls cannot be deleted';

  @override
  String get historyCannotCallBackActive =>
      'Active calls cannot be called back';

  @override
  String get historyCallBack => 'Call back';

  @override
  String get historyLive => 'Live';

  @override
  String get historyHasNoteTooltip => 'Has notes. Select to view';

  @override
  String get historyLoadingMore => 'Loading more';

  @override
  String historyLoadMoreCount(int count) {
    return 'Load more · $count shown';
  }

  @override
  String get historyNoMore => 'No more calls';

  @override
  String historyAllShownCount(int count) {
    return 'All $count calls shown';
  }

  @override
  String get historyStatusOnHold => 'On hold';

  @override
  String get historyStatusRemoteOnHold => 'Remote hold';

  @override
  String get historyStatusInCall => 'In call';

  @override
  String get historyStatusRinging => 'Ringing';

  @override
  String get historyStatusRemoteRinging => 'Remote ringing';

  @override
  String get historyStatusCalling => 'Calling';

  @override
  String get historyStatusTiming => 'Timing';

  @override
  String get historyGroupToday => 'Today';

  @override
  String get historyGroupYesterday => 'Yesterday';

  @override
  String get historyMarkAllReadTitle => 'Mark missed calls as read?';

  @override
  String historyMarkAllReadBody(int count) {
    return 'Mark $count unread missed calls as read.';
  }

  @override
  String get historyMarkAllReadConfirm => 'Mark all as read';

  @override
  String get historyConfirmCallbackTitle => 'Call this number back?';

  @override
  String get historyDialLine => 'Dial line';

  @override
  String get historyConfirmCallback => 'Call back';

  @override
  String get historyDeleteTitle => 'Delete this call record?';

  @override
  String get historyFieldNumber => 'Number';

  @override
  String get historyFieldLine => 'Line';

  @override
  String get historyDeleteBody => 'This cannot be undone.';

  @override
  String get historyDeleteConfirm => 'Delete';

  @override
  String get historyClearTitle => 'Clear call history?';

  @override
  String get historyClearBody =>
      'This cannot be undone. Active calls will be kept.';

  @override
  String get historyClearConfirm => 'Clear';

  @override
  String get historyClearError =>
      'Call history couldn\'t be cleared. Try again later.';

  @override
  String get historyCannotRedialActive => 'This call is already in progress.';

  @override
  String get historyNoCallbackNumber =>
      'This record doesn\'t have a callable number.';

  @override
  String get historyNetworkUnavailable =>
      'You\'re offline. Reconnect and try again.';

  @override
  String get historyAddLineFirst => 'Add a phone line first.';

  @override
  String get historyCallLimitReached => 'You\'ve reached the 4-call limit.';

  @override
  String get historySplitConferenceFirst =>
      'End or split the conference first.';

  @override
  String get historyNoRegisteredLine => 'No registered line is available.';

  @override
  String get historySwitchDetailHint =>
      'Select another call to view its details';

  @override
  String get historyContactDeleted =>
      'Original contact deleted. You can add it again.';

  @override
  String get historyFieldContact => 'Contact';

  @override
  String get historyFieldDirection => 'Direction';

  @override
  String get historyFieldStatus => 'Status';

  @override
  String get historyFieldCalledAt => 'Started';

  @override
  String get historyFieldAnsweredAt => 'Answered';

  @override
  String get historyFieldEndedAt => 'Ended';

  @override
  String get historyFieldDuration => 'Duration';

  @override
  String get historyFieldEndReason => 'End reason';

  @override
  String get historyNotAnswered => 'Not answered';

  @override
  String get historyInProgress => 'In progress';

  @override
  String get historyStatsTitle => 'Call stats';

  @override
  String get historyMetricDialToRing => 'Dial to ring';

  @override
  String get historyMetricRingingDuration => 'Ring duration';

  @override
  String get historyMetricRingToAnswer => 'Ring to answer';

  @override
  String get historyMetricMediaReady => 'Media ready';

  @override
  String get historyMetricHoldCount => 'Holds';

  @override
  String get historyMetricHoldDuration => 'Hold time';

  @override
  String historyTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# times',
      one: '1 time',
      zero: '0 times',
    );
    return '$_temp0';
  }

  @override
  String get historyImmediate => 'Instant';

  @override
  String historySeconds(String value) {
    return '${value}s';
  }

  @override
  String get historyAddNote => 'Add note';

  @override
  String get historyNote => 'Call notes';

  @override
  String get historyEditNote => 'Edit note';

  @override
  String get historyEditNoteTitle => 'Edit call notes';

  @override
  String get historyNoteHint => 'Add key points from this call';

  @override
  String get historyNoteSaveError => 'Could not save call notes. Try again.';

  @override
  String historyNoteBlindTransferTo(String target) {
    return 'Blind transfer to: $target';
  }

  @override
  String historyNoteConference(String note) {
    return 'Conference note: $note';
  }

  @override
  String historyNoteCustomer(String note) {
    return 'Customer note: $note';
  }

  @override
  String get historyDetailTitle => 'Call details';

  @override
  String get historyViewContact => 'View contact';

  @override
  String get historyReAddContact => 'Add contact again';

  @override
  String get historyAddContact => 'Add contact';

  @override
  String get historyRecentCalls => 'Recent calls';

  @override
  String get historyNoRecentCalls => 'No recent calls';

  @override
  String historyCallbackNumber(String number) {
    return 'Call back $number';
  }

  @override
  String historyYesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String get historyLoadMoreError =>
      'More calls couldn\'t be loaded. Try again later.';

  @override
  String get historyStatusPeerRejected => 'Declined';

  @override
  String get historyReasonCallEnded => 'Call ended';

  @override
  String get historyReasonIncomingEnded => 'Incoming call ended';

  @override
  String get historyReasonAuthenticationFailed =>
      'Account authentication failed';

  @override
  String get historyReasonRemoteRejected => 'The other party declined the call';

  @override
  String get historyReasonCallRejected => 'Call rejected';

  @override
  String get historyReasonInvalidNumber =>
      'Number doesn\'t exist or can\'t be reached';

  @override
  String get historyReasonNoAnswer => 'No answer';

  @override
  String get historyReasonTimeout => 'Call timed out';

  @override
  String get historyReasonRemoteUnavailable =>
      'The other party couldn\'t be reached';

  @override
  String get historyReasonRingingUnanswered => 'Rang with no answer';

  @override
  String get historyReasonRemoteBusy => 'Line busy';

  @override
  String get historyReasonCanceled => 'Call canceled';

  @override
  String get historyReasonUnsupportedMedia =>
      'The other party doesn\'t support this call';

  @override
  String get historyReasonServiceUnavailable =>
      'Phone service is temporarily unavailable';

  @override
  String get historyReasonRedirected => 'Call forwarded or redirected';

  @override
  String get historyReasonCallIncomplete => 'Call not completed';

  @override
  String get historyReasonServiceError => 'Phone service error';

  @override
  String get historyReasonRemoteCannotAnswer =>
      'The other party couldn\'t answer';

  @override
  String get historyReasonNotConnected => 'Not connected';

  @override
  String get historyReasonMediaFailed => 'Media negotiation failed';

  @override
  String get historyReasonBlindTransfer => 'Blind transferred';

  @override
  String get historyReasonShortAuthenticationFailed => 'Authentication failed';

  @override
  String get historyReasonShortRemoteRejected => 'Declined';

  @override
  String get historyReasonShortInvalidNumber => 'Invalid number';

  @override
  String get historyReasonShortServiceError => 'Service error';

  @override
  String get historyReasonShortRedirected => 'Forwarded';

  @override
  String get historyReasonShortMediaFailed => 'Media failed';

  @override
  String get historyReasonShortBlindTransfer => 'Transferred';

  @override
  String historyReasonWithSipCode(String reason, int code) {
    return '$reason (SIP $code)';
  }

  @override
  String get activeCallEmpty => 'No active calls';

  @override
  String get activeCallGoToDialpad => 'Go to dialpad';

  @override
  String get activeCallAnswer => 'Answer';

  @override
  String get activeCallReject => 'Decline';

  @override
  String get activeCallMute => 'Mute';

  @override
  String get activeCallUnmute => 'Unmute';

  @override
  String get activeCallKeypad => 'Keypad';

  @override
  String get activeCallHold => 'Hold';

  @override
  String get activeCallResume => 'Resume';

  @override
  String get activeCallTransfer => 'Transfer';

  @override
  String get activeCallMuteRemoteAudio => 'Mute audio';

  @override
  String get activeCallRestoreRemoteAudio => 'Unmute audio';

  @override
  String get activeCallAudio => 'Audio';

  @override
  String get activeCallHangUp => 'End call';

  @override
  String get activeCallHangUpAll => 'End all';

  @override
  String get activeCallMerge => 'Merge';

  @override
  String get activeCallSplit => 'Split';

  @override
  String get activeCallResumeConference => 'Resume conference';

  @override
  String get activeCallOperationAnswering => 'Answering';

  @override
  String get activeCallOperationRejecting => 'Declining';

  @override
  String get activeCallOperationEnding => 'Ending call';

  @override
  String get activeCallOperationHolding => 'Placing on hold';

  @override
  String get activeCallOperationResuming => 'Resuming';

  @override
  String get activeCallOperationSplitting => 'Splitting conference';

  @override
  String get activeCallOperationMerging => 'Merging calls';

  @override
  String get activeCallOperationTransferring => 'Transferring';

  @override
  String get activeCallStatusLocalHold => 'On hold';

  @override
  String get activeCallStatusRemoteHold => 'Remote hold';

  @override
  String get activeCallStatusCalling => 'Calling';

  @override
  String get activeCallStatusIncoming => 'Incoming call';

  @override
  String get activeCallStatusWaitingAnswer => 'Awaiting answer';

  @override
  String get activeCallStatusRemoteRinging => 'Ringing';

  @override
  String get activeCallStatusConnecting => 'Connecting';

  @override
  String get activeCallStatusInCall => 'In call';

  @override
  String get activeCallStatusEnded => 'Call ended';

  @override
  String activeCallStatusUnknown(int state) {
    return 'Unknown status ($state)';
  }

  @override
  String activeCallHeldLocallyFor(String duration) {
    return 'On hold · $duration';
  }

  @override
  String activeCallHeldByRemoteFor(String duration) {
    return 'Held by other party · $duration';
  }

  @override
  String get activeCallPriorityContact => 'Priority customer';

  @override
  String get activeCallOperationInProgress => 'Action in progress';

  @override
  String get activeCallDuration => 'Call duration';

  @override
  String get activeCallCurrentStatus => 'Current status';

  @override
  String get activeCallMediaConnected => 'Media connected';

  @override
  String get activeCallMediaLocalHold => 'Local hold';

  @override
  String get activeCallMediaRemoteHold => 'Remote hold';

  @override
  String get activeCallMediaError => 'Media issue';

  @override
  String get activeCallMediaNotReady => 'Media not connected';

  @override
  String get activeCallMediaPending => 'Waiting for media';

  @override
  String get activeCallMediaUnconfirmed => 'Media not confirmed';

  @override
  String activeCallMediaUnknown(int status) {
    return 'Media status $status';
  }

  @override
  String get activeCallSignalingUnknown => 'Signaling unknown';

  @override
  String activeCallConfiguredMode(String mode) {
    return '$mode configured';
  }

  @override
  String get activeCallMedia => 'Media';

  @override
  String get activeCallSignaling => 'Signaling';

  @override
  String get activeCallMediaEncryption => 'Media encryption';

  @override
  String get activeCallTlsEncrypted => 'TLS encrypted';

  @override
  String get activeCallSrtpNegotiated => 'SRTP negotiated';

  @override
  String get activeCallSrtpNotDetected => 'SRTP not detected';

  @override
  String get activeCallMediaNegotiating => 'Waiting for media negotiation';

  @override
  String get activeCallEncryptedCall => 'Call encrypted';

  @override
  String get activeCallEncryptedAudio => 'Audio encrypted';

  @override
  String get activeCallStandardCall => 'Standard call';

  @override
  String get activeCallVerifyingEncryption => 'Verifying encryption';

  @override
  String activeCallLabeledValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String activeCallValueDetail(String value, String detail) {
    return '$value ($detail)';
  }

  @override
  String get activeCallTransport => 'Transport';

  @override
  String get activeCallTransferTitle => 'Transfer call';

  @override
  String get activeCallTransferDescription =>
      'The call will transfer immediately, and you will leave the call.';

  @override
  String get activeCallCurrentLineUnknown => 'Current line unknown';

  @override
  String get activeCallTransferTargetHint => 'Enter a number or SIP URI';

  @override
  String activeCallTransferTargetExample(String host) {
    return 'For example, 6545 or sip:6545@$host';
  }

  @override
  String get activeCallChooseContact => 'Choose a contact';

  @override
  String activeCallNumberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# numbers',
      one: '1 number',
      zero: 'No numbers',
    );
    return '$_temp0';
  }

  @override
  String get activeCallTransferSearchHint =>
      'Search contacts, numbers, or companies';

  @override
  String get activeCallEnterTransferNumber => 'Enter a transfer number';

  @override
  String get activeCallConfirmTransfer => 'Transfer call';

  @override
  String get activeCallNoContacts => 'No contacts';

  @override
  String get activeCallNoContactMatches => 'No matching contacts';

  @override
  String get activeCallUnnamedContact => 'Unnamed contact';

  @override
  String get activeCallViewingConferenceMember => 'Viewing conference member';

  @override
  String get activeCallCurrentActiveCall => 'Active call';

  @override
  String get activeCallViewingCall => 'Viewing this call';

  @override
  String activeCallResumeForAudio(String name) {
    return '$name · Resume to join audio';
  }

  @override
  String activeCallConferenceInterrupted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# members',
      one: '1 member',
    );
    return 'The conference is on hold. Resume its $_temp0 after handling this call.';
  }

  @override
  String get activeCallConferenceTitle => 'Conference call';

  @override
  String get activeCallConferencePaused => 'Conference paused';

  @override
  String get activeCallConferenceInProgress => 'In conference';

  @override
  String get activeCallConferenceStatus => 'Conference status';

  @override
  String get activeCallConferenceDuration => 'Conference duration';

  @override
  String get activeCallPaused => 'Paused';

  @override
  String activeCallMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String activeCallCustomerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# customers',
      one: '1 customer',
      zero: 'No customers',
    );
    return '$_temp0';
  }

  @override
  String activeCallLineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# lines',
      one: '1 line',
      zero: 'No lines',
    );
    return '$_temp0';
  }

  @override
  String get activeCallPanelConferenceMembers => 'Conference members';

  @override
  String get activeCallPanelCurrentCalls => 'Current calls';

  @override
  String activeCallPanelCount(int current, int total) {
    return '$current/$total calls';
  }

  @override
  String get activeCallNewIncomingAndOthers => 'New incoming and other calls';

  @override
  String get activeCallOtherCalls => 'Other calls';

  @override
  String get activeCallNoActiveCalls => 'No active calls';

  @override
  String get activeCallCustomerInfo => 'Customer information';

  @override
  String get activeCallConferenceCustomers => 'Conference customers';

  @override
  String get activeCallConferenceCustomersDescription =>
      'Customers in this conference';

  @override
  String get activeCallUnmatchedContact => 'No matching contact';

  @override
  String get activeCallUnknownNumber => 'Unknown number';

  @override
  String get activeCallAddContact => 'Add to contacts';

  @override
  String get activeCallViewContact => 'View contact';

  @override
  String get activeCallDefaultNumber => 'Default number';

  @override
  String get activeCallCustomer => 'Call customer';

  @override
  String get activeCallViewContactDetails => 'View contact details';

  @override
  String get activeCallCurrentNumber => 'Current number';

  @override
  String get activeCallCurrentNote => 'Current call notes';

  @override
  String get activeCallNoteHint =>
      'Add key points. Notes are saved to call history when the call ends.';

  @override
  String get activeCallConferenceNote => 'Conference notes';

  @override
  String activeCallNoteSyncMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# conference members',
      one: '1 conference member',
    );
    return 'Sync to $_temp0';
  }

  @override
  String activeCallNoteSavePrimary(String name) {
    return 'Save only to the primary record: $name';
  }

  @override
  String get activeCallCustomerNote => 'Current customer notes';

  @override
  String get activeCallSharedConferenceNote => 'Shared conference notes';

  @override
  String get activeCallSharedNoteHint =>
      'Add the conference outcome to every member\'s call record';

  @override
  String get activeCallCustomerNoteHint =>
      'Add notes for this customer to the primary call record only';

  @override
  String get activeCallNoteStaged => 'Saved';

  @override
  String get activeCallNoteEmpty => 'Not added';

  @override
  String get activeCallNoteStagedTooltip =>
      'Note saved for this call and added to history when the call ends';

  @override
  String get activeCallNoteEmptyTooltip =>
      'Notes save automatically and are added to history when the call ends';

  @override
  String get activeCallViewing => 'Viewing';

  @override
  String get activeCallRemoteAudioMuted => 'Audio muted';

  @override
  String get activeCallDtmfWaiting => 'Waiting for input';

  @override
  String get activeCallDtmfTitle => 'Keypad';

  @override
  String get activeCallDtmfClose => 'Close keypad';

  @override
  String activeCallDtmfSending(String digit) {
    return 'Sending $digit';
  }

  @override
  String activeCallDtmfSent(String digit) {
    return 'Sent $digit';
  }

  @override
  String activeCallDtmfFailed(String digit) {
    return 'Couldn\'t send $digit';
  }

  @override
  String get activeCallMyAudio => 'Microphone';

  @override
  String get activeCallRemoteAudio => 'Speaker';

  @override
  String activeCallMutedValue(String label) {
    return '$label: muted';
  }

  @override
  String activeCallVolumeValue(int volume) {
    return ', volume $volume%';
  }

  @override
  String activeCallMeterMuted(String label, String volume) {
    return '$label: muted$volume';
  }

  @override
  String activeCallMeterValues(
    String label,
    int current,
    int peak,
    String volume,
  ) {
    return '$label: current $current%, peak $peak%$volume';
  }

  @override
  String get audioAddLine => 'Add line';

  @override
  String get audioSoundAlerts => 'Sounds';

  @override
  String get audioIncomingRingtone => 'Incoming ringtone';

  @override
  String get audioIncomingRingtoneDescription =>
      'Play a ringtone for incoming calls';

  @override
  String get audioOutgoingRingback => 'Outgoing ringback';

  @override
  String get audioOutgoingRingbackDescription =>
      'Play while waiting for the other person to answer';

  @override
  String get audioCallEndedTone => 'Call ended sound';

  @override
  String get audioCallEndedToneDescription => 'Play when a connected call ends';

  @override
  String get audioDialpadTones => 'Dialpad tones';

  @override
  String get audioDialpadTonesDescription =>
      'Play tones while entering a number; off by default';

  @override
  String get audioRouting => 'Audio routing';

  @override
  String get audioFollowSystem => 'Follow system';

  @override
  String get audioChooseDevices => 'Choose devices';

  @override
  String get audioFollowSystemDescription =>
      'Recommended. Automatically follows system audio when devices change';

  @override
  String get audioChooseDevicesDescription =>
      'Choose devices for VPhone; system settings may affect actual routing';

  @override
  String get audioAutoSwitch => 'Switch when devices change';

  @override
  String get audioAutoSwitchDescription =>
      'Restore an available audio path when a headset changes during a call';

  @override
  String get audioInputOutput => 'Input & output';

  @override
  String get audioMicrophone => 'Microphone';

  @override
  String get audioInputDevice => 'Input device';

  @override
  String get audioSpeaker => 'Speaker';

  @override
  String get audioOutputDevice => 'Output device';

  @override
  String get audioSystemDefaultInput => 'System default input';

  @override
  String get audioSystemDefaultOutput => 'System default output';

  @override
  String get audioDeviceNotSelected => 'Not selected';

  @override
  String get audioDeviceUnavailable => 'Device unavailable';

  @override
  String audioRecordingRemaining(int seconds) {
    return 'Recording · ${seconds}s';
  }

  @override
  String get audioRecording => 'Recording';

  @override
  String get audioPreparingPlayback => 'Preparing playback';

  @override
  String get audioPlaying => 'Playing';

  @override
  String get audioRecordingTest => 'Test microphone';

  @override
  String get audioTestOutput => 'Test speaker';

  @override
  String get audioMute => 'Mute';

  @override
  String get audioUnmute => 'Unmute';

  @override
  String get audioTesting => 'Testing';

  @override
  String get audioReady => 'Ready';

  @override
  String get audioDeviceNeedsAttention => 'Audio device needs attention';

  @override
  String get audioFollowingSystem => 'Following system audio';

  @override
  String get audioUsingSelectedDevices => 'Using selected devices';

  @override
  String get audioFollowingSystemStatus =>
      'Input and output follow system sound settings';

  @override
  String get audioUsingSelectedDevicesStatus =>
      'Using the selected microphone and speaker';

  @override
  String get audioRefreshDevices => 'Refresh audio devices';

  @override
  String get audioOpenSystemSoundSettings => 'Open system sound settings';

  @override
  String get audioReconnectDevices => 'Reconnect audio devices';

  @override
  String get audioOpenSystemSoundSettingsHint =>
      'Open Sound in system settings';

  @override
  String get audioFollowSystemDeviceHint => 'Follows system sound settings';

  @override
  String get audioSelectedDeviceHint =>
      'Uses this device when possible; system settings may affect routing';

  @override
  String get audioChangeDevicesInSystemHint =>
      'VPhone is following the system. Change input and output in system sound settings';

  @override
  String get audioPermissionEnabled => 'Microphone access is on';

  @override
  String get audioPermissionDisabled => 'Microphone access is off';

  @override
  String get audioPermissionRestricted => 'Microphone access is restricted';

  @override
  String get audioPermissionPending => 'Microphone access is required';

  @override
  String get audioPermissionSystemManaged =>
      'Microphone access is managed by the system';

  @override
  String get audioPermissionUnknown => 'Microphone access not checked';

  @override
  String get audioPermissionEnabledDescription =>
      'VPhone can use the microphone';

  @override
  String get audioPermissionDisabledDescription =>
      'Allow VPhone to use the microphone in system settings';

  @override
  String get audioPermissionRestrictedDescription =>
      'Microphone access is restricted by the system or an administrator';

  @override
  String get audioPermissionPendingDescription =>
      'Click to request microphone access';

  @override
  String get audioPermissionSystemManagedDescription =>
      'Microphone access is managed by the operating system';

  @override
  String get audioPermissionUnknownDescription =>
      'Click to check microphone access';

  @override
  String get audioPermissionOpenSettings => 'Open system settings';

  @override
  String get audioPermissionRequest => 'Request microphone access';

  @override
  String get audioPermissionCheck => 'Check microphone access';

  @override
  String get audioPermissionAvailableToast => 'Microphone access is on';

  @override
  String get audioPermissionRequiredToast =>
      'Allow VPhone to use the microphone in system settings';

  @override
  String get audioPermissionPendingToast =>
      'The system will request microphone access when a call starts';

  @override
  String get audioPermissionSystemManagedToast =>
      'Microphone access is managed by the operating system';

  @override
  String get audioPermissionUnknownToast =>
      'Microphone access could not be confirmed';

  @override
  String get audioIssueMicrophonePermission =>
      'Allow VPhone to use the microphone in system settings';

  @override
  String get audioIssueNoMicrophone =>
      'No microphone detected. Connect a headset or input device';

  @override
  String get audioIssueNoSpeaker =>
      'No speaker detected. Connect a headset or output device';

  @override
  String get audioIssueNoInputOutput =>
      'No microphone or speaker detected. Connect an audio device';

  @override
  String get audioIssueInvalidDevice =>
      'The current audio device is no longer available. Refresh or choose another device';

  @override
  String get audioIssueNoDevice => 'No microphone or speaker was detected';

  @override
  String get audioIssueNoDefaultDevice =>
      'The default microphone or speaker is unavailable';

  @override
  String get audioIssueNotReady =>
      'The audio device is not ready. Try again shortly';

  @override
  String audioIssueUnavailable(int code) {
    return 'Audio is temporarily unavailable (error $code). Reconnect the device and try again';
  }

  @override
  String get audioIssueSpeakerOnly =>
      'The microphone is temporarily unavailable. Speaker-only audio is active; check the input device';

  @override
  String get aboutLoading => 'Loading';

  @override
  String get aboutTagline => 'VeServe desktop softphone';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutRuntime => 'Runtime';

  @override
  String get aboutAppId => 'App ID';

  @override
  String get aboutCompany => 'Company';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutPhoneService => 'Phone service';

  @override
  String get aboutServiceRunning => 'Running';

  @override
  String get aboutServiceStopped => 'Stopped';

  @override
  String get aboutEmailCopied => 'Email copied';

  @override
  String get diagnosticsShowLogs => 'Show logs';

  @override
  String get diagnosticsEventTypes => 'Device, registration, and call events';

  @override
  String get diagnosticsClearLogs => 'Clear logs';

  @override
  String get diagnosticsExporting => 'Exporting';

  @override
  String get diagnosticsExportLogs => 'Export logs';

  @override
  String get diagnosticsPrivacyNotice =>
      'Logs may contain phone numbers, server addresses, and network details. Share only with trusted recipients.';

  @override
  String get diagnosticsLogsHidden => 'Logs hidden';

  @override
  String get diagnosticsExported => 'Diagnostic logs exported';

  @override
  String get diagnosticsExportFailed => 'Export failed. Try again';

  @override
  String get callSettingsControls => 'Call controls';

  @override
  String get callSettingsMaxCalls => 'Concurrent calls';

  @override
  String callSettingsMaxCallsValue(int count) {
    return '$count';
  }

  @override
  String get callSettingsDtmfMethod => 'DTMF mode';

  @override
  String get callSettingsAutoHold => 'Auto-hold other calls';

  @override
  String get callSettingsAutoHoldDescription =>
      'Hold other calls when answering, calling, or resuming';

  @override
  String get callSettingsShortcuts => 'Quick settings';

  @override
  String get callSettingsDefaultMute => 'Mute by default';

  @override
  String get callSettingsOff => 'Off';

  @override
  String get callSettingsConference => 'Conference';

  @override
  String get callSettingsActive => 'Active';

  @override
  String accountSettingsSummary(int total, int online) {
    return '$total lines · $online online';
  }

  @override
  String get accountSettingsDisconnectAll => 'Disconnect';

  @override
  String get accountSettingsRestarting => 'Restarting';

  @override
  String get accountSettingsRestartApp => 'Restart';

  @override
  String get accountSettingsAddLine => 'Add line';

  @override
  String get accountSettingsEmpty => 'No lines yet';

  @override
  String get accountSettingsEmptyHint => 'Add a line to get started';

  @override
  String get accountSettingsDefaultPinned =>
      'The default line stays at the top';

  @override
  String get accountSettingsDragToReorder => 'Drag to reorder';

  @override
  String get accountSettingsReorderUnavailable => 'Reordering unavailable';

  @override
  String get accountSettingsDefaultOutgoing => 'Default';

  @override
  String get accountSettingsSetDefault => 'Set default';

  @override
  String get accountSettingsRestartDescription =>
      'The app will close and reopen. Account settings are kept.';

  @override
  String get accountSettingsRestartStepSave =>
      'Save local settings and call history';

  @override
  String get accountSettingsRestartStepClose => 'Close and reopen the app';

  @override
  String get accountSettingsRestartStepRestore => 'Restore saved lines';

  @override
  String get accountSettingsRestartRecommended =>
      'Use after sleep, a network change, or an abnormal line state.';

  @override
  String get accountSettingsRestartCallWarning =>
      'Active calls will end and all lines will disconnect.';

  @override
  String get accountStatusOnline => 'Online';

  @override
  String get accountStatusConnecting => 'Connecting';

  @override
  String get accountStatusUpdating => 'Updating';

  @override
  String get accountStatusDisabled => 'Disabled';

  @override
  String get accountStatusFailed => 'Failed';

  @override
  String get accountStatusOffline => 'Offline';

  @override
  String get accountStatusRestoring => 'Restoring';

  @override
  String get accountDialogAddTitle => 'Add line';

  @override
  String get accountDialogEditTitle => 'Edit line';

  @override
  String get accountDialogAccountInfo => 'Account';

  @override
  String get accountDialogLineName => 'Line name (optional)';

  @override
  String get accountDialogLineNameHint => 'Shown only in VPhone, e.g. Support';

  @override
  String get accountDialogUsername => 'Line account';

  @override
  String get accountDialogPassword => 'Password';

  @override
  String get accountDialogShowPassword => 'Show password';

  @override
  String get accountDialogHidePassword => 'Hide password';

  @override
  String get accountDialogServer => 'Server';

  @override
  String get accountDialogPort => 'Port';

  @override
  String accountDialogDefaultPortHint(String transport, int port) {
    return 'Optional · $transport defaults to $port';
  }

  @override
  String get accountDialogConnection => 'Connection';

  @override
  String get accountDialogNetworkUnavailable =>
      'No network. A line cannot be added now';

  @override
  String get accountDialogSave => 'Save';

  @override
  String get accountDialogAddAndRegister => 'Add & register';

  @override
  String get accountDialogTransport => 'Transport';

  @override
  String accountDialogDefaultPort(int port) {
    return 'Default port $port';
  }

  @override
  String get accountDialogTransportStandard => 'Standard';

  @override
  String get accountDialogTransportCompatible => 'Compatible';

  @override
  String get accountDialogTransportSecure => 'Secure';

  @override
  String get accountDialogMediaEncryption => 'Media encryption';

  @override
  String get accountDialogSrtpWithoutTlsWarning =>
      'TLS is off. SRTP will not require secure signaling; SDES keys are sent in SDP. TLS is recommended.';

  @override
  String get accountDialogMediaNone => 'Unencrypted RTP';

  @override
  String get accountDialogMediaSdes => 'SDES-SRTP';

  @override
  String get accountDialogMediaDtls => 'DTLS-SRTP';

  @override
  String get accountDialogMediaOptionalDtls => 'Optional SRTP (DTLS)';

  @override
  String get accountDialogMediaOptionalSdes => 'Optional SRTP (SDES)';

  @override
  String get accountDialogMediaBestCompatibility => 'Best compatibility';

  @override
  String get accountDialogMediaUseTls => 'Use with TLS';

  @override
  String get accountDialogMediaAsteriskDtls => 'For Asterisk DTLS';

  @override
  String get accountDialogMediaAllowsFallback => 'Allows RTP fallback';

  @override
  String get accountDialogMediaLegacySrtp => 'For legacy SRTP';

  @override
  String get accountDialogAdvanced => 'Advanced';

  @override
  String get accountDialogAdvancedAccount => 'Account';

  @override
  String get accountDialogAuthUsername => 'Auth username (optional)';

  @override
  String get accountDialogAuthUsernameHint =>
      'Uses the line account when empty; SIP auth only';

  @override
  String get accountDialogSipDisplayName => 'SIP display name (optional)';

  @override
  String get accountDialogSipDisplayNameHint =>
      'May be shown to peers; use Line name for local display';

  @override
  String get accountDialogAdvancedNetwork => 'Network';

  @override
  String get accountDialogOutboundProxy => 'Outbound proxy (optional)';

  @override
  String get accountDialogOutboundProxyHint =>
      'Example: sip:proxy.example.com:5060; empty connects directly';

  @override
  String get accountDialogEnableIpv6 => 'Enable IPv6';

  @override
  String get accountDialogEnableIpv6Hint =>
      'Off by default to reduce SIP and media candidates';

  @override
  String get accountDialogEnableIce => 'Enable ICE';

  @override
  String get accountDialogEnableIceHint =>
      'Negotiates media across complex NAT';

  @override
  String get accountDialogEnableStun => 'Enable STUN';

  @override
  String get accountDialogEnableStunHint =>
      'Discovers public mappings for NAT traversal';

  @override
  String get accountDialogStunServer => 'STUN server';

  @override
  String get accountDialogStunServerHint =>
      'Empty uses the default; separate multiple servers with commas or spaces';

  @override
  String get accountDialogEnableTurn => 'Enable TURN';

  @override
  String get accountDialogTurnHint =>
      'Relays media when direct connection fails';

  @override
  String get accountDialogTurnNeedsIce => 'Enable ICE first';

  @override
  String get accountDialogTurnServer => 'TURN server';

  @override
  String get accountDialogTurnUsername => 'TURN username';

  @override
  String get accountDialogTurnTransport => 'TURN transport';

  @override
  String get accountDialogTurnPassword => 'TURN password';

  @override
  String get accountDialogTurnUdp => 'Default relay';

  @override
  String get accountDialogTurnTcp => 'Stable on restricted networks';

  @override
  String get accountDialogTurnTls => 'Good for enterprise networks';

  @override
  String get accountDialogAdvancedAuth => 'Auth username';

  @override
  String get accountDialogAdvancedDisplayName => 'SIP display name';

  @override
  String get accountDialogAdvancedProxy => 'Outbound proxy';

  @override
  String get accountDialogAdvancedDefaults => 'Account defaults';

  @override
  String get accountDialogIceOff => 'ICE off';

  @override
  String get accountDialogStunOff => 'STUN off';

  @override
  String get accountDialogStunDefault => 'Default STUN';

  @override
  String get accountDialogStunCustom => 'Custom STUN';

  @override
  String get accountDialogIpv4Only => 'IPv4 only';

  @override
  String get accountDialogUdpIceWarning =>
      'UDP + ICE can enlarge SIP messages. Some networks drop fragments. Use TCP/TLS or disable ICE.';

  @override
  String get accountDialogRequired => 'Required';

  @override
  String get accountDialogInvalidPort => 'Enter a port from 1 to 65535';

  @override
  String get accountDialogConfirmUdpIce => 'Use UDP + ICE?';

  @override
  String get accountDialogConfirmUdpIceBody =>
      'UDP + ICE may block outbound calls on some networks. Use TCP/TLS or disable ICE.';

  @override
  String get accountDialogReview => 'Review';

  @override
  String get accountDialogSaveAnyway => 'Save anyway';

  @override
  String accountLimitReached(int count) {
    return 'Up to $count lines are supported. Remove a line and try again';
  }
}
