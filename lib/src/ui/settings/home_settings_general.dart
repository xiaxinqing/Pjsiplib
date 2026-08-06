part of '../../../main.dart';

/// 通用设置：承载语言、窗口和提醒等不属于电话引擎的应用级偏好。
extension _HomeSettingsGeneral on _MyHomePageState {
  Widget _buildGeneralSettingsTab() {
    final l10n = context.l10n;
    final preference = ref.watch(localeControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSettingsSection(
            title: l10n.settingsLanguageSection,
            icon: AppIcons.public,
            children: [
              _buildSettingTile(
                icon: AppIcons.public,
                title: l10n.settingsDisplayLanguage,
                subtitle: l10n.settingsDisplayLanguageDescription,
                trailing: _buildLanguageSelector(preference),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSettingsSection(
            title: l10n.settingsStartupSection,
            icon: AppIcons.devices,
            children: [
              _buildSettingTile(
                icon: AppIcons.power,
                title: l10n.settingsLaunchAtLogin,
                subtitle: l10n.settingsLaunchAtLoginDescription,
                trailing: _buildPlannedStatus(),
              ),
              _buildSettingDivider(),
              _buildSettingTile(
                icon: AppIcons.devices,
                title: l10n.settingsStartMinimized,
                subtitle: l10n.settingsStartMinimizedDescription,
                trailing: _buildPlannedStatus(),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSettingsSection(
            title: l10n.settingsNotificationsSection,
            icon: AppIcons.incoming,
            children: [
              _buildSettingTile(
                icon: AppIcons.incoming,
                title: l10n.settingsShowWindowForIncomingCall,
                subtitle: l10n.settingsShowWindowForIncomingCallDescription,
                trailing: _buildPlannedStatus(),
              ),
              _buildSettingDivider(),
              _buildSettingTile(
                icon: AppIcons.confirm,
                title: l10n.settingsAppBadge,
                subtitle: l10n.settingsAppBadgeDescription,
                trailing: _buildPlannedStatus(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 未接入业务逻辑的设置统一显示为状态标签，避免伪开关造成误操作。
  Widget _buildPlannedStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusXs),
        border: Border.all(color: _softBorder),
      ),
      child: Text(
        context.l10n.settingsComingSoon,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  /// 使用菜单选择语言，避免把仅有三四项的选项做成较重的二级弹窗。
  Widget _buildLanguageSelector(AppLocalePreference preference) {
    final colorScheme = Theme.of(context).colorScheme;
    final optionTextStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400);
    const selectorWidth = 190.0;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(_panelBackground),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(10),
        shadowColor: WidgetStatePropertyAll(
          Colors.black.withValues(alpha: 0.14),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 5),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusSm),
            side: const BorderSide(color: _softBorder),
          ),
        ),
      ),
      menuChildren: AppLocalePreference.values.map((option) {
        final selected = option == preference;
        return MenuItemButton(
          onPressed: () {
            unawaited(
              ref.read(localeControllerProvider.notifier).setPreference(option),
            );
          },
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(selectorWidth, 40)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12),
            ),
            overlayColor: WidgetStatePropertyAll(
              colorScheme.primary.withValues(alpha: 0.07),
            ),
          ),
          child: SizedBox(
            width: selectorWidth - 24,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _languageLabel(option),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: optionTextStyle,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: _iconSm,
                  child: selected
                      ? Icon(
                          AppIcons.check,
                          size: _iconSm,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
      builder: (context, controller, child) {
        return OutlinedButton(
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: _textPrimary,
            backgroundColor: _subtlePanel,
            minimumSize: const Size(selectorWidth, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: const BorderSide(color: _softBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusSm),
            ),
            textStyle: optionTextStyle,
          ),
          child: SizedBox(
            width: selectorWidth - 24,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _languageLabel(preference),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: optionTextStyle,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(AppIcons.chevronDown, size: _iconSm),
              ],
            ),
          ),
        );
      },
    );
  }

  String _languageLabel(AppLocalePreference preference) {
    final l10n = context.l10n;
    return switch (preference) {
      AppLocalePreference.system => l10n.languageFollowSystem,
      AppLocalePreference.simplifiedChinese => l10n.languageSimplifiedChinese,
      AppLocalePreference.traditionalChinese => l10n.languageTraditionalChinese,
      AppLocalePreference.english => l10n.languageEnglish,
    };
  }
}
