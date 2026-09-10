// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String name;
  final DateTime createdAt;
  final int sortOrder;
  const Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Folder copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    int? sortOrder,
  }) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> sortOrder;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
    required int sortOrder,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       sortOrder = Value(sortOrder);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? sortOrder,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TaskSeriesTable extends TaskSeries
    with TableInfo<$TaskSeriesTable, TaskSery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskSeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id)',
    ),
  );
  static const VerificationMeta _repeatTypeMeta = const VerificationMeta(
    'repeatType',
  );
  @override
  late final GeneratedColumn<String> repeatType = GeneratedColumn<String>(
    'repeat_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceIntervalMeta =
      const VerificationMeta('recurrenceInterval');
  @override
  late final GeneratedColumn<int> recurrenceInterval = GeneratedColumn<int>(
    'recurrence_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _customRepeatLabelMeta = const VerificationMeta(
    'customRepeatLabel',
  );
  @override
  late final GeneratedColumn<String> customRepeatLabel =
      GeneratedColumn<String>(
        'custom_repeat_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _anchorDateMeta = const VerificationMeta(
    'anchorDate',
  );
  @override
  late final GeneratedColumn<DateTime> anchorDate = GeneratedColumn<DateTime>(
    'anchor_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<DateTime> reminderTime = GeneratedColumn<DateTime>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusDurationMinutesMeta =
      const VerificationMeta('focusDurationMinutes');
  @override
  late final GeneratedColumn<int> focusDurationMinutes = GeneratedColumn<int>(
    'focus_duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    folderId,
    repeatType,
    recurrenceInterval,
    customRepeatLabel,
    anchorDate,
    time,
    reminderTime,
    focusDurationMinutes,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskSery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('repeat_type')) {
      context.handle(
        _repeatTypeMeta,
        repeatType.isAcceptableOrUnknown(data['repeat_type']!, _repeatTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatTypeMeta);
    }
    if (data.containsKey('recurrence_interval')) {
      context.handle(
        _recurrenceIntervalMeta,
        recurrenceInterval.isAcceptableOrUnknown(
          data['recurrence_interval']!,
          _recurrenceIntervalMeta,
        ),
      );
    }
    if (data.containsKey('custom_repeat_label')) {
      context.handle(
        _customRepeatLabelMeta,
        customRepeatLabel.isAcceptableOrUnknown(
          data['custom_repeat_label']!,
          _customRepeatLabelMeta,
        ),
      );
    }
    if (data.containsKey('anchor_date')) {
      context.handle(
        _anchorDateMeta,
        anchorDate.isAcceptableOrUnknown(data['anchor_date']!, _anchorDateMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorDateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('focus_duration_minutes')) {
      context.handle(
        _focusDurationMinutesMeta,
        focusDurationMinutes.isAcceptableOrUnknown(
          data['focus_duration_minutes']!,
          _focusDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskSery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskSery(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      repeatType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_type'],
      )!,
      recurrenceInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_interval'],
      )!,
      customRepeatLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_repeat_label'],
      ),
      anchorDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}anchor_date'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      ),
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_time'],
      ),
      focusDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_duration_minutes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TaskSeriesTable createAlias(String alias) {
    return $TaskSeriesTable(attachedDatabase, alias);
  }
}

class TaskSery extends DataClass implements Insertable<TaskSery> {
  final int id;
  final String title;
  final int folderId;
  final String repeatType;
  final int recurrenceInterval;
  final String? customRepeatLabel;
  final DateTime anchorDate;
  final DateTime? time;
  final DateTime? reminderTime;
  final int? focusDurationMinutes;
  final bool isActive;
  final DateTime createdAt;
  const TaskSery({
    required this.id,
    required this.title,
    required this.folderId,
    required this.repeatType,
    required this.recurrenceInterval,
    this.customRepeatLabel,
    required this.anchorDate,
    this.time,
    this.reminderTime,
    this.focusDurationMinutes,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['folder_id'] = Variable<int>(folderId);
    map['repeat_type'] = Variable<String>(repeatType);
    map['recurrence_interval'] = Variable<int>(recurrenceInterval);
    if (!nullToAbsent || customRepeatLabel != null) {
      map['custom_repeat_label'] = Variable<String>(customRepeatLabel);
    }
    map['anchor_date'] = Variable<DateTime>(anchorDate);
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<DateTime>(time);
    }
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<DateTime>(reminderTime);
    }
    if (!nullToAbsent || focusDurationMinutes != null) {
      map['focus_duration_minutes'] = Variable<int>(focusDurationMinutes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaskSeriesCompanion toCompanion(bool nullToAbsent) {
    return TaskSeriesCompanion(
      id: Value(id),
      title: Value(title),
      folderId: Value(folderId),
      repeatType: Value(repeatType),
      recurrenceInterval: Value(recurrenceInterval),
      customRepeatLabel: customRepeatLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(customRepeatLabel),
      anchorDate: Value(anchorDate),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      focusDurationMinutes: focusDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(focusDurationMinutes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory TaskSery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskSery(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      folderId: serializer.fromJson<int>(json['folderId']),
      repeatType: serializer.fromJson<String>(json['repeatType']),
      recurrenceInterval: serializer.fromJson<int>(json['recurrenceInterval']),
      customRepeatLabel: serializer.fromJson<String?>(
        json['customRepeatLabel'],
      ),
      anchorDate: serializer.fromJson<DateTime>(json['anchorDate']),
      time: serializer.fromJson<DateTime?>(json['time']),
      reminderTime: serializer.fromJson<DateTime?>(json['reminderTime']),
      focusDurationMinutes: serializer.fromJson<int?>(
        json['focusDurationMinutes'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'folderId': serializer.toJson<int>(folderId),
      'repeatType': serializer.toJson<String>(repeatType),
      'recurrenceInterval': serializer.toJson<int>(recurrenceInterval),
      'customRepeatLabel': serializer.toJson<String?>(customRepeatLabel),
      'anchorDate': serializer.toJson<DateTime>(anchorDate),
      'time': serializer.toJson<DateTime?>(time),
      'reminderTime': serializer.toJson<DateTime?>(reminderTime),
      'focusDurationMinutes': serializer.toJson<int?>(focusDurationMinutes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskSery copyWith({
    int? id,
    String? title,
    int? folderId,
    String? repeatType,
    int? recurrenceInterval,
    Value<String?> customRepeatLabel = const Value.absent(),
    DateTime? anchorDate,
    Value<DateTime?> time = const Value.absent(),
    Value<DateTime?> reminderTime = const Value.absent(),
    Value<int?> focusDurationMinutes = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => TaskSery(
    id: id ?? this.id,
    title: title ?? this.title,
    folderId: folderId ?? this.folderId,
    repeatType: repeatType ?? this.repeatType,
    recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
    customRepeatLabel: customRepeatLabel.present
        ? customRepeatLabel.value
        : this.customRepeatLabel,
    anchorDate: anchorDate ?? this.anchorDate,
    time: time.present ? time.value : this.time,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    focusDurationMinutes: focusDurationMinutes.present
        ? focusDurationMinutes.value
        : this.focusDurationMinutes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskSery copyWithCompanion(TaskSeriesCompanion data) {
    return TaskSery(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      repeatType: data.repeatType.present
          ? data.repeatType.value
          : this.repeatType,
      recurrenceInterval: data.recurrenceInterval.present
          ? data.recurrenceInterval.value
          : this.recurrenceInterval,
      customRepeatLabel: data.customRepeatLabel.present
          ? data.customRepeatLabel.value
          : this.customRepeatLabel,
      anchorDate: data.anchorDate.present
          ? data.anchorDate.value
          : this.anchorDate,
      time: data.time.present ? data.time.value : this.time,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      focusDurationMinutes: data.focusDurationMinutes.present
          ? data.focusDurationMinutes.value
          : this.focusDurationMinutes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskSery(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('folderId: $folderId, ')
          ..write('repeatType: $repeatType, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('customRepeatLabel: $customRepeatLabel, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('time: $time, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('focusDurationMinutes: $focusDurationMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    folderId,
    repeatType,
    recurrenceInterval,
    customRepeatLabel,
    anchorDate,
    time,
    reminderTime,
    focusDurationMinutes,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskSery &&
          other.id == this.id &&
          other.title == this.title &&
          other.folderId == this.folderId &&
          other.repeatType == this.repeatType &&
          other.recurrenceInterval == this.recurrenceInterval &&
          other.customRepeatLabel == this.customRepeatLabel &&
          other.anchorDate == this.anchorDate &&
          other.time == this.time &&
          other.reminderTime == this.reminderTime &&
          other.focusDurationMinutes == this.focusDurationMinutes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class TaskSeriesCompanion extends UpdateCompanion<TaskSery> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> folderId;
  final Value<String> repeatType;
  final Value<int> recurrenceInterval;
  final Value<String?> customRepeatLabel;
  final Value<DateTime> anchorDate;
  final Value<DateTime?> time;
  final Value<DateTime?> reminderTime;
  final Value<int?> focusDurationMinutes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const TaskSeriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.folderId = const Value.absent(),
    this.repeatType = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.customRepeatLabel = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.time = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.focusDurationMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TaskSeriesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int folderId,
    required String repeatType,
    this.recurrenceInterval = const Value.absent(),
    this.customRepeatLabel = const Value.absent(),
    required DateTime anchorDate,
    this.time = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.focusDurationMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : title = Value(title),
       folderId = Value(folderId),
       repeatType = Value(repeatType),
       anchorDate = Value(anchorDate),
       createdAt = Value(createdAt);
  static Insertable<TaskSery> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? folderId,
    Expression<String>? repeatType,
    Expression<int>? recurrenceInterval,
    Expression<String>? customRepeatLabel,
    Expression<DateTime>? anchorDate,
    Expression<DateTime>? time,
    Expression<DateTime>? reminderTime,
    Expression<int>? focusDurationMinutes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (folderId != null) 'folder_id': folderId,
      if (repeatType != null) 'repeat_type': repeatType,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (customRepeatLabel != null) 'custom_repeat_label': customRepeatLabel,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (time != null) 'time': time,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (focusDurationMinutes != null)
        'focus_duration_minutes': focusDurationMinutes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TaskSeriesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? folderId,
    Value<String>? repeatType,
    Value<int>? recurrenceInterval,
    Value<String?>? customRepeatLabel,
    Value<DateTime>? anchorDate,
    Value<DateTime?>? time,
    Value<DateTime?>? reminderTime,
    Value<int?>? focusDurationMinutes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return TaskSeriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      folderId: folderId ?? this.folderId,
      repeatType: repeatType ?? this.repeatType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      customRepeatLabel: customRepeatLabel ?? this.customRepeatLabel,
      anchorDate: anchorDate ?? this.anchorDate,
      time: time ?? this.time,
      reminderTime: reminderTime ?? this.reminderTime,
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (repeatType.present) {
      map['repeat_type'] = Variable<String>(repeatType.value);
    }
    if (recurrenceInterval.present) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval.value);
    }
    if (customRepeatLabel.present) {
      map['custom_repeat_label'] = Variable<String>(customRepeatLabel.value);
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<DateTime>(anchorDate.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<DateTime>(reminderTime.value);
    }
    if (focusDurationMinutes.present) {
      map['focus_duration_minutes'] = Variable<int>(focusDurationMinutes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskSeriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('folderId: $folderId, ')
          ..write('repeatType: $repeatType, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('customRepeatLabel: $customRepeatLabel, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('time: $time, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('focusDurationMinutes: $focusDurationMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task_series (id)',
    ),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>(
        'scheduled_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<DateTime> reminderTime = GeneratedColumn<DateTime>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusDurationMinutesMeta =
      const VerificationMeta('focusDurationMinutes');
  @override
  late final GeneratedColumn<int> focusDurationMinutes = GeneratedColumn<int>(
    'focus_duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _globalSortOrderMeta = const VerificationMeta(
    'globalSortOrder',
  );
  @override
  late final GeneratedColumn<int> globalSortOrder = GeneratedColumn<int>(
    'global_sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seriesId,
    folderId,
    title,
    scheduledDate,
    scheduledTime,
    reminderTime,
    focusDurationMinutes,
    isCompleted,
    completedAt,
    globalSortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('focus_duration_minutes')) {
      context.handle(
        _focusDurationMinutesMeta,
        focusDurationMinutes.isAcceptableOrUnknown(
          data['focus_duration_minutes']!,
          _focusDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('global_sort_order')) {
      context.handle(
        _globalSortOrderMeta,
        globalSortOrder.isAcceptableOrUnknown(
          data['global_sort_order']!,
          _globalSortOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_globalSortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      ),
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_time'],
      ),
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_time'],
      ),
      focusDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_duration_minutes'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      globalSortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}global_sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final int? seriesId;
  final int folderId;
  final String title;
  final DateTime? scheduledDate;
  final DateTime? scheduledTime;
  final DateTime? reminderTime;
  final int? focusDurationMinutes;
  final bool isCompleted;
  final DateTime? completedAt;
  final int globalSortOrder;
  final DateTime createdAt;
  const Task({
    required this.id,
    this.seriesId,
    required this.folderId,
    required this.title,
    this.scheduledDate,
    this.scheduledTime,
    this.reminderTime,
    this.focusDurationMinutes,
    required this.isCompleted,
    this.completedAt,
    required this.globalSortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<int>(seriesId);
    }
    map['folder_id'] = Variable<int>(folderId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    }
    if (!nullToAbsent || scheduledTime != null) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    }
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<DateTime>(reminderTime);
    }
    if (!nullToAbsent || focusDurationMinutes != null) {
      map['focus_duration_minutes'] = Variable<int>(focusDurationMinutes);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['global_sort_order'] = Variable<int>(globalSortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      folderId: Value(folderId),
      title: Value(title),
      scheduledDate: scheduledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDate),
      scheduledTime: scheduledTime == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledTime),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      focusDurationMinutes: focusDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(focusDurationMinutes),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      globalSortOrder: Value(globalSortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      seriesId: serializer.fromJson<int?>(json['seriesId']),
      folderId: serializer.fromJson<int>(json['folderId']),
      title: serializer.fromJson<String>(json['title']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
      scheduledTime: serializer.fromJson<DateTime?>(json['scheduledTime']),
      reminderTime: serializer.fromJson<DateTime?>(json['reminderTime']),
      focusDurationMinutes: serializer.fromJson<int?>(
        json['focusDurationMinutes'],
      ),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      globalSortOrder: serializer.fromJson<int>(json['globalSortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seriesId': serializer.toJson<int?>(seriesId),
      'folderId': serializer.toJson<int>(folderId),
      'title': serializer.toJson<String>(title),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
      'scheduledTime': serializer.toJson<DateTime?>(scheduledTime),
      'reminderTime': serializer.toJson<DateTime?>(reminderTime),
      'focusDurationMinutes': serializer.toJson<int?>(focusDurationMinutes),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'globalSortOrder': serializer.toJson<int>(globalSortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    Value<int?> seriesId = const Value.absent(),
    int? folderId,
    String? title,
    Value<DateTime?> scheduledDate = const Value.absent(),
    Value<DateTime?> scheduledTime = const Value.absent(),
    Value<DateTime?> reminderTime = const Value.absent(),
    Value<int?> focusDurationMinutes = const Value.absent(),
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    int? globalSortOrder,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    folderId: folderId ?? this.folderId,
    title: title ?? this.title,
    scheduledDate: scheduledDate.present
        ? scheduledDate.value
        : this.scheduledDate,
    scheduledTime: scheduledTime.present
        ? scheduledTime.value
        : this.scheduledTime,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    focusDurationMinutes: focusDurationMinutes.present
        ? focusDurationMinutes.value
        : this.focusDurationMinutes,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    globalSortOrder: globalSortOrder ?? this.globalSortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      title: data.title.present ? data.title.value : this.title,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      focusDurationMinutes: data.focusDurationMinutes.present
          ? data.focusDurationMinutes.value
          : this.focusDurationMinutes,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      globalSortOrder: data.globalSortOrder.present
          ? data.globalSortOrder.value
          : this.globalSortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('folderId: $folderId, ')
          ..write('title: $title, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('focusDurationMinutes: $focusDurationMinutes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('globalSortOrder: $globalSortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seriesId,
    folderId,
    title,
    scheduledDate,
    scheduledTime,
    reminderTime,
    focusDurationMinutes,
    isCompleted,
    completedAt,
    globalSortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.folderId == this.folderId &&
          other.title == this.title &&
          other.scheduledDate == this.scheduledDate &&
          other.scheduledTime == this.scheduledTime &&
          other.reminderTime == this.reminderTime &&
          other.focusDurationMinutes == this.focusDurationMinutes &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.globalSortOrder == this.globalSortOrder &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<int?> seriesId;
  final Value<int> folderId;
  final Value<String> title;
  final Value<DateTime?> scheduledDate;
  final Value<DateTime?> scheduledTime;
  final Value<DateTime?> reminderTime;
  final Value<int?> focusDurationMinutes;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<int> globalSortOrder;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.title = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.focusDurationMinutes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.globalSortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    required int folderId,
    required String title,
    this.scheduledDate = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.focusDurationMinutes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int globalSortOrder,
    required DateTime createdAt,
  }) : folderId = Value(folderId),
       title = Value(title),
       globalSortOrder = Value(globalSortOrder),
       createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<int>? seriesId,
    Expression<int>? folderId,
    Expression<String>? title,
    Expression<DateTime>? scheduledDate,
    Expression<DateTime>? scheduledTime,
    Expression<DateTime>? reminderTime,
    Expression<int>? focusDurationMinutes,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<int>? globalSortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (folderId != null) 'folder_id': folderId,
      if (title != null) 'title': title,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (focusDurationMinutes != null)
        'focus_duration_minutes': focusDurationMinutes,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (globalSortOrder != null) 'global_sort_order': globalSortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<int?>? seriesId,
    Value<int>? folderId,
    Value<String>? title,
    Value<DateTime?>? scheduledDate,
    Value<DateTime?>? scheduledTime,
    Value<DateTime?>? reminderTime,
    Value<int?>? focusDurationMinutes,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<int>? globalSortOrder,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      reminderTime: reminderTime ?? this.reminderTime,
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      globalSortOrder: globalSortOrder ?? this.globalSortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<DateTime>(reminderTime.value);
    }
    if (focusDurationMinutes.present) {
      map['focus_duration_minutes'] = Variable<int>(focusDurationMinutes.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (globalSortOrder.present) {
      map['global_sort_order'] = Variable<int>(globalSortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('folderId: $folderId, ')
          ..write('title: $title, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('focusDurationMinutes: $focusDurationMinutes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('globalSortOrder: $globalSortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FocusHistoryTable extends FocusHistory
    with TableInfo<$FocusHistoryTable, FocusHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedDurationMinutesMeta =
      const VerificationMeta('plannedDurationMinutes');
  @override
  late final GeneratedColumn<int> plannedDurationMinutes = GeneratedColumn<int>(
    'planned_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualDurationMinutesMeta =
      const VerificationMeta('actualDurationMinutes');
  @override
  late final GeneratedColumn<int> actualDurationMinutes = GeneratedColumn<int>(
    'actual_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasExtendedMeta = const VerificationMeta(
    'wasExtended',
  );
  @override
  late final GeneratedColumn<bool> wasExtended = GeneratedColumn<bool>(
    'was_extended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_extended" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    startedAt,
    completedAt,
    plannedDurationMinutes,
    actualDurationMinutes,
    wasExtended,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('planned_duration_minutes')) {
      context.handle(
        _plannedDurationMinutesMeta,
        plannedDurationMinutes.isAcceptableOrUnknown(
          data['planned_duration_minutes']!,
          _plannedDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedDurationMinutesMeta);
    }
    if (data.containsKey('actual_duration_minutes')) {
      context.handle(
        _actualDurationMinutesMeta,
        actualDurationMinutes.isAcceptableOrUnknown(
          data['actual_duration_minutes']!,
          _actualDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualDurationMinutesMeta);
    }
    if (data.containsKey('was_extended')) {
      context.handle(
        _wasExtendedMeta,
        wasExtended.isAcceptableOrUnknown(
          data['was_extended']!,
          _wasExtendedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wasExtendedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      plannedDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_minutes'],
      )!,
      actualDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_minutes'],
      )!,
      wasExtended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_extended'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FocusHistoryTable createAlias(String alias) {
    return $FocusHistoryTable(attachedDatabase, alias);
  }
}

class FocusHistoryData extends DataClass
    implements Insertable<FocusHistoryData> {
  final int id;
  final int? taskId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int plannedDurationMinutes;
  final int actualDurationMinutes;
  final bool wasExtended;
  final DateTime createdAt;
  const FocusHistoryData({
    required this.id,
    this.taskId,
    required this.startedAt,
    required this.completedAt,
    required this.plannedDurationMinutes,
    required this.actualDurationMinutes,
    required this.wasExtended,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['planned_duration_minutes'] = Variable<int>(plannedDurationMinutes);
    map['actual_duration_minutes'] = Variable<int>(actualDurationMinutes);
    map['was_extended'] = Variable<bool>(wasExtended);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FocusHistoryCompanion toCompanion(bool nullToAbsent) {
    return FocusHistoryCompanion(
      id: Value(id),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      plannedDurationMinutes: Value(plannedDurationMinutes),
      actualDurationMinutes: Value(actualDurationMinutes),
      wasExtended: Value(wasExtended),
      createdAt: Value(createdAt),
    );
  }

  factory FocusHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusHistoryData(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      plannedDurationMinutes: serializer.fromJson<int>(
        json['plannedDurationMinutes'],
      ),
      actualDurationMinutes: serializer.fromJson<int>(
        json['actualDurationMinutes'],
      ),
      wasExtended: serializer.fromJson<bool>(json['wasExtended']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int?>(taskId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'plannedDurationMinutes': serializer.toJson<int>(plannedDurationMinutes),
      'actualDurationMinutes': serializer.toJson<int>(actualDurationMinutes),
      'wasExtended': serializer.toJson<bool>(wasExtended),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FocusHistoryData copyWith({
    int? id,
    Value<int?> taskId = const Value.absent(),
    DateTime? startedAt,
    DateTime? completedAt,
    int? plannedDurationMinutes,
    int? actualDurationMinutes,
    bool? wasExtended,
    DateTime? createdAt,
  }) => FocusHistoryData(
    id: id ?? this.id,
    taskId: taskId.present ? taskId.value : this.taskId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    plannedDurationMinutes:
        plannedDurationMinutes ?? this.plannedDurationMinutes,
    actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
    wasExtended: wasExtended ?? this.wasExtended,
    createdAt: createdAt ?? this.createdAt,
  );
  FocusHistoryData copyWithCompanion(FocusHistoryCompanion data) {
    return FocusHistoryData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      plannedDurationMinutes: data.plannedDurationMinutes.present
          ? data.plannedDurationMinutes.value
          : this.plannedDurationMinutes,
      actualDurationMinutes: data.actualDurationMinutes.present
          ? data.actualDurationMinutes.value
          : this.actualDurationMinutes,
      wasExtended: data.wasExtended.present
          ? data.wasExtended.value
          : this.wasExtended,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusHistoryData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('plannedDurationMinutes: $plannedDurationMinutes, ')
          ..write('actualDurationMinutes: $actualDurationMinutes, ')
          ..write('wasExtended: $wasExtended, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    startedAt,
    completedAt,
    plannedDurationMinutes,
    actualDurationMinutes,
    wasExtended,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusHistoryData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.plannedDurationMinutes == this.plannedDurationMinutes &&
          other.actualDurationMinutes == this.actualDurationMinutes &&
          other.wasExtended == this.wasExtended &&
          other.createdAt == this.createdAt);
}

class FocusHistoryCompanion extends UpdateCompanion<FocusHistoryData> {
  final Value<int> id;
  final Value<int?> taskId;
  final Value<DateTime> startedAt;
  final Value<DateTime> completedAt;
  final Value<int> plannedDurationMinutes;
  final Value<int> actualDurationMinutes;
  final Value<bool> wasExtended;
  final Value<DateTime> createdAt;
  const FocusHistoryCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.plannedDurationMinutes = const Value.absent(),
    this.actualDurationMinutes = const Value.absent(),
    this.wasExtended = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FocusHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    required DateTime startedAt,
    required DateTime completedAt,
    required int plannedDurationMinutes,
    required int actualDurationMinutes,
    required bool wasExtended,
    required DateTime createdAt,
  }) : startedAt = Value(startedAt),
       completedAt = Value(completedAt),
       plannedDurationMinutes = Value(plannedDurationMinutes),
       actualDurationMinutes = Value(actualDurationMinutes),
       wasExtended = Value(wasExtended),
       createdAt = Value(createdAt);
  static Insertable<FocusHistoryData> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? plannedDurationMinutes,
    Expression<int>? actualDurationMinutes,
    Expression<bool>? wasExtended,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (plannedDurationMinutes != null)
        'planned_duration_minutes': plannedDurationMinutes,
      if (actualDurationMinutes != null)
        'actual_duration_minutes': actualDurationMinutes,
      if (wasExtended != null) 'was_extended': wasExtended,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FocusHistoryCompanion copyWith({
    Value<int>? id,
    Value<int?>? taskId,
    Value<DateTime>? startedAt,
    Value<DateTime>? completedAt,
    Value<int>? plannedDurationMinutes,
    Value<int>? actualDurationMinutes,
    Value<bool>? wasExtended,
    Value<DateTime>? createdAt,
  }) {
    return FocusHistoryCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      plannedDurationMinutes:
          plannedDurationMinutes ?? this.plannedDurationMinutes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      wasExtended: wasExtended ?? this.wasExtended,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (plannedDurationMinutes.present) {
      map['planned_duration_minutes'] = Variable<int>(
        plannedDurationMinutes.value,
      );
    }
    if (actualDurationMinutes.present) {
      map['actual_duration_minutes'] = Variable<int>(
        actualDurationMinutes.value,
      );
    }
    if (wasExtended.present) {
      map['was_extended'] = Variable<bool>(wasExtended.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusHistoryCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('plannedDurationMinutes: $plannedDurationMinutes, ')
          ..write('actualDurationMinutes: $actualDurationMinutes, ')
          ..write('wasExtended: $wasExtended, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTable extends Receipts with TableInfo<$ReceiptsTable, Receipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNumberMeta = const VerificationMeta(
    'displayNumber',
  );
  @override
  late final GeneratedColumn<int> displayNumber = GeneratedColumn<int>(
    'display_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedStartMeta = const VerificationMeta(
    'selectedStart',
  );
  @override
  late final GeneratedColumn<DateTime> selectedStart =
      GeneratedColumn<DateTime>(
        'selected_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _selectedEndExclusiveMeta =
      const VerificationMeta('selectedEndExclusive');
  @override
  late final GeneratedColumn<DateTime> selectedEndExclusive =
      GeneratedColumn<DateTime>(
        'selected_end_exclusive',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _includeFolderLabelsMeta =
      const VerificationMeta('includeFolderLabels');
  @override
  late final GeneratedColumn<bool> includeFolderLabels = GeneratedColumn<bool>(
    'include_folder_labels',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_folder_labels" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _artworkTypeMeta = const VerificationMeta(
    'artworkType',
  );
  @override
  late final GeneratedColumn<String> artworkType = GeneratedColumn<String>(
    'artwork_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drawingStrokesJsonMeta =
      const VerificationMeta('drawingStrokesJson');
  @override
  late final GeneratedColumn<String> drawingStrokesJson =
      GeneratedColumn<String>(
        'drawing_strokes_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateVersionMeta = const VerificationMeta(
    'templateVersion',
  );
  @override
  late final GeneratedColumn<int> templateVersion = GeneratedColumn<int>(
    'template_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationId,
    displayNumber,
    title,
    source,
    createdAt,
    updatedAt,
    selectedStart,
    selectedEndExclusive,
    includeFolderLabels,
    artworkType,
    drawingStrokesJson,
    photoPath,
    templateVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Receipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('display_number')) {
      context.handle(
        _displayNumberMeta,
        displayNumber.isAcceptableOrUnknown(
          data['display_number']!,
          _displayNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('selected_start')) {
      context.handle(
        _selectedStartMeta,
        selectedStart.isAcceptableOrUnknown(
          data['selected_start']!,
          _selectedStartMeta,
        ),
      );
    }
    if (data.containsKey('selected_end_exclusive')) {
      context.handle(
        _selectedEndExclusiveMeta,
        selectedEndExclusive.isAcceptableOrUnknown(
          data['selected_end_exclusive']!,
          _selectedEndExclusiveMeta,
        ),
      );
    }
    if (data.containsKey('include_folder_labels')) {
      context.handle(
        _includeFolderLabelsMeta,
        includeFolderLabels.isAcceptableOrUnknown(
          data['include_folder_labels']!,
          _includeFolderLabelsMeta,
        ),
      );
    }
    if (data.containsKey('artwork_type')) {
      context.handle(
        _artworkTypeMeta,
        artworkType.isAcceptableOrUnknown(
          data['artwork_type']!,
          _artworkTypeMeta,
        ),
      );
    }
    if (data.containsKey('drawing_strokes_json')) {
      context.handle(
        _drawingStrokesJsonMeta,
        drawingStrokesJson.isAcceptableOrUnknown(
          data['drawing_strokes_json']!,
          _drawingStrokesJsonMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('template_version')) {
      context.handle(
        _templateVersionMeta,
        templateVersion.isAcceptableOrUnknown(
          data['template_version']!,
          _templateVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Receipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      displayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      selectedStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}selected_start'],
      ),
      selectedEndExclusive: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}selected_end_exclusive'],
      ),
      includeFolderLabels: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_folder_labels'],
      )!,
      artworkType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_type'],
      ),
      drawingStrokesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drawing_strokes_json'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      templateVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_version'],
      )!,
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }
}

class Receipt extends DataClass implements Insertable<Receipt> {
  final String id;
  final String operationId;
  final int displayNumber;
  final String title;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? selectedStart;
  final DateTime? selectedEndExclusive;
  final bool includeFolderLabels;
  final String? artworkType;
  final String? drawingStrokesJson;
  final String? photoPath;
  final int templateVersion;
  const Receipt({
    required this.id,
    required this.operationId,
    required this.displayNumber,
    required this.title,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.selectedStart,
    this.selectedEndExclusive,
    required this.includeFolderLabels,
    this.artworkType,
    this.drawingStrokesJson,
    this.photoPath,
    required this.templateVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation_id'] = Variable<String>(operationId);
    map['display_number'] = Variable<int>(displayNumber);
    map['title'] = Variable<String>(title);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || selectedStart != null) {
      map['selected_start'] = Variable<DateTime>(selectedStart);
    }
    if (!nullToAbsent || selectedEndExclusive != null) {
      map['selected_end_exclusive'] = Variable<DateTime>(selectedEndExclusive);
    }
    map['include_folder_labels'] = Variable<bool>(includeFolderLabels);
    if (!nullToAbsent || artworkType != null) {
      map['artwork_type'] = Variable<String>(artworkType);
    }
    if (!nullToAbsent || drawingStrokesJson != null) {
      map['drawing_strokes_json'] = Variable<String>(drawingStrokesJson);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['template_version'] = Variable<int>(templateVersion);
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      operationId: Value(operationId),
      displayNumber: Value(displayNumber),
      title: Value(title),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      selectedStart: selectedStart == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedStart),
      selectedEndExclusive: selectedEndExclusive == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedEndExclusive),
      includeFolderLabels: Value(includeFolderLabels),
      artworkType: artworkType == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkType),
      drawingStrokesJson: drawingStrokesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(drawingStrokesJson),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      templateVersion: Value(templateVersion),
    );
  }

  factory Receipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Receipt(
      id: serializer.fromJson<String>(json['id']),
      operationId: serializer.fromJson<String>(json['operationId']),
      displayNumber: serializer.fromJson<int>(json['displayNumber']),
      title: serializer.fromJson<String>(json['title']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      selectedStart: serializer.fromJson<DateTime?>(json['selectedStart']),
      selectedEndExclusive: serializer.fromJson<DateTime?>(
        json['selectedEndExclusive'],
      ),
      includeFolderLabels: serializer.fromJson<bool>(
        json['includeFolderLabels'],
      ),
      artworkType: serializer.fromJson<String?>(json['artworkType']),
      drawingStrokesJson: serializer.fromJson<String?>(
        json['drawingStrokesJson'],
      ),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      templateVersion: serializer.fromJson<int>(json['templateVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationId': serializer.toJson<String>(operationId),
      'displayNumber': serializer.toJson<int>(displayNumber),
      'title': serializer.toJson<String>(title),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'selectedStart': serializer.toJson<DateTime?>(selectedStart),
      'selectedEndExclusive': serializer.toJson<DateTime?>(
        selectedEndExclusive,
      ),
      'includeFolderLabels': serializer.toJson<bool>(includeFolderLabels),
      'artworkType': serializer.toJson<String?>(artworkType),
      'drawingStrokesJson': serializer.toJson<String?>(drawingStrokesJson),
      'photoPath': serializer.toJson<String?>(photoPath),
      'templateVersion': serializer.toJson<int>(templateVersion),
    };
  }

  Receipt copyWith({
    String? id,
    String? operationId,
    int? displayNumber,
    String? title,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> selectedStart = const Value.absent(),
    Value<DateTime?> selectedEndExclusive = const Value.absent(),
    bool? includeFolderLabels,
    Value<String?> artworkType = const Value.absent(),
    Value<String?> drawingStrokesJson = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    int? templateVersion,
  }) => Receipt(
    id: id ?? this.id,
    operationId: operationId ?? this.operationId,
    displayNumber: displayNumber ?? this.displayNumber,
    title: title ?? this.title,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    selectedStart: selectedStart.present
        ? selectedStart.value
        : this.selectedStart,
    selectedEndExclusive: selectedEndExclusive.present
        ? selectedEndExclusive.value
        : this.selectedEndExclusive,
    includeFolderLabels: includeFolderLabels ?? this.includeFolderLabels,
    artworkType: artworkType.present ? artworkType.value : this.artworkType,
    drawingStrokesJson: drawingStrokesJson.present
        ? drawingStrokesJson.value
        : this.drawingStrokesJson,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    templateVersion: templateVersion ?? this.templateVersion,
  );
  Receipt copyWithCompanion(ReceiptsCompanion data) {
    return Receipt(
      id: data.id.present ? data.id.value : this.id,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      displayNumber: data.displayNumber.present
          ? data.displayNumber.value
          : this.displayNumber,
      title: data.title.present ? data.title.value : this.title,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      selectedStart: data.selectedStart.present
          ? data.selectedStart.value
          : this.selectedStart,
      selectedEndExclusive: data.selectedEndExclusive.present
          ? data.selectedEndExclusive.value
          : this.selectedEndExclusive,
      includeFolderLabels: data.includeFolderLabels.present
          ? data.includeFolderLabels.value
          : this.includeFolderLabels,
      artworkType: data.artworkType.present
          ? data.artworkType.value
          : this.artworkType,
      drawingStrokesJson: data.drawingStrokesJson.present
          ? data.drawingStrokesJson.value
          : this.drawingStrokesJson,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      templateVersion: data.templateVersion.present
          ? data.templateVersion.value
          : this.templateVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Receipt(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('displayNumber: $displayNumber, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('selectedStart: $selectedStart, ')
          ..write('selectedEndExclusive: $selectedEndExclusive, ')
          ..write('includeFolderLabels: $includeFolderLabels, ')
          ..write('artworkType: $artworkType, ')
          ..write('drawingStrokesJson: $drawingStrokesJson, ')
          ..write('photoPath: $photoPath, ')
          ..write('templateVersion: $templateVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationId,
    displayNumber,
    title,
    source,
    createdAt,
    updatedAt,
    selectedStart,
    selectedEndExclusive,
    includeFolderLabels,
    artworkType,
    drawingStrokesJson,
    photoPath,
    templateVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Receipt &&
          other.id == this.id &&
          other.operationId == this.operationId &&
          other.displayNumber == this.displayNumber &&
          other.title == this.title &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.selectedStart == this.selectedStart &&
          other.selectedEndExclusive == this.selectedEndExclusive &&
          other.includeFolderLabels == this.includeFolderLabels &&
          other.artworkType == this.artworkType &&
          other.drawingStrokesJson == this.drawingStrokesJson &&
          other.photoPath == this.photoPath &&
          other.templateVersion == this.templateVersion);
}

class ReceiptsCompanion extends UpdateCompanion<Receipt> {
  final Value<String> id;
  final Value<String> operationId;
  final Value<int> displayNumber;
  final Value<String> title;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> selectedStart;
  final Value<DateTime?> selectedEndExclusive;
  final Value<bool> includeFolderLabels;
  final Value<String?> artworkType;
  final Value<String?> drawingStrokesJson;
  final Value<String?> photoPath;
  final Value<int> templateVersion;
  final Value<int> rowid;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.displayNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.selectedStart = const Value.absent(),
    this.selectedEndExclusive = const Value.absent(),
    this.includeFolderLabels = const Value.absent(),
    this.artworkType = const Value.absent(),
    this.drawingStrokesJson = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.templateVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    required String id,
    required String operationId,
    required int displayNumber,
    required String title,
    required String source,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.selectedStart = const Value.absent(),
    this.selectedEndExclusive = const Value.absent(),
    this.includeFolderLabels = const Value.absent(),
    this.artworkType = const Value.absent(),
    this.drawingStrokesJson = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.templateVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationId = Value(operationId),
       displayNumber = Value(displayNumber),
       title = Value(title),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Receipt> custom({
    Expression<String>? id,
    Expression<String>? operationId,
    Expression<int>? displayNumber,
    Expression<String>? title,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? selectedStart,
    Expression<DateTime>? selectedEndExclusive,
    Expression<bool>? includeFolderLabels,
    Expression<String>? artworkType,
    Expression<String>? drawingStrokesJson,
    Expression<String>? photoPath,
    Expression<int>? templateVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationId != null) 'operation_id': operationId,
      if (displayNumber != null) 'display_number': displayNumber,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (selectedStart != null) 'selected_start': selectedStart,
      if (selectedEndExclusive != null)
        'selected_end_exclusive': selectedEndExclusive,
      if (includeFolderLabels != null)
        'include_folder_labels': includeFolderLabels,
      if (artworkType != null) 'artwork_type': artworkType,
      if (drawingStrokesJson != null)
        'drawing_strokes_json': drawingStrokesJson,
      if (photoPath != null) 'photo_path': photoPath,
      if (templateVersion != null) 'template_version': templateVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptsCompanion copyWith({
    Value<String>? id,
    Value<String>? operationId,
    Value<int>? displayNumber,
    Value<String>? title,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? selectedStart,
    Value<DateTime?>? selectedEndExclusive,
    Value<bool>? includeFolderLabels,
    Value<String?>? artworkType,
    Value<String?>? drawingStrokesJson,
    Value<String?>? photoPath,
    Value<int>? templateVersion,
    Value<int>? rowid,
  }) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      displayNumber: displayNumber ?? this.displayNumber,
      title: title ?? this.title,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      selectedStart: selectedStart ?? this.selectedStart,
      selectedEndExclusive: selectedEndExclusive ?? this.selectedEndExclusive,
      includeFolderLabels: includeFolderLabels ?? this.includeFolderLabels,
      artworkType: artworkType ?? this.artworkType,
      drawingStrokesJson: drawingStrokesJson ?? this.drawingStrokesJson,
      photoPath: photoPath ?? this.photoPath,
      templateVersion: templateVersion ?? this.templateVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (displayNumber.present) {
      map['display_number'] = Variable<int>(displayNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (selectedStart.present) {
      map['selected_start'] = Variable<DateTime>(selectedStart.value);
    }
    if (selectedEndExclusive.present) {
      map['selected_end_exclusive'] = Variable<DateTime>(
        selectedEndExclusive.value,
      );
    }
    if (includeFolderLabels.present) {
      map['include_folder_labels'] = Variable<bool>(includeFolderLabels.value);
    }
    if (artworkType.present) {
      map['artwork_type'] = Variable<String>(artworkType.value);
    }
    if (drawingStrokesJson.present) {
      map['drawing_strokes_json'] = Variable<String>(drawingStrokesJson.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (templateVersion.present) {
      map['template_version'] = Variable<int>(templateVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('displayNumber: $displayNumber, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('selectedStart: $selectedStart, ')
          ..write('selectedEndExclusive: $selectedEndExclusive, ')
          ..write('includeFolderLabels: $includeFolderLabels, ')
          ..write('artworkType: $artworkType, ')
          ..write('drawingStrokesJson: $drawingStrokesJson, ')
          ..write('photoPath: $photoPath, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptItemsTable extends ReceiptItems
    with TableInfo<$ReceiptItemsTable, ReceiptItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _receiptIdMeta = const VerificationMeta(
    'receiptId',
  );
  @override
  late final GeneratedColumn<String> receiptId = GeneratedColumn<String>(
    'receipt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES receipts (id)',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleSnapshotMeta = const VerificationMeta(
    'titleSnapshot',
  );
  @override
  late final GeneratedColumn<String> titleSnapshot = GeneratedColumn<String>(
    'title_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderSnapshotMeta = const VerificationMeta(
    'folderSnapshot',
  );
  @override
  late final GeneratedColumn<String> folderSnapshot = GeneratedColumn<String>(
    'folder_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receiptId,
    taskId,
    position,
    titleSnapshot,
    folderSnapshot,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('receipt_id')) {
      context.handle(
        _receiptIdMeta,
        receiptId.isAcceptableOrUnknown(data['receipt_id']!, _receiptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('title_snapshot')) {
      context.handle(
        _titleSnapshotMeta,
        titleSnapshot.isAcceptableOrUnknown(
          data['title_snapshot']!,
          _titleSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleSnapshotMeta);
    }
    if (data.containsKey('folder_snapshot')) {
      context.handle(
        _folderSnapshotMeta,
        folderSnapshot.isAcceptableOrUnknown(
          data['folder_snapshot']!,
          _folderSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      receiptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      titleSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_snapshot'],
      )!,
      folderSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_snapshot'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $ReceiptItemsTable createAlias(String alias) {
    return $ReceiptItemsTable(attachedDatabase, alias);
  }
}

class ReceiptItem extends DataClass implements Insertable<ReceiptItem> {
  final int id;
  final String receiptId;
  final int? taskId;
  final int position;
  final String titleSnapshot;
  final String? folderSnapshot;
  final DateTime completedAt;
  const ReceiptItem({
    required this.id,
    required this.receiptId,
    this.taskId,
    required this.position,
    required this.titleSnapshot,
    this.folderSnapshot,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['receipt_id'] = Variable<String>(receiptId);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    map['position'] = Variable<int>(position);
    map['title_snapshot'] = Variable<String>(titleSnapshot);
    if (!nullToAbsent || folderSnapshot != null) {
      map['folder_snapshot'] = Variable<String>(folderSnapshot);
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  ReceiptItemsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptItemsCompanion(
      id: Value(id),
      receiptId: Value(receiptId),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      position: Value(position),
      titleSnapshot: Value(titleSnapshot),
      folderSnapshot: folderSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(folderSnapshot),
      completedAt: Value(completedAt),
    );
  }

  factory ReceiptItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptItem(
      id: serializer.fromJson<int>(json['id']),
      receiptId: serializer.fromJson<String>(json['receiptId']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      position: serializer.fromJson<int>(json['position']),
      titleSnapshot: serializer.fromJson<String>(json['titleSnapshot']),
      folderSnapshot: serializer.fromJson<String?>(json['folderSnapshot']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'receiptId': serializer.toJson<String>(receiptId),
      'taskId': serializer.toJson<int?>(taskId),
      'position': serializer.toJson<int>(position),
      'titleSnapshot': serializer.toJson<String>(titleSnapshot),
      'folderSnapshot': serializer.toJson<String?>(folderSnapshot),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  ReceiptItem copyWith({
    int? id,
    String? receiptId,
    Value<int?> taskId = const Value.absent(),
    int? position,
    String? titleSnapshot,
    Value<String?> folderSnapshot = const Value.absent(),
    DateTime? completedAt,
  }) => ReceiptItem(
    id: id ?? this.id,
    receiptId: receiptId ?? this.receiptId,
    taskId: taskId.present ? taskId.value : this.taskId,
    position: position ?? this.position,
    titleSnapshot: titleSnapshot ?? this.titleSnapshot,
    folderSnapshot: folderSnapshot.present
        ? folderSnapshot.value
        : this.folderSnapshot,
    completedAt: completedAt ?? this.completedAt,
  );
  ReceiptItem copyWithCompanion(ReceiptItemsCompanion data) {
    return ReceiptItem(
      id: data.id.present ? data.id.value : this.id,
      receiptId: data.receiptId.present ? data.receiptId.value : this.receiptId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      position: data.position.present ? data.position.value : this.position,
      titleSnapshot: data.titleSnapshot.present
          ? data.titleSnapshot.value
          : this.titleSnapshot,
      folderSnapshot: data.folderSnapshot.present
          ? data.folderSnapshot.value
          : this.folderSnapshot,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptItem(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('taskId: $taskId, ')
          ..write('position: $position, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('folderSnapshot: $folderSnapshot, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    receiptId,
    taskId,
    position,
    titleSnapshot,
    folderSnapshot,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptItem &&
          other.id == this.id &&
          other.receiptId == this.receiptId &&
          other.taskId == this.taskId &&
          other.position == this.position &&
          other.titleSnapshot == this.titleSnapshot &&
          other.folderSnapshot == this.folderSnapshot &&
          other.completedAt == this.completedAt);
}

class ReceiptItemsCompanion extends UpdateCompanion<ReceiptItem> {
  final Value<int> id;
  final Value<String> receiptId;
  final Value<int?> taskId;
  final Value<int> position;
  final Value<String> titleSnapshot;
  final Value<String?> folderSnapshot;
  final Value<DateTime> completedAt;
  const ReceiptItemsCompanion({
    this.id = const Value.absent(),
    this.receiptId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.position = const Value.absent(),
    this.titleSnapshot = const Value.absent(),
    this.folderSnapshot = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  ReceiptItemsCompanion.insert({
    this.id = const Value.absent(),
    required String receiptId,
    this.taskId = const Value.absent(),
    required int position,
    required String titleSnapshot,
    this.folderSnapshot = const Value.absent(),
    required DateTime completedAt,
  }) : receiptId = Value(receiptId),
       position = Value(position),
       titleSnapshot = Value(titleSnapshot),
       completedAt = Value(completedAt);
  static Insertable<ReceiptItem> custom({
    Expression<int>? id,
    Expression<String>? receiptId,
    Expression<int>? taskId,
    Expression<int>? position,
    Expression<String>? titleSnapshot,
    Expression<String>? folderSnapshot,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptId != null) 'receipt_id': receiptId,
      if (taskId != null) 'task_id': taskId,
      if (position != null) 'position': position,
      if (titleSnapshot != null) 'title_snapshot': titleSnapshot,
      if (folderSnapshot != null) 'folder_snapshot': folderSnapshot,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  ReceiptItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? receiptId,
    Value<int?>? taskId,
    Value<int>? position,
    Value<String>? titleSnapshot,
    Value<String?>? folderSnapshot,
    Value<DateTime>? completedAt,
  }) {
    return ReceiptItemsCompanion(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      taskId: taskId ?? this.taskId,
      position: position ?? this.position,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      folderSnapshot: folderSnapshot ?? this.folderSnapshot,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (receiptId.present) {
      map['receipt_id'] = Variable<String>(receiptId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (titleSnapshot.present) {
      map['title_snapshot'] = Variable<String>(titleSnapshot.value);
    }
    if (folderSnapshot.present) {
      map['folder_snapshot'] = Variable<String>(folderSnapshot.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptItemsCompanion(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('taskId: $taskId, ')
          ..write('position: $position, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('folderSnapshot: $folderSnapshot, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $ReceiptUsageEventsTable extends ReceiptUsageEvents
    with TableInfo<$ReceiptUsageEventsTable, ReceiptUsageEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptUsageEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _receiptIdMeta = const VerificationMeta(
    'receiptId',
  );
  @override
  late final GeneratedColumn<String> receiptId = GeneratedColumn<String>(
    'receipt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES receipts (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<DateTime> weekStart = GeneratedColumn<DateTime>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grantTypeMeta = const VerificationMeta(
    'grantType',
  );
  @override
  late final GeneratedColumn<String> grantType = GeneratedColumn<String>(
    'grant_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationId,
    receiptId,
    createdAt,
    weekStart,
    grantType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_usage_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptUsageEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('receipt_id')) {
      context.handle(
        _receiptIdMeta,
        receiptId.isAcceptableOrUnknown(data['receipt_id']!, _receiptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('grant_type')) {
      context.handle(
        _grantTypeMeta,
        grantType.isAcceptableOrUnknown(data['grant_type']!, _grantTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptUsageEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptUsageEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      receiptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start'],
      )!,
      grantType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grant_type'],
      )!,
    );
  }

  @override
  $ReceiptUsageEventsTable createAlias(String alias) {
    return $ReceiptUsageEventsTable(attachedDatabase, alias);
  }
}

class ReceiptUsageEvent extends DataClass
    implements Insertable<ReceiptUsageEvent> {
  final int id;
  final String operationId;
  final String receiptId;
  final DateTime createdAt;
  final DateTime weekStart;
  final String grantType;
  const ReceiptUsageEvent({
    required this.id,
    required this.operationId,
    required this.receiptId,
    required this.createdAt,
    required this.weekStart,
    required this.grantType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation_id'] = Variable<String>(operationId);
    map['receipt_id'] = Variable<String>(receiptId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['week_start'] = Variable<DateTime>(weekStart);
    map['grant_type'] = Variable<String>(grantType);
    return map;
  }

  ReceiptUsageEventsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptUsageEventsCompanion(
      id: Value(id),
      operationId: Value(operationId),
      receiptId: Value(receiptId),
      createdAt: Value(createdAt),
      weekStart: Value(weekStart),
      grantType: Value(grantType),
    );
  }

  factory ReceiptUsageEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptUsageEvent(
      id: serializer.fromJson<int>(json['id']),
      operationId: serializer.fromJson<String>(json['operationId']),
      receiptId: serializer.fromJson<String>(json['receiptId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      weekStart: serializer.fromJson<DateTime>(json['weekStart']),
      grantType: serializer.fromJson<String>(json['grantType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operationId': serializer.toJson<String>(operationId),
      'receiptId': serializer.toJson<String>(receiptId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'weekStart': serializer.toJson<DateTime>(weekStart),
      'grantType': serializer.toJson<String>(grantType),
    };
  }

  ReceiptUsageEvent copyWith({
    int? id,
    String? operationId,
    String? receiptId,
    DateTime? createdAt,
    DateTime? weekStart,
    String? grantType,
  }) => ReceiptUsageEvent(
    id: id ?? this.id,
    operationId: operationId ?? this.operationId,
    receiptId: receiptId ?? this.receiptId,
    createdAt: createdAt ?? this.createdAt,
    weekStart: weekStart ?? this.weekStart,
    grantType: grantType ?? this.grantType,
  );
  ReceiptUsageEvent copyWithCompanion(ReceiptUsageEventsCompanion data) {
    return ReceiptUsageEvent(
      id: data.id.present ? data.id.value : this.id,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      receiptId: data.receiptId.present ? data.receiptId.value : this.receiptId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      grantType: data.grantType.present ? data.grantType.value : this.grantType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptUsageEvent(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('receiptId: $receiptId, ')
          ..write('createdAt: $createdAt, ')
          ..write('weekStart: $weekStart, ')
          ..write('grantType: $grantType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, operationId, receiptId, createdAt, weekStart, grantType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptUsageEvent &&
          other.id == this.id &&
          other.operationId == this.operationId &&
          other.receiptId == this.receiptId &&
          other.createdAt == this.createdAt &&
          other.weekStart == this.weekStart &&
          other.grantType == this.grantType);
}

class ReceiptUsageEventsCompanion extends UpdateCompanion<ReceiptUsageEvent> {
  final Value<int> id;
  final Value<String> operationId;
  final Value<String> receiptId;
  final Value<DateTime> createdAt;
  final Value<DateTime> weekStart;
  final Value<String> grantType;
  const ReceiptUsageEventsCompanion({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.receiptId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.grantType = const Value.absent(),
  });
  ReceiptUsageEventsCompanion.insert({
    this.id = const Value.absent(),
    required String operationId,
    required String receiptId,
    required DateTime createdAt,
    required DateTime weekStart,
    this.grantType = const Value.absent(),
  }) : operationId = Value(operationId),
       receiptId = Value(receiptId),
       createdAt = Value(createdAt),
       weekStart = Value(weekStart);
  static Insertable<ReceiptUsageEvent> custom({
    Expression<int>? id,
    Expression<String>? operationId,
    Expression<String>? receiptId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? weekStart,
    Expression<String>? grantType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationId != null) 'operation_id': operationId,
      if (receiptId != null) 'receipt_id': receiptId,
      if (createdAt != null) 'created_at': createdAt,
      if (weekStart != null) 'week_start': weekStart,
      if (grantType != null) 'grant_type': grantType,
    });
  }

  ReceiptUsageEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? operationId,
    Value<String>? receiptId,
    Value<DateTime>? createdAt,
    Value<DateTime>? weekStart,
    Value<String>? grantType,
  }) {
    return ReceiptUsageEventsCompanion(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      receiptId: receiptId ?? this.receiptId,
      createdAt: createdAt ?? this.createdAt,
      weekStart: weekStart ?? this.weekStart,
      grantType: grantType ?? this.grantType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (receiptId.present) {
      map['receipt_id'] = Variable<String>(receiptId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<DateTime>(weekStart.value);
    }
    if (grantType.present) {
      map['grant_type'] = Variable<String>(grantType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptUsageEventsCompanion(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('receiptId: $receiptId, ')
          ..write('createdAt: $createdAt, ')
          ..write('weekStart: $weekStart, ')
          ..write('grantType: $grantType')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $TaskSeriesTable taskSeries = $TaskSeriesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $FocusHistoryTable focusHistory = $FocusHistoryTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $ReceiptItemsTable receiptItems = $ReceiptItemsTable(this);
  late final $ReceiptUsageEventsTable receiptUsageEvents =
      $ReceiptUsageEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    folders,
    taskSeries,
    tasks,
    focusHistory,
    receipts,
    receiptItems,
    receiptUsageEvents,
  ];
}

typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      required String name,
      required DateTime createdAt,
      required int sortOrder,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> sortOrder,
    });

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskSeriesTable, List<TaskSery>>
  _taskSeriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskSeries,
    aliasName: $_aliasNameGenerator(db.folders.id, db.taskSeries.folderId),
  );

  $$TaskSeriesTableProcessedTableManager get taskSeriesRefs {
    final manager = $$TaskSeriesTableTableManager(
      $_db,
      $_db.taskSeries,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskSeriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: $_aliasNameGenerator(db.folders.id, db.tasks.folderId),
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> taskSeriesRefs(
    Expression<bool> Function($$TaskSeriesTableFilterComposer f) f,
  ) {
    final $$TaskSeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableFilterComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> taskSeriesRefs<T extends Object>(
    Expression<T> Function($$TaskSeriesTableAnnotationComposer a) f,
  ) {
    final $$TaskSeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool taskSeriesRefs, bool tasksRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime createdAt,
                required int sortOrder,
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskSeriesRefs = false, tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (taskSeriesRefs) db.taskSeries,
                if (tasksRefs) db.tasks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskSeriesRefs)
                    await $_getPrefetchedData<Folder, $FoldersTable, TaskSery>(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences
                          ._taskSeriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$FoldersTableReferences(
                        db,
                        table,
                        p0,
                      ).taskSeriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                  if (tasksRefs)
                    await $_getPrefetchedData<Folder, $FoldersTable, Task>(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences._tasksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool taskSeriesRefs, bool tasksRefs})
    >;
typedef $$TaskSeriesTableCreateCompanionBuilder =
    TaskSeriesCompanion Function({
      Value<int> id,
      required String title,
      required int folderId,
      required String repeatType,
      Value<int> recurrenceInterval,
      Value<String?> customRepeatLabel,
      required DateTime anchorDate,
      Value<DateTime?> time,
      Value<DateTime?> reminderTime,
      Value<int?> focusDurationMinutes,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$TaskSeriesTableUpdateCompanionBuilder =
    TaskSeriesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> folderId,
      Value<String> repeatType,
      Value<int> recurrenceInterval,
      Value<String?> customRepeatLabel,
      Value<DateTime> anchorDate,
      Value<DateTime?> time,
      Value<DateTime?> reminderTime,
      Value<int?> focusDurationMinutes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$TaskSeriesTableReferences
    extends BaseReferences<_$AppDatabase, $TaskSeriesTable, TaskSery> {
  $$TaskSeriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.taskSeries.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: $_aliasNameGenerator(db.taskSeries.id, db.tasks.seriesId),
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TaskSeriesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskSeriesTable> {
  $$TaskSeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customRepeatLabel => $composableBuilder(
    column: $table.customRepeatLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusDurationMinutes => $composableBuilder(
    column: $table.focusDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskSeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskSeriesTable> {
  $$TaskSeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customRepeatLabel => $composableBuilder(
    column: $table.customRepeatLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusDurationMinutes => $composableBuilder(
    column: $table.focusDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskSeriesTable> {
  $$TaskSeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get repeatType => $composableBuilder(
    column: $table.repeatType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customRepeatLabel => $composableBuilder(
    column: $table.customRepeatLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focusDurationMinutes => $composableBuilder(
    column: $table.focusDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskSeriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskSeriesTable,
          TaskSery,
          $$TaskSeriesTableFilterComposer,
          $$TaskSeriesTableOrderingComposer,
          $$TaskSeriesTableAnnotationComposer,
          $$TaskSeriesTableCreateCompanionBuilder,
          $$TaskSeriesTableUpdateCompanionBuilder,
          (TaskSery, $$TaskSeriesTableReferences),
          TaskSery,
          PrefetchHooks Function({bool folderId, bool tasksRefs})
        > {
  $$TaskSeriesTableTableManager(_$AppDatabase db, $TaskSeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskSeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskSeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskSeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<String> repeatType = const Value.absent(),
                Value<int> recurrenceInterval = const Value.absent(),
                Value<String?> customRepeatLabel = const Value.absent(),
                Value<DateTime> anchorDate = const Value.absent(),
                Value<DateTime?> time = const Value.absent(),
                Value<DateTime?> reminderTime = const Value.absent(),
                Value<int?> focusDurationMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TaskSeriesCompanion(
                id: id,
                title: title,
                folderId: folderId,
                repeatType: repeatType,
                recurrenceInterval: recurrenceInterval,
                customRepeatLabel: customRepeatLabel,
                anchorDate: anchorDate,
                time: time,
                reminderTime: reminderTime,
                focusDurationMinutes: focusDurationMinutes,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int folderId,
                required String repeatType,
                Value<int> recurrenceInterval = const Value.absent(),
                Value<String?> customRepeatLabel = const Value.absent(),
                required DateTime anchorDate,
                Value<DateTime?> time = const Value.absent(),
                Value<DateTime?> reminderTime = const Value.absent(),
                Value<int?> focusDurationMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => TaskSeriesCompanion.insert(
                id: id,
                title: title,
                folderId: folderId,
                repeatType: repeatType,
                recurrenceInterval: recurrenceInterval,
                customRepeatLabel: customRepeatLabel,
                anchorDate: anchorDate,
                time: time,
                reminderTime: reminderTime,
                focusDurationMinutes: focusDurationMinutes,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskSeriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false, tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$TaskSeriesTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$TaskSeriesTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<TaskSery, $TaskSeriesTable, Task>(
                      currentTable: table,
                      referencedTable: $$TaskSeriesTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TaskSeriesTableReferences(db, table, p0).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.seriesId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TaskSeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskSeriesTable,
      TaskSery,
      $$TaskSeriesTableFilterComposer,
      $$TaskSeriesTableOrderingComposer,
      $$TaskSeriesTableAnnotationComposer,
      $$TaskSeriesTableCreateCompanionBuilder,
      $$TaskSeriesTableUpdateCompanionBuilder,
      (TaskSery, $$TaskSeriesTableReferences),
      TaskSery,
      PrefetchHooks Function({bool folderId, bool tasksRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int?> seriesId,
      required int folderId,
      required String title,
      Value<DateTime?> scheduledDate,
      Value<DateTime?> scheduledTime,
      Value<DateTime?> reminderTime,
      Value<int?> focusDurationMinutes,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      required int globalSortOrder,
      required DateTime createdAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int?> seriesId,
      Value<int> folderId,
      Value<String> title,
      Value<DateTime?> scheduledDate,
      Value<DateTime?> scheduledTime,
      Value<DateTime?> reminderTime,
      Value<int?> focusDurationMinutes,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<int> globalSortOrder,
      Value<DateTime> createdAt,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TaskSeriesTable _seriesIdTable(_$AppDatabase db) => db.taskSeries
      .createAlias($_aliasNameGenerator(db.tasks.seriesId, db.taskSeries.id));

  $$TaskSeriesTableProcessedTableManager? get seriesId {
    final $_column = $_itemColumn<int>('series_id');
    if ($_column == null) return null;
    final manager = $$TaskSeriesTableTableManager(
      $_db,
      $_db.taskSeries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FoldersTable _folderIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.tasks.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FocusHistoryTable, List<FocusHistoryData>>
  _focusHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusHistory,
    aliasName: $_aliasNameGenerator(db.tasks.id, db.focusHistory.taskId),
  );

  $$FocusHistoryTableProcessedTableManager get focusHistoryRefs {
    final manager = $$FocusHistoryTableTableManager(
      $_db,
      $_db.focusHistory,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReceiptItemsTable, List<ReceiptItem>>
  _receiptItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receiptItems,
    aliasName: $_aliasNameGenerator(db.tasks.id, db.receiptItems.taskId),
  );

  $$ReceiptItemsTableProcessedTableManager get receiptItemsRefs {
    final manager = $$ReceiptItemsTableTableManager(
      $_db,
      $_db.receiptItems,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusDurationMinutes => $composableBuilder(
    column: $table.focusDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get globalSortOrder => $composableBuilder(
    column: $table.globalSortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TaskSeriesTableFilterComposer get seriesId {
    final $$TaskSeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableFilterComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> focusHistoryRefs(
    Expression<bool> Function($$FocusHistoryTableFilterComposer f) f,
  ) {
    final $$FocusHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusHistory,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusHistoryTableFilterComposer(
            $db: $db,
            $table: $db.focusHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> receiptItemsRefs(
    Expression<bool> Function($$ReceiptItemsTableFilterComposer f) f,
  ) {
    final $$ReceiptItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptItems,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptItemsTableFilterComposer(
            $db: $db,
            $table: $db.receiptItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusDurationMinutes => $composableBuilder(
    column: $table.focusDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get globalSortOrder => $composableBuilder(
    column: $table.globalSortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TaskSeriesTableOrderingComposer get seriesId {
    final $$TaskSeriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableOrderingComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focusDurationMinutes => $composableBuilder(
    column: $table.focusDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get globalSortOrder => $composableBuilder(
    column: $table.globalSortOrder,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TaskSeriesTableAnnotationComposer get seriesId {
    final $$TaskSeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> focusHistoryRefs<T extends Object>(
    Expression<T> Function($$FocusHistoryTableAnnotationComposer a) f,
  ) {
    final $$FocusHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusHistory,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.focusHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> receiptItemsRefs<T extends Object>(
    Expression<T> Function($$ReceiptItemsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptItems,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.receiptItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({
            bool seriesId,
            bool folderId,
            bool focusHistoryRefs,
            bool receiptItemsRefs,
          })
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<DateTime?> scheduledTime = const Value.absent(),
                Value<DateTime?> reminderTime = const Value.absent(),
                Value<int?> focusDurationMinutes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> globalSortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                seriesId: seriesId,
                folderId: folderId,
                title: title,
                scheduledDate: scheduledDate,
                scheduledTime: scheduledTime,
                reminderTime: reminderTime,
                focusDurationMinutes: focusDurationMinutes,
                isCompleted: isCompleted,
                completedAt: completedAt,
                globalSortOrder: globalSortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
                required int folderId,
                required String title,
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<DateTime?> scheduledTime = const Value.absent(),
                Value<DateTime?> reminderTime = const Value.absent(),
                Value<int?> focusDurationMinutes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required int globalSortOrder,
                required DateTime createdAt,
              }) => TasksCompanion.insert(
                id: id,
                seriesId: seriesId,
                folderId: folderId,
                title: title,
                scheduledDate: scheduledDate,
                scheduledTime: scheduledTime,
                reminderTime: reminderTime,
                focusDurationMinutes: focusDurationMinutes,
                isCompleted: isCompleted,
                completedAt: completedAt,
                globalSortOrder: globalSortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                seriesId = false,
                folderId = false,
                focusHistoryRefs = false,
                receiptItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (focusHistoryRefs) db.focusHistory,
                    if (receiptItemsRefs) db.receiptItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (seriesId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.seriesId,
                                    referencedTable: $$TasksTableReferences
                                        ._seriesIdTable(db),
                                    referencedColumn: $$TasksTableReferences
                                        ._seriesIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (folderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.folderId,
                                    referencedTable: $$TasksTableReferences
                                        ._folderIdTable(db),
                                    referencedColumn: $$TasksTableReferences
                                        ._folderIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (focusHistoryRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          FocusHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._focusHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).focusHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (receiptItemsRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          ReceiptItem
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._receiptItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({
        bool seriesId,
        bool folderId,
        bool focusHistoryRefs,
        bool receiptItemsRefs,
      })
    >;
typedef $$FocusHistoryTableCreateCompanionBuilder =
    FocusHistoryCompanion Function({
      Value<int> id,
      Value<int?> taskId,
      required DateTime startedAt,
      required DateTime completedAt,
      required int plannedDurationMinutes,
      required int actualDurationMinutes,
      required bool wasExtended,
      required DateTime createdAt,
    });
typedef $$FocusHistoryTableUpdateCompanionBuilder =
    FocusHistoryCompanion Function({
      Value<int> id,
      Value<int?> taskId,
      Value<DateTime> startedAt,
      Value<DateTime> completedAt,
      Value<int> plannedDurationMinutes,
      Value<int> actualDurationMinutes,
      Value<bool> wasExtended,
      Value<DateTime> createdAt,
    });

final class $$FocusHistoryTableReferences
    extends
        BaseReferences<_$AppDatabase, $FocusHistoryTable, FocusHistoryData> {
  $$FocusHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
    $_aliasNameGenerator(db.focusHistory.taskId, db.tasks.id),
  );

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FocusHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $FocusHistoryTable> {
  $$FocusHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationMinutes => $composableBuilder(
    column: $table.plannedDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasExtended => $composableBuilder(
    column: $table.wasExtended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusHistoryTable> {
  $$FocusHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationMinutes => $composableBuilder(
    column: $table.plannedDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasExtended => $composableBuilder(
    column: $table.wasExtended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusHistoryTable> {
  $$FocusHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDurationMinutes => $composableBuilder(
    column: $table.plannedDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasExtended => $composableBuilder(
    column: $table.wasExtended,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusHistoryTable,
          FocusHistoryData,
          $$FocusHistoryTableFilterComposer,
          $$FocusHistoryTableOrderingComposer,
          $$FocusHistoryTableAnnotationComposer,
          $$FocusHistoryTableCreateCompanionBuilder,
          $$FocusHistoryTableUpdateCompanionBuilder,
          (FocusHistoryData, $$FocusHistoryTableReferences),
          FocusHistoryData,
          PrefetchHooks Function({bool taskId})
        > {
  $$FocusHistoryTableTableManager(_$AppDatabase db, $FocusHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> plannedDurationMinutes = const Value.absent(),
                Value<int> actualDurationMinutes = const Value.absent(),
                Value<bool> wasExtended = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FocusHistoryCompanion(
                id: id,
                taskId: taskId,
                startedAt: startedAt,
                completedAt: completedAt,
                plannedDurationMinutes: plannedDurationMinutes,
                actualDurationMinutes: actualDurationMinutes,
                wasExtended: wasExtended,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                required DateTime startedAt,
                required DateTime completedAt,
                required int plannedDurationMinutes,
                required int actualDurationMinutes,
                required bool wasExtended,
                required DateTime createdAt,
              }) => FocusHistoryCompanion.insert(
                id: id,
                taskId: taskId,
                startedAt: startedAt,
                completedAt: completedAt,
                plannedDurationMinutes: plannedDurationMinutes,
                actualDurationMinutes: actualDurationMinutes,
                wasExtended: wasExtended,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FocusHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$FocusHistoryTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$FocusHistoryTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FocusHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusHistoryTable,
      FocusHistoryData,
      $$FocusHistoryTableFilterComposer,
      $$FocusHistoryTableOrderingComposer,
      $$FocusHistoryTableAnnotationComposer,
      $$FocusHistoryTableCreateCompanionBuilder,
      $$FocusHistoryTableUpdateCompanionBuilder,
      (FocusHistoryData, $$FocusHistoryTableReferences),
      FocusHistoryData,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$ReceiptsTableCreateCompanionBuilder =
    ReceiptsCompanion Function({
      required String id,
      required String operationId,
      required int displayNumber,
      required String title,
      required String source,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> selectedStart,
      Value<DateTime?> selectedEndExclusive,
      Value<bool> includeFolderLabels,
      Value<String?> artworkType,
      Value<String?> drawingStrokesJson,
      Value<String?> photoPath,
      Value<int> templateVersion,
      Value<int> rowid,
    });
typedef $$ReceiptsTableUpdateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<String> id,
      Value<String> operationId,
      Value<int> displayNumber,
      Value<String> title,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> selectedStart,
      Value<DateTime?> selectedEndExclusive,
      Value<bool> includeFolderLabels,
      Value<String?> artworkType,
      Value<String?> drawingStrokesJson,
      Value<String?> photoPath,
      Value<int> templateVersion,
      Value<int> rowid,
    });

final class $$ReceiptsTableReferences
    extends BaseReferences<_$AppDatabase, $ReceiptsTable, Receipt> {
  $$ReceiptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReceiptItemsTable, List<ReceiptItem>>
  _receiptItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receiptItems,
    aliasName: $_aliasNameGenerator(db.receipts.id, db.receiptItems.receiptId),
  );

  $$ReceiptItemsTableProcessedTableManager get receiptItemsRefs {
    final manager = $$ReceiptItemsTableTableManager(
      $_db,
      $_db.receiptItems,
    ).filter((f) => f.receiptId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReceiptUsageEventsTable, List<ReceiptUsageEvent>>
  _receiptUsageEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.receiptUsageEvents,
        aliasName: $_aliasNameGenerator(
          db.receipts.id,
          db.receiptUsageEvents.receiptId,
        ),
      );

  $$ReceiptUsageEventsTableProcessedTableManager get receiptUsageEventsRefs {
    final manager = $$ReceiptUsageEventsTableTableManager(
      $_db,
      $_db.receiptUsageEvents,
    ).filter((f) => f.receiptId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _receiptUsageEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayNumber => $composableBuilder(
    column: $table.displayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get selectedStart => $composableBuilder(
    column: $table.selectedStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get selectedEndExclusive => $composableBuilder(
    column: $table.selectedEndExclusive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeFolderLabels => $composableBuilder(
    column: $table.includeFolderLabels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkType => $composableBuilder(
    column: $table.artworkType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drawingStrokesJson => $composableBuilder(
    column: $table.drawingStrokesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> receiptItemsRefs(
    Expression<bool> Function($$ReceiptItemsTableFilterComposer f) f,
  ) {
    final $$ReceiptItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptItems,
      getReferencedColumn: (t) => t.receiptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptItemsTableFilterComposer(
            $db: $db,
            $table: $db.receiptItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> receiptUsageEventsRefs(
    Expression<bool> Function($$ReceiptUsageEventsTableFilterComposer f) f,
  ) {
    final $$ReceiptUsageEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptUsageEvents,
      getReferencedColumn: (t) => t.receiptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptUsageEventsTableFilterComposer(
            $db: $db,
            $table: $db.receiptUsageEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayNumber => $composableBuilder(
    column: $table.displayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get selectedStart => $composableBuilder(
    column: $table.selectedStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get selectedEndExclusive => $composableBuilder(
    column: $table.selectedEndExclusive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeFolderLabels => $composableBuilder(
    column: $table.includeFolderLabels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkType => $composableBuilder(
    column: $table.artworkType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drawingStrokesJson => $composableBuilder(
    column: $table.drawingStrokesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayNumber => $composableBuilder(
    column: $table.displayNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get selectedStart => $composableBuilder(
    column: $table.selectedStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get selectedEndExclusive => $composableBuilder(
    column: $table.selectedEndExclusive,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeFolderLabels => $composableBuilder(
    column: $table.includeFolderLabels,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkType => $composableBuilder(
    column: $table.artworkType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get drawingStrokesJson => $composableBuilder(
    column: $table.drawingStrokesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => column,
  );

  Expression<T> receiptItemsRefs<T extends Object>(
    Expression<T> Function($$ReceiptItemsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptItems,
      getReferencedColumn: (t) => t.receiptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.receiptItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> receiptUsageEventsRefs<T extends Object>(
    Expression<T> Function($$ReceiptUsageEventsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptUsageEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.receiptUsageEvents,
          getReferencedColumn: (t) => t.receiptId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReceiptUsageEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.receiptUsageEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTable,
          Receipt,
          $$ReceiptsTableFilterComposer,
          $$ReceiptsTableOrderingComposer,
          $$ReceiptsTableAnnotationComposer,
          $$ReceiptsTableCreateCompanionBuilder,
          $$ReceiptsTableUpdateCompanionBuilder,
          (Receipt, $$ReceiptsTableReferences),
          Receipt,
          PrefetchHooks Function({
            bool receiptItemsRefs,
            bool receiptUsageEventsRefs,
          })
        > {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<int> displayNumber = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> selectedStart = const Value.absent(),
                Value<DateTime?> selectedEndExclusive = const Value.absent(),
                Value<bool> includeFolderLabels = const Value.absent(),
                Value<String?> artworkType = const Value.absent(),
                Value<String?> drawingStrokesJson = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> templateVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsCompanion(
                id: id,
                operationId: operationId,
                displayNumber: displayNumber,
                title: title,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                selectedStart: selectedStart,
                selectedEndExclusive: selectedEndExclusive,
                includeFolderLabels: includeFolderLabels,
                artworkType: artworkType,
                drawingStrokesJson: drawingStrokesJson,
                photoPath: photoPath,
                templateVersion: templateVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operationId,
                required int displayNumber,
                required String title,
                required String source,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> selectedStart = const Value.absent(),
                Value<DateTime?> selectedEndExclusive = const Value.absent(),
                Value<bool> includeFolderLabels = const Value.absent(),
                Value<String?> artworkType = const Value.absent(),
                Value<String?> drawingStrokesJson = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> templateVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsCompanion.insert(
                id: id,
                operationId: operationId,
                displayNumber: displayNumber,
                title: title,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                selectedStart: selectedStart,
                selectedEndExclusive: selectedEndExclusive,
                includeFolderLabels: includeFolderLabels,
                artworkType: artworkType,
                drawingStrokesJson: drawingStrokesJson,
                photoPath: photoPath,
                templateVersion: templateVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReceiptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({receiptItemsRefs = false, receiptUsageEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (receiptItemsRefs) db.receiptItems,
                    if (receiptUsageEventsRefs) db.receiptUsageEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (receiptItemsRefs)
                        await $_getPrefetchedData<
                          Receipt,
                          $ReceiptsTable,
                          ReceiptItem
                        >(
                          currentTable: table,
                          referencedTable: $$ReceiptsTableReferences
                              ._receiptItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReceiptsTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.receiptId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (receiptUsageEventsRefs)
                        await $_getPrefetchedData<
                          Receipt,
                          $ReceiptsTable,
                          ReceiptUsageEvent
                        >(
                          currentTable: table,
                          referencedTable: $$ReceiptsTableReferences
                              ._receiptUsageEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReceiptsTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptUsageEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.receiptId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTable,
      Receipt,
      $$ReceiptsTableFilterComposer,
      $$ReceiptsTableOrderingComposer,
      $$ReceiptsTableAnnotationComposer,
      $$ReceiptsTableCreateCompanionBuilder,
      $$ReceiptsTableUpdateCompanionBuilder,
      (Receipt, $$ReceiptsTableReferences),
      Receipt,
      PrefetchHooks Function({
        bool receiptItemsRefs,
        bool receiptUsageEventsRefs,
      })
    >;
typedef $$ReceiptItemsTableCreateCompanionBuilder =
    ReceiptItemsCompanion Function({
      Value<int> id,
      required String receiptId,
      Value<int?> taskId,
      required int position,
      required String titleSnapshot,
      Value<String?> folderSnapshot,
      required DateTime completedAt,
    });
typedef $$ReceiptItemsTableUpdateCompanionBuilder =
    ReceiptItemsCompanion Function({
      Value<int> id,
      Value<String> receiptId,
      Value<int?> taskId,
      Value<int> position,
      Value<String> titleSnapshot,
      Value<String?> folderSnapshot,
      Value<DateTime> completedAt,
    });

final class $$ReceiptItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ReceiptItemsTable, ReceiptItem> {
  $$ReceiptItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReceiptsTable _receiptIdTable(_$AppDatabase db) =>
      db.receipts.createAlias(
        $_aliasNameGenerator(db.receiptItems.receiptId, db.receipts.id),
      );

  $$ReceiptsTableProcessedTableManager get receiptId {
    final $_column = $_itemColumn<String>('receipt_id')!;

    final manager = $$ReceiptsTableTableManager(
      $_db,
      $_db.receipts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receiptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
    $_aliasNameGenerator(db.receiptItems.taskId, db.tasks.id),
  );

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceiptItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderSnapshot => $composableBuilder(
    column: $table.folderSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ReceiptsTableFilterComposer get receiptId {
    final $$ReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderSnapshot => $composableBuilder(
    column: $table.folderSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReceiptsTableOrderingComposer get receiptId {
    final $$ReceiptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableOrderingComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderSnapshot => $composableBuilder(
    column: $table.folderSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$ReceiptsTableAnnotationComposer get receiptId {
    final $$ReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptItemsTable,
          ReceiptItem,
          $$ReceiptItemsTableFilterComposer,
          $$ReceiptItemsTableOrderingComposer,
          $$ReceiptItemsTableAnnotationComposer,
          $$ReceiptItemsTableCreateCompanionBuilder,
          $$ReceiptItemsTableUpdateCompanionBuilder,
          (ReceiptItem, $$ReceiptItemsTableReferences),
          ReceiptItem,
          PrefetchHooks Function({bool receiptId, bool taskId})
        > {
  $$ReceiptItemsTableTableManager(_$AppDatabase db, $ReceiptItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> receiptId = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> titleSnapshot = const Value.absent(),
                Value<String?> folderSnapshot = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => ReceiptItemsCompanion(
                id: id,
                receiptId: receiptId,
                taskId: taskId,
                position: position,
                titleSnapshot: titleSnapshot,
                folderSnapshot: folderSnapshot,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String receiptId,
                Value<int?> taskId = const Value.absent(),
                required int position,
                required String titleSnapshot,
                Value<String?> folderSnapshot = const Value.absent(),
                required DateTime completedAt,
              }) => ReceiptItemsCompanion.insert(
                id: id,
                receiptId: receiptId,
                taskId: taskId,
                position: position,
                titleSnapshot: titleSnapshot,
                folderSnapshot: folderSnapshot,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReceiptItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({receiptId = false, taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (receiptId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.receiptId,
                                referencedTable: $$ReceiptItemsTableReferences
                                    ._receiptIdTable(db),
                                referencedColumn: $$ReceiptItemsTableReferences
                                    ._receiptIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$ReceiptItemsTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$ReceiptItemsTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReceiptItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptItemsTable,
      ReceiptItem,
      $$ReceiptItemsTableFilterComposer,
      $$ReceiptItemsTableOrderingComposer,
      $$ReceiptItemsTableAnnotationComposer,
      $$ReceiptItemsTableCreateCompanionBuilder,
      $$ReceiptItemsTableUpdateCompanionBuilder,
      (ReceiptItem, $$ReceiptItemsTableReferences),
      ReceiptItem,
      PrefetchHooks Function({bool receiptId, bool taskId})
    >;
typedef $$ReceiptUsageEventsTableCreateCompanionBuilder =
    ReceiptUsageEventsCompanion Function({
      Value<int> id,
      required String operationId,
      required String receiptId,
      required DateTime createdAt,
      required DateTime weekStart,
      Value<String> grantType,
    });
typedef $$ReceiptUsageEventsTableUpdateCompanionBuilder =
    ReceiptUsageEventsCompanion Function({
      Value<int> id,
      Value<String> operationId,
      Value<String> receiptId,
      Value<DateTime> createdAt,
      Value<DateTime> weekStart,
      Value<String> grantType,
    });

final class $$ReceiptUsageEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReceiptUsageEventsTable,
          ReceiptUsageEvent
        > {
  $$ReceiptUsageEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReceiptsTable _receiptIdTable(_$AppDatabase db) =>
      db.receipts.createAlias(
        $_aliasNameGenerator(db.receiptUsageEvents.receiptId, db.receipts.id),
      );

  $$ReceiptsTableProcessedTableManager get receiptId {
    final $_column = $_itemColumn<String>('receipt_id')!;

    final manager = $$ReceiptsTableTableManager(
      $_db,
      $_db.receipts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receiptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceiptUsageEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptUsageEventsTable> {
  $$ReceiptUsageEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grantType => $composableBuilder(
    column: $table.grantType,
    builder: (column) => ColumnFilters(column),
  );

  $$ReceiptsTableFilterComposer get receiptId {
    final $$ReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptUsageEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptUsageEventsTable> {
  $$ReceiptUsageEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grantType => $composableBuilder(
    column: $table.grantType,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReceiptsTableOrderingComposer get receiptId {
    final $$ReceiptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableOrderingComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptUsageEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptUsageEventsTable> {
  $$ReceiptUsageEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<String> get grantType =>
      $composableBuilder(column: $table.grantType, builder: (column) => column);

  $$ReceiptsTableAnnotationComposer get receiptId {
    final $$ReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptUsageEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptUsageEventsTable,
          ReceiptUsageEvent,
          $$ReceiptUsageEventsTableFilterComposer,
          $$ReceiptUsageEventsTableOrderingComposer,
          $$ReceiptUsageEventsTableAnnotationComposer,
          $$ReceiptUsageEventsTableCreateCompanionBuilder,
          $$ReceiptUsageEventsTableUpdateCompanionBuilder,
          (ReceiptUsageEvent, $$ReceiptUsageEventsTableReferences),
          ReceiptUsageEvent,
          PrefetchHooks Function({bool receiptId})
        > {
  $$ReceiptUsageEventsTableTableManager(
    _$AppDatabase db,
    $ReceiptUsageEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptUsageEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptUsageEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptUsageEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<String> receiptId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> weekStart = const Value.absent(),
                Value<String> grantType = const Value.absent(),
              }) => ReceiptUsageEventsCompanion(
                id: id,
                operationId: operationId,
                receiptId: receiptId,
                createdAt: createdAt,
                weekStart: weekStart,
                grantType: grantType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operationId,
                required String receiptId,
                required DateTime createdAt,
                required DateTime weekStart,
                Value<String> grantType = const Value.absent(),
              }) => ReceiptUsageEventsCompanion.insert(
                id: id,
                operationId: operationId,
                receiptId: receiptId,
                createdAt: createdAt,
                weekStart: weekStart,
                grantType: grantType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReceiptUsageEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({receiptId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (receiptId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.receiptId,
                                referencedTable:
                                    $$ReceiptUsageEventsTableReferences
                                        ._receiptIdTable(db),
                                referencedColumn:
                                    $$ReceiptUsageEventsTableReferences
                                        ._receiptIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReceiptUsageEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptUsageEventsTable,
      ReceiptUsageEvent,
      $$ReceiptUsageEventsTableFilterComposer,
      $$ReceiptUsageEventsTableOrderingComposer,
      $$ReceiptUsageEventsTableAnnotationComposer,
      $$ReceiptUsageEventsTableCreateCompanionBuilder,
      $$ReceiptUsageEventsTableUpdateCompanionBuilder,
      (ReceiptUsageEvent, $$ReceiptUsageEventsTableReferences),
      ReceiptUsageEvent,
      PrefetchHooks Function({bool receiptId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$TaskSeriesTableTableManager get taskSeries =>
      $$TaskSeriesTableTableManager(_db, _db.taskSeries);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$FocusHistoryTableTableManager get focusHistory =>
      $$FocusHistoryTableTableManager(_db, _db.focusHistory);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$ReceiptItemsTableTableManager get receiptItems =>
      $$ReceiptItemsTableTableManager(_db, _db.receiptItems);
  $$ReceiptUsageEventsTableTableManager get receiptUsageEvents =>
      $$ReceiptUsageEventsTableTableManager(_db, _db.receiptUsageEvents);
}
