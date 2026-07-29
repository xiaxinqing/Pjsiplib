part of '../../../../main.dart';

/// 通话记录列表：负责日期分组、记录行、状态徽标、备注标识和加载更多。
extension _HistoryList on _MyHomePageState {
  /// 通话记录行是“信息区 + 操作区”的简单布局。
  ///
  /// 信息区从左到右依次是：方向图标、客户、外呼线路、状态、通话时长、拨打时间。
  /// 操作区只包含回拨和删除，并通过 Spacer 推到最右侧。

  /// 双栏模式下外呼线路的最大宽度；实际宽度会像 toolbar 搜索框一样弹性收缩。
  static const double _historyAccountInlineMaxWidth = 220;

  /// 单栏列表空间更充裕，但线路列仍保持最大宽度，避免把状态和时间推得太远。
  static const double _historyAccountSingleMaxWidth = 250;

  /// 线路列最小宽度，避免窗口变窄时只剩几位号码，影响判断外呼线路。
  static const double _historyAccountMinWidth = 112;

  /// 客户昵称/号码固定宽度；觉得前面太散可以调小，名字被截断就调大。
  static const double _historyPrimaryWidth = 86;

  /// 通话时长列固定宽度，使用等宽数字保持纵向对齐。
  static const double _historyDurationColumnWidth = 48;

  /// 状态列固定宽度，保证表头和不同长度的状态标签保持同一列起点。
  static const double _historyStatusColumnWidth = 72;

  /// 拨打时间列固定宽度，方便同一列纵向对齐。
  static const double _historyTimeColumnWidth = 54;

  /// 右侧操作区宽度，包含回拨和删除两个图标按钮。
  static const double _historyActionColumnWidth = 78;

  Widget _buildHistoryList(
    List<_HistoryItem> items,
    PjsipService service, {
    required String? selectedKey,
    required bool showDetailInline,
    required bool hasMorePersistedEntries,
    required int persistedEntryCount,
    required bool isLoadingMore,
  }) {
    final grouped = _groupHistoryItems(items);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grouped.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHistoryColumnHeader(showDetailInline: showDetailInline);
        }
        final groupIndex = index - 1;
        if (groupIndex == grouped.length) {
          return _buildHistoryLoadMoreFooter(
            hasMorePersistedEntries: hasMorePersistedEntries,
            persistedEntryCount: persistedEntryCount,
            isLoadingMore: isLoadingMore,
          );
        }
        final group = grouped[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
              child: Text(
                group.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final item in group.items)
              _buildHistoryRow(
                item,
                service: service,
                selectedKey: selectedKey,
                showDetailInline: showDetailInline,
              ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryColumnHeader({required bool showDetailInline}) {
    final accountMaxWidth = showDetailInline
        ? _historyAccountInlineMaxWidth
        : _historyAccountSingleMaxWidth;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: _textSecondary,
      fontWeight: FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
      child: Row(
        children: [
          const SizedBox(width: 34),
          const SizedBox(width: 12),
          SizedBox(
            width: _historyPrimaryWidth,
            child: Text('客户', style: style),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: _historyAccountMinWidth,
                maxWidth: accountMaxWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  '线路',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: _historyStatusColumnWidth,
            child: Text('状态', style: style),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: _historyDurationColumnWidth,
            child: Text('时长', textAlign: TextAlign.right, style: style),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: _historyTimeColumnWidth,
            child: Text('时间', textAlign: TextAlign.right, style: style),
          ),
          const Spacer(),
          const SizedBox(width: 8),
          SizedBox(
            width: _historyActionColumnWidth,
            child: Text('操作', textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(
    _HistoryItem item, {
    required PjsipService service,
    required String? selectedKey,
    required bool showDetailInline,
  }) {
    final statusColor = _historyItemColor(item);
    final primary = item.displayName?.trim().isNotEmpty == true
        ? item.displayName!.trim()
        : item.phoneNumber;
    final selected = showDetailInline && selectedKey == item.key;
    final note = _historyNoteText(item);
    final unreadMissed = item.isUnreadMissedCall;

    final accountMaxWidth = showDetailInline
        ? _historyAccountInlineMaxWidth
        : _historyAccountSingleMaxWidth;

    return Material(
      color: selected
          ? _brandGreen.withValues(alpha: 0.06)
          : Colors.transparent,
      child: InkWell(
        hoverColor: _subtlePanel,
        onHover: showDetailInline
            ? (hovering) {
                if (hovering) _selectHistoryItem(item.key, item);
              }
            : null,
        onTap: () {
          if (showDetailInline) {
            _selectHistoryItem(item.key, item);
          } else {
            unawaited(_markHistoryItemRead(item));
            _showHistoryDetail(item, service);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(_radiusSm),
                    ),
                    child: Icon(
                      item.direction == CallHistoryDirection.inbound
                          ? AppIcons.incoming
                          : AppIcons.outgoing,
                      size: _iconMd,
                      color: statusColor,
                    ),
                  ),
                  if (unreadMissed)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _dangerRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.4),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: _historyPrimaryWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            primary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (item.isLive) ...[
                          const SizedBox(width: 8),
                          _buildLiveHistoryBadge(),
                        ],
                        if (note != null) ...[
                          const SizedBox(width: 8),
                          _buildHistoryNoteBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.phoneNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: _historyAccountMinWidth,
                    maxWidth: accountMaxWidth,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      item.accountLabel ?? '未知线路',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: _historyStatusColumnWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildHistoryStatusChip(item),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: _historyDurationColumnWidth,
                child: Text(
                  _formatHistoryDuration(item),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: _historyTimeColumnWidth,
                child: Text(
                  DateFormat('HH:mm').format(item.startedAt),
                  textAlign: TextAlign.right,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ),
              const Spacer(),
              const SizedBox(width: 8),
              SizedBox(
                width: _historyActionColumnWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHistoryCallButton(item, service),
                    IconButton(
                      tooltip: item.canDelete ? '删除记录' : '进行中的通话不能删除',
                      onPressed: item.canDelete
                          ? () => _deleteHistoryEntry(item)
                          : null,
                      icon: const Icon(AppIcons.delete),
                      constraints: const BoxConstraints.tightFor(
                        width: 34,
                        height: 34,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCallButton(_HistoryItem item, PjsipService service) {
    final canCall = !item.isLive && item.phoneNumber.trim().isNotEmpty;
    return _CallActionButton(
      tooltip: item.isLive ? '进行中的通话不能回拨' : '回拨',
      onPressed: canCall ? () => _callHistoryItem(item, service) : null,
    );
  }

  Widget _buildLiveHistoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _callGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_radiusXs),
      ),
      child: Text(
        '实时',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _callGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHistoryNoteBadge() {
    return Tooltip(
      message: '有备注，点击记录查看',
      waitDuration: const Duration(milliseconds: 350),
      child: SizedBox.square(
        dimension: 22,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _brandGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(_radiusXs),
            border: Border.all(color: _brandGreen.withValues(alpha: 0.16)),
          ),
          child: const Icon(AppIcons.note, size: _iconXs, color: _brandGreen),
        ),
      ),
    );
  }

  Widget _buildHistoryLoadMoreFooter({
    required bool hasMorePersistedEntries,
    required int persistedEntryCount,
    required bool isLoadingMore,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Center(
        child: hasMorePersistedEntries
            ? OutlinedButton.icon(
                onPressed: isLoadingMore ? null : _loadMoreHistoryEntries,
                icon: isLoadingMore
                    ? const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(AppIcons.next),
                label: Text(
                  isLoadingMore
                      ? '正在加载更多'
                      : '加载更多 · 已显示 $persistedEntryCount 条',
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _softBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radiusSm),
                  ),
                ),
              )
            : Text(
                persistedEntryCount == 0
                    ? '没有更多历史记录'
                    : '已显示全部 $persistedEntryCount 条历史记录',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _textSecondary),
              ),
      ),
    );
  }
}
