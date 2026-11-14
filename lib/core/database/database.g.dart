// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streamMeta = const VerificationMeta('stream');
  @override
  late final GeneratedColumn<String> stream = GeneratedColumn<String>(
    'stream',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyGoalMinutesMeta = const VerificationMeta(
    'dailyGoalMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyGoalMinutes = GeneratedColumn<int>(
    'daily_goal_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120),
  );
  static const VerificationMeta _streakCountMeta = const VerificationMeta(
    'streakCount',
  );
  @override
  late final GeneratedColumn<int> streakCount = GeneratedColumn<int>(
    'streak_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakFreezesMeta = const VerificationMeta(
    'streakFreezes',
  );
  @override
  late final GeneratedColumn<int> streakFreezes = GeneratedColumn<int>(
    'streak_freezes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastStudyDateMeta = const VerificationMeta(
    'lastStudyDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastStudyDate =
      GeneratedColumn<DateTime>(
        'last_study_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    name,
    grade,
    gender,
    stream,
    dailyGoalMinutes,
    streakCount,
    streakFreezes,
    lastStudyDate,
    avatarUrl,
    createdAt,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('stream')) {
      context.handle(
        _streamMeta,
        stream.isAcceptableOrUnknown(data['stream']!, _streamMeta),
      );
    } else if (isInserting) {
      context.missing(_streamMeta);
    }
    if (data.containsKey('daily_goal_minutes')) {
      context.handle(
        _dailyGoalMinutesMeta,
        dailyGoalMinutes.isAcceptableOrUnknown(
          data['daily_goal_minutes']!,
          _dailyGoalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('streak_count')) {
      context.handle(
        _streakCountMeta,
        streakCount.isAcceptableOrUnknown(
          data['streak_count']!,
          _streakCountMeta,
        ),
      );
    }
    if (data.containsKey('streak_freezes')) {
      context.handle(
        _streakFreezesMeta,
        streakFreezes.isAcceptableOrUnknown(
          data['streak_freezes']!,
          _streakFreezesMeta,
        ),
      );
    }
    if (data.containsKey('last_study_date')) {
      context.handle(
        _lastStudyDateMeta,
        lastStudyDate.isAcceptableOrUnknown(
          data['last_study_date']!,
          _lastStudyDateMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      stream: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream'],
      )!,
      dailyGoalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal_minutes'],
      )!,
      streakCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_count'],
      )!,
      streakFreezes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_freezes'],
      )!,
      lastStudyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_study_date'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final String id;
  final String email;
  final String name;
  final int grade;
  final String gender;
  final String stream;
  final int dailyGoalMinutes;
  final int streakCount;
  final int streakFreezes;
  final DateTime? lastStudyDate;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  const Student({
    required this.id,
    required this.email,
    required this.name,
    required this.grade,
    required this.gender,
    required this.stream,
    required this.dailyGoalMinutes,
    required this.streakCount,
    required this.streakFreezes,
    this.lastStudyDate,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['name'] = Variable<String>(name);
    map['grade'] = Variable<int>(grade);
    map['gender'] = Variable<String>(gender);
    map['stream'] = Variable<String>(stream);
    map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes);
    map['streak_count'] = Variable<int>(streakCount);
    map['streak_freezes'] = Variable<int>(streakFreezes);
    if (!nullToAbsent || lastStudyDate != null) {
      map['last_study_date'] = Variable<DateTime>(lastStudyDate);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      email: Value(email),
      name: Value(name),
      grade: Value(grade),
      gender: Value(gender),
      stream: Value(stream),
      dailyGoalMinutes: Value(dailyGoalMinutes),
      streakCount: Value(streakCount),
      streakFreezes: Value(streakFreezes),
      lastStudyDate: lastStudyDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudyDate),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String>(json['name']),
      grade: serializer.fromJson<int>(json['grade']),
      gender: serializer.fromJson<String>(json['gender']),
      stream: serializer.fromJson<String>(json['stream']),
      dailyGoalMinutes: serializer.fromJson<int>(json['dailyGoalMinutes']),
      streakCount: serializer.fromJson<int>(json['streakCount']),
      streakFreezes: serializer.fromJson<int>(json['streakFreezes']),
      lastStudyDate: serializer.fromJson<DateTime?>(json['lastStudyDate']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String>(name),
      'grade': serializer.toJson<int>(grade),
      'gender': serializer.toJson<String>(gender),
      'stream': serializer.toJson<String>(stream),
      'dailyGoalMinutes': serializer.toJson<int>(dailyGoalMinutes),
      'streakCount': serializer.toJson<int>(streakCount),
      'streakFreezes': serializer.toJson<int>(streakFreezes),
      'lastStudyDate': serializer.toJson<DateTime?>(lastStudyDate),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Student copyWith({
    String? id,
    String? email,
    String? name,
    int? grade,
    String? gender,
    String? stream,
    int? dailyGoalMinutes,
    int? streakCount,
    int? streakFreezes,
    Value<DateTime?> lastStudyDate = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) => Student(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    grade: grade ?? this.grade,
    gender: gender ?? this.gender,
    stream: stream ?? this.stream,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    streakCount: streakCount ?? this.streakCount,
    streakFreezes: streakFreezes ?? this.streakFreezes,
    lastStudyDate: lastStudyDate.present
        ? lastStudyDate.value
        : this.lastStudyDate,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      grade: data.grade.present ? data.grade.value : this.grade,
      gender: data.gender.present ? data.gender.value : this.gender,
      stream: data.stream.present ? data.stream.value : this.stream,
      dailyGoalMinutes: data.dailyGoalMinutes.present
          ? data.dailyGoalMinutes.value
          : this.dailyGoalMinutes,
      streakCount: data.streakCount.present
          ? data.streakCount.value
          : this.streakCount,
      streakFreezes: data.streakFreezes.present
          ? data.streakFreezes.value
          : this.streakFreezes,
      lastStudyDate: data.lastStudyDate.present
          ? data.lastStudyDate.value
          : this.lastStudyDate,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('grade: $grade, ')
          ..write('gender: $gender, ')
          ..write('stream: $stream, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('streakCount: $streakCount, ')
          ..write('streakFreezes: $streakFreezes, ')
          ..write('lastStudyDate: $lastStudyDate, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    name,
    grade,
    gender,
    stream,
    dailyGoalMinutes,
    streakCount,
    streakFreezes,
    lastStudyDate,
    avatarUrl,
    createdAt,
    updatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.grade == this.grade &&
          other.gender == this.gender &&
          other.stream == this.stream &&
          other.dailyGoalMinutes == this.dailyGoalMinutes &&
          other.streakCount == this.streakCount &&
          other.streakFreezes == this.streakFreezes &&
          other.lastStudyDate == this.lastStudyDate &&
          other.avatarUrl == this.avatarUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> name;
  final Value<int> grade;
  final Value<String> gender;
  final Value<String> stream;
  final Value<int> dailyGoalMinutes;
  final Value<int> streakCount;
  final Value<int> streakFreezes;
  final Value<DateTime?> lastStudyDate;
  final Value<String?> avatarUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.grade = const Value.absent(),
    this.gender = const Value.absent(),
    this.stream = const Value.absent(),
    this.dailyGoalMinutes = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.streakFreezes = const Value.absent(),
    this.lastStudyDate = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required String email,
    required String name,
    required int grade,
    required String gender,
    required String stream,
    this.dailyGoalMinutes = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.streakFreezes = const Value.absent(),
    this.lastStudyDate = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       name = Value(name),
       grade = Value(grade),
       gender = Value(gender),
       stream = Value(stream);
  static Insertable<Student> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<int>? grade,
    Expression<String>? gender,
    Expression<String>? stream,
    Expression<int>? dailyGoalMinutes,
    Expression<int>? streakCount,
    Expression<int>? streakFreezes,
    Expression<DateTime>? lastStudyDate,
    Expression<String>? avatarUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (grade != null) 'grade': grade,
      if (gender != null) 'gender': gender,
      if (stream != null) 'stream': stream,
      if (dailyGoalMinutes != null) 'daily_goal_minutes': dailyGoalMinutes,
      if (streakCount != null) 'streak_count': streakCount,
      if (streakFreezes != null) 'streak_freezes': streakFreezes,
      if (lastStudyDate != null) 'last_study_date': lastStudyDate,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? name,
    Value<int>? grade,
    Value<String>? gender,
    Value<String>? stream,
    Value<int>? dailyGoalMinutes,
    Value<int>? streakCount,
    Value<int>? streakFreezes,
    Value<DateTime?>? lastStudyDate,
    Value<String?>? avatarUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      gender: gender ?? this.gender,
      stream: stream ?? this.stream,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      streakCount: streakCount ?? this.streakCount,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (stream.present) {
      map['stream'] = Variable<String>(stream.value);
    }
    if (dailyGoalMinutes.present) {
      map['daily_goal_minutes'] = Variable<int>(dailyGoalMinutes.value);
    }
    if (streakCount.present) {
      map['streak_count'] = Variable<int>(streakCount.value);
    }
    if (streakFreezes.present) {
      map['streak_freezes'] = Variable<int>(streakFreezes.value);
    }
    if (lastStudyDate.present) {
      map['last_study_date'] = Variable<DateTime>(lastStudyDate.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('grade: $grade, ')
          ..write('gender: $gender, ')
          ..write('stream: $stream, ')
          ..write('dailyGoalMinutes: $dailyGoalMinutes, ')
          ..write('streakCount: $streakCount, ')
          ..write('streakFreezes: $streakFreezes, ')
          ..write('lastStudyDate: $lastStudyDate, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streamMeta = const VerificationMeta('stream');
  @override
  late final GeneratedColumn<String> stream = GeneratedColumn<String>(
    'stream',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalUnitsMeta = const VerificationMeta(
    'totalUnits',
  );
  @override
  late final GeneratedColumn<int> totalUnits = GeneratedColumn<int>(
    'total_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    code,
    grade,
    stream,
    totalUnits,
    iconName,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('stream')) {
      context.handle(
        _streamMeta,
        stream.isAcceptableOrUnknown(data['stream']!, _streamMeta),
      );
    } else if (isInserting) {
      context.missing(_streamMeta);
    }
    if (data.containsKey('total_units')) {
      context.handle(
        _totalUnitsMeta,
        totalUnits.isAcceptableOrUnknown(data['total_units']!, _totalUnitsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalUnitsMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      )!,
      stream: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream'],
      )!,
      totalUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_units'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final String id;
  final String name;
  final String code;
  final int grade;
  final String stream;
  final int totalUnits;
  final String? iconName;
  final int sortOrder;
  const Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.grade,
    required this.stream,
    required this.totalUnits,
    this.iconName,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['grade'] = Variable<int>(grade);
    map['stream'] = Variable<String>(stream);
    map['total_units'] = Variable<int>(totalUnits);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      grade: Value(grade),
      stream: Value(stream),
      totalUnits: Value(totalUnits),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      sortOrder: Value(sortOrder),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      grade: serializer.fromJson<int>(json['grade']),
      stream: serializer.fromJson<String>(json['stream']),
      totalUnits: serializer.fromJson<int>(json['totalUnits']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'grade': serializer.toJson<int>(grade),
      'stream': serializer.toJson<String>(stream),
      'totalUnits': serializer.toJson<int>(totalUnits),
      'iconName': serializer.toJson<String?>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    int? grade,
    String? stream,
    int? totalUnits,
    Value<String?> iconName = const Value.absent(),
    int? sortOrder,
  }) => Subject(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    grade: grade ?? this.grade,
    stream: stream ?? this.stream,
    totalUnits: totalUnits ?? this.totalUnits,
    iconName: iconName.present ? iconName.value : this.iconName,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      grade: data.grade.present ? data.grade.value : this.grade,
      stream: data.stream.present ? data.stream.value : this.stream,
      totalUnits: data.totalUnits.present
          ? data.totalUnits.value
          : this.totalUnits,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('grade: $grade, ')
          ..write('stream: $stream, ')
          ..write('totalUnits: $totalUnits, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    code,
    grade,
    stream,
    totalUnits,
    iconName,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.grade == this.grade &&
          other.stream == this.stream &&
          other.totalUnits == this.totalUnits &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<int> grade;
  final Value<String> stream;
  final Value<int> totalUnits;
  final Value<String?> iconName;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.grade = const Value.absent(),
    this.stream = const Value.absent(),
    this.totalUnits = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String name,
    required String code,
    required int grade,
    required String stream,
    required int totalUnits,
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       code = Value(code),
       grade = Value(grade),
       stream = Value(stream),
       totalUnits = Value(totalUnits);
  static Insertable<Subject> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<int>? grade,
    Expression<String>? stream,
    Expression<int>? totalUnits,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (grade != null) 'grade': grade,
      if (stream != null) 'stream': stream,
      if (totalUnits != null) 'total_units': totalUnits,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? code,
    Value<int>? grade,
    Value<String>? stream,
    Value<int>? totalUnits,
    Value<String?>? iconName,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      grade: grade ?? this.grade,
      stream: stream ?? this.stream,
      totalUnits: totalUnits ?? this.totalUnits,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (stream.present) {
      map['stream'] = Variable<String>(stream.value);
    }
    if (totalUnits.present) {
      map['total_units'] = Variable<int>(totalUnits.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('grade: $grade, ')
          ..write('stream: $stream, ')
          ..write('totalUnits: $totalUnits, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
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
  static const VerificationMeta _subtopicsJsonMeta = const VerificationMeta(
    'subtopicsJson',
  );
  @override
  late final GeneratedColumn<String> subtopicsJson = GeneratedColumn<String>(
    'subtopics_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    chapterNumber,
    title,
    subtopicsJson,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtopics_json')) {
      context.handle(
        _subtopicsJsonMeta,
        subtopicsJson.isAcceptableOrUnknown(
          data['subtopics_json']!,
          _subtopicsJsonMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtopicsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtopics_json'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final String id;
  final String subjectId;
  final int chapterNumber;
  final String title;
  final String? subtopicsJson;
  final int sortOrder;
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.chapterNumber,
    required this.title,
    this.subtopicsJson,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtopicsJson != null) {
      map['subtopics_json'] = Variable<String>(subtopicsJson);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      chapterNumber: Value(chapterNumber),
      title: Value(title),
      subtopicsJson: subtopicsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(subtopicsJson),
      sortOrder: Value(sortOrder),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      title: serializer.fromJson<String>(json['title']),
      subtopicsJson: serializer.fromJson<String?>(json['subtopicsJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'title': serializer.toJson<String>(title),
      'subtopicsJson': serializer.toJson<String?>(subtopicsJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Chapter copyWith({
    String? id,
    String? subjectId,
    int? chapterNumber,
    String? title,
    Value<String?> subtopicsJson = const Value.absent(),
    int? sortOrder,
  }) => Chapter(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    title: title ?? this.title,
    subtopicsJson: subtopicsJson.present
        ? subtopicsJson.value
        : this.subtopicsJson,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      title: data.title.present ? data.title.value : this.title,
      subtopicsJson: data.subtopicsJson.present
          ? data.subtopicsJson.value
          : this.subtopicsJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('title: $title, ')
          ..write('subtopicsJson: $subtopicsJson, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    chapterNumber,
    title,
    subtopicsJson,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.chapterNumber == this.chapterNumber &&
          other.title == this.title &&
          other.subtopicsJson == this.subtopicsJson &&
          other.sortOrder == this.sortOrder);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<int> chapterNumber;
  final Value<String> title;
  final Value<String?> subtopicsJson;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.subtopicsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required String id,
    required String subjectId,
    required int chapterNumber,
    required String title,
    this.subtopicsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectId = Value(subjectId),
       chapterNumber = Value(chapterNumber),
       title = Value(title);
  static Insertable<Chapter> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<int>? chapterNumber,
    Expression<String>? title,
    Expression<String>? subtopicsJson,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (title != null) 'title': title,
      if (subtopicsJson != null) 'subtopics_json': subtopicsJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectId,
    Value<int>? chapterNumber,
    Value<String>? title,
    Value<String?>? subtopicsJson,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      subtopicsJson: subtopicsJson ?? this.subtopicsJson,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtopicsJson.present) {
      map['subtopics_json'] = Variable<String>(subtopicsJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('title: $title, ')
          ..write('subtopicsJson: $subtopicsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterProgressTable extends ChapterProgress
    with TableInfo<$ChapterProgressTable, ChapterProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chapters (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('not_started'),
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
  static const VerificationMeta _masteredAtMeta = const VerificationMeta(
    'masteredAt',
  );
  @override
  late final GeneratedColumn<DateTime> masteredAt = GeneratedColumn<DateTime>(
    'mastered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    chapterId,
    status,
    completedAt,
    masteredAt,
    notes,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('mastered_at')) {
      context.handle(
        _masteredAtMeta,
        masteredAt.isAcceptableOrUnknown(data['mastered_at']!, _masteredAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      masteredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}mastered_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ChapterProgressTable createAlias(String alias) {
    return $ChapterProgressTable(attachedDatabase, alias);
  }
}

class ChapterProgressData extends DataClass
    implements Insertable<ChapterProgressData> {
  final String id;
  final String studentId;
  final String chapterId;
  final String status;
  final DateTime? completedAt;
  final DateTime? masteredAt;
  final String? notes;
  final DateTime updatedAt;
  final bool isSynced;
  const ChapterProgressData({
    required this.id,
    required this.studentId,
    required this.chapterId,
    required this.status,
    this.completedAt,
    this.masteredAt,
    this.notes,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || masteredAt != null) {
      map['mastered_at'] = Variable<DateTime>(masteredAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ChapterProgressCompanion toCompanion(bool nullToAbsent) {
    return ChapterProgressCompanion(
      id: Value(id),
      studentId: Value(studentId),
      chapterId: Value(chapterId),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      masteredAt: masteredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(masteredAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory ChapterProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterProgressData(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      masteredAt: serializer.fromJson<DateTime?>(json['masteredAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'chapterId': serializer.toJson<String>(chapterId),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'masteredAt': serializer.toJson<DateTime?>(masteredAt),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  ChapterProgressData copyWith({
    String? id,
    String? studentId,
    String? chapterId,
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> masteredAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? updatedAt,
    bool? isSynced,
  }) => ChapterProgressData(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    chapterId: chapterId ?? this.chapterId,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    masteredAt: masteredAt.present ? masteredAt.value : this.masteredAt,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  ChapterProgressData copyWithCompanion(ChapterProgressCompanion data) {
    return ChapterProgressData(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      masteredAt: data.masteredAt.present
          ? data.masteredAt.value
          : this.masteredAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressData(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('chapterId: $chapterId, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('masteredAt: $masteredAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    chapterId,
    status,
    completedAt,
    masteredAt,
    notes,
    updatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterProgressData &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.chapterId == this.chapterId &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.masteredAt == this.masteredAt &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class ChapterProgressCompanion extends UpdateCompanion<ChapterProgressData> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> chapterId;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> masteredAt;
  final Value<String?> notes;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const ChapterProgressCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.masteredAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterProgressCompanion.insert({
    required String id,
    required String studentId,
    required String chapterId,
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.masteredAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       chapterId = Value(chapterId);
  static Insertable<ChapterProgressData> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? chapterId,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? masteredAt,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (masteredAt != null) 'mastered_at': masteredAt,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterProgressCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? chapterId,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? masteredAt,
    Value<String?>? notes,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return ChapterProgressCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      chapterId: chapterId ?? this.chapterId,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      masteredAt: masteredAt ?? this.masteredAt,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (masteredAt.present) {
      map['mastered_at'] = Variable<DateTime>(masteredAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('chapterId: $chapterId, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('masteredAt: $masteredAt, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    chapterId,
    durationSeconds,
    startedAt,
    endedAt,
    mode,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final String id;
  final String studentId;
  final String? chapterId;
  final int durationSeconds;
  final DateTime startedAt;
  final DateTime endedAt;
  final String mode;
  final bool isSynced;
  const StudySession({
    required this.id,
    required this.studentId,
    this.chapterId,
    required this.durationSeconds,
    required this.startedAt,
    required this.endedAt,
    required this.mode,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['mode'] = Variable<String>(mode);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      durationSeconds: Value(durationSeconds),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      mode: Value(mode),
      isSynced: Value(isSynced),
    );
  }

  factory StudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      mode: serializer.fromJson<String>(json['mode']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'chapterId': serializer.toJson<String?>(chapterId),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'mode': serializer.toJson<String>(mode),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  StudySession copyWith({
    String? id,
    String? studentId,
    Value<String?> chapterId = const Value.absent(),
    int? durationSeconds,
    DateTime? startedAt,
    DateTime? endedAt,
    String? mode,
    bool? isSynced,
  }) => StudySession(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    chapterId: chapterId.present ? chapterId.value : this.chapterId,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    mode: mode ?? this.mode,
    isSynced: isSynced ?? this.isSynced,
  );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      mode: data.mode.present ? data.mode.value : this.mode,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('chapterId: $chapterId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('mode: $mode, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    chapterId,
    durationSeconds,
    startedAt,
    endedAt,
    mode,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.chapterId == this.chapterId &&
          other.durationSeconds == this.durationSeconds &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.mode == this.mode &&
          other.isSynced == this.isSynced);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String?> chapterId;
  final Value<int> durationSeconds;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<String> mode;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.mode = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required String id,
    required String studentId,
    this.chapterId = const Value.absent(),
    required int durationSeconds,
    required DateTime startedAt,
    required DateTime endedAt,
    required String mode,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       durationSeconds = Value(durationSeconds),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       mode = Value(mode);
  static Insertable<StudySession> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? chapterId,
    Expression<int>? durationSeconds,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? mode,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (mode != null) 'mode': mode,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String?>? chapterId,
    Value<int>? durationSeconds,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<String>? mode,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      chapterId: chapterId ?? this.chapterId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      mode: mode ?? this.mode,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('chapterId: $chapterId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('mode: $mode, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    action,
    targetTable,
    recordId,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String action;
  final String targetTable;
  final String recordId;
  final String payload;
  final DateTime createdAt;
  const SyncQueueData({
    required this.id,
    required this.action,
    required this.targetTable,
    required this.recordId,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action'] = Variable<String>(action);
    map['target_table'] = Variable<String>(targetTable);
    map['record_id'] = Variable<String>(recordId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      action: Value(action),
      targetTable: Value(targetTable),
      recordId: Value(recordId),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'action': serializer.toJson<String>(action),
      'targetTable': serializer.toJson<String>(targetTable),
      'recordId': serializer.toJson<String>(recordId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? action,
    String? targetTable,
    String? recordId,
    String? payload,
    DateTime? createdAt,
  }) => SyncQueueData(
    id: id ?? this.id,
    action: action ?? this.action,
    targetTable: targetTable ?? this.targetTable,
    recordId: recordId ?? this.recordId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, action, targetTable, recordId, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.action == this.action &&
          other.targetTable == this.targetTable &&
          other.recordId == this.recordId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> action;
  final Value<String> targetTable;
  final Value<String> recordId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String action,
    required String targetTable,
    required String recordId,
    required String payload,
    this.createdAt = const Value.absent(),
  }) : action = Value(action),
       targetTable = Value(targetTable),
       recordId = Value(recordId),
       payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? action,
    Expression<String>? targetTable,
    Expression<String>? recordId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (targetTable != null) 'target_table': targetTable,
      if (recordId != null) 'record_id': recordId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? action,
    Value<String>? targetTable,
    Value<String>? recordId,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      targetTable: targetTable ?? this.targetTable,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LocalAssessmentsTable extends LocalAssessments
    with TableInfo<$LocalAssessmentsTable, LocalAssessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assessmentTypeMeta = const VerificationMeta(
    'assessmentType',
  );
  @override
  late final GeneratedColumn<String> assessmentType = GeneratedColumn<String>(
    'assessment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unit'),
  );
  static const VerificationMeta _currentVersionIdMeta = const VerificationMeta(
    'currentVersionId',
  );
  @override
  late final GeneratedColumn<String> currentVersionId = GeneratedColumn<String>(
    'current_version_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamMeta = const VerificationMeta('stream');
  @override
  late final GeneratedColumn<String> stream = GeneratedColumn<String>(
    'stream',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    title,
    description,
    assessmentType,
    currentVersionId,
    subjectId,
    grade,
    stream,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('assessment_type')) {
      context.handle(
        _assessmentTypeMeta,
        assessmentType.isAcceptableOrUnknown(
          data['assessment_type']!,
          _assessmentTypeMeta,
        ),
      );
    }
    if (data.containsKey('current_version_id')) {
      context.handle(
        _currentVersionIdMeta,
        currentVersionId.isAcceptableOrUnknown(
          data['current_version_id']!,
          _currentVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('stream')) {
      context.handle(
        _streamMeta,
        stream.isAcceptableOrUnknown(data['stream']!, _streamMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAssessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssessment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      assessmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_type'],
      )!,
      currentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_version_id'],
      ),
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      ),
      stream: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAssessmentsTable createAlias(String alias) {
    return $LocalAssessmentsTable(attachedDatabase, alias);
  }
}

class LocalAssessment extends DataClass implements Insertable<LocalAssessment> {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String assessmentType;
  final String? currentVersionId;
  final String? subjectId;
  final int? grade;
  final String? stream;
  final DateTime updatedAt;
  const LocalAssessment({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.assessmentType,
    this.currentVersionId,
    this.subjectId,
    this.grade,
    this.stream,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['assessment_type'] = Variable<String>(assessmentType);
    if (!nullToAbsent || currentVersionId != null) {
      map['current_version_id'] = Variable<String>(currentVersionId);
    }
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<int>(grade);
    }
    if (!nullToAbsent || stream != null) {
      map['stream'] = Variable<String>(stream);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAssessmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssessmentsCompanion(
      id: Value(id),
      code: Value(code),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      assessmentType: Value(assessmentType),
      currentVersionId: currentVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentVersionId),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      stream: stream == null && nullToAbsent
          ? const Value.absent()
          : Value(stream),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAssessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssessment(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      assessmentType: serializer.fromJson<String>(json['assessmentType']),
      currentVersionId: serializer.fromJson<String?>(json['currentVersionId']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      grade: serializer.fromJson<int?>(json['grade']),
      stream: serializer.fromJson<String?>(json['stream']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'assessmentType': serializer.toJson<String>(assessmentType),
      'currentVersionId': serializer.toJson<String?>(currentVersionId),
      'subjectId': serializer.toJson<String?>(subjectId),
      'grade': serializer.toJson<int?>(grade),
      'stream': serializer.toJson<String?>(stream),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAssessment copyWith({
    String? id,
    String? code,
    String? title,
    Value<String?> description = const Value.absent(),
    String? assessmentType,
    Value<String?> currentVersionId = const Value.absent(),
    Value<String?> subjectId = const Value.absent(),
    Value<int?> grade = const Value.absent(),
    Value<String?> stream = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalAssessment(
    id: id ?? this.id,
    code: code ?? this.code,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    assessmentType: assessmentType ?? this.assessmentType,
    currentVersionId: currentVersionId.present
        ? currentVersionId.value
        : this.currentVersionId,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    grade: grade.present ? grade.value : this.grade,
    stream: stream.present ? stream.value : this.stream,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAssessment copyWithCompanion(LocalAssessmentsCompanion data) {
    return LocalAssessment(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      assessmentType: data.assessmentType.present
          ? data.assessmentType.value
          : this.assessmentType,
      currentVersionId: data.currentVersionId.present
          ? data.currentVersionId.value
          : this.currentVersionId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      grade: data.grade.present ? data.grade.value : this.grade,
      stream: data.stream.present ? data.stream.value : this.stream,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessment(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('assessmentType: $assessmentType, ')
          ..write('currentVersionId: $currentVersionId, ')
          ..write('subjectId: $subjectId, ')
          ..write('grade: $grade, ')
          ..write('stream: $stream, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    title,
    description,
    assessmentType,
    currentVersionId,
    subjectId,
    grade,
    stream,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssessment &&
          other.id == this.id &&
          other.code == this.code &&
          other.title == this.title &&
          other.description == this.description &&
          other.assessmentType == this.assessmentType &&
          other.currentVersionId == this.currentVersionId &&
          other.subjectId == this.subjectId &&
          other.grade == this.grade &&
          other.stream == this.stream &&
          other.updatedAt == this.updatedAt);
}

class LocalAssessmentsCompanion extends UpdateCompanion<LocalAssessment> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> assessmentType;
  final Value<String?> currentVersionId;
  final Value<String?> subjectId;
  final Value<int?> grade;
  final Value<String?> stream;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalAssessmentsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.assessmentType = const Value.absent(),
    this.currentVersionId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.grade = const Value.absent(),
    this.stream = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssessmentsCompanion.insert({
    required String id,
    required String code,
    required String title,
    this.description = const Value.absent(),
    this.assessmentType = const Value.absent(),
    this.currentVersionId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.grade = const Value.absent(),
    this.stream = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       title = Value(title);
  static Insertable<LocalAssessment> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? assessmentType,
    Expression<String>? currentVersionId,
    Expression<String>? subjectId,
    Expression<int>? grade,
    Expression<String>? stream,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (assessmentType != null) 'assessment_type': assessmentType,
      if (currentVersionId != null) 'current_version_id': currentVersionId,
      if (subjectId != null) 'subject_id': subjectId,
      if (grade != null) 'grade': grade,
      if (stream != null) 'stream': stream,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssessmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? assessmentType,
    Value<String?>? currentVersionId,
    Value<String?>? subjectId,
    Value<int?>? grade,
    Value<String?>? stream,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAssessmentsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      assessmentType: assessmentType ?? this.assessmentType,
      currentVersionId: currentVersionId ?? this.currentVersionId,
      subjectId: subjectId ?? this.subjectId,
      grade: grade ?? this.grade,
      stream: stream ?? this.stream,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (assessmentType.present) {
      map['assessment_type'] = Variable<String>(assessmentType.value);
    }
    if (currentVersionId.present) {
      map['current_version_id'] = Variable<String>(currentVersionId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (stream.present) {
      map['stream'] = Variable<String>(stream.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('assessmentType: $assessmentType, ')
          ..write('currentVersionId: $currentVersionId, ')
          ..write('subjectId: $subjectId, ')
          ..write('grade: $grade, ')
          ..write('stream: $stream, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssessmentVersionsTable extends LocalAssessmentVersions
    with TableInfo<$LocalAssessmentVersionsTable, LocalAssessmentVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssessmentVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  @override
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionNumberMeta = const VerificationMeta(
    'versionNumber',
  );
  @override
  late final GeneratedColumn<int> versionNumber = GeneratedColumn<int>(
    'version_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('published'),
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPointsMeta = const VerificationMeta(
    'totalPoints',
  );
  @override
  late final GeneratedColumn<double> totalPoints = GeneratedColumn<double>(
    'total_points',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _timeLimitMinutesMeta = const VerificationMeta(
    'timeLimitMinutes',
  );
  @override
  late final GeneratedColumn<int> timeLimitMinutes = GeneratedColumn<int>(
    'time_limit_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passingPercentageMeta = const VerificationMeta(
    'passingPercentage',
  );
  @override
  late final GeneratedColumn<double> passingPercentage =
      GeneratedColumn<double>(
        'passing_percentage',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assessmentId,
    versionNumber,
    status,
    totalQuestions,
    totalPoints,
    timeLimitMinutes,
    passingPercentage,
    publishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assessment_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssessmentVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('version_number')) {
      context.handle(
        _versionNumberMeta,
        versionNumber.isAcceptableOrUnknown(
          data['version_number']!,
          _versionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    }
    if (data.containsKey('total_points')) {
      context.handle(
        _totalPointsMeta,
        totalPoints.isAcceptableOrUnknown(
          data['total_points']!,
          _totalPointsMeta,
        ),
      );
    }
    if (data.containsKey('time_limit_minutes')) {
      context.handle(
        _timeLimitMinutesMeta,
        timeLimitMinutes.isAcceptableOrUnknown(
          data['time_limit_minutes']!,
          _timeLimitMinutesMeta,
        ),
      );
    }
    if (data.containsKey('passing_percentage')) {
      context.handle(
        _passingPercentageMeta,
        passingPercentage.isAcceptableOrUnknown(
          data['passing_percentage']!,
          _passingPercentageMeta,
        ),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAssessmentVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssessmentVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      versionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      totalPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_points'],
      )!,
      timeLimitMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_limit_minutes'],
      ),
      passingPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}passing_percentage'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
    );
  }

  @override
  $LocalAssessmentVersionsTable createAlias(String alias) {
    return $LocalAssessmentVersionsTable(attachedDatabase, alias);
  }
}

class LocalAssessmentVersion extends DataClass
    implements Insertable<LocalAssessmentVersion> {
  final String id;
  final String assessmentId;
  final int versionNumber;
  final String status;
  final int totalQuestions;
  final double totalPoints;
  final int? timeLimitMinutes;
  final double? passingPercentage;
  final DateTime? publishedAt;
  const LocalAssessmentVersion({
    required this.id,
    required this.assessmentId,
    required this.versionNumber,
    required this.status,
    required this.totalQuestions,
    required this.totalPoints,
    this.timeLimitMinutes,
    this.passingPercentage,
    this.publishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessment_id'] = Variable<String>(assessmentId);
    map['version_number'] = Variable<int>(versionNumber);
    map['status'] = Variable<String>(status);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['total_points'] = Variable<double>(totalPoints);
    if (!nullToAbsent || timeLimitMinutes != null) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes);
    }
    if (!nullToAbsent || passingPercentage != null) {
      map['passing_percentage'] = Variable<double>(passingPercentage);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    return map;
  }

  LocalAssessmentVersionsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssessmentVersionsCompanion(
      id: Value(id),
      assessmentId: Value(assessmentId),
      versionNumber: Value(versionNumber),
      status: Value(status),
      totalQuestions: Value(totalQuestions),
      totalPoints: Value(totalPoints),
      timeLimitMinutes: timeLimitMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeLimitMinutes),
      passingPercentage: passingPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(passingPercentage),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
    );
  }

  factory LocalAssessmentVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssessmentVersion(
      id: serializer.fromJson<String>(json['id']),
      assessmentId: serializer.fromJson<String>(json['assessmentId']),
      versionNumber: serializer.fromJson<int>(json['versionNumber']),
      status: serializer.fromJson<String>(json['status']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      totalPoints: serializer.fromJson<double>(json['totalPoints']),
      timeLimitMinutes: serializer.fromJson<int?>(json['timeLimitMinutes']),
      passingPercentage: serializer.fromJson<double?>(
        json['passingPercentage'],
      ),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessmentId': serializer.toJson<String>(assessmentId),
      'versionNumber': serializer.toJson<int>(versionNumber),
      'status': serializer.toJson<String>(status),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'totalPoints': serializer.toJson<double>(totalPoints),
      'timeLimitMinutes': serializer.toJson<int?>(timeLimitMinutes),
      'passingPercentage': serializer.toJson<double?>(passingPercentage),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
    };
  }

  LocalAssessmentVersion copyWith({
    String? id,
    String? assessmentId,
    int? versionNumber,
    String? status,
    int? totalQuestions,
    double? totalPoints,
    Value<int?> timeLimitMinutes = const Value.absent(),
    Value<double?> passingPercentage = const Value.absent(),
    Value<DateTime?> publishedAt = const Value.absent(),
  }) => LocalAssessmentVersion(
    id: id ?? this.id,
    assessmentId: assessmentId ?? this.assessmentId,
    versionNumber: versionNumber ?? this.versionNumber,
    status: status ?? this.status,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    totalPoints: totalPoints ?? this.totalPoints,
    timeLimitMinutes: timeLimitMinutes.present
        ? timeLimitMinutes.value
        : this.timeLimitMinutes,
    passingPercentage: passingPercentage.present
        ? passingPercentage.value
        : this.passingPercentage,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
  );
  LocalAssessmentVersion copyWithCompanion(
    LocalAssessmentVersionsCompanion data,
  ) {
    return LocalAssessmentVersion(
      id: data.id.present ? data.id.value : this.id,
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      versionNumber: data.versionNumber.present
          ? data.versionNumber.value
          : this.versionNumber,
      status: data.status.present ? data.status.value : this.status,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      totalPoints: data.totalPoints.present
          ? data.totalPoints.value
          : this.totalPoints,
      timeLimitMinutes: data.timeLimitMinutes.present
          ? data.timeLimitMinutes.value
          : this.timeLimitMinutes,
      passingPercentage: data.passingPercentage.present
          ? data.passingPercentage.value
          : this.passingPercentage,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentVersion(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('status: $status, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('timeLimitMinutes: $timeLimitMinutes, ')
          ..write('passingPercentage: $passingPercentage, ')
          ..write('publishedAt: $publishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assessmentId,
    versionNumber,
    status,
    totalQuestions,
    totalPoints,
    timeLimitMinutes,
    passingPercentage,
    publishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssessmentVersion &&
          other.id == this.id &&
          other.assessmentId == this.assessmentId &&
          other.versionNumber == this.versionNumber &&
          other.status == this.status &&
          other.totalQuestions == this.totalQuestions &&
          other.totalPoints == this.totalPoints &&
          other.timeLimitMinutes == this.timeLimitMinutes &&
          other.passingPercentage == this.passingPercentage &&
          other.publishedAt == this.publishedAt);
}

class LocalAssessmentVersionsCompanion
    extends UpdateCompanion<LocalAssessmentVersion> {
  final Value<String> id;
  final Value<String> assessmentId;
  final Value<int> versionNumber;
  final Value<String> status;
  final Value<int> totalQuestions;
  final Value<double> totalPoints;
  final Value<int?> timeLimitMinutes;
  final Value<double?> passingPercentage;
  final Value<DateTime?> publishedAt;
  final Value<int> rowid;
  const LocalAssessmentVersionsCompanion({
    this.id = const Value.absent(),
    this.assessmentId = const Value.absent(),
    this.versionNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.totalPoints = const Value.absent(),
    this.timeLimitMinutes = const Value.absent(),
    this.passingPercentage = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssessmentVersionsCompanion.insert({
    required String id,
    required String assessmentId,
    required int versionNumber,
    this.status = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.totalPoints = const Value.absent(),
    this.timeLimitMinutes = const Value.absent(),
    this.passingPercentage = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessmentId = Value(assessmentId),
       versionNumber = Value(versionNumber);
  static Insertable<LocalAssessmentVersion> custom({
    Expression<String>? id,
    Expression<String>? assessmentId,
    Expression<int>? versionNumber,
    Expression<String>? status,
    Expression<int>? totalQuestions,
    Expression<double>? totalPoints,
    Expression<int>? timeLimitMinutes,
    Expression<double>? passingPercentage,
    Expression<DateTime>? publishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (versionNumber != null) 'version_number': versionNumber,
      if (status != null) 'status': status,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (totalPoints != null) 'total_points': totalPoints,
      if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
      if (passingPercentage != null) 'passing_percentage': passingPercentage,
      if (publishedAt != null) 'published_at': publishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssessmentVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? assessmentId,
    Value<int>? versionNumber,
    Value<String>? status,
    Value<int>? totalQuestions,
    Value<double>? totalPoints,
    Value<int?>? timeLimitMinutes,
    Value<double?>? passingPercentage,
    Value<DateTime?>? publishedAt,
    Value<int>? rowid,
  }) {
    return LocalAssessmentVersionsCompanion(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      versionNumber: versionNumber ?? this.versionNumber,
      status: status ?? this.status,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      publishedAt: publishedAt ?? this.publishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (versionNumber.present) {
      map['version_number'] = Variable<int>(versionNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (totalPoints.present) {
      map['total_points'] = Variable<double>(totalPoints.value);
    }
    if (timeLimitMinutes.present) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes.value);
    }
    if (passingPercentage.present) {
      map['passing_percentage'] = Variable<double>(passingPercentage.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentVersionsCompanion(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('status: $status, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('totalPoints: $totalPoints, ')
          ..write('timeLimitMinutes: $timeLimitMinutes, ')
          ..write('passingPercentage: $passingPercentage, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssessmentVersionChaptersTable
    extends LocalAssessmentVersionChapters
    with
        TableInfo<
          $LocalAssessmentVersionChaptersTable,
          LocalAssessmentVersionChapter
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssessmentVersionChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assessmentVersionIdMeta =
      const VerificationMeta('assessmentVersionId');
  @override
  late final GeneratedColumn<String> assessmentVersionId =
      GeneratedColumn<String>(
        'assessment_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    assessmentVersionId,
    chapterId,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assessment_version_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssessmentVersionChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assessment_version_id')) {
      context.handle(
        _assessmentVersionIdMeta,
        assessmentVersionId.isAcceptableOrUnknown(
          data['assessment_version_id']!,
          _assessmentVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentVersionIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assessmentVersionId, chapterId};
  @override
  LocalAssessmentVersionChapter map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssessmentVersionChapter(
      assessmentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_version_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LocalAssessmentVersionChaptersTable createAlias(String alias) {
    return $LocalAssessmentVersionChaptersTable(attachedDatabase, alias);
  }
}

class LocalAssessmentVersionChapter extends DataClass
    implements Insertable<LocalAssessmentVersionChapter> {
  final String assessmentVersionId;
  final String chapterId;
  final int sortOrder;
  const LocalAssessmentVersionChapter({
    required this.assessmentVersionId,
    required this.chapterId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assessment_version_id'] = Variable<String>(assessmentVersionId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalAssessmentVersionChaptersCompanion toCompanion(bool nullToAbsent) {
    return LocalAssessmentVersionChaptersCompanion(
      assessmentVersionId: Value(assessmentVersionId),
      chapterId: Value(chapterId),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalAssessmentVersionChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssessmentVersionChapter(
      assessmentVersionId: serializer.fromJson<String>(
        json['assessmentVersionId'],
      ),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assessmentVersionId': serializer.toJson<String>(assessmentVersionId),
      'chapterId': serializer.toJson<String>(chapterId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalAssessmentVersionChapter copyWith({
    String? assessmentVersionId,
    String? chapterId,
    int? sortOrder,
  }) => LocalAssessmentVersionChapter(
    assessmentVersionId: assessmentVersionId ?? this.assessmentVersionId,
    chapterId: chapterId ?? this.chapterId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalAssessmentVersionChapter copyWithCompanion(
    LocalAssessmentVersionChaptersCompanion data,
  ) {
    return LocalAssessmentVersionChapter(
      assessmentVersionId: data.assessmentVersionId.present
          ? data.assessmentVersionId.value
          : this.assessmentVersionId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentVersionChapter(')
          ..write('assessmentVersionId: $assessmentVersionId, ')
          ..write('chapterId: $chapterId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assessmentVersionId, chapterId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssessmentVersionChapter &&
          other.assessmentVersionId == this.assessmentVersionId &&
          other.chapterId == this.chapterId &&
          other.sortOrder == this.sortOrder);
}

class LocalAssessmentVersionChaptersCompanion
    extends UpdateCompanion<LocalAssessmentVersionChapter> {
  final Value<String> assessmentVersionId;
  final Value<String> chapterId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalAssessmentVersionChaptersCompanion({
    this.assessmentVersionId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssessmentVersionChaptersCompanion.insert({
    required String assessmentVersionId,
    required String chapterId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : assessmentVersionId = Value(assessmentVersionId),
       chapterId = Value(chapterId);
  static Insertable<LocalAssessmentVersionChapter> custom({
    Expression<String>? assessmentVersionId,
    Expression<String>? chapterId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assessmentVersionId != null)
        'assessment_version_id': assessmentVersionId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssessmentVersionChaptersCompanion copyWith({
    Value<String>? assessmentVersionId,
    Value<String>? chapterId,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalAssessmentVersionChaptersCompanion(
      assessmentVersionId: assessmentVersionId ?? this.assessmentVersionId,
      chapterId: chapterId ?? this.chapterId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assessmentVersionId.present) {
      map['assessment_version_id'] = Variable<String>(
        assessmentVersionId.value,
      );
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentVersionChaptersCompanion(')
          ..write('assessmentVersionId: $assessmentVersionId, ')
          ..write('chapterId: $chapterId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQuestionsTable extends LocalQuestions
    with TableInfo<$LocalQuestionsTable, LocalQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentVersionIdMeta =
      const VerificationMeta('assessmentVersionId');
  @override
  late final GeneratedColumn<String> assessmentVersionId =
      GeneratedColumn<String>(
        'assessment_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTypeMeta = const VerificationMeta(
    'questionType',
  );
  @override
  late final GeneratedColumn<String> questionType = GeneratedColumn<String>(
    'question_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('single_choice'),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<double> points = GeneratedColumn<double>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assessmentVersionId,
    chapterId,
    questionText,
    questionType,
    imageUrl,
    points,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessment_version_id')) {
      context.handle(
        _assessmentVersionIdMeta,
        assessmentVersionId.isAcceptableOrUnknown(
          data['assessment_version_id']!,
          _assessmentVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentVersionIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('question_type')) {
      context.handle(
        _questionTypeMeta,
        questionType.isAcceptableOrUnknown(
          data['question_type']!,
          _questionTypeMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assessmentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_version_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      questionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_type'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}points'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LocalQuestionsTable createAlias(String alias) {
    return $LocalQuestionsTable(attachedDatabase, alias);
  }
}

class LocalQuestion extends DataClass implements Insertable<LocalQuestion> {
  final String id;
  final String assessmentVersionId;
  final String chapterId;
  final String questionText;
  final String questionType;
  final String? imageUrl;
  final double points;
  final int sortOrder;
  const LocalQuestion({
    required this.id,
    required this.assessmentVersionId,
    required this.chapterId,
    required this.questionText,
    required this.questionType,
    this.imageUrl,
    required this.points,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessment_version_id'] = Variable<String>(assessmentVersionId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['question_text'] = Variable<String>(questionText);
    map['question_type'] = Variable<String>(questionType);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['points'] = Variable<double>(points);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalQuestionsCompanion toCompanion(bool nullToAbsent) {
    return LocalQuestionsCompanion(
      id: Value(id),
      assessmentVersionId: Value(assessmentVersionId),
      chapterId: Value(chapterId),
      questionText: Value(questionText),
      questionType: Value(questionType),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      points: Value(points),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuestion(
      id: serializer.fromJson<String>(json['id']),
      assessmentVersionId: serializer.fromJson<String>(
        json['assessmentVersionId'],
      ),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      questionText: serializer.fromJson<String>(json['questionText']),
      questionType: serializer.fromJson<String>(json['questionType']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      points: serializer.fromJson<double>(json['points']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessmentVersionId': serializer.toJson<String>(assessmentVersionId),
      'chapterId': serializer.toJson<String>(chapterId),
      'questionText': serializer.toJson<String>(questionText),
      'questionType': serializer.toJson<String>(questionType),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'points': serializer.toJson<double>(points),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalQuestion copyWith({
    String? id,
    String? assessmentVersionId,
    String? chapterId,
    String? questionText,
    String? questionType,
    Value<String?> imageUrl = const Value.absent(),
    double? points,
    int? sortOrder,
  }) => LocalQuestion(
    id: id ?? this.id,
    assessmentVersionId: assessmentVersionId ?? this.assessmentVersionId,
    chapterId: chapterId ?? this.chapterId,
    questionText: questionText ?? this.questionText,
    questionType: questionType ?? this.questionType,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    points: points ?? this.points,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalQuestion copyWithCompanion(LocalQuestionsCompanion data) {
    return LocalQuestion(
      id: data.id.present ? data.id.value : this.id,
      assessmentVersionId: data.assessmentVersionId.present
          ? data.assessmentVersionId.value
          : this.assessmentVersionId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      questionType: data.questionType.present
          ? data.questionType.value
          : this.questionType,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      points: data.points.present ? data.points.value : this.points,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestion(')
          ..write('id: $id, ')
          ..write('assessmentVersionId: $assessmentVersionId, ')
          ..write('chapterId: $chapterId, ')
          ..write('questionText: $questionText, ')
          ..write('questionType: $questionType, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('points: $points, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assessmentVersionId,
    chapterId,
    questionText,
    questionType,
    imageUrl,
    points,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuestion &&
          other.id == this.id &&
          other.assessmentVersionId == this.assessmentVersionId &&
          other.chapterId == this.chapterId &&
          other.questionText == this.questionText &&
          other.questionType == this.questionType &&
          other.imageUrl == this.imageUrl &&
          other.points == this.points &&
          other.sortOrder == this.sortOrder);
}

class LocalQuestionsCompanion extends UpdateCompanion<LocalQuestion> {
  final Value<String> id;
  final Value<String> assessmentVersionId;
  final Value<String> chapterId;
  final Value<String> questionText;
  final Value<String> questionType;
  final Value<String?> imageUrl;
  final Value<double> points;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalQuestionsCompanion({
    this.id = const Value.absent(),
    this.assessmentVersionId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.questionText = const Value.absent(),
    this.questionType = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.points = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuestionsCompanion.insert({
    required String id,
    required String assessmentVersionId,
    required String chapterId,
    required String questionText,
    this.questionType = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.points = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessmentVersionId = Value(assessmentVersionId),
       chapterId = Value(chapterId),
       questionText = Value(questionText);
  static Insertable<LocalQuestion> custom({
    Expression<String>? id,
    Expression<String>? assessmentVersionId,
    Expression<String>? chapterId,
    Expression<String>? questionText,
    Expression<String>? questionType,
    Expression<String>? imageUrl,
    Expression<double>? points,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentVersionId != null)
        'assessment_version_id': assessmentVersionId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (questionText != null) 'question_text': questionText,
      if (questionType != null) 'question_type': questionType,
      if (imageUrl != null) 'image_url': imageUrl,
      if (points != null) 'points': points,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? assessmentVersionId,
    Value<String>? chapterId,
    Value<String>? questionText,
    Value<String>? questionType,
    Value<String?>? imageUrl,
    Value<double>? points,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalQuestionsCompanion(
      id: id ?? this.id,
      assessmentVersionId: assessmentVersionId ?? this.assessmentVersionId,
      chapterId: chapterId ?? this.chapterId,
      questionText: questionText ?? this.questionText,
      questionType: questionType ?? this.questionType,
      imageUrl: imageUrl ?? this.imageUrl,
      points: points ?? this.points,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assessmentVersionId.present) {
      map['assessment_version_id'] = Variable<String>(
        assessmentVersionId.value,
      );
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (questionType.present) {
      map['question_type'] = Variable<String>(questionType.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (points.present) {
      map['points'] = Variable<double>(points.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('assessmentVersionId: $assessmentVersionId, ')
          ..write('chapterId: $chapterId, ')
          ..write('questionText: $questionText, ')
          ..write('questionType: $questionType, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('points: $points, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQuestionOptionsTable extends LocalQuestionOptions
    with TableInfo<$LocalQuestionOptionsTable, LocalQuestionOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuestionOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionLetterMeta = const VerificationMeta(
    'optionLetter',
  );
  @override
  late final GeneratedColumn<String> optionLetter = GeneratedColumn<String>(
    'option_letter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionTextMeta = const VerificationMeta(
    'optionText',
  );
  @override
  late final GeneratedColumn<String> optionText = GeneratedColumn<String>(
    'option_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questionId,
    optionLetter,
    optionText,
    imageUrl,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_question_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQuestionOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('option_letter')) {
      context.handle(
        _optionLetterMeta,
        optionLetter.isAcceptableOrUnknown(
          data['option_letter']!,
          _optionLetterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_optionLetterMeta);
    }
    if (data.containsKey('option_text')) {
      context.handle(
        _optionTextMeta,
        optionText.isAcceptableOrUnknown(data['option_text']!, _optionTextMeta),
      );
    } else if (isInserting) {
      context.missing(_optionTextMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuestionOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuestionOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      optionLetter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_letter'],
      )!,
      optionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_text'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LocalQuestionOptionsTable createAlias(String alias) {
    return $LocalQuestionOptionsTable(attachedDatabase, alias);
  }
}

class LocalQuestionOption extends DataClass
    implements Insertable<LocalQuestionOption> {
  final String id;
  final String questionId;
  final String optionLetter;
  final String optionText;
  final String? imageUrl;
  final int sortOrder;
  const LocalQuestionOption({
    required this.id,
    required this.questionId,
    required this.optionLetter,
    required this.optionText,
    this.imageUrl,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question_id'] = Variable<String>(questionId);
    map['option_letter'] = Variable<String>(optionLetter);
    map['option_text'] = Variable<String>(optionText);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalQuestionOptionsCompanion toCompanion(bool nullToAbsent) {
    return LocalQuestionOptionsCompanion(
      id: Value(id),
      questionId: Value(questionId),
      optionLetter: Value(optionLetter),
      optionText: Value(optionText),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalQuestionOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuestionOption(
      id: serializer.fromJson<String>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      optionLetter: serializer.fromJson<String>(json['optionLetter']),
      optionText: serializer.fromJson<String>(json['optionText']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionId': serializer.toJson<String>(questionId),
      'optionLetter': serializer.toJson<String>(optionLetter),
      'optionText': serializer.toJson<String>(optionText),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalQuestionOption copyWith({
    String? id,
    String? questionId,
    String? optionLetter,
    String? optionText,
    Value<String?> imageUrl = const Value.absent(),
    int? sortOrder,
  }) => LocalQuestionOption(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    optionLetter: optionLetter ?? this.optionLetter,
    optionText: optionText ?? this.optionText,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalQuestionOption copyWithCompanion(LocalQuestionOptionsCompanion data) {
    return LocalQuestionOption(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      optionLetter: data.optionLetter.present
          ? data.optionLetter.value
          : this.optionLetter,
      optionText: data.optionText.present
          ? data.optionText.value
          : this.optionText,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestionOption(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('optionLetter: $optionLetter, ')
          ..write('optionText: $optionText, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    questionId,
    optionLetter,
    optionText,
    imageUrl,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuestionOption &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.optionLetter == this.optionLetter &&
          other.optionText == this.optionText &&
          other.imageUrl == this.imageUrl &&
          other.sortOrder == this.sortOrder);
}

class LocalQuestionOptionsCompanion
    extends UpdateCompanion<LocalQuestionOption> {
  final Value<String> id;
  final Value<String> questionId;
  final Value<String> optionLetter;
  final Value<String> optionText;
  final Value<String?> imageUrl;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalQuestionOptionsCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.optionLetter = const Value.absent(),
    this.optionText = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuestionOptionsCompanion.insert({
    required String id,
    required String questionId,
    required String optionLetter,
    required String optionText,
    this.imageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       questionId = Value(questionId),
       optionLetter = Value(optionLetter),
       optionText = Value(optionText);
  static Insertable<LocalQuestionOption> custom({
    Expression<String>? id,
    Expression<String>? questionId,
    Expression<String>? optionLetter,
    Expression<String>? optionText,
    Expression<String>? imageUrl,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (optionLetter != null) 'option_letter': optionLetter,
      if (optionText != null) 'option_text': optionText,
      if (imageUrl != null) 'image_url': imageUrl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuestionOptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? questionId,
    Value<String>? optionLetter,
    Value<String>? optionText,
    Value<String?>? imageUrl,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalQuestionOptionsCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      optionLetter: optionLetter ?? this.optionLetter,
      optionText: optionText ?? this.optionText,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (optionLetter.present) {
      map['option_letter'] = Variable<String>(optionLetter.value);
    }
    if (optionText.present) {
      map['option_text'] = Variable<String>(optionText.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestionOptionsCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('optionLetter: $optionLetter, ')
          ..write('optionText: $optionText, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssessmentAttemptsTable extends LocalAssessmentAttempts
    with TableInfo<$LocalAssessmentAttemptsTable, LocalAssessmentAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssessmentAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentVersionIdMeta =
      const VerificationMeta('assessmentVersionId');
  @override
  late final GeneratedColumn<String> assessmentVersionId =
      GeneratedColumn<String>(
        'assessment_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('in_progress'),
  );
  static const VerificationMeta _isOfflineSyncMeta = const VerificationMeta(
    'isOfflineSync',
  );
  @override
  late final GeneratedColumn<bool> isOfflineSync = GeneratedColumn<bool>(
    'is_offline_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_offline_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timingVerifiedMeta = const VerificationMeta(
    'timingVerified',
  );
  @override
  late final GeneratedColumn<bool> timingVerified = GeneratedColumn<bool>(
    'timing_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("timing_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverDurationSecondsMeta =
      const VerificationMeta('serverDurationSeconds');
  @override
  late final GeneratedColumn<int> serverDurationSeconds = GeneratedColumn<int>(
    'server_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientReportedDurationSecondsMeta =
      const VerificationMeta('clientReportedDurationSeconds');
  @override
  late final GeneratedColumn<int> clientReportedDurationSeconds =
      GeneratedColumn<int>(
        'client_reported_duration_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersJsonMeta = const VerificationMeta(
    'answersJson',
  );
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
    'answers_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    assessmentVersionId,
    status,
    isOfflineSync,
    timingVerified,
    startedAt,
    submittedAt,
    serverDurationSeconds,
    clientReportedDurationSeconds,
    idempotencyKey,
    answersJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assessment_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssessmentAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('assessment_version_id')) {
      context.handle(
        _assessmentVersionIdMeta,
        assessmentVersionId.isAcceptableOrUnknown(
          data['assessment_version_id']!,
          _assessmentVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentVersionIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_offline_sync')) {
      context.handle(
        _isOfflineSyncMeta,
        isOfflineSync.isAcceptableOrUnknown(
          data['is_offline_sync']!,
          _isOfflineSyncMeta,
        ),
      );
    }
    if (data.containsKey('timing_verified')) {
      context.handle(
        _timingVerifiedMeta,
        timingVerified.isAcceptableOrUnknown(
          data['timing_verified']!,
          _timingVerifiedMeta,
        ),
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
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('server_duration_seconds')) {
      context.handle(
        _serverDurationSecondsMeta,
        serverDurationSeconds.isAcceptableOrUnknown(
          data['server_duration_seconds']!,
          _serverDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('client_reported_duration_seconds')) {
      context.handle(
        _clientReportedDurationSecondsMeta,
        clientReportedDurationSeconds.isAcceptableOrUnknown(
          data['client_reported_duration_seconds']!,
          _clientReportedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('answers_json')) {
      context.handle(
        _answersJsonMeta,
        answersJson.isAcceptableOrUnknown(
          data['answers_json']!,
          _answersJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAssessmentAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssessmentAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      assessmentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_version_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isOfflineSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_offline_sync'],
      )!,
      timingVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}timing_verified'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      ),
      serverDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_duration_seconds'],
      ),
      clientReportedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_reported_duration_seconds'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      answersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers_json'],
      ),
    );
  }

  @override
  $LocalAssessmentAttemptsTable createAlias(String alias) {
    return $LocalAssessmentAttemptsTable(attachedDatabase, alias);
  }
}

class LocalAssessmentAttempt extends DataClass
    implements Insertable<LocalAssessmentAttempt> {
  final String id;
  final String studentId;
  final String assessmentVersionId;
  final String status;
  final bool isOfflineSync;
  final bool timingVerified;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final int? serverDurationSeconds;
  final int? clientReportedDurationSeconds;
  final String idempotencyKey;
  final String? answersJson;
  const LocalAssessmentAttempt({
    required this.id,
    required this.studentId,
    required this.assessmentVersionId,
    required this.status,
    required this.isOfflineSync,
    required this.timingVerified,
    required this.startedAt,
    this.submittedAt,
    this.serverDurationSeconds,
    this.clientReportedDurationSeconds,
    required this.idempotencyKey,
    this.answersJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['assessment_version_id'] = Variable<String>(assessmentVersionId);
    map['status'] = Variable<String>(status);
    map['is_offline_sync'] = Variable<bool>(isOfflineSync);
    map['timing_verified'] = Variable<bool>(timingVerified);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    if (!nullToAbsent || serverDurationSeconds != null) {
      map['server_duration_seconds'] = Variable<int>(serverDurationSeconds);
    }
    if (!nullToAbsent || clientReportedDurationSeconds != null) {
      map['client_reported_duration_seconds'] = Variable<int>(
        clientReportedDurationSeconds,
      );
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    if (!nullToAbsent || answersJson != null) {
      map['answers_json'] = Variable<String>(answersJson);
    }
    return map;
  }

  LocalAssessmentAttemptsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssessmentAttemptsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      assessmentVersionId: Value(assessmentVersionId),
      status: Value(status),
      isOfflineSync: Value(isOfflineSync),
      timingVerified: Value(timingVerified),
      startedAt: Value(startedAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
      serverDurationSeconds: serverDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(serverDurationSeconds),
      clientReportedDurationSeconds:
          clientReportedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(clientReportedDurationSeconds),
      idempotencyKey: Value(idempotencyKey),
      answersJson: answersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(answersJson),
    );
  }

  factory LocalAssessmentAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssessmentAttempt(
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      assessmentVersionId: serializer.fromJson<String>(
        json['assessmentVersionId'],
      ),
      status: serializer.fromJson<String>(json['status']),
      isOfflineSync: serializer.fromJson<bool>(json['isOfflineSync']),
      timingVerified: serializer.fromJson<bool>(json['timingVerified']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
      serverDurationSeconds: serializer.fromJson<int?>(
        json['serverDurationSeconds'],
      ),
      clientReportedDurationSeconds: serializer.fromJson<int?>(
        json['clientReportedDurationSeconds'],
      ),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      answersJson: serializer.fromJson<String?>(json['answersJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'assessmentVersionId': serializer.toJson<String>(assessmentVersionId),
      'status': serializer.toJson<String>(status),
      'isOfflineSync': serializer.toJson<bool>(isOfflineSync),
      'timingVerified': serializer.toJson<bool>(timingVerified),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
      'serverDurationSeconds': serializer.toJson<int?>(serverDurationSeconds),
      'clientReportedDurationSeconds': serializer.toJson<int?>(
        clientReportedDurationSeconds,
      ),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'answersJson': serializer.toJson<String?>(answersJson),
    };
  }

  LocalAssessmentAttempt copyWith({
    String? id,
    String? studentId,
    String? assessmentVersionId,
    String? status,
    bool? isOfflineSync,
    bool? timingVerified,
    DateTime? startedAt,
    Value<DateTime?> submittedAt = const Value.absent(),
    Value<int?> serverDurationSeconds = const Value.absent(),
    Value<int?> clientReportedDurationSeconds = const Value.absent(),
    String? idempotencyKey,
    Value<String?> answersJson = const Value.absent(),
  }) => LocalAssessmentAttempt(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    assessmentVersionId: assessmentVersionId ?? this.assessmentVersionId,
    status: status ?? this.status,
    isOfflineSync: isOfflineSync ?? this.isOfflineSync,
    timingVerified: timingVerified ?? this.timingVerified,
    startedAt: startedAt ?? this.startedAt,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
    serverDurationSeconds: serverDurationSeconds.present
        ? serverDurationSeconds.value
        : this.serverDurationSeconds,
    clientReportedDurationSeconds: clientReportedDurationSeconds.present
        ? clientReportedDurationSeconds.value
        : this.clientReportedDurationSeconds,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    answersJson: answersJson.present ? answersJson.value : this.answersJson,
  );
  LocalAssessmentAttempt copyWithCompanion(
    LocalAssessmentAttemptsCompanion data,
  ) {
    return LocalAssessmentAttempt(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      assessmentVersionId: data.assessmentVersionId.present
          ? data.assessmentVersionId.value
          : this.assessmentVersionId,
      status: data.status.present ? data.status.value : this.status,
      isOfflineSync: data.isOfflineSync.present
          ? data.isOfflineSync.value
          : this.isOfflineSync,
      timingVerified: data.timingVerified.present
          ? data.timingVerified.value
          : this.timingVerified,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      serverDurationSeconds: data.serverDurationSeconds.present
          ? data.serverDurationSeconds.value
          : this.serverDurationSeconds,
      clientReportedDurationSeconds: data.clientReportedDurationSeconds.present
          ? data.clientReportedDurationSeconds.value
          : this.clientReportedDurationSeconds,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      answersJson: data.answersJson.present
          ? data.answersJson.value
          : this.answersJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentAttempt(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('assessmentVersionId: $assessmentVersionId, ')
          ..write('status: $status, ')
          ..write('isOfflineSync: $isOfflineSync, ')
          ..write('timingVerified: $timingVerified, ')
          ..write('startedAt: $startedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('serverDurationSeconds: $serverDurationSeconds, ')
          ..write(
            'clientReportedDurationSeconds: $clientReportedDurationSeconds, ',
          )
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('answersJson: $answersJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    assessmentVersionId,
    status,
    isOfflineSync,
    timingVerified,
    startedAt,
    submittedAt,
    serverDurationSeconds,
    clientReportedDurationSeconds,
    idempotencyKey,
    answersJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssessmentAttempt &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.assessmentVersionId == this.assessmentVersionId &&
          other.status == this.status &&
          other.isOfflineSync == this.isOfflineSync &&
          other.timingVerified == this.timingVerified &&
          other.startedAt == this.startedAt &&
          other.submittedAt == this.submittedAt &&
          other.serverDurationSeconds == this.serverDurationSeconds &&
          other.clientReportedDurationSeconds ==
              this.clientReportedDurationSeconds &&
          other.idempotencyKey == this.idempotencyKey &&
          other.answersJson == this.answersJson);
}

class LocalAssessmentAttemptsCompanion
    extends UpdateCompanion<LocalAssessmentAttempt> {
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> assessmentVersionId;
  final Value<String> status;
  final Value<bool> isOfflineSync;
  final Value<bool> timingVerified;
  final Value<DateTime> startedAt;
  final Value<DateTime?> submittedAt;
  final Value<int?> serverDurationSeconds;
  final Value<int?> clientReportedDurationSeconds;
  final Value<String> idempotencyKey;
  final Value<String?> answersJson;
  final Value<int> rowid;
  const LocalAssessmentAttemptsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.assessmentVersionId = const Value.absent(),
    this.status = const Value.absent(),
    this.isOfflineSync = const Value.absent(),
    this.timingVerified = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.serverDurationSeconds = const Value.absent(),
    this.clientReportedDurationSeconds = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssessmentAttemptsCompanion.insert({
    required String id,
    required String studentId,
    required String assessmentVersionId,
    this.status = const Value.absent(),
    this.isOfflineSync = const Value.absent(),
    this.timingVerified = const Value.absent(),
    required DateTime startedAt,
    this.submittedAt = const Value.absent(),
    this.serverDurationSeconds = const Value.absent(),
    this.clientReportedDurationSeconds = const Value.absent(),
    required String idempotencyKey,
    this.answersJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       assessmentVersionId = Value(assessmentVersionId),
       startedAt = Value(startedAt),
       idempotencyKey = Value(idempotencyKey);
  static Insertable<LocalAssessmentAttempt> custom({
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? assessmentVersionId,
    Expression<String>? status,
    Expression<bool>? isOfflineSync,
    Expression<bool>? timingVerified,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? submittedAt,
    Expression<int>? serverDurationSeconds,
    Expression<int>? clientReportedDurationSeconds,
    Expression<String>? idempotencyKey,
    Expression<String>? answersJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (assessmentVersionId != null)
        'assessment_version_id': assessmentVersionId,
      if (status != null) 'status': status,
      if (isOfflineSync != null) 'is_offline_sync': isOfflineSync,
      if (timingVerified != null) 'timing_verified': timingVerified,
      if (startedAt != null) 'started_at': startedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (serverDurationSeconds != null)
        'server_duration_seconds': serverDurationSeconds,
      if (clientReportedDurationSeconds != null)
        'client_reported_duration_seconds': clientReportedDurationSeconds,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (answersJson != null) 'answers_json': answersJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssessmentAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? assessmentVersionId,
    Value<String>? status,
    Value<bool>? isOfflineSync,
    Value<bool>? timingVerified,
    Value<DateTime>? startedAt,
    Value<DateTime?>? submittedAt,
    Value<int?>? serverDurationSeconds,
    Value<int?>? clientReportedDurationSeconds,
    Value<String>? idempotencyKey,
    Value<String?>? answersJson,
    Value<int>? rowid,
  }) {
    return LocalAssessmentAttemptsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      assessmentVersionId: assessmentVersionId ?? this.assessmentVersionId,
      status: status ?? this.status,
      isOfflineSync: isOfflineSync ?? this.isOfflineSync,
      timingVerified: timingVerified ?? this.timingVerified,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      serverDurationSeconds:
          serverDurationSeconds ?? this.serverDurationSeconds,
      clientReportedDurationSeconds:
          clientReportedDurationSeconds ?? this.clientReportedDurationSeconds,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      answersJson: answersJson ?? this.answersJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (assessmentVersionId.present) {
      map['assessment_version_id'] = Variable<String>(
        assessmentVersionId.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isOfflineSync.present) {
      map['is_offline_sync'] = Variable<bool>(isOfflineSync.value);
    }
    if (timingVerified.present) {
      map['timing_verified'] = Variable<bool>(timingVerified.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (serverDurationSeconds.present) {
      map['server_duration_seconds'] = Variable<int>(
        serverDurationSeconds.value,
      );
    }
    if (clientReportedDurationSeconds.present) {
      map['client_reported_duration_seconds'] = Variable<int>(
        clientReportedDurationSeconds.value,
      );
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('assessmentVersionId: $assessmentVersionId, ')
          ..write('status: $status, ')
          ..write('isOfflineSync: $isOfflineSync, ')
          ..write('timingVerified: $timingVerified, ')
          ..write('startedAt: $startedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('serverDurationSeconds: $serverDurationSeconds, ')
          ..write(
            'clientReportedDurationSeconds: $clientReportedDurationSeconds, ',
          )
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('answersJson: $answersJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssessmentResultsTable extends LocalAssessmentResults
    with TableInfo<$LocalAssessmentResultsTable, LocalAssessmentResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssessmentResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentVersionIdMeta =
      const VerificationMeta('assessmentVersionId');
  @override
  late final GeneratedColumn<String> assessmentVersionId =
      GeneratedColumn<String>(
        'assessment_version_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredQuestionsMeta = const VerificationMeta(
    'answeredQuestions',
  );
  @override
  late final GeneratedColumn<int> answeredQuestions = GeneratedColumn<int>(
    'answered_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _incorrectAnswersMeta = const VerificationMeta(
    'incorrectAnswers',
  );
  @override
  late final GeneratedColumn<int> incorrectAnswers = GeneratedColumn<int>(
    'incorrect_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skippedQuestionsMeta = const VerificationMeta(
    'skippedQuestions',
  );
  @override
  late final GeneratedColumn<int> skippedQuestions = GeneratedColumn<int>(
    'skipped_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scoreObtainedMeta = const VerificationMeta(
    'scoreObtained',
  );
  @override
  late final GeneratedColumn<double> scoreObtained = GeneratedColumn<double>(
    'score_obtained',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _maxScoreMeta = const VerificationMeta(
    'maxScore',
  );
  @override
  late final GeneratedColumn<double> maxScore = GeneratedColumn<double>(
    'max_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
    'percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  @override
  late final GeneratedColumn<bool> passed = GeneratedColumn<bool>(
    'passed',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("passed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isOverdueMeta = const VerificationMeta(
    'isOverdue',
  );
  @override
  late final GeneratedColumn<bool> isOverdue = GeneratedColumn<bool>(
    'is_overdue',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_overdue" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _correctionsJsonMeta = const VerificationMeta(
    'correctionsJson',
  );
  @override
  late final GeneratedColumn<String> correctionsJson = GeneratedColumn<String>(
    'corrections_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradedAtMeta = const VerificationMeta(
    'gradedAt',
  );
  @override
  late final GeneratedColumn<DateTime> gradedAt = GeneratedColumn<DateTime>(
    'graded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attemptId,
    studentId,
    assessmentVersionId,
    totalQuestions,
    answeredQuestions,
    correctAnswers,
    incorrectAnswers,
    skippedQuestions,
    scoreObtained,
    maxScore,
    percentage,
    passed,
    isOverdue,
    correctionsJson,
    gradedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_assessment_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssessmentResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('assessment_version_id')) {
      context.handle(
        _assessmentVersionIdMeta,
        assessmentVersionId.isAcceptableOrUnknown(
          data['assessment_version_id']!,
          _assessmentVersionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentVersionIdMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('answered_questions')) {
      context.handle(
        _answeredQuestionsMeta,
        answeredQuestions.isAcceptableOrUnknown(
          data['answered_questions']!,
          _answeredQuestionsMeta,
        ),
      );
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    }
    if (data.containsKey('incorrect_answers')) {
      context.handle(
        _incorrectAnswersMeta,
        incorrectAnswers.isAcceptableOrUnknown(
          data['incorrect_answers']!,
          _incorrectAnswersMeta,
        ),
      );
    }
    if (data.containsKey('skipped_questions')) {
      context.handle(
        _skippedQuestionsMeta,
        skippedQuestions.isAcceptableOrUnknown(
          data['skipped_questions']!,
          _skippedQuestionsMeta,
        ),
      );
    }
    if (data.containsKey('score_obtained')) {
      context.handle(
        _scoreObtainedMeta,
        scoreObtained.isAcceptableOrUnknown(
          data['score_obtained']!,
          _scoreObtainedMeta,
        ),
      );
    }
    if (data.containsKey('max_score')) {
      context.handle(
        _maxScoreMeta,
        maxScore.isAcceptableOrUnknown(data['max_score']!, _maxScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_maxScoreMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    if (data.containsKey('passed')) {
      context.handle(
        _passedMeta,
        passed.isAcceptableOrUnknown(data['passed']!, _passedMeta),
      );
    }
    if (data.containsKey('is_overdue')) {
      context.handle(
        _isOverdueMeta,
        isOverdue.isAcceptableOrUnknown(data['is_overdue']!, _isOverdueMeta),
      );
    }
    if (data.containsKey('corrections_json')) {
      context.handle(
        _correctionsJsonMeta,
        correctionsJson.isAcceptableOrUnknown(
          data['corrections_json']!,
          _correctionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('graded_at')) {
      context.handle(
        _gradedAtMeta,
        gradedAt.isAcceptableOrUnknown(data['graded_at']!, _gradedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAssessmentResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssessmentResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      assessmentVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_version_id'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      answeredQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_questions'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      incorrectAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}incorrect_answers'],
      )!,
      skippedQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped_questions'],
      )!,
      scoreObtained: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score_obtained'],
      )!,
      maxScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_score'],
      )!,
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentage'],
      )!,
      passed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}passed'],
      ),
      isOverdue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_overdue'],
      )!,
      correctionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrections_json'],
      ),
      gradedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}graded_at'],
      )!,
    );
  }

  @override
  $LocalAssessmentResultsTable createAlias(String alias) {
    return $LocalAssessmentResultsTable(attachedDatabase, alias);
  }
}

class LocalAssessmentResult extends DataClass
    implements Insertable<LocalAssessmentResult> {
  final String id;
  final String attemptId;
  final String studentId;
  final String assessmentVersionId;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final double scoreObtained;
  final double maxScore;
  final double percentage;
  final bool? passed;
  final bool isOverdue;
  final String? correctionsJson;
  final DateTime gradedAt;
  const LocalAssessmentResult({
    required this.id,
    required this.attemptId,
    required this.studentId,
    required this.assessmentVersionId,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedQuestions,
    required this.scoreObtained,
    required this.maxScore,
    required this.percentage,
    this.passed,
    required this.isOverdue,
    this.correctionsJson,
    required this.gradedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['attempt_id'] = Variable<String>(attemptId);
    map['student_id'] = Variable<String>(studentId);
    map['assessment_version_id'] = Variable<String>(assessmentVersionId);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['answered_questions'] = Variable<int>(answeredQuestions);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['incorrect_answers'] = Variable<int>(incorrectAnswers);
    map['skipped_questions'] = Variable<int>(skippedQuestions);
    map['score_obtained'] = Variable<double>(scoreObtained);
    map['max_score'] = Variable<double>(maxScore);
    map['percentage'] = Variable<double>(percentage);
    if (!nullToAbsent || passed != null) {
      map['passed'] = Variable<bool>(passed);
    }
    map['is_overdue'] = Variable<bool>(isOverdue);
    if (!nullToAbsent || correctionsJson != null) {
      map['corrections_json'] = Variable<String>(correctionsJson);
    }
    map['graded_at'] = Variable<DateTime>(gradedAt);
    return map;
  }

  LocalAssessmentResultsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssessmentResultsCompanion(
      id: Value(id),
      attemptId: Value(attemptId),
      studentId: Value(studentId),
      assessmentVersionId: Value(assessmentVersionId),
      totalQuestions: Value(totalQuestions),
      answeredQuestions: Value(answeredQuestions),
      correctAnswers: Value(correctAnswers),
      incorrectAnswers: Value(incorrectAnswers),
      skippedQuestions: Value(skippedQuestions),
      scoreObtained: Value(scoreObtained),
      maxScore: Value(maxScore),
      percentage: Value(percentage),
      passed: passed == null && nullToAbsent
          ? const Value.absent()
          : Value(passed),
      isOverdue: Value(isOverdue),
      correctionsJson: correctionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionsJson),
      gradedAt: Value(gradedAt),
    );
  }

  factory LocalAssessmentResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssessmentResult(
      id: serializer.fromJson<String>(json['id']),
      attemptId: serializer.fromJson<String>(json['attemptId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      assessmentVersionId: serializer.fromJson<String>(
        json['assessmentVersionId'],
      ),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      answeredQuestions: serializer.fromJson<int>(json['answeredQuestions']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      incorrectAnswers: serializer.fromJson<int>(json['incorrectAnswers']),
      skippedQuestions: serializer.fromJson<int>(json['skippedQuestions']),
      scoreObtained: serializer.fromJson<double>(json['scoreObtained']),
      maxScore: serializer.fromJson<double>(json['maxScore']),
      percentage: serializer.fromJson<double>(json['percentage']),
      passed: serializer.fromJson<bool?>(json['passed']),
      isOverdue: serializer.fromJson<bool>(json['isOverdue']),
      correctionsJson: serializer.fromJson<String?>(json['correctionsJson']),
      gradedAt: serializer.fromJson<DateTime>(json['gradedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'attemptId': serializer.toJson<String>(attemptId),
      'studentId': serializer.toJson<String>(studentId),
      'assessmentVersionId': serializer.toJson<String>(assessmentVersionId),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'answeredQuestions': serializer.toJson<int>(answeredQuestions),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'incorrectAnswers': serializer.toJson<int>(incorrectAnswers),
      'skippedQuestions': serializer.toJson<int>(skippedQuestions),
      'scoreObtained': serializer.toJson<double>(scoreObtained),
      'maxScore': serializer.toJson<double>(maxScore),
      'percentage': serializer.toJson<double>(percentage),
      'passed': serializer.toJson<bool?>(passed),
      'isOverdue': serializer.toJson<bool>(isOverdue),
      'correctionsJson': serializer.toJson<String?>(correctionsJson),
      'gradedAt': serializer.toJson<DateTime>(gradedAt),
    };
  }

  LocalAssessmentResult copyWith({
    String? id,
    String? attemptId,
    String? studentId,
    String? assessmentVersionId,
    int? totalQuestions,
    int? answeredQuestions,
    int? correctAnswers,
    int? incorrectAnswers,
    int? skippedQuestions,
    double? scoreObtained,
    double? maxScore,
    double? percentage,
    Value<bool?> passed = const Value.absent(),
    bool? isOverdue,
    Value<String?> correctionsJson = const Value.absent(),
    DateTime? gradedAt,
  }) => LocalAssessmentResult(
    id: id ?? this.id,
    attemptId: attemptId ?? this.attemptId,
    studentId: studentId ?? this.studentId,
    assessmentVersionId: assessmentVersionId ?? this.assessmentVersionId,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    answeredQuestions: answeredQuestions ?? this.answeredQuestions,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
    skippedQuestions: skippedQuestions ?? this.skippedQuestions,
    scoreObtained: scoreObtained ?? this.scoreObtained,
    maxScore: maxScore ?? this.maxScore,
    percentage: percentage ?? this.percentage,
    passed: passed.present ? passed.value : this.passed,
    isOverdue: isOverdue ?? this.isOverdue,
    correctionsJson: correctionsJson.present
        ? correctionsJson.value
        : this.correctionsJson,
    gradedAt: gradedAt ?? this.gradedAt,
  );
  LocalAssessmentResult copyWithCompanion(
    LocalAssessmentResultsCompanion data,
  ) {
    return LocalAssessmentResult(
      id: data.id.present ? data.id.value : this.id,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      assessmentVersionId: data.assessmentVersionId.present
          ? data.assessmentVersionId.value
          : this.assessmentVersionId,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      answeredQuestions: data.answeredQuestions.present
          ? data.answeredQuestions.value
          : this.answeredQuestions,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      incorrectAnswers: data.incorrectAnswers.present
          ? data.incorrectAnswers.value
          : this.incorrectAnswers,
      skippedQuestions: data.skippedQuestions.present
          ? data.skippedQuestions.value
          : this.skippedQuestions,
      scoreObtained: data.scoreObtained.present
          ? data.scoreObtained.value
          : this.scoreObtained,
      maxScore: data.maxScore.present ? data.maxScore.value : this.maxScore,
      percentage: data.percentage.present
          ? data.percentage.value
          : this.percentage,
      passed: data.passed.present ? data.passed.value : this.passed,
      isOverdue: data.isOverdue.present ? data.isOverdue.value : this.isOverdue,
      correctionsJson: data.correctionsJson.present
          ? data.correctionsJson.value
          : this.correctionsJson,
      gradedAt: data.gradedAt.present ? data.gradedAt.value : this.gradedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentResult(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('studentId: $studentId, ')
          ..write('assessmentVersionId: $assessmentVersionId, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('answeredQuestions: $answeredQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('incorrectAnswers: $incorrectAnswers, ')
          ..write('skippedQuestions: $skippedQuestions, ')
          ..write('scoreObtained: $scoreObtained, ')
          ..write('maxScore: $maxScore, ')
          ..write('percentage: $percentage, ')
          ..write('passed: $passed, ')
          ..write('isOverdue: $isOverdue, ')
          ..write('correctionsJson: $correctionsJson, ')
          ..write('gradedAt: $gradedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attemptId,
    studentId,
    assessmentVersionId,
    totalQuestions,
    answeredQuestions,
    correctAnswers,
    incorrectAnswers,
    skippedQuestions,
    scoreObtained,
    maxScore,
    percentage,
    passed,
    isOverdue,
    correctionsJson,
    gradedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssessmentResult &&
          other.id == this.id &&
          other.attemptId == this.attemptId &&
          other.studentId == this.studentId &&
          other.assessmentVersionId == this.assessmentVersionId &&
          other.totalQuestions == this.totalQuestions &&
          other.answeredQuestions == this.answeredQuestions &&
          other.correctAnswers == this.correctAnswers &&
          other.incorrectAnswers == this.incorrectAnswers &&
          other.skippedQuestions == this.skippedQuestions &&
          other.scoreObtained == this.scoreObtained &&
          other.maxScore == this.maxScore &&
          other.percentage == this.percentage &&
          other.passed == this.passed &&
          other.isOverdue == this.isOverdue &&
          other.correctionsJson == this.correctionsJson &&
          other.gradedAt == this.gradedAt);
}

class LocalAssessmentResultsCompanion
    extends UpdateCompanion<LocalAssessmentResult> {
  final Value<String> id;
  final Value<String> attemptId;
  final Value<String> studentId;
  final Value<String> assessmentVersionId;
  final Value<int> totalQuestions;
  final Value<int> answeredQuestions;
  final Value<int> correctAnswers;
  final Value<int> incorrectAnswers;
  final Value<int> skippedQuestions;
  final Value<double> scoreObtained;
  final Value<double> maxScore;
  final Value<double> percentage;
  final Value<bool?> passed;
  final Value<bool> isOverdue;
  final Value<String?> correctionsJson;
  final Value<DateTime> gradedAt;
  final Value<int> rowid;
  const LocalAssessmentResultsCompanion({
    this.id = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.assessmentVersionId = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.answeredQuestions = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.incorrectAnswers = const Value.absent(),
    this.skippedQuestions = const Value.absent(),
    this.scoreObtained = const Value.absent(),
    this.maxScore = const Value.absent(),
    this.percentage = const Value.absent(),
    this.passed = const Value.absent(),
    this.isOverdue = const Value.absent(),
    this.correctionsJson = const Value.absent(),
    this.gradedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssessmentResultsCompanion.insert({
    required String id,
    required String attemptId,
    required String studentId,
    required String assessmentVersionId,
    required int totalQuestions,
    this.answeredQuestions = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.incorrectAnswers = const Value.absent(),
    this.skippedQuestions = const Value.absent(),
    this.scoreObtained = const Value.absent(),
    required double maxScore,
    required double percentage,
    this.passed = const Value.absent(),
    this.isOverdue = const Value.absent(),
    this.correctionsJson = const Value.absent(),
    this.gradedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       attemptId = Value(attemptId),
       studentId = Value(studentId),
       assessmentVersionId = Value(assessmentVersionId),
       totalQuestions = Value(totalQuestions),
       maxScore = Value(maxScore),
       percentage = Value(percentage);
  static Insertable<LocalAssessmentResult> custom({
    Expression<String>? id,
    Expression<String>? attemptId,
    Expression<String>? studentId,
    Expression<String>? assessmentVersionId,
    Expression<int>? totalQuestions,
    Expression<int>? answeredQuestions,
    Expression<int>? correctAnswers,
    Expression<int>? incorrectAnswers,
    Expression<int>? skippedQuestions,
    Expression<double>? scoreObtained,
    Expression<double>? maxScore,
    Expression<double>? percentage,
    Expression<bool>? passed,
    Expression<bool>? isOverdue,
    Expression<String>? correctionsJson,
    Expression<DateTime>? gradedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attemptId != null) 'attempt_id': attemptId,
      if (studentId != null) 'student_id': studentId,
      if (assessmentVersionId != null)
        'assessment_version_id': assessmentVersionId,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (answeredQuestions != null) 'answered_questions': answeredQuestions,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (incorrectAnswers != null) 'incorrect_answers': incorrectAnswers,
      if (skippedQuestions != null) 'skipped_questions': skippedQuestions,
      if (scoreObtained != null) 'score_obtained': scoreObtained,
      if (maxScore != null) 'max_score': maxScore,
      if (percentage != null) 'percentage': percentage,
      if (passed != null) 'passed': passed,
      if (isOverdue != null) 'is_overdue': isOverdue,
      if (correctionsJson != null) 'corrections_json': correctionsJson,
      if (gradedAt != null) 'graded_at': gradedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssessmentResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? attemptId,
    Value<String>? studentId,
    Value<String>? assessmentVersionId,
    Value<int>? totalQuestions,
    Value<int>? answeredQuestions,
    Value<int>? correctAnswers,
    Value<int>? incorrectAnswers,
    Value<int>? skippedQuestions,
    Value<double>? scoreObtained,
    Value<double>? maxScore,
    Value<double>? percentage,
    Value<bool?>? passed,
    Value<bool>? isOverdue,
    Value<String?>? correctionsJson,
    Value<DateTime>? gradedAt,
    Value<int>? rowid,
  }) {
    return LocalAssessmentResultsCompanion(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      studentId: studentId ?? this.studentId,
      assessmentVersionId: assessmentVersionId ?? this.assessmentVersionId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      scoreObtained: scoreObtained ?? this.scoreObtained,
      maxScore: maxScore ?? this.maxScore,
      percentage: percentage ?? this.percentage,
      passed: passed ?? this.passed,
      isOverdue: isOverdue ?? this.isOverdue,
      correctionsJson: correctionsJson ?? this.correctionsJson,
      gradedAt: gradedAt ?? this.gradedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (assessmentVersionId.present) {
      map['assessment_version_id'] = Variable<String>(
        assessmentVersionId.value,
      );
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (answeredQuestions.present) {
      map['answered_questions'] = Variable<int>(answeredQuestions.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (incorrectAnswers.present) {
      map['incorrect_answers'] = Variable<int>(incorrectAnswers.value);
    }
    if (skippedQuestions.present) {
      map['skipped_questions'] = Variable<int>(skippedQuestions.value);
    }
    if (scoreObtained.present) {
      map['score_obtained'] = Variable<double>(scoreObtained.value);
    }
    if (maxScore.present) {
      map['max_score'] = Variable<double>(maxScore.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (passed.present) {
      map['passed'] = Variable<bool>(passed.value);
    }
    if (isOverdue.present) {
      map['is_overdue'] = Variable<bool>(isOverdue.value);
    }
    if (correctionsJson.present) {
      map['corrections_json'] = Variable<String>(correctionsJson.value);
    }
    if (gradedAt.present) {
      map['graded_at'] = Variable<DateTime>(gradedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssessmentResultsCompanion(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('studentId: $studentId, ')
          ..write('assessmentVersionId: $assessmentVersionId, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('answeredQuestions: $answeredQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('incorrectAnswers: $incorrectAnswers, ')
          ..write('skippedQuestions: $skippedQuestions, ')
          ..write('scoreObtained: $scoreObtained, ')
          ..write('maxScore: $maxScore, ')
          ..write('percentage: $percentage, ')
          ..write('passed: $passed, ')
          ..write('isOverdue: $isOverdue, ')
          ..write('correctionsJson: $correctionsJson, ')
          ..write('gradedAt: $gradedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $ChapterProgressTable chapterProgress = $ChapterProgressTable(
    this,
  );
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $LocalAssessmentsTable localAssessments = $LocalAssessmentsTable(
    this,
  );
  late final $LocalAssessmentVersionsTable localAssessmentVersions =
      $LocalAssessmentVersionsTable(this);
  late final $LocalAssessmentVersionChaptersTable
  localAssessmentVersionChapters = $LocalAssessmentVersionChaptersTable(this);
  late final $LocalQuestionsTable localQuestions = $LocalQuestionsTable(this);
  late final $LocalQuestionOptionsTable localQuestionOptions =
      $LocalQuestionOptionsTable(this);
  late final $LocalAssessmentAttemptsTable localAssessmentAttempts =
      $LocalAssessmentAttemptsTable(this);
  late final $LocalAssessmentResultsTable localAssessmentResults =
      $LocalAssessmentResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    students,
    subjects,
    chapters,
    chapterProgress,
    studySessions,
    syncQueue,
    localAssessments,
    localAssessmentVersions,
    localAssessmentVersionChapters,
    localQuestions,
    localQuestionOptions,
    localAssessmentAttempts,
    localAssessmentResults,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subjects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chapters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chapters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chapter_progress', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      required String id,
      required String email,
      required String name,
      required int grade,
      required String gender,
      required String stream,
      Value<int> dailyGoalMinutes,
      Value<int> streakCount,
      Value<int> streakFreezes,
      Value<DateTime?> lastStudyDate,
      Value<String?> avatarUrl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> name,
      Value<int> grade,
      Value<String> gender,
      Value<String> stream,
      Value<int> dailyGoalMinutes,
      Value<int> streakCount,
      Value<int> streakFreezes,
      Value<DateTime?> lastStudyDate,
      Value<String?> avatarUrl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakFreezes => $composableBuilder(
    column: $table.streakFreezes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastStudyDate => $composableBuilder(
    column: $table.lastStudyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakFreezes => $composableBuilder(
    column: $table.streakFreezes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastStudyDate => $composableBuilder(
    column: $table.lastStudyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get stream =>
      $composableBuilder(column: $table.stream, builder: (column) => column);

  GeneratedColumn<int> get dailyGoalMinutes => $composableBuilder(
    column: $table.dailyGoalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakFreezes => $composableBuilder(
    column: $table.streakFreezes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastStudyDate => $composableBuilder(
    column: $table.lastStudyDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
          Student,
          PrefetchHooks Function()
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> grade = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> stream = const Value.absent(),
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<int> streakCount = const Value.absent(),
                Value<int> streakFreezes = const Value.absent(),
                Value<DateTime?> lastStudyDate = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                email: email,
                name: name,
                grade: grade,
                gender: gender,
                stream: stream,
                dailyGoalMinutes: dailyGoalMinutes,
                streakCount: streakCount,
                streakFreezes: streakFreezes,
                lastStudyDate: lastStudyDate,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String name,
                required int grade,
                required String gender,
                required String stream,
                Value<int> dailyGoalMinutes = const Value.absent(),
                Value<int> streakCount = const Value.absent(),
                Value<int> streakFreezes = const Value.absent(),
                Value<DateTime?> lastStudyDate = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                email: email,
                name: name,
                grade: grade,
                gender: gender,
                stream: stream,
                dailyGoalMinutes: dailyGoalMinutes,
                streakCount: streakCount,
                streakFreezes: streakFreezes,
                lastStudyDate: lastStudyDate,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
      Student,
      PrefetchHooks Function()
    >;
typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      required String id,
      required String name,
      required String code,
      required int grade,
      required String stream,
      required int totalUnits,
      Value<String?> iconName,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> code,
      Value<int> grade,
      Value<String> stream,
      Value<int> totalUnits,
      Value<String?> iconName,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChaptersTable, List<Chapter>> _chaptersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chapters,
    aliasName: 'subjects__id__chapters__subject_id',
  );

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalUnits => $composableBuilder(
    column: $table.totalUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chaptersRefs(
    Expression<bool> Function($$ChaptersTableFilterComposer f) f,
  ) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalUnits => $composableBuilder(
    column: $table.totalUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get stream =>
      $composableBuilder(column: $table.stream, builder: (column) => column);

  GeneratedColumn<int> get totalUnits => $composableBuilder(
    column: $table.totalUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> chaptersRefs<T extends Object>(
    Expression<T> Function($$ChaptersTableAnnotationComposer a) f,
  ) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, $$SubjectsTableReferences),
          Subject,
          PrefetchHooks Function({bool chaptersRefs})
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int> grade = const Value.absent(),
                Value<String> stream = const Value.absent(),
                Value<int> totalUnits = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                name: name,
                code: code,
                grade: grade,
                stream: stream,
                totalUnits: totalUnits,
                iconName: iconName,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String code,
                required int grade,
                required String stream,
                required int totalUnits,
                Value<String?> iconName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                name: name,
                code: code,
                grade: grade,
                stream: stream,
                totalUnits: totalUnits,
                iconName: iconName,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chaptersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chaptersRefs) db.chapters],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chaptersRefs)
                    await $_getPrefetchedData<Subject, $SubjectsTable, Chapter>(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._chaptersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SubjectsTableReferences(db, table, p0).chaptersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.subjectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, $$SubjectsTableReferences),
      Subject,
      PrefetchHooks Function({bool chaptersRefs})
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      required String id,
      required String subjectId,
      required int chapterNumber,
      required String title,
      Value<String?> subtopicsJson,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<String> id,
      Value<String> subjectId,
      Value<int> chapterNumber,
      Value<String> title,
      Value<String?> subtopicsJson,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, Chapter> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias('chapters__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<String>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChapterProgressTable, List<ChapterProgressData>>
  _chapterProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chapterProgress,
    aliasName: 'chapters__id__chapter_progress__chapter_id',
  );

  $$ChapterProgressTableProcessedTableManager get chapterProgressRefs {
    final manager = $$ChapterProgressTableTableManager(
      $_db,
      $_db.chapterProgress,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chapterProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
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

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtopicsJson => $composableBuilder(
    column: $table.subtopicsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chapterProgressRefs(
    Expression<bool> Function($$ChapterProgressTableFilterComposer f) f,
  ) {
    final $$ChapterProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapterProgress,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChapterProgressTableFilterComposer(
            $db: $db,
            $table: $db.chapterProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
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

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtopicsJson => $composableBuilder(
    column: $table.subtopicsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtopicsJson => $composableBuilder(
    column: $table.subtopicsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chapterProgressRefs<T extends Object>(
    Expression<T> Function($$ChapterProgressTableAnnotationComposer a) f,
  ) {
    final $$ChapterProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapterProgress,
      getReferencedColumn: (t) => t.chapterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChapterProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.chapterProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, $$ChaptersTableReferences),
          Chapter,
          PrefetchHooks Function({bool subjectId, bool chapterProgressRefs})
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtopicsJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                subjectId: subjectId,
                chapterNumber: chapterNumber,
                title: title,
                subtopicsJson: subtopicsJson,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectId,
                required int chapterNumber,
                required String title,
                Value<String?> subtopicsJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion.insert(
                id: id,
                subjectId: subjectId,
                chapterNumber: chapterNumber,
                title: title,
                subtopicsJson: subtopicsJson,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({subjectId = false, chapterProgressRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chapterProgressRefs) db.chapterProgress,
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
                        if (subjectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subjectId,
                                    referencedTable: $$ChaptersTableReferences
                                        ._subjectIdTable(db),
                                    referencedColumn: $$ChaptersTableReferences
                                        ._subjectIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chapterProgressRefs)
                        await $_getPrefetchedData<
                          Chapter,
                          $ChaptersTable,
                          ChapterProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$ChaptersTableReferences
                              ._chapterProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChaptersTableReferences(
                                db,
                                table,
                                p0,
                              ).chapterProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chapterId == item.id,
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

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, $$ChaptersTableReferences),
      Chapter,
      PrefetchHooks Function({bool subjectId, bool chapterProgressRefs})
    >;
typedef $$ChapterProgressTableCreateCompanionBuilder =
    ChapterProgressCompanion Function({
      required String id,
      required String studentId,
      required String chapterId,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<DateTime?> masteredAt,
      Value<String?> notes,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$ChapterProgressTableUpdateCompanionBuilder =
    ChapterProgressCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> chapterId,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<DateTime?> masteredAt,
      Value<String?> notes,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$ChapterProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ChapterProgressTable,
          ChapterProgressData
        > {
  $$ChapterProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias('chapter_progress__chapter_id__chapters__id');

  $$ChaptersTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<String>('chapter_id')!;

    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChapterProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterProgressTable> {
  $$ChapterProgressTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChapterProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterProgressTable> {
  $$ChapterProgressTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableOrderingComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChapterProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterProgressTable> {
  $$ChapterProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chapterId,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChapterProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterProgressTable,
          ChapterProgressData,
          $$ChapterProgressTableFilterComposer,
          $$ChapterProgressTableOrderingComposer,
          $$ChapterProgressTableAnnotationComposer,
          $$ChapterProgressTableCreateCompanionBuilder,
          $$ChapterProgressTableUpdateCompanionBuilder,
          (ChapterProgressData, $$ChapterProgressTableReferences),
          ChapterProgressData,
          PrefetchHooks Function({bool chapterId})
        > {
  $$ChapterProgressTableTableManager(
    _$AppDatabase db,
    $ChapterProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> masteredAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressCompanion(
                id: id,
                studentId: studentId,
                chapterId: chapterId,
                status: status,
                completedAt: completedAt,
                masteredAt: masteredAt,
                notes: notes,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String chapterId,
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> masteredAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressCompanion.insert(
                id: id,
                studentId: studentId,
                chapterId: chapterId,
                status: status,
                completedAt: completedAt,
                masteredAt: masteredAt,
                notes: notes,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChapterProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
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
                    if (chapterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chapterId,
                                referencedTable:
                                    $$ChapterProgressTableReferences
                                        ._chapterIdTable(db),
                                referencedColumn:
                                    $$ChapterProgressTableReferences
                                        ._chapterIdTable(db)
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

typedef $$ChapterProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterProgressTable,
      ChapterProgressData,
      $$ChapterProgressTableFilterComposer,
      $$ChapterProgressTableOrderingComposer,
      $$ChapterProgressTableAnnotationComposer,
      $$ChapterProgressTableCreateCompanionBuilder,
      $$ChapterProgressTableUpdateCompanionBuilder,
      (ChapterProgressData, $$ChapterProgressTableReferences),
      ChapterProgressData,
      PrefetchHooks Function({bool chapterId})
    >;
typedef $$StudySessionsTableCreateCompanionBuilder =
    StudySessionsCompanion Function({
      required String id,
      required String studentId,
      Value<String?> chapterId,
      required int durationSeconds,
      required DateTime startedAt,
      required DateTime endedAt,
      required String mode,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$StudySessionsTableUpdateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String?> chapterId,
      Value<int> durationSeconds,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<String> mode,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$StudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionsTable,
          StudySession,
          $$StudySessionsTableFilterComposer,
          $$StudySessionsTableOrderingComposer,
          $$StudySessionsTableAnnotationComposer,
          $$StudySessionsTableCreateCompanionBuilder,
          $$StudySessionsTableUpdateCompanionBuilder,
          (
            StudySession,
            BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
          ),
          StudySession,
          PrefetchHooks Function()
        > {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String?> chapterId = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion(
                id: id,
                studentId: studentId,
                chapterId: chapterId,
                durationSeconds: durationSeconds,
                startedAt: startedAt,
                endedAt: endedAt,
                mode: mode,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                Value<String?> chapterId = const Value.absent(),
                required int durationSeconds,
                required DateTime startedAt,
                required DateTime endedAt,
                required String mode,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion.insert(
                id: id,
                studentId: studentId,
                chapterId: chapterId,
                durationSeconds: durationSeconds,
                startedAt: startedAt,
                endedAt: endedAt,
                mode: mode,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionsTable,
      StudySession,
      $$StudySessionsTableFilterComposer,
      $$StudySessionsTableOrderingComposer,
      $$StudySessionsTableAnnotationComposer,
      $$StudySessionsTableCreateCompanionBuilder,
      $$StudySessionsTableUpdateCompanionBuilder,
      (
        StudySession,
        BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
      ),
      StudySession,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String action,
      required String targetTable,
      required String recordId,
      required String payload,
      Value<DateTime> createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> action,
      Value<String> targetTable,
      Value<String> recordId,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                action: action,
                targetTable: targetTable,
                recordId: recordId,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String action,
                required String targetTable,
                required String recordId,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                action: action,
                targetTable: targetTable,
                recordId: recordId,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$LocalAssessmentsTableCreateCompanionBuilder =
    LocalAssessmentsCompanion Function({
      required String id,
      required String code,
      required String title,
      Value<String?> description,
      Value<String> assessmentType,
      Value<String?> currentVersionId,
      Value<String?> subjectId,
      Value<int?> grade,
      Value<String?> stream,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAssessmentsTableUpdateCompanionBuilder =
    LocalAssessmentsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> title,
      Value<String?> description,
      Value<String> assessmentType,
      Value<String?> currentVersionId,
      Value<String?> subjectId,
      Value<int?> grade,
      Value<String?> stream,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalAssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssessmentsTable> {
  $$LocalAssessmentsTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessmentType => $composableBuilder(
    column: $table.assessmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssessmentsTable> {
  $$LocalAssessmentsTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessmentType => $composableBuilder(
    column: $table.assessmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssessmentsTable> {
  $$LocalAssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assessmentType => $composableBuilder(
    column: $table.assessmentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentVersionId => $composableBuilder(
    column: $table.currentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get stream =>
      $composableBuilder(column: $table.stream, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssessmentsTable,
          LocalAssessment,
          $$LocalAssessmentsTableFilterComposer,
          $$LocalAssessmentsTableOrderingComposer,
          $$LocalAssessmentsTableAnnotationComposer,
          $$LocalAssessmentsTableCreateCompanionBuilder,
          $$LocalAssessmentsTableUpdateCompanionBuilder,
          (
            LocalAssessment,
            BaseReferences<
              _$AppDatabase,
              $LocalAssessmentsTable,
              LocalAssessment
            >,
          ),
          LocalAssessment,
          PrefetchHooks Function()
        > {
  $$LocalAssessmentsTableTableManager(
    _$AppDatabase db,
    $LocalAssessmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssessmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssessmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> assessmentType = const Value.absent(),
                Value<String?> currentVersionId = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<String?> stream = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentsCompanion(
                id: id,
                code: code,
                title: title,
                description: description,
                assessmentType: assessmentType,
                currentVersionId: currentVersionId,
                subjectId: subjectId,
                grade: grade,
                stream: stream,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String> assessmentType = const Value.absent(),
                Value<String?> currentVersionId = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<String?> stream = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentsCompanion.insert(
                id: id,
                code: code,
                title: title,
                description: description,
                assessmentType: assessmentType,
                currentVersionId: currentVersionId,
                subjectId: subjectId,
                grade: grade,
                stream: stream,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssessmentsTable,
      LocalAssessment,
      $$LocalAssessmentsTableFilterComposer,
      $$LocalAssessmentsTableOrderingComposer,
      $$LocalAssessmentsTableAnnotationComposer,
      $$LocalAssessmentsTableCreateCompanionBuilder,
      $$LocalAssessmentsTableUpdateCompanionBuilder,
      (
        LocalAssessment,
        BaseReferences<_$AppDatabase, $LocalAssessmentsTable, LocalAssessment>,
      ),
      LocalAssessment,
      PrefetchHooks Function()
    >;
typedef $$LocalAssessmentVersionsTableCreateCompanionBuilder =
    LocalAssessmentVersionsCompanion Function({
      required String id,
      required String assessmentId,
      required int versionNumber,
      Value<String> status,
      Value<int> totalQuestions,
      Value<double> totalPoints,
      Value<int?> timeLimitMinutes,
      Value<double?> passingPercentage,
      Value<DateTime?> publishedAt,
      Value<int> rowid,
    });
typedef $$LocalAssessmentVersionsTableUpdateCompanionBuilder =
    LocalAssessmentVersionsCompanion Function({
      Value<String> id,
      Value<String> assessmentId,
      Value<int> versionNumber,
      Value<String> status,
      Value<int> totalQuestions,
      Value<double> totalPoints,
      Value<int?> timeLimitMinutes,
      Value<double?> passingPercentage,
      Value<DateTime?> publishedAt,
      Value<int> rowid,
    });

class $$LocalAssessmentVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssessmentVersionsTable> {
  $$LocalAssessmentVersionsTableFilterComposer({
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

  ColumnFilters<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get passingPercentage => $composableBuilder(
    column: $table.passingPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssessmentVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssessmentVersionsTable> {
  $$LocalAssessmentVersionsTableOrderingComposer({
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

  ColumnOrderings<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get passingPercentage => $composableBuilder(
    column: $table.passingPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssessmentVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssessmentVersionsTable> {
  $$LocalAssessmentVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalPoints => $composableBuilder(
    column: $table.totalPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get passingPercentage => $composableBuilder(
    column: $table.passingPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );
}

class $$LocalAssessmentVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssessmentVersionsTable,
          LocalAssessmentVersion,
          $$LocalAssessmentVersionsTableFilterComposer,
          $$LocalAssessmentVersionsTableOrderingComposer,
          $$LocalAssessmentVersionsTableAnnotationComposer,
          $$LocalAssessmentVersionsTableCreateCompanionBuilder,
          $$LocalAssessmentVersionsTableUpdateCompanionBuilder,
          (
            LocalAssessmentVersion,
            BaseReferences<
              _$AppDatabase,
              $LocalAssessmentVersionsTable,
              LocalAssessmentVersion
            >,
          ),
          LocalAssessmentVersion,
          PrefetchHooks Function()
        > {
  $$LocalAssessmentVersionsTableTableManager(
    _$AppDatabase db,
    $LocalAssessmentVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssessmentVersionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAssessmentVersionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAssessmentVersionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assessmentId = const Value.absent(),
                Value<int> versionNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<double> totalPoints = const Value.absent(),
                Value<int?> timeLimitMinutes = const Value.absent(),
                Value<double?> passingPercentage = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentVersionsCompanion(
                id: id,
                assessmentId: assessmentId,
                versionNumber: versionNumber,
                status: status,
                totalQuestions: totalQuestions,
                totalPoints: totalPoints,
                timeLimitMinutes: timeLimitMinutes,
                passingPercentage: passingPercentage,
                publishedAt: publishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assessmentId,
                required int versionNumber,
                Value<String> status = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<double> totalPoints = const Value.absent(),
                Value<int?> timeLimitMinutes = const Value.absent(),
                Value<double?> passingPercentage = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentVersionsCompanion.insert(
                id: id,
                assessmentId: assessmentId,
                versionNumber: versionNumber,
                status: status,
                totalQuestions: totalQuestions,
                totalPoints: totalPoints,
                timeLimitMinutes: timeLimitMinutes,
                passingPercentage: passingPercentage,
                publishedAt: publishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssessmentVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssessmentVersionsTable,
      LocalAssessmentVersion,
      $$LocalAssessmentVersionsTableFilterComposer,
      $$LocalAssessmentVersionsTableOrderingComposer,
      $$LocalAssessmentVersionsTableAnnotationComposer,
      $$LocalAssessmentVersionsTableCreateCompanionBuilder,
      $$LocalAssessmentVersionsTableUpdateCompanionBuilder,
      (
        LocalAssessmentVersion,
        BaseReferences<
          _$AppDatabase,
          $LocalAssessmentVersionsTable,
          LocalAssessmentVersion
        >,
      ),
      LocalAssessmentVersion,
      PrefetchHooks Function()
    >;
typedef $$LocalAssessmentVersionChaptersTableCreateCompanionBuilder =
    LocalAssessmentVersionChaptersCompanion Function({
      required String assessmentVersionId,
      required String chapterId,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$LocalAssessmentVersionChaptersTableUpdateCompanionBuilder =
    LocalAssessmentVersionChaptersCompanion Function({
      Value<String> assessmentVersionId,
      Value<String> chapterId,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalAssessmentVersionChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssessmentVersionChaptersTable> {
  $$LocalAssessmentVersionChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssessmentVersionChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssessmentVersionChaptersTable> {
  $$LocalAssessmentVersionChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssessmentVersionChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssessmentVersionChaptersTable> {
  $$LocalAssessmentVersionChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalAssessmentVersionChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssessmentVersionChaptersTable,
          LocalAssessmentVersionChapter,
          $$LocalAssessmentVersionChaptersTableFilterComposer,
          $$LocalAssessmentVersionChaptersTableOrderingComposer,
          $$LocalAssessmentVersionChaptersTableAnnotationComposer,
          $$LocalAssessmentVersionChaptersTableCreateCompanionBuilder,
          $$LocalAssessmentVersionChaptersTableUpdateCompanionBuilder,
          (
            LocalAssessmentVersionChapter,
            BaseReferences<
              _$AppDatabase,
              $LocalAssessmentVersionChaptersTable,
              LocalAssessmentVersionChapter
            >,
          ),
          LocalAssessmentVersionChapter,
          PrefetchHooks Function()
        > {
  $$LocalAssessmentVersionChaptersTableTableManager(
    _$AppDatabase db,
    $LocalAssessmentVersionChaptersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssessmentVersionChaptersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAssessmentVersionChaptersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAssessmentVersionChaptersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> assessmentVersionId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentVersionChaptersCompanion(
                assessmentVersionId: assessmentVersionId,
                chapterId: chapterId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assessmentVersionId,
                required String chapterId,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentVersionChaptersCompanion.insert(
                assessmentVersionId: assessmentVersionId,
                chapterId: chapterId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssessmentVersionChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssessmentVersionChaptersTable,
      LocalAssessmentVersionChapter,
      $$LocalAssessmentVersionChaptersTableFilterComposer,
      $$LocalAssessmentVersionChaptersTableOrderingComposer,
      $$LocalAssessmentVersionChaptersTableAnnotationComposer,
      $$LocalAssessmentVersionChaptersTableCreateCompanionBuilder,
      $$LocalAssessmentVersionChaptersTableUpdateCompanionBuilder,
      (
        LocalAssessmentVersionChapter,
        BaseReferences<
          _$AppDatabase,
          $LocalAssessmentVersionChaptersTable,
          LocalAssessmentVersionChapter
        >,
      ),
      LocalAssessmentVersionChapter,
      PrefetchHooks Function()
    >;
typedef $$LocalQuestionsTableCreateCompanionBuilder =
    LocalQuestionsCompanion Function({
      required String id,
      required String assessmentVersionId,
      required String chapterId,
      required String questionText,
      Value<String> questionType,
      Value<String?> imageUrl,
      Value<double> points,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$LocalQuestionsTableUpdateCompanionBuilder =
    LocalQuestionsCompanion Function({
      Value<String> id,
      Value<String> assessmentVersionId,
      Value<String> chapterId,
      Value<String> questionText,
      Value<String> questionType,
      Value<String?> imageUrl,
      Value<double> points,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableFilterComposer({
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

  ColumnFilters<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableOrderingComposer({
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

  ColumnOrderings<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalQuestionsTable,
          LocalQuestion,
          $$LocalQuestionsTableFilterComposer,
          $$LocalQuestionsTableOrderingComposer,
          $$LocalQuestionsTableAnnotationComposer,
          $$LocalQuestionsTableCreateCompanionBuilder,
          $$LocalQuestionsTableUpdateCompanionBuilder,
          (
            LocalQuestion,
            BaseReferences<_$AppDatabase, $LocalQuestionsTable, LocalQuestion>,
          ),
          LocalQuestion,
          PrefetchHooks Function()
        > {
  $$LocalQuestionsTableTableManager(
    _$AppDatabase db,
    $LocalQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assessmentVersionId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<String> questionType = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double> points = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuestionsCompanion(
                id: id,
                assessmentVersionId: assessmentVersionId,
                chapterId: chapterId,
                questionText: questionText,
                questionType: questionType,
                imageUrl: imageUrl,
                points: points,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assessmentVersionId,
                required String chapterId,
                required String questionText,
                Value<String> questionType = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double> points = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuestionsCompanion.insert(
                id: id,
                assessmentVersionId: assessmentVersionId,
                chapterId: chapterId,
                questionText: questionText,
                questionType: questionType,
                imageUrl: imageUrl,
                points: points,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalQuestionsTable,
      LocalQuestion,
      $$LocalQuestionsTableFilterComposer,
      $$LocalQuestionsTableOrderingComposer,
      $$LocalQuestionsTableAnnotationComposer,
      $$LocalQuestionsTableCreateCompanionBuilder,
      $$LocalQuestionsTableUpdateCompanionBuilder,
      (
        LocalQuestion,
        BaseReferences<_$AppDatabase, $LocalQuestionsTable, LocalQuestion>,
      ),
      LocalQuestion,
      PrefetchHooks Function()
    >;
typedef $$LocalQuestionOptionsTableCreateCompanionBuilder =
    LocalQuestionOptionsCompanion Function({
      required String id,
      required String questionId,
      required String optionLetter,
      required String optionText,
      Value<String?> imageUrl,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$LocalQuestionOptionsTableUpdateCompanionBuilder =
    LocalQuestionOptionsCompanion Function({
      Value<String> id,
      Value<String> questionId,
      Value<String> optionLetter,
      Value<String> optionText,
      Value<String?> imageUrl,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalQuestionOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuestionOptionsTable> {
  $$LocalQuestionOptionsTableFilterComposer({
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

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionLetter => $composableBuilder(
    column: $table.optionLetter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQuestionOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuestionOptionsTable> {
  $$LocalQuestionOptionsTableOrderingComposer({
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

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionLetter => $composableBuilder(
    column: $table.optionLetter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQuestionOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuestionOptionsTable> {
  $$LocalQuestionOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionLetter => $composableBuilder(
    column: $table.optionLetter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalQuestionOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalQuestionOptionsTable,
          LocalQuestionOption,
          $$LocalQuestionOptionsTableFilterComposer,
          $$LocalQuestionOptionsTableOrderingComposer,
          $$LocalQuestionOptionsTableAnnotationComposer,
          $$LocalQuestionOptionsTableCreateCompanionBuilder,
          $$LocalQuestionOptionsTableUpdateCompanionBuilder,
          (
            LocalQuestionOption,
            BaseReferences<
              _$AppDatabase,
              $LocalQuestionOptionsTable,
              LocalQuestionOption
            >,
          ),
          LocalQuestionOption,
          PrefetchHooks Function()
        > {
  $$LocalQuestionOptionsTableTableManager(
    _$AppDatabase db,
    $LocalQuestionOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuestionOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuestionOptionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalQuestionOptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> optionLetter = const Value.absent(),
                Value<String> optionText = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuestionOptionsCompanion(
                id: id,
                questionId: questionId,
                optionLetter: optionLetter,
                optionText: optionText,
                imageUrl: imageUrl,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String questionId,
                required String optionLetter,
                required String optionText,
                Value<String?> imageUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuestionOptionsCompanion.insert(
                id: id,
                questionId: questionId,
                optionLetter: optionLetter,
                optionText: optionText,
                imageUrl: imageUrl,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQuestionOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalQuestionOptionsTable,
      LocalQuestionOption,
      $$LocalQuestionOptionsTableFilterComposer,
      $$LocalQuestionOptionsTableOrderingComposer,
      $$LocalQuestionOptionsTableAnnotationComposer,
      $$LocalQuestionOptionsTableCreateCompanionBuilder,
      $$LocalQuestionOptionsTableUpdateCompanionBuilder,
      (
        LocalQuestionOption,
        BaseReferences<
          _$AppDatabase,
          $LocalQuestionOptionsTable,
          LocalQuestionOption
        >,
      ),
      LocalQuestionOption,
      PrefetchHooks Function()
    >;
typedef $$LocalAssessmentAttemptsTableCreateCompanionBuilder =
    LocalAssessmentAttemptsCompanion Function({
      required String id,
      required String studentId,
      required String assessmentVersionId,
      Value<String> status,
      Value<bool> isOfflineSync,
      Value<bool> timingVerified,
      required DateTime startedAt,
      Value<DateTime?> submittedAt,
      Value<int?> serverDurationSeconds,
      Value<int?> clientReportedDurationSeconds,
      required String idempotencyKey,
      Value<String?> answersJson,
      Value<int> rowid,
    });
typedef $$LocalAssessmentAttemptsTableUpdateCompanionBuilder =
    LocalAssessmentAttemptsCompanion Function({
      Value<String> id,
      Value<String> studentId,
      Value<String> assessmentVersionId,
      Value<String> status,
      Value<bool> isOfflineSync,
      Value<bool> timingVerified,
      Value<DateTime> startedAt,
      Value<DateTime?> submittedAt,
      Value<int?> serverDurationSeconds,
      Value<int?> clientReportedDurationSeconds,
      Value<String> idempotencyKey,
      Value<String?> answersJson,
      Value<int> rowid,
    });

class $$LocalAssessmentAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssessmentAttemptsTable> {
  $$LocalAssessmentAttemptsTableFilterComposer({
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

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOfflineSync => $composableBuilder(
    column: $table.isOfflineSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get timingVerified => $composableBuilder(
    column: $table.timingVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverDurationSeconds => $composableBuilder(
    column: $table.serverDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientReportedDurationSeconds => $composableBuilder(
    column: $table.clientReportedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssessmentAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssessmentAttemptsTable> {
  $$LocalAssessmentAttemptsTableOrderingComposer({
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

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOfflineSync => $composableBuilder(
    column: $table.isOfflineSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get timingVerified => $composableBuilder(
    column: $table.timingVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverDurationSeconds => $composableBuilder(
    column: $table.serverDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientReportedDurationSeconds => $composableBuilder(
    column: $table.clientReportedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssessmentAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssessmentAttemptsTable> {
  $$LocalAssessmentAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isOfflineSync => $composableBuilder(
    column: $table.isOfflineSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get timingVerified => $composableBuilder(
    column: $table.timingVerified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverDurationSeconds => $composableBuilder(
    column: $table.serverDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clientReportedDurationSeconds => $composableBuilder(
    column: $table.clientReportedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => column,
  );
}

class $$LocalAssessmentAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssessmentAttemptsTable,
          LocalAssessmentAttempt,
          $$LocalAssessmentAttemptsTableFilterComposer,
          $$LocalAssessmentAttemptsTableOrderingComposer,
          $$LocalAssessmentAttemptsTableAnnotationComposer,
          $$LocalAssessmentAttemptsTableCreateCompanionBuilder,
          $$LocalAssessmentAttemptsTableUpdateCompanionBuilder,
          (
            LocalAssessmentAttempt,
            BaseReferences<
              _$AppDatabase,
              $LocalAssessmentAttemptsTable,
              LocalAssessmentAttempt
            >,
          ),
          LocalAssessmentAttempt,
          PrefetchHooks Function()
        > {
  $$LocalAssessmentAttemptsTableTableManager(
    _$AppDatabase db,
    $LocalAssessmentAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssessmentAttemptsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAssessmentAttemptsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAssessmentAttemptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> assessmentVersionId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isOfflineSync = const Value.absent(),
                Value<bool> timingVerified = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<int?> serverDurationSeconds = const Value.absent(),
                Value<int?> clientReportedDurationSeconds =
                    const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String?> answersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentAttemptsCompanion(
                id: id,
                studentId: studentId,
                assessmentVersionId: assessmentVersionId,
                status: status,
                isOfflineSync: isOfflineSync,
                timingVerified: timingVerified,
                startedAt: startedAt,
                submittedAt: submittedAt,
                serverDurationSeconds: serverDurationSeconds,
                clientReportedDurationSeconds: clientReportedDurationSeconds,
                idempotencyKey: idempotencyKey,
                answersJson: answersJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentId,
                required String assessmentVersionId,
                Value<String> status = const Value.absent(),
                Value<bool> isOfflineSync = const Value.absent(),
                Value<bool> timingVerified = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<int?> serverDurationSeconds = const Value.absent(),
                Value<int?> clientReportedDurationSeconds =
                    const Value.absent(),
                required String idempotencyKey,
                Value<String?> answersJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentAttemptsCompanion.insert(
                id: id,
                studentId: studentId,
                assessmentVersionId: assessmentVersionId,
                status: status,
                isOfflineSync: isOfflineSync,
                timingVerified: timingVerified,
                startedAt: startedAt,
                submittedAt: submittedAt,
                serverDurationSeconds: serverDurationSeconds,
                clientReportedDurationSeconds: clientReportedDurationSeconds,
                idempotencyKey: idempotencyKey,
                answersJson: answersJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssessmentAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssessmentAttemptsTable,
      LocalAssessmentAttempt,
      $$LocalAssessmentAttemptsTableFilterComposer,
      $$LocalAssessmentAttemptsTableOrderingComposer,
      $$LocalAssessmentAttemptsTableAnnotationComposer,
      $$LocalAssessmentAttemptsTableCreateCompanionBuilder,
      $$LocalAssessmentAttemptsTableUpdateCompanionBuilder,
      (
        LocalAssessmentAttempt,
        BaseReferences<
          _$AppDatabase,
          $LocalAssessmentAttemptsTable,
          LocalAssessmentAttempt
        >,
      ),
      LocalAssessmentAttempt,
      PrefetchHooks Function()
    >;
typedef $$LocalAssessmentResultsTableCreateCompanionBuilder =
    LocalAssessmentResultsCompanion Function({
      required String id,
      required String attemptId,
      required String studentId,
      required String assessmentVersionId,
      required int totalQuestions,
      Value<int> answeredQuestions,
      Value<int> correctAnswers,
      Value<int> incorrectAnswers,
      Value<int> skippedQuestions,
      Value<double> scoreObtained,
      required double maxScore,
      required double percentage,
      Value<bool?> passed,
      Value<bool> isOverdue,
      Value<String?> correctionsJson,
      Value<DateTime> gradedAt,
      Value<int> rowid,
    });
typedef $$LocalAssessmentResultsTableUpdateCompanionBuilder =
    LocalAssessmentResultsCompanion Function({
      Value<String> id,
      Value<String> attemptId,
      Value<String> studentId,
      Value<String> assessmentVersionId,
      Value<int> totalQuestions,
      Value<int> answeredQuestions,
      Value<int> correctAnswers,
      Value<int> incorrectAnswers,
      Value<int> skippedQuestions,
      Value<double> scoreObtained,
      Value<double> maxScore,
      Value<double> percentage,
      Value<bool?> passed,
      Value<bool> isOverdue,
      Value<String?> correctionsJson,
      Value<DateTime> gradedAt,
      Value<int> rowid,
    });

class $$LocalAssessmentResultsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAssessmentResultsTable> {
  $$LocalAssessmentResultsTableFilterComposer({
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

  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredQuestions => $composableBuilder(
    column: $table.answeredQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get incorrectAnswers => $composableBuilder(
    column: $table.incorrectAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedQuestions => $composableBuilder(
    column: $table.skippedQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scoreObtained => $composableBuilder(
    column: $table.scoreObtained,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxScore => $composableBuilder(
    column: $table.maxScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOverdue => $composableBuilder(
    column: $table.isOverdue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctionsJson => $composableBuilder(
    column: $table.correctionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get gradedAt => $composableBuilder(
    column: $table.gradedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAssessmentResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAssessmentResultsTable> {
  $$LocalAssessmentResultsTableOrderingComposer({
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

  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredQuestions => $composableBuilder(
    column: $table.answeredQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get incorrectAnswers => $composableBuilder(
    column: $table.incorrectAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedQuestions => $composableBuilder(
    column: $table.skippedQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scoreObtained => $composableBuilder(
    column: $table.scoreObtained,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxScore => $composableBuilder(
    column: $table.maxScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOverdue => $composableBuilder(
    column: $table.isOverdue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctionsJson => $composableBuilder(
    column: $table.correctionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get gradedAt => $composableBuilder(
    column: $table.gradedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAssessmentResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAssessmentResultsTable> {
  $$LocalAssessmentResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get assessmentVersionId => $composableBuilder(
    column: $table.assessmentVersionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredQuestions => $composableBuilder(
    column: $table.answeredQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get incorrectAnswers => $composableBuilder(
    column: $table.incorrectAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skippedQuestions => $composableBuilder(
    column: $table.skippedQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scoreObtained => $composableBuilder(
    column: $table.scoreObtained,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxScore =>
      $composableBuilder(column: $table.maxScore, builder: (column) => column);

  GeneratedColumn<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);

  GeneratedColumn<bool> get isOverdue =>
      $composableBuilder(column: $table.isOverdue, builder: (column) => column);

  GeneratedColumn<String> get correctionsJson => $composableBuilder(
    column: $table.correctionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get gradedAt =>
      $composableBuilder(column: $table.gradedAt, builder: (column) => column);
}

class $$LocalAssessmentResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAssessmentResultsTable,
          LocalAssessmentResult,
          $$LocalAssessmentResultsTableFilterComposer,
          $$LocalAssessmentResultsTableOrderingComposer,
          $$LocalAssessmentResultsTableAnnotationComposer,
          $$LocalAssessmentResultsTableCreateCompanionBuilder,
          $$LocalAssessmentResultsTableUpdateCompanionBuilder,
          (
            LocalAssessmentResult,
            BaseReferences<
              _$AppDatabase,
              $LocalAssessmentResultsTable,
              LocalAssessmentResult
            >,
          ),
          LocalAssessmentResult,
          PrefetchHooks Function()
        > {
  $$LocalAssessmentResultsTableTableManager(
    _$AppDatabase db,
    $LocalAssessmentResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssessmentResultsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAssessmentResultsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAssessmentResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> attemptId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> assessmentVersionId = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> answeredQuestions = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> incorrectAnswers = const Value.absent(),
                Value<int> skippedQuestions = const Value.absent(),
                Value<double> scoreObtained = const Value.absent(),
                Value<double> maxScore = const Value.absent(),
                Value<double> percentage = const Value.absent(),
                Value<bool?> passed = const Value.absent(),
                Value<bool> isOverdue = const Value.absent(),
                Value<String?> correctionsJson = const Value.absent(),
                Value<DateTime> gradedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentResultsCompanion(
                id: id,
                attemptId: attemptId,
                studentId: studentId,
                assessmentVersionId: assessmentVersionId,
                totalQuestions: totalQuestions,
                answeredQuestions: answeredQuestions,
                correctAnswers: correctAnswers,
                incorrectAnswers: incorrectAnswers,
                skippedQuestions: skippedQuestions,
                scoreObtained: scoreObtained,
                maxScore: maxScore,
                percentage: percentage,
                passed: passed,
                isOverdue: isOverdue,
                correctionsJson: correctionsJson,
                gradedAt: gradedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String attemptId,
                required String studentId,
                required String assessmentVersionId,
                required int totalQuestions,
                Value<int> answeredQuestions = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> incorrectAnswers = const Value.absent(),
                Value<int> skippedQuestions = const Value.absent(),
                Value<double> scoreObtained = const Value.absent(),
                required double maxScore,
                required double percentage,
                Value<bool?> passed = const Value.absent(),
                Value<bool> isOverdue = const Value.absent(),
                Value<String?> correctionsJson = const Value.absent(),
                Value<DateTime> gradedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssessmentResultsCompanion.insert(
                id: id,
                attemptId: attemptId,
                studentId: studentId,
                assessmentVersionId: assessmentVersionId,
                totalQuestions: totalQuestions,
                answeredQuestions: answeredQuestions,
                correctAnswers: correctAnswers,
                incorrectAnswers: incorrectAnswers,
                skippedQuestions: skippedQuestions,
                scoreObtained: scoreObtained,
                maxScore: maxScore,
                percentage: percentage,
                passed: passed,
                isOverdue: isOverdue,
                correctionsJson: correctionsJson,
                gradedAt: gradedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAssessmentResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAssessmentResultsTable,
      LocalAssessmentResult,
      $$LocalAssessmentResultsTableFilterComposer,
      $$LocalAssessmentResultsTableOrderingComposer,
      $$LocalAssessmentResultsTableAnnotationComposer,
      $$LocalAssessmentResultsTableCreateCompanionBuilder,
      $$LocalAssessmentResultsTableUpdateCompanionBuilder,
      (
        LocalAssessmentResult,
        BaseReferences<
          _$AppDatabase,
          $LocalAssessmentResultsTable,
          LocalAssessmentResult
        >,
      ),
      LocalAssessmentResult,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$ChapterProgressTableTableManager get chapterProgress =>
      $$ChapterProgressTableTableManager(_db, _db.chapterProgress);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$LocalAssessmentsTableTableManager get localAssessments =>
      $$LocalAssessmentsTableTableManager(_db, _db.localAssessments);
  $$LocalAssessmentVersionsTableTableManager get localAssessmentVersions =>
      $$LocalAssessmentVersionsTableTableManager(
        _db,
        _db.localAssessmentVersions,
      );
  $$LocalAssessmentVersionChaptersTableTableManager
  get localAssessmentVersionChapters =>
      $$LocalAssessmentVersionChaptersTableTableManager(
        _db,
        _db.localAssessmentVersionChapters,
      );
  $$LocalQuestionsTableTableManager get localQuestions =>
      $$LocalQuestionsTableTableManager(_db, _db.localQuestions);
  $$LocalQuestionOptionsTableTableManager get localQuestionOptions =>
      $$LocalQuestionOptionsTableTableManager(_db, _db.localQuestionOptions);
  $$LocalAssessmentAttemptsTableTableManager get localAssessmentAttempts =>
      $$LocalAssessmentAttemptsTableTableManager(
        _db,
        _db.localAssessmentAttempts,
      );
  $$LocalAssessmentResultsTableTableManager get localAssessmentResults =>
      $$LocalAssessmentResultsTableTableManager(
        _db,
        _db.localAssessmentResults,
      );
}
