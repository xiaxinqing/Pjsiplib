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
  String get contactNewTitle => 'Add contact';

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
  String get contactsAdd => 'Add contact';

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
}
