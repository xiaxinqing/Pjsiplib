part of '../../../../main.dart';

/// 联系人预览弹窗：复用详情内容并提供编辑、呼叫或打开联系人页操作。
class _ContactPreviewDialog extends StatelessWidget {
  const _ContactPreviewDialog({
    required this.body,
    required this.onEdit,
    this.onCall,
    this.onOpenContactPage,
  });

  final Widget body;
  final VoidCallback onEdit;
  final VoidCallback? onCall;
  final VoidCallback? onOpenContactPage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 18, 12, 0),
      title: Row(
        children: [
          Expanded(child: Text(context.l10n.contactDetailsTitle)),
          IconButton(
            tooltip: context.l10n.contactClose,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(AppIcons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 640),
          child: SingleChildScrollView(child: body),
        ),
      ),
      actions: [
        if (onOpenContactPage != null)
          TextButton.icon(
            onPressed: onOpenContactPage,
            icon: const Icon(AppIcons.contacts),
            label: Text(context.l10n.contactOpenPage),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.contactClose),
        ),
        FilledButton.tonalIcon(
          onPressed: onEdit,
          icon: const Icon(AppIcons.edit),
          label: Text(context.l10n.contactEdit),
        ),
        if (onCall != null)
          FilledButton.icon(
            onPressed: onCall,
            icon: const Icon(AppIcons.call),
            label: Text(context.l10n.contactCall),
          ),
      ],
    );
  }
}
