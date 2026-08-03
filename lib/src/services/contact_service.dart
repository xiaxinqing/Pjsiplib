import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'call_history_database.dart';

String normalizeContactPhoneNumber(String value) {
  return value.replaceAll(RegExp(r'[^0-9+*#]'), '');
}

class ContactPhoneEntry {
  const ContactPhoneEntry({
    required this.label,
    required this.number,
    this.isPrimary = false,
  });

  final String label;
  final String number;
  final bool isPrimary;

  ContactPhoneEntry copyWith({String? label, String? number, bool? isPrimary}) {
    return ContactPhoneEntry(
      label: label ?? this.label,
      number: number ?? this.number,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class ContactPhoneConflict {
  const ContactPhoneConflict({
    required this.contact,
    required this.phone,
    required this.normalizedNumber,
  });

  final ContactEntry contact;
  final ContactPhoneEntry phone;
  final String normalizedNumber;
}

class ContactEntry {
  const ContactEntry({
    required this.id,
    required this.name,
    required this.number,
    this.phones = const [],
    this.company = '',
    this.department = '',
    this.remark = '',
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String number;
  final List<ContactPhoneEntry> phones;
  final String company;
  final String department;
  final String remark;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get organizationLabel {
    final parts = [
      company,
      department,
    ].map((value) => value.trim()).where((value) => value.isNotEmpty).toList();
    return parts.isEmpty ? '未设置组织' : parts.join(' · ');
  }

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  bool matches(String keyword) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return [
      name,
      number,
      ...phoneEntries.map((phone) => phone.number),
      ...phoneEntries.map((phone) => phone.label),
      company,
      department,
      remark,
    ].any((value) => value.toLowerCase().contains(normalized));
  }

  List<ContactPhoneEntry> get phoneEntries {
    final normalized = <ContactPhoneEntry>[];
    for (final phone in phones) {
      final label = phone.label.trim().isEmpty ? '默认' : phone.label.trim();
      final number = phone.number.trim();
      if (number.isEmpty) continue;
      normalized.add(
        ContactPhoneEntry(
          label: label,
          number: number,
          isPrimary: phone.isPrimary,
        ),
      );
    }
    final primaryNumber = number.trim();
    if (primaryNumber.isNotEmpty &&
        !normalized.any((phone) => phone.number.trim() == primaryNumber)) {
      normalized.insert(
        0,
        ContactPhoneEntry(label: '默认', number: primaryNumber, isPrimary: true),
      );
    }
    if (normalized.isEmpty) return const [];
    final primaryIndex = normalized.indexWhere((phone) => phone.isPrimary);
    final next = [
      for (var index = 0; index < normalized.length; index++)
        normalized[index].copyWith(
          isPrimary: primaryIndex == -1 ? index == 0 : index == primaryIndex,
        ),
    ];
    next.sort((a, b) {
      if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
      return 0;
    });
    return next;
  }

  ContactEntry copyWith({
    String? id,
    String? name,
    String? number,
    List<ContactPhoneEntry>? phones,
    String? company,
    String? department,
    String? remark,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      phones: phones ?? this.phones,
      company: company ?? this.company,
      department: department ?? this.department,
      remark: remark ?? this.remark,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ContactBookState {
  const ContactBookState({
    this.contacts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ContactEntry> contacts;
  final bool isLoading;
  final String? errorMessage;

  int get favoriteCount =>
      contacts.where((contact) => contact.isFavorite).length;

  int get organizationCount {
    return contacts
        .map((contact) => contact.company.trim())
        .where((company) => company.isNotEmpty)
        .toSet()
        .length;
  }

  ContactPhoneConflict? findPhoneConflict(
    Iterable<ContactPhoneEntry> phones, {
    String? excludingContactId,
  }) {
    final normalizedInputs = phones
        .map((phone) => normalizeContactPhoneNumber(phone.number))
        .where((number) => number.isNotEmpty)
        .toSet();
    if (normalizedInputs.isEmpty) return null;

    for (final contact in contacts) {
      if (contact.id == excludingContactId) continue;
      for (final phone in contact.phoneEntries) {
        final normalized = normalizeContactPhoneNumber(phone.number);
        if (normalizedInputs.contains(normalized)) {
          return ContactPhoneConflict(
            contact: contact,
            phone: phone,
            normalizedNumber: normalized,
          );
        }
      }
    }
    return null;
  }

  ContactBookState copyWith({
    List<ContactEntry>? contacts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ContactBookState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ContactBookNotifier extends Notifier<ContactBookState> {
  @override
  ContactBookState build() {
    scheduleMicrotask(_loadContacts);
    return const ContactBookState(isLoading: true);
  }

  Future<void> _loadContacts() async {
    state = state.copyWith(isLoading: true);
    final stopwatch = Stopwatch()..start();
    try {
      final database = ref.read(callHistoryDatabaseProvider);
      final storedContacts = await database.listContacts();
      final databaseElapsed = stopwatch.elapsedMilliseconds;
      final contacts = storedContacts.map(_fromStored).toList();
      final sortedContacts = _sortContacts(contacts);
      stopwatch.stop();
      debugPrint(
        '⏱ 联系人首次加载: 数据库=${databaseElapsed}ms, '
        '转换与排序=${stopwatch.elapsedMilliseconds - databaseElapsed}ms, '
        '总计=${stopwatch.elapsedMilliseconds}ms, 数量=${sortedContacts.length}',
      );
      state = ContactBookState(contacts: sortedContacts);
    } catch (error) {
      stopwatch.stop();
      debugPrint('⏱ 联系人首次加载失败: ${stopwatch.elapsedMilliseconds}ms, $error');
      state = ContactBookState(
        contacts: const [],
        errorMessage: '联系人加载失败，请稍后重试',
      );
    }
  }

  void addContact({
    required String name,
    required String number,
    List<ContactPhoneEntry> phones = const [],
    String company = '',
    String department = '',
    String remark = '',
    bool isFavorite = false,
  }) {
    final now = DateTime.now();
    final contact = ContactEntry(
      id: now.microsecondsSinceEpoch.toString(),
      name: name.trim(),
      number: number.trim(),
      phones: phones,
      company: company.trim(),
      department: department.trim(),
      remark: remark.trim(),
      isFavorite: isFavorite,
      createdAt: now,
      updatedAt: now,
    );
    state = state.copyWith(
      contacts: _sortContacts([...state.contacts, contact]),
    );
    _persist(
      ref.read(callHistoryDatabaseProvider).upsertContact(_toStored(contact)),
      'add contact',
    );
  }

  void updateContact(ContactEntry contact) {
    final updatedContact = contact.copyWith(updatedAt: DateTime.now());
    final next = [
      for (final item in state.contacts)
        if (item.id == contact.id) updatedContact else item,
    ];
    state = state.copyWith(contacts: _sortContacts(next));
    _persist(
      ref
          .read(callHistoryDatabaseProvider)
          .upsertContact(_toStored(updatedContact)),
      'update contact',
    );
  }

  void deleteContact(String id) {
    state = state.copyWith(
      contacts: state.contacts.where((contact) => contact.id != id).toList(),
    );
    _persist(
      ref.read(callHistoryDatabaseProvider).deleteContact(id),
      'delete contact',
    );
  }

  void deleteContacts(Set<String> ids) {
    if (ids.isEmpty) return;
    state = state.copyWith(
      contacts: state.contacts
          .where((contact) => !ids.contains(contact.id))
          .toList(),
    );
    _persist(
      ref.read(callHistoryDatabaseProvider).deleteContacts(ids),
      'delete contacts',
    );
  }

  void toggleFavorite(String id) {
    final next = [
      for (final contact in state.contacts)
        if (contact.id == id)
          contact.copyWith(
            isFavorite: !contact.isFavorite,
            updatedAt: DateTime.now(),
          )
        else
          contact,
    ];
    state = state.copyWith(contacts: _sortContacts(next));
    ContactEntry? contact;
    for (final item in next) {
      if (item.id == id) {
        contact = item;
        break;
      }
    }
    if (contact != null) {
      _persist(
        ref.read(callHistoryDatabaseProvider).upsertContact(_toStored(contact)),
        'toggle favorite contact',
      );
    }
  }

  /// Keeps optimistic UI updates responsive while making persistence failures
  /// observable instead of leaving an unhandled future in the root isolate.
  void _persist(Future<void> operation, String label) {
    unawaited(
      operation.catchError((Object error, StackTrace stackTrace) {
        debugPrint('Contact persistence failed ($label): $error');
        debugPrint('$stackTrace');
      }),
    );
  }

  List<ContactEntry> _sortContacts(List<ContactEntry> contacts) {
    final sorted = [...contacts];
    sorted.sort((a, b) {
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  ContactEntry _fromStored(StoredContactRow row) {
    return ContactEntry(
      id: row.id,
      name: row.name,
      number: row.number,
      phones: row.phones
          .map(
            (phone) => ContactPhoneEntry(
              label: phone.label,
              number: phone.number,
              isPrimary: phone.isPrimary,
            ),
          )
          .toList(),
      company: row.company,
      department: row.department,
      remark: row.remark,
      isFavorite: row.isFavorite,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  StoredContactRow _toStored(ContactEntry contact) {
    return StoredContactRow(
      id: contact.id,
      name: contact.name,
      number: contact.number,
      phones: contact.phoneEntries
          .map(
            (phone) => StoredContactPhoneRow(
              label: phone.label,
              number: phone.number,
              isPrimary: phone.isPrimary,
            ),
          )
          .toList(),
      company: contact.company,
      department: contact.department,
      remark: contact.remark,
      isFavorite: contact.isFavorite,
      createdAt: contact.createdAt ?? DateTime.now(),
      updatedAt: contact.updatedAt,
    );
  }
}

final contactBookProvider =
    NotifierProvider<ContactBookNotifier, ContactBookState>(
      ContactBookNotifier.new,
    );
