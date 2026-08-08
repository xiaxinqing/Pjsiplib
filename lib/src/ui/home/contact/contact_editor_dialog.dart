part of '../../../../main.dart';

/// 联系人表单结果：承载编辑弹窗提交后的规范化联系人字段。
class _ContactFormResult {
  const _ContactFormResult({
    required this.name,
    required this.number,
    required this.phones,
    required this.company,
    required this.department,
    required this.remark,
    required this.isFavorite,
  });

  final String name;
  final String number;
  final List<ContactPhoneEntry> phones;
  final String company;
  final String department;
  final String remark;
  final bool isFavorite;
}

/// 联系人号码输入行状态：持有标签、号码控制器和默认号码标记。
class _ContactPhoneField {
  _ContactPhoneField({
    required String label,
    required String number,
    required this.isPrimary,
  }) : labelController = TextEditingController(text: label),
       numberController = TextEditingController(text: number);

  final TextEditingController labelController;
  final TextEditingController numberController;
  bool isPrimary;

  void dispose() {
    labelController.dispose();
    numberController.dispose();
  }
}

/// 联系人编辑弹窗：负责新增/编辑联系人表单的展示和提交。
class _ContactEditorDialog extends StatefulWidget {
  const _ContactEditorDialog({
    this.contact,
    this.initialName = '',
    this.initialNumber = '',
  });

  final ContactEntry? contact;
  final String initialName;
  final String initialNumber;

  @override
  State<_ContactEditorDialog> createState() => _ContactEditorDialogState();
}

/// 联系人编辑弹窗状态：管理表单控制器、号码行、校验和提交。
class _ContactEditorDialogState extends State<_ContactEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _departmentController;
  late final TextEditingController _remarkController;
  late final List<_ContactPhoneField> _phoneFields;
  late bool _isFavorite;
  bool _didApplyLocalizedDefaults = false;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    _nameController = TextEditingController(
      text: contact?.name ?? widget.initialName,
    );
    final initialPhones = contact?.phoneEntries;
    _phoneFields = [
      if (initialPhones != null && initialPhones.isNotEmpty)
        for (final phone in initialPhones)
          _ContactPhoneField(
            label: phone.label,
            number: phone.number,
            isPrimary: phone.isPrimary,
          )
      else
        _ContactPhoneField(
          label: '',
          number: widget.initialNumber,
          isPrimary: true,
        ),
    ];
    _companyController = TextEditingController(text: contact?.company ?? '');
    _departmentController = TextEditingController(
      text: contact?.department ?? '',
    );
    _remarkController = TextEditingController(text: contact?.remark ?? '');
    _isFavorite = contact?.isFavorite ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyLocalizedDefaults) return;
    _didApplyLocalizedDefaults = true;
    for (final phone in _phoneFields) {
      final raw = phone.labelController.text.trim();
      final isLegacyDefault =
          raw.isEmpty ||
          raw == '默认' ||
          raw == '默认号码' ||
          raw == '預設' ||
          raw == '預設號碼' ||
          raw.toLowerCase() == 'default' ||
          raw.toLowerCase() == 'default number';
      if (phone.isPrimary && isLegacyDefault) {
        phone.labelController.text = context.l10n.contactDefaultNumber;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final phone in _phoneFields) {
      phone.dispose();
    }
    _companyController.dispose();
    _departmentController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = widget.contact != null;
    return AlertDialog(
      title: Text(isEditing ? l10n.contactEditTitle : l10n.contactNewTitle),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.contactName,
                    prefixIcon: const Icon(AppIcons.person),
                  ),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? l10n.contactNameRequired
                      : null,
                ),
                const SizedBox(height: 12),
                _buildPhoneFields(context),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _companyController,
                        decoration: InputDecoration(
                          labelText: l10n.contactCompany,
                          prefixIcon: const Icon(AppIcons.organization),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _departmentController,
                        decoration: InputDecoration(
                          labelText: l10n.contactDepartment,
                          prefixIcon: const Icon(AppIcons.department),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _remarkController,
                  decoration: InputDecoration(
                    labelText: l10n.contactNotes,
                    prefixIcon: const Icon(AppIcons.note),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _isFavorite,
                  onChanged: (value) => setState(() => _isFavorite = value),
                  title: Text(l10n.contactPriority),
                  secondary: const Icon(AppIcons.favorite),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(AppIcons.confirm),
          label: Text(l10n.contactSave),
        ),
      ],
    );
  }

  Widget _buildPhoneFields(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _subtlePanel,
        borderRadius: BorderRadius.circular(_radiusSm),
        border: Border.all(color: _softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(AppIcons.call, size: _iconSm, color: _textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.contactPhones,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addPhoneField,
                  icon: const Icon(AppIcons.add),
                  label: Text(context.l10n.contactAddPhone),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: _primaryPhoneIndex,
              onChanged: (value) {
                if (value == null) return;
                _setPrimaryPhone(value);
              },
              child: Column(
                children: [
                  for (var index = 0; index < _phoneFields.length; index++) ...[
                    _buildPhoneFieldRow(context, index),
                    if (index != _phoneFields.length - 1)
                      const Divider(height: 18),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneFieldRow(BuildContext context, int index) {
    final field = _phoneFields[index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio<int>(value: index),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: field.labelController,
            decoration: InputDecoration(
              labelText: context.l10n.contactPhoneLabel,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: TextFormField(
            controller: field.numberController,
            decoration: InputDecoration(labelText: context.l10n.contactPhone),
            keyboardType: TextInputType.phone,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return context.l10n.contactPhoneRequired;
              if (!RegExp(r'^[0-9+*#(). -]+$').hasMatch(trimmed)) {
                return context.l10n.contactPhoneInvalid;
              }
              final normalized = _normalizePhoneField(trimmed);
              final sameCount = _phoneFields.where((field) {
                return _normalizePhoneField(field.numberController.text) ==
                    normalized;
              }).length;
              if (sameCount > 1) return context.l10n.contactPhoneDuplicate;
              return null;
            },
          ),
        ),
        if (!field.isPrimary) ...[
          const SizedBox(width: 6),
          IconButton(
            tooltip: context.l10n.contactDeletePhone,
            onPressed: () => _removePhoneField(index),
            icon: const Icon(AppIcons.delete),
          ),
        ],
      ],
    );
  }

  int get _primaryPhoneIndex {
    final index = _phoneFields.indexWhere((field) => field.isPrimary);
    return index == -1 ? 0 : index;
  }

  void _addPhoneField() {
    setState(() {
      _phoneFields.add(
        _ContactPhoneField(
          label: context.l10n.contactAlternateLabel,
          number: '',
          isPrimary: false,
        ),
      );
    });
  }

  void _removePhoneField(int index) {
    if (_phoneFields.length <= 1) return;
    setState(() {
      final wasPrimary = _phoneFields[index].isPrimary;
      final removed = _phoneFields.removeAt(index);
      removed.dispose();
      if (wasPrimary && _phoneFields.isNotEmpty) {
        _phoneFields.first.isPrimary = true;
      }
    });
  }

  void _setPrimaryPhone(int index) {
    setState(() {
      for (var i = 0; i < _phoneFields.length; i++) {
        _phoneFields[i].isPrimary = i == index;
      }
    });
  }

  String _normalizePhoneField(String value) {
    return value.replaceAll(RegExp(r'[^0-9+*#]'), '');
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    final primaryIndex = _primaryPhoneIndex;
    final phones = [
      for (var index = 0; index < _phoneFields.length; index++)
        ContactPhoneEntry(
          label: _phoneFields[index].labelController.text.trim().isEmpty
              ? (index == primaryIndex
                    ? l10n.contactDefaultNumber
                    : l10n.contactAlternateLabel)
              : _phoneFields[index].labelController.text.trim(),
          number: _phoneFields[index].numberController.text.trim(),
          isPrimary: index == primaryIndex,
        ),
    ];
    final primaryPhone = phones.firstWhere((phone) => phone.isPrimary);
    // 弹窗只返回用户输入；重复校验、保存和提示由调用方统一处理。
    Navigator.of(context).pop(
      _ContactFormResult(
        name: _nameController.text.trim(),
        number: primaryPhone.number,
        phones: phones,
        company: _companyController.text.trim(),
        department: _departmentController.text.trim(),
        remark: _remarkController.text.trim(),
        isFavorite: _isFavorite,
      ),
    );
  }
}
