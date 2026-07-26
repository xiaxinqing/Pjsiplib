part of '../../../../main.dart';

/// 拨号联系人匹配卡：负责展示当前输入号码命中的联系人和号码来源。
extension _DialpadContactMatchView on _MyHomePageState {
  Widget _buildDialpadContactMatch(_DialpadContactMatch match) {
    final organization = match.contact.organizationLabel;
    final phoneLabel = match.phone.label.trim().isEmpty
        ? '默认'
        : match.phone.label.trim();
    return Material(
      color: _subtlePanel,
      borderRadius: BorderRadius.circular(_radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radiusSm),
        hoverColor: _brandGreen.withValues(alpha: 0.06),
        onTap: () {
          _selectContactDetail(match.contact.id);
          _selectSection(_WorkspaceSection.contacts);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radiusSm),
            border: Border.all(color: _softBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: match.contact.isFavorite
                    ? _brandGreen
                    : _hoverPanel,
                foregroundColor: match.contact.isFavorite
                    ? Colors.white
                    : _textPrimary,
                child: Text(
                  match.contact.initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTooltipText(
                      match.contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    _buildTooltipText(
                      organization,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    match.exact ? '已匹配' : '尾号匹配',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _brandGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildTooltipText(
                    '$phoneLabel · ${match.phone.number}',
                    textAlign: TextAlign.right,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
