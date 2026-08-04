part of '../../../main.dart';

const _appBackground = AppColors.appBackground;
const _sidebarBackground = AppColors.sidebarBackground;
const _panelBackground = AppColors.panelBackground;
const _subtlePanel = AppColors.subtlePanel;
const _hoverPanel = AppColors.hoverPanel;
const _softBorder = AppColors.softBorder;
const _textPrimary = AppColors.textPrimary;
const _textSecondary = AppColors.textSecondary;
const _brandGreen = AppColors.brandGreen;
const _dangerRed = AppColors.dangerRed;
const _callGreen = AppColors.callGreen;

const double _radiusXs = 6;
const double _radiusSm = 8;
const double _radiusMd = 10;
const double _iconXs = 14;
const double _iconSm = 16;
const double _iconMd = 18;
const double _iconLg = 20;

const _fontFallback = <String>[
  'PingFang SC',
  'SF Pro Text',
  'Microsoft YaHei',
  'Noto Sans CJK SC',
  'Helvetica Neue',
  'Arial',
];

class AppIcons {
  const AppIcons._();

  static const settings = LucideIcons.settings300;
  static const close = LucideIcons.x300;
  static const search = LucideIcons.search300;
  static const clear = LucideIcons.x300;
  static const confirm = LucideIcons.badgeCheck300;
  static const more = LucideIcons.ellipsis300;
  static const next = LucideIcons.chevronRight300;
  static const chevronDown = LucideIcons.chevronDown300;
  static const chevronUp = LucideIcons.chevronUp300;
  static const check = LucideIcons.check300;
  static const add = LucideIcons.plus300;
  static const edit = LucideIcons.squarePen300;
  static const save = LucideIcons.save300;
  static const copy = LucideIcons.copy300;
  static const export = LucideIcons.download300;
  static const delete = LucideIcons.trash2300;
  static const refresh = LucideIcons.refreshCw300;
  static const power = LucideIcons.power300;
  static const login = LucideIcons.logIn300;

  static const appLogo = LucideIcons.phoneCall300;
  static const dialpad = LucideIcons.grid3x3300;
  static const call = LucideIcons.phone300;
  static const callEnd = LucideIcons.phoneOff300;
  static const calls = LucideIcons.phoneCall300;
  static const incoming = LucideIcons.phoneIncoming300;
  static const missed = LucideIcons.phoneMissed300;
  static const outgoing = LucideIcons.phoneOutgoing300;
  static const contacts = LucideIcons.users300;
  static const contactAdd = LucideIcons.userPlus300;
  static const person = LucideIcons.user300;
  static const history = LucideIcons.history300;
  static const calendar = LucideIcons.calendarDays300;
  static const headset = LucideIcons.headset300;
  static const line = LucideIcons.route300;
  static const lines = LucideIcons.waypoints300;
  static const network = LucideIcons.network300;
  static const server = LucideIcons.serverCog300;
  static const transport = LucideIcons.cable300;
  static const defaultLine = LucideIcons.phoneOutgoing300;
  static const pointer = LucideIcons.mousePointerClick300;

  static const account = LucideIcons.circleUserRound300;
  static const audio = LucideIcons.headphones300;
  static const callSettings = LucideIcons.phone300;
  static const diagnostics = LucideIcons.bug300;
  static const devices = LucideIcons.monitorSpeaker300;
  static const meters = LucideIcons.audioLines300;
  static const microphone = LucideIcons.mic300;
  static const microphoneOff = LucideIcons.micOff300;
  static const speaker = LucideIcons.volume2300;
  static const speakerOff = LucideIcons.volumeOff300;
  static const audioMode = LucideIcons.slidersHorizontal300;
  static const automatic = LucideIcons.sparkles300;
  static const info = LucideIcons.info300;
  static const activity = LucideIcons.activity300;
  static const pause = LucideIcons.pause300;
  static const play = LucideIcons.play300;
  static const stop = LucideIcons.square300;
  static const merge = LucideIcons.merge300;
  static const split = LucideIcons.split300;
  static const tune = LucideIcons.slidersHorizontal300;
  static const bolt = LucideIcons.zap300;

  static const favorite = LucideIcons.star300;
  static const organization = LucideIcons.building2300;
  static const department = LucideIcons.badge300;
  static const note = LucideIcons.notebookText300;
  static const receipt = LucideIcons.receiptText300;
  static const clean = LucideIcons.eraser300;
  static const route = LucideIcons.route300;
  static const lock = LucideIcons.lock300;
  static const key = LucideIcons.key300;
  static const visible = LucideIcons.eye300;
  static const hidden = LucideIcons.eyeOff300;
  static const host = LucideIcons.server300;
  static const public = LucideIcons.globe300;
  static const cloud = LucideIcons.cloudCog300;
  static const security = LucideIcons.shieldCheck300;
  static const hub = LucideIcons.waypoints300;
  static const swap = LucideIcons.gitPullRequest300;
}

ThemeData _buildAppTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: _brandGreen,
    brightness: Brightness.light,
  );
  final colors = base.copyWith(
    primary: _brandGreen,
    onPrimary: Colors.white,
    surface: _panelBackground,
    surfaceContainerLowest: _panelBackground,
    surfaceContainerLow: _subtlePanel,
    surfaceContainer: _appBackground,
    surfaceContainerHigh: _hoverPanel,
    outline: _softBorder,
    onSurface: _textPrimary,
    onSurfaceVariant: _textSecondary,
  );
  final textTheme = _buildTextTheme();

  return ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: _appBackground,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    fontFamilyFallback: _fontFallback,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    dividerTheme: const DividerThemeData(color: _softBorder, thickness: 0.7),
    iconTheme: const IconThemeData(size: _iconMd, color: _textSecondary),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: _panelBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(_radiusSm)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: _subtlePanel,
      hintStyle: textTheme.bodyMedium?.copyWith(color: _textSecondary),
      labelStyle: textTheme.bodyMedium?.copyWith(color: _textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      prefixIconColor: _textSecondary,
      suffixIconColor: _textSecondary,
      prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(_radiusSm)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(_radiusSm)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(_radiusSm)),
        borderSide: BorderSide(color: _textPrimary, width: 0.9),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        iconSize: _iconMd,
        textStyle: textTheme.labelLarge,
        overlayColor: _hoverPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusSm),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        foregroundColor: _textPrimary,
        backgroundColor: _panelBackground,
        iconSize: _iconMd,
        textStyle: textTheme.labelLarge,
        side: const BorderSide(color: _softBorder),
        overlayColor: _hoverPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusSm),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        foregroundColor: _textPrimary,
        iconSize: _iconMd,
        textStyle: textTheme.labelLarge,
        overlayColor: _hoverPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusSm),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size.square(34),
        fixedSize: const Size.square(34),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: _textSecondary,
        hoverColor: _hoverPanel,
        highlightColor: _hoverPanel,
        iconSize: _iconMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusSm),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      visualDensity: VisualDensity.compact,
      side: const BorderSide(color: _softBorder, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _subtlePanel,
      selectedColor: _hoverPanel,
      side: BorderSide.none,
      labelStyle: textTheme.bodySmall,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusSm),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _panelBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      textStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusSm),
        side: const BorderSide(color: _softBorder),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: _textPrimary,
      unselectedLabelColor: _textSecondary,
      labelStyle: textTheme.labelMedium,
      unselectedLabelStyle: textTheme.labelMedium,
      indicatorColor: _textPrimary,
      dividerColor: _softBorder,
    ),
    listTileTheme: ListTileThemeData(
      dense: true,
      minLeadingWidth: 24,
      iconColor: _textSecondary,
      textColor: _textPrimary,
      titleTextStyle: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: textTheme.bodySmall,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _panelBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusMd),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
  );
}

TextTheme _buildTextTheme() {
  const base = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      height: 1.18,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      height: 1.22,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      height: 1.26,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      height: 1.32,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      height: 1.36,
      fontWeight: FontWeight.w600,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      height: 1.38,
      fontWeight: FontWeight.w600,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.42,
      fontWeight: FontWeight.w400,
      color: _textSecondary,
      letterSpacing: 0,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: _textPrimary,
      letterSpacing: 0,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: _textSecondary,
      letterSpacing: 0,
    ),
  );
  return base;
}
