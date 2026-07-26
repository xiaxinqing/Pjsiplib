part of '../../../../../main.dart';

/// 右侧客户卡片：负责通话客户、未知号码和会议客户列表展示。
extension _CallSideCustomerCards on _MyHomePageState {
  Widget _buildConferenceCustomerRow(CallInfo call) {
    final match = _callContactMatch(call);
    final contact = match?.contact;
    final phone = match?.phone;
    final number = phone?.number ?? _callDisplayNumber(call);
    final statusColor = _callStatusColor(call);
    final title = contact?.name ?? '未匹配联系人';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: statusColor.withValues(alpha: 0.12),
            foregroundColor: statusColor,
            child: Text(contact?.initials ?? _avatarText(call.remoteUri)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTooltipText(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                _buildTooltipText(
                  phone == null ? number : '${phone.label} · $number',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (contact == null)
            IconButton(
              tooltip: number.isEmpty ? '未知号码' : '添加到联系人',
              onPressed: number.isEmpty
                  ? null
                  : () => unawaited(_showContactDialog(initialNumber: number)),
              icon: const Icon(AppIcons.contactAdd),
              color: _brandGreen,
              style: IconButton.styleFrom(
                backgroundColor: _panelBackground,
                hoverColor: _brandGreen.withValues(alpha: 0.08),
                highlightColor: _brandGreen.withValues(alpha: 0.12),
              ),
            )
          else
            IconButton(
              tooltip: '查看联系人',
              onPressed: () => _openCallContact(contact),
              icon: const Icon(AppIcons.next),
              style: IconButton.styleFrom(
                backgroundColor: _panelBackground,
                hoverColor: _hoverPanel,
                highlightColor: _hoverPanel,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCallCustomerCard(
    ContactEntry contact,
    ContactPhoneEntry? phone,
    String contextLabel,
  ) {
    final organization = contact.organizationLabel;
    final remark = contact.remark.trim();
    final phoneLabel = phone?.label.trim();
    final phoneNumber = phone?.number.trim().isNotEmpty == true
        ? phone!.number.trim()
        : contact.number.trim();
    final phoneSummary = phoneNumber.isEmpty
        ? null
        : '${phoneLabel?.isNotEmpty == true ? phoneLabel : '默认'}号码 · $phoneNumber';
    return _buildCallContextSection(
      icon: AppIcons.person,
      title: '通话客户',
      trailing: IconButton(
        tooltip: '查看联系人详情',
        onPressed: () => _openCallContact(contact),
        icon: const Icon(AppIcons.next),
        iconSize: _iconSm,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          foregroundColor: _textPrimary,
          backgroundColor: _panelBackground,
          hoverColor: _hoverPanel,
          highlightColor: _hoverPanel,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: contact.isFavorite ? _brandGreen : _hoverPanel,
                foregroundColor: contact.isFavorite
                    ? Colors.white
                    : _textPrimary,
                child: Text(contact.initials),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTooltipText(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (phoneSummary != null) ...[
                      const SizedBox(height: 2),
                      _buildTooltipText(
                        phoneSummary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (contact.isFavorite)
                _buildCustomerAttribute(
                  icon: AppIcons.favorite,
                  label: '重点客户',
                  color: _brandGreen,
                ),
              if (organization != '未设置组织')
                _buildCustomerAttribute(
                  icon: AppIcons.organization,
                  label: organization,
                ),
              if (remark.isNotEmpty)
                _buildCustomerAttribute(icon: AppIcons.note, label: remark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAttribute({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final foreground = color ?? _textSecondary;
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 350),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 150),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: _iconXs, color: foreground),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownCallCustomerCard(String number, String contextLabel) {
    return _buildCallContextSection(
      icon: AppIcons.person,
      title: '当前号码',
      subtitle: contextLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _hoverPanel,
                foregroundColor: _textSecondary,
                child: Text(number.isEmpty ? '?' : number.characters.first),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '未匹配联系人',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    _buildTooltipText(
                      number.isEmpty ? '未知号码' : number,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: number.isEmpty
                ? null
                : () => unawaited(_showContactDialog(initialNumber: number)),
            icon: const Icon(AppIcons.contactAdd),
            label: const Text('添加到联系人'),
          ),
        ],
      ),
    );
  }

  String _callContextTargetLabel(CallInfo call, _CallContactMatch? match) {
    final contact = match?.contact;
    final number = match?.phone.number ?? _callDisplayNumber(call);
    if (contact == null) {
      return number.isEmpty ? _displayRemote(call.remoteUri) : number;
    }
    final contactName = contact.name.trim();
    if (number.trim().isEmpty) return contactName;
    return '$contactName · $number';
  }
}
