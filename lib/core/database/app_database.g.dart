// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectRecordsTable extends ProjectRecords
    with TableInfo<$ProjectRecordsTable, ProjectRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aspectRatioMeta = const VerificationMeta(
    'aspectRatio',
  );
  @override
  late final GeneratedColumn<String> aspectRatio = GeneratedColumn<String>(
    'aspect_ratio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _framesPerSecondMeta = const VerificationMeta(
    'framesPerSecond',
  );
  @override
  late final GeneratedColumn<int> framesPerSecond = GeneratedColumn<int>(
    'frames_per_second',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backgroundColorMeta = const VerificationMeta(
    'backgroundColor',
  );
  @override
  late final GeneratedColumn<int> backgroundColor = GeneratedColumn<int>(
    'background_color',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentRevisionMeta = const VerificationMeta(
    'currentRevision',
  );
  @override
  late final GeneratedColumn<int> currentRevision = GeneratedColumn<int>(
    'current_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastExportedRevisionMeta =
      const VerificationMeta('lastExportedRevision');
  @override
  late final GeneratedColumn<int> lastExportedRevision = GeneratedColumn<int>(
    'last_exported_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masterVolumeMeta = const VerificationMeta(
    'masterVolume',
  );
  @override
  late final GeneratedColumn<double> masterVolume = GeneratedColumn<double>(
    'master_volume',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _audioMutedMeta = const VerificationMeta(
    'audioMuted',
  );
  @override
  late final GeneratedColumn<bool> audioMuted = GeneratedColumn<bool>(
    'audio_muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("audio_muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    aspectRatio,
    resolution,
    framesPerSecond,
    backgroundColor,
    createdAt,
    updatedAt,
    deletedAt,
    status,
    currentRevision,
    lastExportedRevision,
    masterVolume,
    audioMuted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('aspect_ratio')) {
      context.handle(
        _aspectRatioMeta,
        aspectRatio.isAcceptableOrUnknown(
          data['aspect_ratio']!,
          _aspectRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aspectRatioMeta);
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    } else if (isInserting) {
      context.missing(_resolutionMeta);
    }
    if (data.containsKey('frames_per_second')) {
      context.handle(
        _framesPerSecondMeta,
        framesPerSecond.isAcceptableOrUnknown(
          data['frames_per_second']!,
          _framesPerSecondMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_framesPerSecondMeta);
    }
    if (data.containsKey('background_color')) {
      context.handle(
        _backgroundColorMeta,
        backgroundColor.isAcceptableOrUnknown(
          data['background_color']!,
          _backgroundColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_backgroundColorMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('current_revision')) {
      context.handle(
        _currentRevisionMeta,
        currentRevision.isAcceptableOrUnknown(
          data['current_revision']!,
          _currentRevisionMeta,
        ),
      );
    }
    if (data.containsKey('last_exported_revision')) {
      context.handle(
        _lastExportedRevisionMeta,
        lastExportedRevision.isAcceptableOrUnknown(
          data['last_exported_revision']!,
          _lastExportedRevisionMeta,
        ),
      );
    }
    if (data.containsKey('master_volume')) {
      context.handle(
        _masterVolumeMeta,
        masterVolume.isAcceptableOrUnknown(
          data['master_volume']!,
          _masterVolumeMeta,
        ),
      );
    }
    if (data.containsKey('audio_muted')) {
      context.handle(
        _audioMutedMeta,
        audioMuted.isAcceptableOrUnknown(data['audio_muted']!, _audioMutedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      aspectRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aspect_ratio'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      )!,
      framesPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frames_per_second'],
      )!,
      backgroundColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}background_color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      currentRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_revision'],
      )!,
      lastExportedRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_exported_revision'],
      ),
      masterVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}master_volume'],
      )!,
      audioMuted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}audio_muted'],
      )!,
    );
  }

  @override
  $ProjectRecordsTable createAlias(String alias) {
    return $ProjectRecordsTable(attachedDatabase, alias);
  }
}

class ProjectRecord extends DataClass implements Insertable<ProjectRecord> {
  final String id;
  final String title;
  final String aspectRatio;
  final String resolution;
  final int framesPerSecond;
  final int backgroundColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String status;
  final int currentRevision;
  final int? lastExportedRevision;
  final double masterVolume;
  final bool audioMuted;
  const ProjectRecord({
    required this.id,
    required this.title,
    required this.aspectRatio,
    required this.resolution,
    required this.framesPerSecond,
    required this.backgroundColor,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.status,
    required this.currentRevision,
    this.lastExportedRevision,
    required this.masterVolume,
    required this.audioMuted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['aspect_ratio'] = Variable<String>(aspectRatio);
    map['resolution'] = Variable<String>(resolution);
    map['frames_per_second'] = Variable<int>(framesPerSecond);
    map['background_color'] = Variable<int>(backgroundColor);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['status'] = Variable<String>(status);
    map['current_revision'] = Variable<int>(currentRevision);
    if (!nullToAbsent || lastExportedRevision != null) {
      map['last_exported_revision'] = Variable<int>(lastExportedRevision);
    }
    map['master_volume'] = Variable<double>(masterVolume);
    map['audio_muted'] = Variable<bool>(audioMuted);
    return map;
  }

  ProjectRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProjectRecordsCompanion(
      id: Value(id),
      title: Value(title),
      aspectRatio: Value(aspectRatio),
      resolution: Value(resolution),
      framesPerSecond: Value(framesPerSecond),
      backgroundColor: Value(backgroundColor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      status: Value(status),
      currentRevision: Value(currentRevision),
      lastExportedRevision: lastExportedRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExportedRevision),
      masterVolume: Value(masterVolume),
      audioMuted: Value(audioMuted),
    );
  }

  factory ProjectRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      aspectRatio: serializer.fromJson<String>(json['aspectRatio']),
      resolution: serializer.fromJson<String>(json['resolution']),
      framesPerSecond: serializer.fromJson<int>(json['framesPerSecond']),
      backgroundColor: serializer.fromJson<int>(json['backgroundColor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      status: serializer.fromJson<String>(json['status']),
      currentRevision: serializer.fromJson<int>(json['currentRevision']),
      lastExportedRevision: serializer.fromJson<int?>(
        json['lastExportedRevision'],
      ),
      masterVolume: serializer.fromJson<double>(json['masterVolume']),
      audioMuted: serializer.fromJson<bool>(json['audioMuted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'aspectRatio': serializer.toJson<String>(aspectRatio),
      'resolution': serializer.toJson<String>(resolution),
      'framesPerSecond': serializer.toJson<int>(framesPerSecond),
      'backgroundColor': serializer.toJson<int>(backgroundColor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'status': serializer.toJson<String>(status),
      'currentRevision': serializer.toJson<int>(currentRevision),
      'lastExportedRevision': serializer.toJson<int?>(lastExportedRevision),
      'masterVolume': serializer.toJson<double>(masterVolume),
      'audioMuted': serializer.toJson<bool>(audioMuted),
    };
  }

  ProjectRecord copyWith({
    String? id,
    String? title,
    String? aspectRatio,
    String? resolution,
    int? framesPerSecond,
    int? backgroundColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? status,
    int? currentRevision,
    Value<int?> lastExportedRevision = const Value.absent(),
    double? masterVolume,
    bool? audioMuted,
  }) => ProjectRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    aspectRatio: aspectRatio ?? this.aspectRatio,
    resolution: resolution ?? this.resolution,
    framesPerSecond: framesPerSecond ?? this.framesPerSecond,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    status: status ?? this.status,
    currentRevision: currentRevision ?? this.currentRevision,
    lastExportedRevision: lastExportedRevision.present
        ? lastExportedRevision.value
        : this.lastExportedRevision,
    masterVolume: masterVolume ?? this.masterVolume,
    audioMuted: audioMuted ?? this.audioMuted,
  );
  ProjectRecord copyWithCompanion(ProjectRecordsCompanion data) {
    return ProjectRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      aspectRatio: data.aspectRatio.present
          ? data.aspectRatio.value
          : this.aspectRatio,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      framesPerSecond: data.framesPerSecond.present
          ? data.framesPerSecond.value
          : this.framesPerSecond,
      backgroundColor: data.backgroundColor.present
          ? data.backgroundColor.value
          : this.backgroundColor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      status: data.status.present ? data.status.value : this.status,
      currentRevision: data.currentRevision.present
          ? data.currentRevision.value
          : this.currentRevision,
      lastExportedRevision: data.lastExportedRevision.present
          ? data.lastExportedRevision.value
          : this.lastExportedRevision,
      masterVolume: data.masterVolume.present
          ? data.masterVolume.value
          : this.masterVolume,
      audioMuted: data.audioMuted.present
          ? data.audioMuted.value
          : this.audioMuted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('aspectRatio: $aspectRatio, ')
          ..write('resolution: $resolution, ')
          ..write('framesPerSecond: $framesPerSecond, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('status: $status, ')
          ..write('currentRevision: $currentRevision, ')
          ..write('lastExportedRevision: $lastExportedRevision, ')
          ..write('masterVolume: $masterVolume, ')
          ..write('audioMuted: $audioMuted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    aspectRatio,
    resolution,
    framesPerSecond,
    backgroundColor,
    createdAt,
    updatedAt,
    deletedAt,
    status,
    currentRevision,
    lastExportedRevision,
    masterVolume,
    audioMuted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.aspectRatio == this.aspectRatio &&
          other.resolution == this.resolution &&
          other.framesPerSecond == this.framesPerSecond &&
          other.backgroundColor == this.backgroundColor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.status == this.status &&
          other.currentRevision == this.currentRevision &&
          other.lastExportedRevision == this.lastExportedRevision &&
          other.masterVolume == this.masterVolume &&
          other.audioMuted == this.audioMuted);
}

class ProjectRecordsCompanion extends UpdateCompanion<ProjectRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> aspectRatio;
  final Value<String> resolution;
  final Value<int> framesPerSecond;
  final Value<int> backgroundColor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> status;
  final Value<int> currentRevision;
  final Value<int?> lastExportedRevision;
  final Value<double> masterVolume;
  final Value<bool> audioMuted;
  final Value<int> rowid;
  const ProjectRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.aspectRatio = const Value.absent(),
    this.resolution = const Value.absent(),
    this.framesPerSecond = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.currentRevision = const Value.absent(),
    this.lastExportedRevision = const Value.absent(),
    this.masterVolume = const Value.absent(),
    this.audioMuted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectRecordsCompanion.insert({
    required String id,
    required String title,
    required String aspectRatio,
    required String resolution,
    required int framesPerSecond,
    required int backgroundColor,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String status,
    this.currentRevision = const Value.absent(),
    this.lastExportedRevision = const Value.absent(),
    this.masterVolume = const Value.absent(),
    this.audioMuted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       aspectRatio = Value(aspectRatio),
       resolution = Value(resolution),
       framesPerSecond = Value(framesPerSecond),
       backgroundColor = Value(backgroundColor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       status = Value(status);
  static Insertable<ProjectRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? aspectRatio,
    Expression<String>? resolution,
    Expression<int>? framesPerSecond,
    Expression<int>? backgroundColor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? status,
    Expression<int>? currentRevision,
    Expression<int>? lastExportedRevision,
    Expression<double>? masterVolume,
    Expression<bool>? audioMuted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (aspectRatio != null) 'aspect_ratio': aspectRatio,
      if (resolution != null) 'resolution': resolution,
      if (framesPerSecond != null) 'frames_per_second': framesPerSecond,
      if (backgroundColor != null) 'background_color': backgroundColor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (status != null) 'status': status,
      if (currentRevision != null) 'current_revision': currentRevision,
      if (lastExportedRevision != null)
        'last_exported_revision': lastExportedRevision,
      if (masterVolume != null) 'master_volume': masterVolume,
      if (audioMuted != null) 'audio_muted': audioMuted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? aspectRatio,
    Value<String>? resolution,
    Value<int>? framesPerSecond,
    Value<int>? backgroundColor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? status,
    Value<int>? currentRevision,
    Value<int?>? lastExportedRevision,
    Value<double>? masterVolume,
    Value<bool>? audioMuted,
    Value<int>? rowid,
  }) {
    return ProjectRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      resolution: resolution ?? this.resolution,
      framesPerSecond: framesPerSecond ?? this.framesPerSecond,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      status: status ?? this.status,
      currentRevision: currentRevision ?? this.currentRevision,
      lastExportedRevision: lastExportedRevision ?? this.lastExportedRevision,
      masterVolume: masterVolume ?? this.masterVolume,
      audioMuted: audioMuted ?? this.audioMuted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (aspectRatio.present) {
      map['aspect_ratio'] = Variable<String>(aspectRatio.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (framesPerSecond.present) {
      map['frames_per_second'] = Variable<int>(framesPerSecond.value);
    }
    if (backgroundColor.present) {
      map['background_color'] = Variable<int>(backgroundColor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentRevision.present) {
      map['current_revision'] = Variable<int>(currentRevision.value);
    }
    if (lastExportedRevision.present) {
      map['last_exported_revision'] = Variable<int>(lastExportedRevision.value);
    }
    if (masterVolume.present) {
      map['master_volume'] = Variable<double>(masterVolume.value);
    }
    if (audioMuted.present) {
      map['audio_muted'] = Variable<bool>(audioMuted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('aspectRatio: $aspectRatio, ')
          ..write('resolution: $resolution, ')
          ..write('framesPerSecond: $framesPerSecond, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('status: $status, ')
          ..write('currentRevision: $currentRevision, ')
          ..write('lastExportedRevision: $lastExportedRevision, ')
          ..write('masterVolume: $masterVolume, ')
          ..write('audioMuted: $audioMuted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FrameRecordsTable extends FrameRecords
    with TableInfo<$FrameRecordsTable, FrameRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FrameRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relativeSourcePathMeta =
      const VerificationMeta('relativeSourcePath');
  @override
  late final GeneratedColumn<String> relativeSourcePath =
      GeneratedColumn<String>(
        'relative_source_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
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
  static const VerificationMeta _holdFramesMeta = const VerificationMeta(
    'holdFrames',
  );
  @override
  late final GeneratedColumn<int> holdFrames = GeneratedColumn<int>(
    'hold_frames',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _sourceWidthMeta = const VerificationMeta(
    'sourceWidth',
  );
  @override
  late final GeneratedColumn<int> sourceWidth = GeneratedColumn<int>(
    'source_width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceHeightMeta = const VerificationMeta(
    'sourceHeight',
  );
  @override
  late final GeneratedColumn<int> sourceHeight = GeneratedColumn<int>(
    'source_height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missingMeta = const VerificationMeta(
    'missing',
  );
  @override
  late final GeneratedColumn<bool> missing = GeneratedColumn<bool>(
    'missing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("missing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _adjustmentsJsonMeta = const VerificationMeta(
    'adjustmentsJson',
  );
  @override
  late final GeneratedColumn<String> adjustmentsJson = GeneratedColumn<String>(
    'adjustments_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    relativeSourcePath,
    position,
    holdFrames,
    createdAt,
    sourceWidth,
    sourceHeight,
    missing,
    adjustmentsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'frame_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<FrameRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('relative_source_path')) {
      context.handle(
        _relativeSourcePathMeta,
        relativeSourcePath.isAcceptableOrUnknown(
          data['relative_source_path']!,
          _relativeSourcePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativeSourcePathMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('hold_frames')) {
      context.handle(
        _holdFramesMeta,
        holdFrames.isAcceptableOrUnknown(data['hold_frames']!, _holdFramesMeta),
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
    if (data.containsKey('source_width')) {
      context.handle(
        _sourceWidthMeta,
        sourceWidth.isAcceptableOrUnknown(
          data['source_width']!,
          _sourceWidthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceWidthMeta);
    }
    if (data.containsKey('source_height')) {
      context.handle(
        _sourceHeightMeta,
        sourceHeight.isAcceptableOrUnknown(
          data['source_height']!,
          _sourceHeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceHeightMeta);
    }
    if (data.containsKey('missing')) {
      context.handle(
        _missingMeta,
        missing.isAcceptableOrUnknown(data['missing']!, _missingMeta),
      );
    }
    if (data.containsKey('adjustments_json')) {
      context.handle(
        _adjustmentsJsonMeta,
        adjustmentsJson.isAcceptableOrUnknown(
          data['adjustments_json']!,
          _adjustmentsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FrameRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FrameRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      relativeSourcePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_source_path'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      holdFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hold_frames'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sourceWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_width'],
      )!,
      sourceHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_height'],
      )!,
      missing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}missing'],
      )!,
      adjustmentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustments_json'],
      )!,
    );
  }

  @override
  $FrameRecordsTable createAlias(String alias) {
    return $FrameRecordsTable(attachedDatabase, alias);
  }
}

class FrameRecord extends DataClass implements Insertable<FrameRecord> {
  final String id;
  final String projectId;
  final String relativeSourcePath;
  final int position;
  final int holdFrames;
  final DateTime createdAt;
  final int sourceWidth;
  final int sourceHeight;
  final bool missing;
  final String adjustmentsJson;
  const FrameRecord({
    required this.id,
    required this.projectId,
    required this.relativeSourcePath,
    required this.position,
    required this.holdFrames,
    required this.createdAt,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.missing,
    required this.adjustmentsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['relative_source_path'] = Variable<String>(relativeSourcePath);
    map['position'] = Variable<int>(position);
    map['hold_frames'] = Variable<int>(holdFrames);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['source_width'] = Variable<int>(sourceWidth);
    map['source_height'] = Variable<int>(sourceHeight);
    map['missing'] = Variable<bool>(missing);
    map['adjustments_json'] = Variable<String>(adjustmentsJson);
    return map;
  }

  FrameRecordsCompanion toCompanion(bool nullToAbsent) {
    return FrameRecordsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      relativeSourcePath: Value(relativeSourcePath),
      position: Value(position),
      holdFrames: Value(holdFrames),
      createdAt: Value(createdAt),
      sourceWidth: Value(sourceWidth),
      sourceHeight: Value(sourceHeight),
      missing: Value(missing),
      adjustmentsJson: Value(adjustmentsJson),
    );
  }

  factory FrameRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FrameRecord(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      relativeSourcePath: serializer.fromJson<String>(
        json['relativeSourcePath'],
      ),
      position: serializer.fromJson<int>(json['position']),
      holdFrames: serializer.fromJson<int>(json['holdFrames']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sourceWidth: serializer.fromJson<int>(json['sourceWidth']),
      sourceHeight: serializer.fromJson<int>(json['sourceHeight']),
      missing: serializer.fromJson<bool>(json['missing']),
      adjustmentsJson: serializer.fromJson<String>(json['adjustmentsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'relativeSourcePath': serializer.toJson<String>(relativeSourcePath),
      'position': serializer.toJson<int>(position),
      'holdFrames': serializer.toJson<int>(holdFrames),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sourceWidth': serializer.toJson<int>(sourceWidth),
      'sourceHeight': serializer.toJson<int>(sourceHeight),
      'missing': serializer.toJson<bool>(missing),
      'adjustmentsJson': serializer.toJson<String>(adjustmentsJson),
    };
  }

  FrameRecord copyWith({
    String? id,
    String? projectId,
    String? relativeSourcePath,
    int? position,
    int? holdFrames,
    DateTime? createdAt,
    int? sourceWidth,
    int? sourceHeight,
    bool? missing,
    String? adjustmentsJson,
  }) => FrameRecord(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    relativeSourcePath: relativeSourcePath ?? this.relativeSourcePath,
    position: position ?? this.position,
    holdFrames: holdFrames ?? this.holdFrames,
    createdAt: createdAt ?? this.createdAt,
    sourceWidth: sourceWidth ?? this.sourceWidth,
    sourceHeight: sourceHeight ?? this.sourceHeight,
    missing: missing ?? this.missing,
    adjustmentsJson: adjustmentsJson ?? this.adjustmentsJson,
  );
  FrameRecord copyWithCompanion(FrameRecordsCompanion data) {
    return FrameRecord(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      relativeSourcePath: data.relativeSourcePath.present
          ? data.relativeSourcePath.value
          : this.relativeSourcePath,
      position: data.position.present ? data.position.value : this.position,
      holdFrames: data.holdFrames.present
          ? data.holdFrames.value
          : this.holdFrames,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sourceWidth: data.sourceWidth.present
          ? data.sourceWidth.value
          : this.sourceWidth,
      sourceHeight: data.sourceHeight.present
          ? data.sourceHeight.value
          : this.sourceHeight,
      missing: data.missing.present ? data.missing.value : this.missing,
      adjustmentsJson: data.adjustmentsJson.present
          ? data.adjustmentsJson.value
          : this.adjustmentsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FrameRecord(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('relativeSourcePath: $relativeSourcePath, ')
          ..write('position: $position, ')
          ..write('holdFrames: $holdFrames, ')
          ..write('createdAt: $createdAt, ')
          ..write('sourceWidth: $sourceWidth, ')
          ..write('sourceHeight: $sourceHeight, ')
          ..write('missing: $missing, ')
          ..write('adjustmentsJson: $adjustmentsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    relativeSourcePath,
    position,
    holdFrames,
    createdAt,
    sourceWidth,
    sourceHeight,
    missing,
    adjustmentsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FrameRecord &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.relativeSourcePath == this.relativeSourcePath &&
          other.position == this.position &&
          other.holdFrames == this.holdFrames &&
          other.createdAt == this.createdAt &&
          other.sourceWidth == this.sourceWidth &&
          other.sourceHeight == this.sourceHeight &&
          other.missing == this.missing &&
          other.adjustmentsJson == this.adjustmentsJson);
}

class FrameRecordsCompanion extends UpdateCompanion<FrameRecord> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> relativeSourcePath;
  final Value<int> position;
  final Value<int> holdFrames;
  final Value<DateTime> createdAt;
  final Value<int> sourceWidth;
  final Value<int> sourceHeight;
  final Value<bool> missing;
  final Value<String> adjustmentsJson;
  final Value<int> rowid;
  const FrameRecordsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.relativeSourcePath = const Value.absent(),
    this.position = const Value.absent(),
    this.holdFrames = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sourceWidth = const Value.absent(),
    this.sourceHeight = const Value.absent(),
    this.missing = const Value.absent(),
    this.adjustmentsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FrameRecordsCompanion.insert({
    required String id,
    required String projectId,
    required String relativeSourcePath,
    required int position,
    this.holdFrames = const Value.absent(),
    required DateTime createdAt,
    required int sourceWidth,
    required int sourceHeight,
    this.missing = const Value.absent(),
    this.adjustmentsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       relativeSourcePath = Value(relativeSourcePath),
       position = Value(position),
       createdAt = Value(createdAt),
       sourceWidth = Value(sourceWidth),
       sourceHeight = Value(sourceHeight);
  static Insertable<FrameRecord> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? relativeSourcePath,
    Expression<int>? position,
    Expression<int>? holdFrames,
    Expression<DateTime>? createdAt,
    Expression<int>? sourceWidth,
    Expression<int>? sourceHeight,
    Expression<bool>? missing,
    Expression<String>? adjustmentsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (relativeSourcePath != null)
        'relative_source_path': relativeSourcePath,
      if (position != null) 'position': position,
      if (holdFrames != null) 'hold_frames': holdFrames,
      if (createdAt != null) 'created_at': createdAt,
      if (sourceWidth != null) 'source_width': sourceWidth,
      if (sourceHeight != null) 'source_height': sourceHeight,
      if (missing != null) 'missing': missing,
      if (adjustmentsJson != null) 'adjustments_json': adjustmentsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FrameRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? relativeSourcePath,
    Value<int>? position,
    Value<int>? holdFrames,
    Value<DateTime>? createdAt,
    Value<int>? sourceWidth,
    Value<int>? sourceHeight,
    Value<bool>? missing,
    Value<String>? adjustmentsJson,
    Value<int>? rowid,
  }) {
    return FrameRecordsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      relativeSourcePath: relativeSourcePath ?? this.relativeSourcePath,
      position: position ?? this.position,
      holdFrames: holdFrames ?? this.holdFrames,
      createdAt: createdAt ?? this.createdAt,
      sourceWidth: sourceWidth ?? this.sourceWidth,
      sourceHeight: sourceHeight ?? this.sourceHeight,
      missing: missing ?? this.missing,
      adjustmentsJson: adjustmentsJson ?? this.adjustmentsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (relativeSourcePath.present) {
      map['relative_source_path'] = Variable<String>(relativeSourcePath.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (holdFrames.present) {
      map['hold_frames'] = Variable<int>(holdFrames.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sourceWidth.present) {
      map['source_width'] = Variable<int>(sourceWidth.value);
    }
    if (sourceHeight.present) {
      map['source_height'] = Variable<int>(sourceHeight.value);
    }
    if (missing.present) {
      map['missing'] = Variable<bool>(missing.value);
    }
    if (adjustmentsJson.present) {
      map['adjustments_json'] = Variable<String>(adjustmentsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FrameRecordsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('relativeSourcePath: $relativeSourcePath, ')
          ..write('position: $position, ')
          ..write('holdFrames: $holdFrames, ')
          ..write('createdAt: $createdAt, ')
          ..write('sourceWidth: $sourceWidth, ')
          ..write('sourceHeight: $sourceHeight, ')
          ..write('missing: $missing, ')
          ..write('adjustmentsJson: $adjustmentsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioClipRecordsTable extends AudioClipRecords
    with TableInfo<$AudioClipRecordsTable, AudioClipRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioClipRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relativeSourcePathMeta =
      const VerificationMeta('relativeSourcePath');
  @override
  late final GeneratedColumn<String> relativeSourcePath =
      GeneratedColumn<String>(
        'relative_source_path',
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
  static const VerificationMeta _trackTypeMeta = const VerificationMeta(
    'trackType',
  );
  @override
  late final GeneratedColumn<String> trackType = GeneratedColumn<String>(
    'track_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMillisecondsMeta = const VerificationMeta(
    'startMilliseconds',
  );
  @override
  late final GeneratedColumn<int> startMilliseconds = GeneratedColumn<int>(
    'start_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trimStartMillisecondsMeta =
      const VerificationMeta('trimStartMilliseconds');
  @override
  late final GeneratedColumn<int> trimStartMilliseconds = GeneratedColumn<int>(
    'trim_start_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trimEndMillisecondsMeta =
      const VerificationMeta('trimEndMilliseconds');
  @override
  late final GeneratedColumn<int> trimEndMilliseconds = GeneratedColumn<int>(
    'trim_end_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _fadeInMillisecondsMeta =
      const VerificationMeta('fadeInMilliseconds');
  @override
  late final GeneratedColumn<int> fadeInMilliseconds = GeneratedColumn<int>(
    'fade_in_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fadeOutMillisecondsMeta =
      const VerificationMeta('fadeOutMilliseconds');
  @override
  late final GeneratedColumn<int> fadeOutMilliseconds = GeneratedColumn<int>(
    'fade_out_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<bool> muted = GeneratedColumn<bool>(
    'muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _missingMeta = const VerificationMeta(
    'missing',
  );
  @override
  late final GeneratedColumn<bool> missing = GeneratedColumn<bool>(
    'missing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("missing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    relativeSourcePath,
    name,
    trackType,
    startMilliseconds,
    trimStartMilliseconds,
    trimEndMilliseconds,
    volume,
    fadeInMilliseconds,
    fadeOutMilliseconds,
    muted,
    missing,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_clip_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioClipRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('relative_source_path')) {
      context.handle(
        _relativeSourcePathMeta,
        relativeSourcePath.isAcceptableOrUnknown(
          data['relative_source_path']!,
          _relativeSourcePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativeSourcePathMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('track_type')) {
      context.handle(
        _trackTypeMeta,
        trackType.isAcceptableOrUnknown(data['track_type']!, _trackTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_trackTypeMeta);
    }
    if (data.containsKey('start_milliseconds')) {
      context.handle(
        _startMillisecondsMeta,
        startMilliseconds.isAcceptableOrUnknown(
          data['start_milliseconds']!,
          _startMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMillisecondsMeta);
    }
    if (data.containsKey('trim_start_milliseconds')) {
      context.handle(
        _trimStartMillisecondsMeta,
        trimStartMilliseconds.isAcceptableOrUnknown(
          data['trim_start_milliseconds']!,
          _trimStartMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trimStartMillisecondsMeta);
    }
    if (data.containsKey('trim_end_milliseconds')) {
      context.handle(
        _trimEndMillisecondsMeta,
        trimEndMilliseconds.isAcceptableOrUnknown(
          data['trim_end_milliseconds']!,
          _trimEndMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trimEndMillisecondsMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('fade_in_milliseconds')) {
      context.handle(
        _fadeInMillisecondsMeta,
        fadeInMilliseconds.isAcceptableOrUnknown(
          data['fade_in_milliseconds']!,
          _fadeInMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('fade_out_milliseconds')) {
      context.handle(
        _fadeOutMillisecondsMeta,
        fadeOutMilliseconds.isAcceptableOrUnknown(
          data['fade_out_milliseconds']!,
          _fadeOutMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('muted')) {
      context.handle(
        _mutedMeta,
        muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta),
      );
    }
    if (data.containsKey('missing')) {
      context.handle(
        _missingMeta,
        missing.isAcceptableOrUnknown(data['missing']!, _missingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioClipRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioClipRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      relativeSourcePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_source_path'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      trackType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_type'],
      )!,
      startMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_milliseconds'],
      )!,
      trimStartMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trim_start_milliseconds'],
      )!,
      trimEndMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trim_end_milliseconds'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume'],
      )!,
      fadeInMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fade_in_milliseconds'],
      )!,
      fadeOutMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fade_out_milliseconds'],
      )!,
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}muted'],
      )!,
      missing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}missing'],
      )!,
    );
  }

  @override
  $AudioClipRecordsTable createAlias(String alias) {
    return $AudioClipRecordsTable(attachedDatabase, alias);
  }
}

class AudioClipRecord extends DataClass implements Insertable<AudioClipRecord> {
  final String id;
  final String projectId;
  final String relativeSourcePath;
  final String name;
  final String trackType;
  final int startMilliseconds;
  final int trimStartMilliseconds;
  final int trimEndMilliseconds;
  final double volume;
  final int fadeInMilliseconds;
  final int fadeOutMilliseconds;
  final bool muted;
  final bool missing;
  const AudioClipRecord({
    required this.id,
    required this.projectId,
    required this.relativeSourcePath,
    required this.name,
    required this.trackType,
    required this.startMilliseconds,
    required this.trimStartMilliseconds,
    required this.trimEndMilliseconds,
    required this.volume,
    required this.fadeInMilliseconds,
    required this.fadeOutMilliseconds,
    required this.muted,
    required this.missing,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['relative_source_path'] = Variable<String>(relativeSourcePath);
    map['name'] = Variable<String>(name);
    map['track_type'] = Variable<String>(trackType);
    map['start_milliseconds'] = Variable<int>(startMilliseconds);
    map['trim_start_milliseconds'] = Variable<int>(trimStartMilliseconds);
    map['trim_end_milliseconds'] = Variable<int>(trimEndMilliseconds);
    map['volume'] = Variable<double>(volume);
    map['fade_in_milliseconds'] = Variable<int>(fadeInMilliseconds);
    map['fade_out_milliseconds'] = Variable<int>(fadeOutMilliseconds);
    map['muted'] = Variable<bool>(muted);
    map['missing'] = Variable<bool>(missing);
    return map;
  }

  AudioClipRecordsCompanion toCompanion(bool nullToAbsent) {
    return AudioClipRecordsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      relativeSourcePath: Value(relativeSourcePath),
      name: Value(name),
      trackType: Value(trackType),
      startMilliseconds: Value(startMilliseconds),
      trimStartMilliseconds: Value(trimStartMilliseconds),
      trimEndMilliseconds: Value(trimEndMilliseconds),
      volume: Value(volume),
      fadeInMilliseconds: Value(fadeInMilliseconds),
      fadeOutMilliseconds: Value(fadeOutMilliseconds),
      muted: Value(muted),
      missing: Value(missing),
    );
  }

  factory AudioClipRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioClipRecord(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      relativeSourcePath: serializer.fromJson<String>(
        json['relativeSourcePath'],
      ),
      name: serializer.fromJson<String>(json['name']),
      trackType: serializer.fromJson<String>(json['trackType']),
      startMilliseconds: serializer.fromJson<int>(json['startMilliseconds']),
      trimStartMilliseconds: serializer.fromJson<int>(
        json['trimStartMilliseconds'],
      ),
      trimEndMilliseconds: serializer.fromJson<int>(
        json['trimEndMilliseconds'],
      ),
      volume: serializer.fromJson<double>(json['volume']),
      fadeInMilliseconds: serializer.fromJson<int>(json['fadeInMilliseconds']),
      fadeOutMilliseconds: serializer.fromJson<int>(
        json['fadeOutMilliseconds'],
      ),
      muted: serializer.fromJson<bool>(json['muted']),
      missing: serializer.fromJson<bool>(json['missing']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'relativeSourcePath': serializer.toJson<String>(relativeSourcePath),
      'name': serializer.toJson<String>(name),
      'trackType': serializer.toJson<String>(trackType),
      'startMilliseconds': serializer.toJson<int>(startMilliseconds),
      'trimStartMilliseconds': serializer.toJson<int>(trimStartMilliseconds),
      'trimEndMilliseconds': serializer.toJson<int>(trimEndMilliseconds),
      'volume': serializer.toJson<double>(volume),
      'fadeInMilliseconds': serializer.toJson<int>(fadeInMilliseconds),
      'fadeOutMilliseconds': serializer.toJson<int>(fadeOutMilliseconds),
      'muted': serializer.toJson<bool>(muted),
      'missing': serializer.toJson<bool>(missing),
    };
  }

  AudioClipRecord copyWith({
    String? id,
    String? projectId,
    String? relativeSourcePath,
    String? name,
    String? trackType,
    int? startMilliseconds,
    int? trimStartMilliseconds,
    int? trimEndMilliseconds,
    double? volume,
    int? fadeInMilliseconds,
    int? fadeOutMilliseconds,
    bool? muted,
    bool? missing,
  }) => AudioClipRecord(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    relativeSourcePath: relativeSourcePath ?? this.relativeSourcePath,
    name: name ?? this.name,
    trackType: trackType ?? this.trackType,
    startMilliseconds: startMilliseconds ?? this.startMilliseconds,
    trimStartMilliseconds: trimStartMilliseconds ?? this.trimStartMilliseconds,
    trimEndMilliseconds: trimEndMilliseconds ?? this.trimEndMilliseconds,
    volume: volume ?? this.volume,
    fadeInMilliseconds: fadeInMilliseconds ?? this.fadeInMilliseconds,
    fadeOutMilliseconds: fadeOutMilliseconds ?? this.fadeOutMilliseconds,
    muted: muted ?? this.muted,
    missing: missing ?? this.missing,
  );
  AudioClipRecord copyWithCompanion(AudioClipRecordsCompanion data) {
    return AudioClipRecord(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      relativeSourcePath: data.relativeSourcePath.present
          ? data.relativeSourcePath.value
          : this.relativeSourcePath,
      name: data.name.present ? data.name.value : this.name,
      trackType: data.trackType.present ? data.trackType.value : this.trackType,
      startMilliseconds: data.startMilliseconds.present
          ? data.startMilliseconds.value
          : this.startMilliseconds,
      trimStartMilliseconds: data.trimStartMilliseconds.present
          ? data.trimStartMilliseconds.value
          : this.trimStartMilliseconds,
      trimEndMilliseconds: data.trimEndMilliseconds.present
          ? data.trimEndMilliseconds.value
          : this.trimEndMilliseconds,
      volume: data.volume.present ? data.volume.value : this.volume,
      fadeInMilliseconds: data.fadeInMilliseconds.present
          ? data.fadeInMilliseconds.value
          : this.fadeInMilliseconds,
      fadeOutMilliseconds: data.fadeOutMilliseconds.present
          ? data.fadeOutMilliseconds.value
          : this.fadeOutMilliseconds,
      muted: data.muted.present ? data.muted.value : this.muted,
      missing: data.missing.present ? data.missing.value : this.missing,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioClipRecord(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('relativeSourcePath: $relativeSourcePath, ')
          ..write('name: $name, ')
          ..write('trackType: $trackType, ')
          ..write('startMilliseconds: $startMilliseconds, ')
          ..write('trimStartMilliseconds: $trimStartMilliseconds, ')
          ..write('trimEndMilliseconds: $trimEndMilliseconds, ')
          ..write('volume: $volume, ')
          ..write('fadeInMilliseconds: $fadeInMilliseconds, ')
          ..write('fadeOutMilliseconds: $fadeOutMilliseconds, ')
          ..write('muted: $muted, ')
          ..write('missing: $missing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    relativeSourcePath,
    name,
    trackType,
    startMilliseconds,
    trimStartMilliseconds,
    trimEndMilliseconds,
    volume,
    fadeInMilliseconds,
    fadeOutMilliseconds,
    muted,
    missing,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioClipRecord &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.relativeSourcePath == this.relativeSourcePath &&
          other.name == this.name &&
          other.trackType == this.trackType &&
          other.startMilliseconds == this.startMilliseconds &&
          other.trimStartMilliseconds == this.trimStartMilliseconds &&
          other.trimEndMilliseconds == this.trimEndMilliseconds &&
          other.volume == this.volume &&
          other.fadeInMilliseconds == this.fadeInMilliseconds &&
          other.fadeOutMilliseconds == this.fadeOutMilliseconds &&
          other.muted == this.muted &&
          other.missing == this.missing);
}

class AudioClipRecordsCompanion extends UpdateCompanion<AudioClipRecord> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> relativeSourcePath;
  final Value<String> name;
  final Value<String> trackType;
  final Value<int> startMilliseconds;
  final Value<int> trimStartMilliseconds;
  final Value<int> trimEndMilliseconds;
  final Value<double> volume;
  final Value<int> fadeInMilliseconds;
  final Value<int> fadeOutMilliseconds;
  final Value<bool> muted;
  final Value<bool> missing;
  final Value<int> rowid;
  const AudioClipRecordsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.relativeSourcePath = const Value.absent(),
    this.name = const Value.absent(),
    this.trackType = const Value.absent(),
    this.startMilliseconds = const Value.absent(),
    this.trimStartMilliseconds = const Value.absent(),
    this.trimEndMilliseconds = const Value.absent(),
    this.volume = const Value.absent(),
    this.fadeInMilliseconds = const Value.absent(),
    this.fadeOutMilliseconds = const Value.absent(),
    this.muted = const Value.absent(),
    this.missing = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioClipRecordsCompanion.insert({
    required String id,
    required String projectId,
    required String relativeSourcePath,
    required String name,
    required String trackType,
    required int startMilliseconds,
    required int trimStartMilliseconds,
    required int trimEndMilliseconds,
    this.volume = const Value.absent(),
    this.fadeInMilliseconds = const Value.absent(),
    this.fadeOutMilliseconds = const Value.absent(),
    this.muted = const Value.absent(),
    this.missing = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       relativeSourcePath = Value(relativeSourcePath),
       name = Value(name),
       trackType = Value(trackType),
       startMilliseconds = Value(startMilliseconds),
       trimStartMilliseconds = Value(trimStartMilliseconds),
       trimEndMilliseconds = Value(trimEndMilliseconds);
  static Insertable<AudioClipRecord> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? relativeSourcePath,
    Expression<String>? name,
    Expression<String>? trackType,
    Expression<int>? startMilliseconds,
    Expression<int>? trimStartMilliseconds,
    Expression<int>? trimEndMilliseconds,
    Expression<double>? volume,
    Expression<int>? fadeInMilliseconds,
    Expression<int>? fadeOutMilliseconds,
    Expression<bool>? muted,
    Expression<bool>? missing,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (relativeSourcePath != null)
        'relative_source_path': relativeSourcePath,
      if (name != null) 'name': name,
      if (trackType != null) 'track_type': trackType,
      if (startMilliseconds != null) 'start_milliseconds': startMilliseconds,
      if (trimStartMilliseconds != null)
        'trim_start_milliseconds': trimStartMilliseconds,
      if (trimEndMilliseconds != null)
        'trim_end_milliseconds': trimEndMilliseconds,
      if (volume != null) 'volume': volume,
      if (fadeInMilliseconds != null)
        'fade_in_milliseconds': fadeInMilliseconds,
      if (fadeOutMilliseconds != null)
        'fade_out_milliseconds': fadeOutMilliseconds,
      if (muted != null) 'muted': muted,
      if (missing != null) 'missing': missing,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioClipRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? relativeSourcePath,
    Value<String>? name,
    Value<String>? trackType,
    Value<int>? startMilliseconds,
    Value<int>? trimStartMilliseconds,
    Value<int>? trimEndMilliseconds,
    Value<double>? volume,
    Value<int>? fadeInMilliseconds,
    Value<int>? fadeOutMilliseconds,
    Value<bool>? muted,
    Value<bool>? missing,
    Value<int>? rowid,
  }) {
    return AudioClipRecordsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      relativeSourcePath: relativeSourcePath ?? this.relativeSourcePath,
      name: name ?? this.name,
      trackType: trackType ?? this.trackType,
      startMilliseconds: startMilliseconds ?? this.startMilliseconds,
      trimStartMilliseconds:
          trimStartMilliseconds ?? this.trimStartMilliseconds,
      trimEndMilliseconds: trimEndMilliseconds ?? this.trimEndMilliseconds,
      volume: volume ?? this.volume,
      fadeInMilliseconds: fadeInMilliseconds ?? this.fadeInMilliseconds,
      fadeOutMilliseconds: fadeOutMilliseconds ?? this.fadeOutMilliseconds,
      muted: muted ?? this.muted,
      missing: missing ?? this.missing,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (relativeSourcePath.present) {
      map['relative_source_path'] = Variable<String>(relativeSourcePath.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (trackType.present) {
      map['track_type'] = Variable<String>(trackType.value);
    }
    if (startMilliseconds.present) {
      map['start_milliseconds'] = Variable<int>(startMilliseconds.value);
    }
    if (trimStartMilliseconds.present) {
      map['trim_start_milliseconds'] = Variable<int>(
        trimStartMilliseconds.value,
      );
    }
    if (trimEndMilliseconds.present) {
      map['trim_end_milliseconds'] = Variable<int>(trimEndMilliseconds.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (fadeInMilliseconds.present) {
      map['fade_in_milliseconds'] = Variable<int>(fadeInMilliseconds.value);
    }
    if (fadeOutMilliseconds.present) {
      map['fade_out_milliseconds'] = Variable<int>(fadeOutMilliseconds.value);
    }
    if (muted.present) {
      map['muted'] = Variable<bool>(muted.value);
    }
    if (missing.present) {
      map['missing'] = Variable<bool>(missing.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioClipRecordsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('relativeSourcePath: $relativeSourcePath, ')
          ..write('name: $name, ')
          ..write('trackType: $trackType, ')
          ..write('startMilliseconds: $startMilliseconds, ')
          ..write('trimStartMilliseconds: $trimStartMilliseconds, ')
          ..write('trimEndMilliseconds: $trimEndMilliseconds, ')
          ..write('volume: $volume, ')
          ..write('fadeInMilliseconds: $fadeInMilliseconds, ')
          ..write('fadeOutMilliseconds: $fadeOutMilliseconds, ')
          ..write('muted: $muted, ')
          ..write('missing: $missing, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportRecordsTable extends ExportRecords
    with TableInfo<$ExportRecordsTable, ExportRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES project_records (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
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
  static const VerificationMeta _relativeOutputPathMeta =
      const VerificationMeta('relativeOutputPath');
  @override
  late final GeneratedColumn<String> relativeOutputPath =
      GeneratedColumn<String>(
        'relative_output_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    format,
    status,
    revision,
    createdAt,
    relativeOutputPath,
    errorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('relative_output_path')) {
      context.handle(
        _relativeOutputPathMeta,
        relativeOutputPath.isAcceptableOrUnknown(
          data['relative_output_path']!,
          _relativeOutputPathMeta,
        ),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      relativeOutputPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_output_path'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
    );
  }

  @override
  $ExportRecordsTable createAlias(String alias) {
    return $ExportRecordsTable(attachedDatabase, alias);
  }
}

class ExportRecord extends DataClass implements Insertable<ExportRecord> {
  final String id;
  final String projectId;
  final String format;
  final String status;
  final int revision;
  final DateTime createdAt;
  final String? relativeOutputPath;
  final String? errorCode;
  const ExportRecord({
    required this.id,
    required this.projectId,
    required this.format,
    required this.status,
    required this.revision,
    required this.createdAt,
    this.relativeOutputPath,
    this.errorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['format'] = Variable<String>(format);
    map['status'] = Variable<String>(status);
    map['revision'] = Variable<int>(revision);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || relativeOutputPath != null) {
      map['relative_output_path'] = Variable<String>(relativeOutputPath);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    return map;
  }

  ExportRecordsCompanion toCompanion(bool nullToAbsent) {
    return ExportRecordsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      format: Value(format),
      status: Value(status),
      revision: Value(revision),
      createdAt: Value(createdAt),
      relativeOutputPath: relativeOutputPath == null && nullToAbsent
          ? const Value.absent()
          : Value(relativeOutputPath),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
    );
  }

  factory ExportRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportRecord(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      format: serializer.fromJson<String>(json['format']),
      status: serializer.fromJson<String>(json['status']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      relativeOutputPath: serializer.fromJson<String?>(
        json['relativeOutputPath'],
      ),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'format': serializer.toJson<String>(format),
      'status': serializer.toJson<String>(status),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'relativeOutputPath': serializer.toJson<String?>(relativeOutputPath),
      'errorCode': serializer.toJson<String?>(errorCode),
    };
  }

  ExportRecord copyWith({
    String? id,
    String? projectId,
    String? format,
    String? status,
    int? revision,
    DateTime? createdAt,
    Value<String?> relativeOutputPath = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
  }) => ExportRecord(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    format: format ?? this.format,
    status: status ?? this.status,
    revision: revision ?? this.revision,
    createdAt: createdAt ?? this.createdAt,
    relativeOutputPath: relativeOutputPath.present
        ? relativeOutputPath.value
        : this.relativeOutputPath,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
  );
  ExportRecord copyWithCompanion(ExportRecordsCompanion data) {
    return ExportRecord(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      format: data.format.present ? data.format.value : this.format,
      status: data.status.present ? data.status.value : this.status,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      relativeOutputPath: data.relativeOutputPath.present
          ? data.relativeOutputPath.value
          : this.relativeOutputPath,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportRecord(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('relativeOutputPath: $relativeOutputPath, ')
          ..write('errorCode: $errorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    format,
    status,
    revision,
    createdAt,
    relativeOutputPath,
    errorCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportRecord &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.format == this.format &&
          other.status == this.status &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.relativeOutputPath == this.relativeOutputPath &&
          other.errorCode == this.errorCode);
}

class ExportRecordsCompanion extends UpdateCompanion<ExportRecord> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> format;
  final Value<String> status;
  final Value<int> revision;
  final Value<DateTime> createdAt;
  final Value<String?> relativeOutputPath;
  final Value<String?> errorCode;
  final Value<int> rowid;
  const ExportRecordsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.relativeOutputPath = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportRecordsCompanion.insert({
    required String id,
    required String projectId,
    required String format,
    required String status,
    required int revision,
    required DateTime createdAt,
    this.relativeOutputPath = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       format = Value(format),
       status = Value(status),
       revision = Value(revision),
       createdAt = Value(createdAt);
  static Insertable<ExportRecord> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? format,
    Expression<String>? status,
    Expression<int>? revision,
    Expression<DateTime>? createdAt,
    Expression<String>? relativeOutputPath,
    Expression<String>? errorCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (format != null) 'format': format,
      if (status != null) 'status': status,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (relativeOutputPath != null)
        'relative_output_path': relativeOutputPath,
      if (errorCode != null) 'error_code': errorCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? format,
    Value<String>? status,
    Value<int>? revision,
    Value<DateTime>? createdAt,
    Value<String?>? relativeOutputPath,
    Value<String?>? errorCode,
    Value<int>? rowid,
  }) {
    return ExportRecordsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      format: format ?? this.format,
      status: status ?? this.status,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      relativeOutputPath: relativeOutputPath ?? this.relativeOutputPath,
      errorCode: errorCode ?? this.errorCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (relativeOutputPath.present) {
      map['relative_output_path'] = Variable<String>(relativeOutputPath.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportRecordsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('relativeOutputPath: $relativeOutputPath, ')
          ..write('errorCode: $errorCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperationJournalsTable extends OperationJournals
    with TableInfo<$OperationJournalsTable, OperationJournal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationJournalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationProjectIdMeta =
      const VerificationMeta('destinationProjectId');
  @override
  late final GeneratedColumn<String> destinationProjectId =
      GeneratedColumn<String>(
        'destination_project_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _temporaryPathMeta = const VerificationMeta(
    'temporaryPath',
  );
  @override
  late final GeneratedColumn<String> temporaryPath = GeneratedColumn<String>(
    'temporary_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalPathMeta = const VerificationMeta(
    'finalPath',
  );
  @override
  late final GeneratedColumn<String> finalPath = GeneratedColumn<String>(
    'final_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    state,
    projectId,
    destinationProjectId,
    temporaryPath,
    finalPath,
    errorCode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operation_journals';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationJournal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('destination_project_id')) {
      context.handle(
        _destinationProjectIdMeta,
        destinationProjectId.isAcceptableOrUnknown(
          data['destination_project_id']!,
          _destinationProjectIdMeta,
        ),
      );
    }
    if (data.containsKey('temporary_path')) {
      context.handle(
        _temporaryPathMeta,
        temporaryPath.isAcceptableOrUnknown(
          data['temporary_path']!,
          _temporaryPathMeta,
        ),
      );
    }
    if (data.containsKey('final_path')) {
      context.handle(
        _finalPathMeta,
        finalPath.isAcceptableOrUnknown(data['final_path']!, _finalPathMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperationJournal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationJournal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      destinationProjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_project_id'],
      ),
      temporaryPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temporary_path'],
      ),
      finalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_path'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OperationJournalsTable createAlias(String alias) {
    return $OperationJournalsTable(attachedDatabase, alias);
  }
}

class OperationJournal extends DataClass
    implements Insertable<OperationJournal> {
  final String id;
  final String type;
  final String state;
  final String projectId;
  final String? destinationProjectId;
  final String? temporaryPath;
  final String? finalPath;
  final String? errorCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OperationJournal({
    required this.id,
    required this.type,
    required this.state,
    required this.projectId,
    this.destinationProjectId,
    this.temporaryPath,
    this.finalPath,
    this.errorCode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['state'] = Variable<String>(state);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || destinationProjectId != null) {
      map['destination_project_id'] = Variable<String>(destinationProjectId);
    }
    if (!nullToAbsent || temporaryPath != null) {
      map['temporary_path'] = Variable<String>(temporaryPath);
    }
    if (!nullToAbsent || finalPath != null) {
      map['final_path'] = Variable<String>(finalPath);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OperationJournalsCompanion toCompanion(bool nullToAbsent) {
    return OperationJournalsCompanion(
      id: Value(id),
      type: Value(type),
      state: Value(state),
      projectId: Value(projectId),
      destinationProjectId: destinationProjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationProjectId),
      temporaryPath: temporaryPath == null && nullToAbsent
          ? const Value.absent()
          : Value(temporaryPath),
      finalPath: finalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(finalPath),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OperationJournal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationJournal(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      state: serializer.fromJson<String>(json['state']),
      projectId: serializer.fromJson<String>(json['projectId']),
      destinationProjectId: serializer.fromJson<String?>(
        json['destinationProjectId'],
      ),
      temporaryPath: serializer.fromJson<String?>(json['temporaryPath']),
      finalPath: serializer.fromJson<String?>(json['finalPath']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'state': serializer.toJson<String>(state),
      'projectId': serializer.toJson<String>(projectId),
      'destinationProjectId': serializer.toJson<String?>(destinationProjectId),
      'temporaryPath': serializer.toJson<String?>(temporaryPath),
      'finalPath': serializer.toJson<String?>(finalPath),
      'errorCode': serializer.toJson<String?>(errorCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OperationJournal copyWith({
    String? id,
    String? type,
    String? state,
    String? projectId,
    Value<String?> destinationProjectId = const Value.absent(),
    Value<String?> temporaryPath = const Value.absent(),
    Value<String?> finalPath = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OperationJournal(
    id: id ?? this.id,
    type: type ?? this.type,
    state: state ?? this.state,
    projectId: projectId ?? this.projectId,
    destinationProjectId: destinationProjectId.present
        ? destinationProjectId.value
        : this.destinationProjectId,
    temporaryPath: temporaryPath.present
        ? temporaryPath.value
        : this.temporaryPath,
    finalPath: finalPath.present ? finalPath.value : this.finalPath,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OperationJournal copyWithCompanion(OperationJournalsCompanion data) {
    return OperationJournal(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      state: data.state.present ? data.state.value : this.state,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      destinationProjectId: data.destinationProjectId.present
          ? data.destinationProjectId.value
          : this.destinationProjectId,
      temporaryPath: data.temporaryPath.present
          ? data.temporaryPath.value
          : this.temporaryPath,
      finalPath: data.finalPath.present ? data.finalPath.value : this.finalPath,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationJournal(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('state: $state, ')
          ..write('projectId: $projectId, ')
          ..write('destinationProjectId: $destinationProjectId, ')
          ..write('temporaryPath: $temporaryPath, ')
          ..write('finalPath: $finalPath, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    state,
    projectId,
    destinationProjectId,
    temporaryPath,
    finalPath,
    errorCode,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationJournal &&
          other.id == this.id &&
          other.type == this.type &&
          other.state == this.state &&
          other.projectId == this.projectId &&
          other.destinationProjectId == this.destinationProjectId &&
          other.temporaryPath == this.temporaryPath &&
          other.finalPath == this.finalPath &&
          other.errorCode == this.errorCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OperationJournalsCompanion extends UpdateCompanion<OperationJournal> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> state;
  final Value<String> projectId;
  final Value<String?> destinationProjectId;
  final Value<String?> temporaryPath;
  final Value<String?> finalPath;
  final Value<String?> errorCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OperationJournalsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.state = const Value.absent(),
    this.projectId = const Value.absent(),
    this.destinationProjectId = const Value.absent(),
    this.temporaryPath = const Value.absent(),
    this.finalPath = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationJournalsCompanion.insert({
    required String id,
    required String type,
    required String state,
    required String projectId,
    this.destinationProjectId = const Value.absent(),
    this.temporaryPath = const Value.absent(),
    this.finalPath = const Value.absent(),
    this.errorCode = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       state = Value(state),
       projectId = Value(projectId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OperationJournal> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? state,
    Expression<String>? projectId,
    Expression<String>? destinationProjectId,
    Expression<String>? temporaryPath,
    Expression<String>? finalPath,
    Expression<String>? errorCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (state != null) 'state': state,
      if (projectId != null) 'project_id': projectId,
      if (destinationProjectId != null)
        'destination_project_id': destinationProjectId,
      if (temporaryPath != null) 'temporary_path': temporaryPath,
      if (finalPath != null) 'final_path': finalPath,
      if (errorCode != null) 'error_code': errorCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationJournalsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? state,
    Value<String>? projectId,
    Value<String?>? destinationProjectId,
    Value<String?>? temporaryPath,
    Value<String?>? finalPath,
    Value<String?>? errorCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OperationJournalsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      state: state ?? this.state,
      projectId: projectId ?? this.projectId,
      destinationProjectId: destinationProjectId ?? this.destinationProjectId,
      temporaryPath: temporaryPath ?? this.temporaryPath,
      finalPath: finalPath ?? this.finalPath,
      errorCode: errorCode ?? this.errorCode,
      createdAt: createdAt ?? this.createdAt,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (destinationProjectId.present) {
      map['destination_project_id'] = Variable<String>(
        destinationProjectId.value,
      );
    }
    if (temporaryPath.present) {
      map['temporary_path'] = Variable<String>(temporaryPath.value);
    }
    if (finalPath.present) {
      map['final_path'] = Variable<String>(finalPath.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('OperationJournalsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('state: $state, ')
          ..write('projectId: $projectId, ')
          ..write('destinationProjectId: $destinationProjectId, ')
          ..write('temporaryPath: $temporaryPath, ')
          ..write('finalPath: $finalPath, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectRecordsTable projectRecords = $ProjectRecordsTable(this);
  late final $FrameRecordsTable frameRecords = $FrameRecordsTable(this);
  late final $AudioClipRecordsTable audioClipRecords = $AudioClipRecordsTable(
    this,
  );
  late final $ExportRecordsTable exportRecords = $ExportRecordsTable(this);
  late final $OperationJournalsTable operationJournals =
      $OperationJournalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projectRecords,
    frameRecords,
    audioClipRecords,
    exportRecords,
    operationJournals,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'project_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('frame_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'project_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('audio_clip_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'project_records',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('export_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProjectRecordsTableCreateCompanionBuilder =
    ProjectRecordsCompanion Function({
      required String id,
      required String title,
      required String aspectRatio,
      required String resolution,
      required int framesPerSecond,
      required int backgroundColor,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String status,
      Value<int> currentRevision,
      Value<int?> lastExportedRevision,
      Value<double> masterVolume,
      Value<bool> audioMuted,
      Value<int> rowid,
    });
typedef $$ProjectRecordsTableUpdateCompanionBuilder =
    ProjectRecordsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> aspectRatio,
      Value<String> resolution,
      Value<int> framesPerSecond,
      Value<int> backgroundColor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> status,
      Value<int> currentRevision,
      Value<int?> lastExportedRevision,
      Value<double> masterVolume,
      Value<bool> audioMuted,
      Value<int> rowid,
    });

final class $$ProjectRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectRecordsTable, ProjectRecord> {
  $$ProjectRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$FrameRecordsTable, List<FrameRecord>>
  _frameRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.frameRecords,
    aliasName: 'project_records__id__frame_records__project_id',
  );

  $$FrameRecordsTableProcessedTableManager get frameRecordsRefs {
    final manager = $$FrameRecordsTableTableManager(
      $_db,
      $_db.frameRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_frameRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AudioClipRecordsTable, List<AudioClipRecord>>
  _audioClipRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.audioClipRecords,
    aliasName: 'project_records__id__audio_clip_records__project_id',
  );

  $$AudioClipRecordsTableProcessedTableManager get audioClipRecordsRefs {
    final manager = $$AudioClipRecordsTableTableManager(
      $_db,
      $_db.audioClipRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _audioClipRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExportRecordsTable, List<ExportRecord>>
  _exportRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exportRecords,
    aliasName: 'project_records__id__export_records__project_id',
  );

  $$ExportRecordsTableProcessedTableManager get exportRecordsRefs {
    final manager = $$ExportRecordsTableTableManager(
      $_db,
      $_db.exportRecords,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exportRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectRecordsTable> {
  $$ProjectRecordsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get framesPerSecond => $composableBuilder(
    column: $table.framesPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentRevision => $composableBuilder(
    column: $table.currentRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastExportedRevision => $composableBuilder(
    column: $table.lastExportedRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get masterVolume => $composableBuilder(
    column: $table.masterVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get audioMuted => $composableBuilder(
    column: $table.audioMuted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> frameRecordsRefs(
    Expression<bool> Function($$FrameRecordsTableFilterComposer f) f,
  ) {
    final $$FrameRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.frameRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FrameRecordsTableFilterComposer(
            $db: $db,
            $table: $db.frameRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> audioClipRecordsRefs(
    Expression<bool> Function($$AudioClipRecordsTableFilterComposer f) f,
  ) {
    final $$AudioClipRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioClipRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioClipRecordsTableFilterComposer(
            $db: $db,
            $table: $db.audioClipRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exportRecordsRefs(
    Expression<bool> Function($$ExportRecordsTableFilterComposer f) f,
  ) {
    final $$ExportRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportRecordsTableFilterComposer(
            $db: $db,
            $table: $db.exportRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectRecordsTable> {
  $$ProjectRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get framesPerSecond => $composableBuilder(
    column: $table.framesPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentRevision => $composableBuilder(
    column: $table.currentRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastExportedRevision => $composableBuilder(
    column: $table.lastExportedRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get masterVolume => $composableBuilder(
    column: $table.masterVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get audioMuted => $composableBuilder(
    column: $table.audioMuted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectRecordsTable> {
  $$ProjectRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get aspectRatio => $composableBuilder(
    column: $table.aspectRatio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get framesPerSecond => $composableBuilder(
    column: $table.framesPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<int> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get currentRevision => $composableBuilder(
    column: $table.currentRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastExportedRevision => $composableBuilder(
    column: $table.lastExportedRevision,
    builder: (column) => column,
  );

  GeneratedColumn<double> get masterVolume => $composableBuilder(
    column: $table.masterVolume,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get audioMuted => $composableBuilder(
    column: $table.audioMuted,
    builder: (column) => column,
  );

  Expression<T> frameRecordsRefs<T extends Object>(
    Expression<T> Function($$FrameRecordsTableAnnotationComposer a) f,
  ) {
    final $$FrameRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.frameRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FrameRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.frameRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> audioClipRecordsRefs<T extends Object>(
    Expression<T> Function($$AudioClipRecordsTableAnnotationComposer a) f,
  ) {
    final $$AudioClipRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioClipRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioClipRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioClipRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exportRecordsRefs<T extends Object>(
    Expression<T> Function($$ExportRecordsTableAnnotationComposer a) f,
  ) {
    final $$ExportRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportRecords,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.exportRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectRecordsTable,
          ProjectRecord,
          $$ProjectRecordsTableFilterComposer,
          $$ProjectRecordsTableOrderingComposer,
          $$ProjectRecordsTableAnnotationComposer,
          $$ProjectRecordsTableCreateCompanionBuilder,
          $$ProjectRecordsTableUpdateCompanionBuilder,
          (ProjectRecord, $$ProjectRecordsTableReferences),
          ProjectRecord,
          PrefetchHooks Function({
            bool frameRecordsRefs,
            bool audioClipRecordsRefs,
            bool exportRecordsRefs,
          })
        > {
  $$ProjectRecordsTableTableManager(
    _$AppDatabase db,
    $ProjectRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> aspectRatio = const Value.absent(),
                Value<String> resolution = const Value.absent(),
                Value<int> framesPerSecond = const Value.absent(),
                Value<int> backgroundColor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> currentRevision = const Value.absent(),
                Value<int?> lastExportedRevision = const Value.absent(),
                Value<double> masterVolume = const Value.absent(),
                Value<bool> audioMuted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectRecordsCompanion(
                id: id,
                title: title,
                aspectRatio: aspectRatio,
                resolution: resolution,
                framesPerSecond: framesPerSecond,
                backgroundColor: backgroundColor,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                status: status,
                currentRevision: currentRevision,
                lastExportedRevision: lastExportedRevision,
                masterVolume: masterVolume,
                audioMuted: audioMuted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String aspectRatio,
                required String resolution,
                required int framesPerSecond,
                required int backgroundColor,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String status,
                Value<int> currentRevision = const Value.absent(),
                Value<int?> lastExportedRevision = const Value.absent(),
                Value<double> masterVolume = const Value.absent(),
                Value<bool> audioMuted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectRecordsCompanion.insert(
                id: id,
                title: title,
                aspectRatio: aspectRatio,
                resolution: resolution,
                framesPerSecond: framesPerSecond,
                backgroundColor: backgroundColor,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                status: status,
                currentRevision: currentRevision,
                lastExportedRevision: lastExportedRevision,
                masterVolume: masterVolume,
                audioMuted: audioMuted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                frameRecordsRefs = false,
                audioClipRecordsRefs = false,
                exportRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (frameRecordsRefs) db.frameRecords,
                    if (audioClipRecordsRefs) db.audioClipRecords,
                    if (exportRecordsRefs) db.exportRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (frameRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          FrameRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._frameRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).frameRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (audioClipRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          AudioClipRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._audioClipRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).audioClipRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exportRecordsRefs)
                        await $_getPrefetchedData<
                          ProjectRecord,
                          $ProjectRecordsTable,
                          ExportRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectRecordsTableReferences
                              ._exportRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).exportRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
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

typedef $$ProjectRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectRecordsTable,
      ProjectRecord,
      $$ProjectRecordsTableFilterComposer,
      $$ProjectRecordsTableOrderingComposer,
      $$ProjectRecordsTableAnnotationComposer,
      $$ProjectRecordsTableCreateCompanionBuilder,
      $$ProjectRecordsTableUpdateCompanionBuilder,
      (ProjectRecord, $$ProjectRecordsTableReferences),
      ProjectRecord,
      PrefetchHooks Function({
        bool frameRecordsRefs,
        bool audioClipRecordsRefs,
        bool exportRecordsRefs,
      })
    >;
typedef $$FrameRecordsTableCreateCompanionBuilder =
    FrameRecordsCompanion Function({
      required String id,
      required String projectId,
      required String relativeSourcePath,
      required int position,
      Value<int> holdFrames,
      required DateTime createdAt,
      required int sourceWidth,
      required int sourceHeight,
      Value<bool> missing,
      Value<String> adjustmentsJson,
      Value<int> rowid,
    });
typedef $$FrameRecordsTableUpdateCompanionBuilder =
    FrameRecordsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> relativeSourcePath,
      Value<int> position,
      Value<int> holdFrames,
      Value<DateTime> createdAt,
      Value<int> sourceWidth,
      Value<int> sourceHeight,
      Value<bool> missing,
      Value<String> adjustmentsJson,
      Value<int> rowid,
    });

final class $$FrameRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $FrameRecordsTable, FrameRecord> {
  $$FrameRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) => db
      .projectRecords
      .createAlias('frame_records__project_id__project_records__id');

  $$ProjectRecordsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectRecordsTableTableManager(
      $_db,
      $_db.projectRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FrameRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FrameRecordsTable> {
  $$FrameRecordsTableFilterComposer({
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

  ColumnFilters<String> get relativeSourcePath => $composableBuilder(
    column: $table.relativeSourcePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get holdFrames => $composableBuilder(
    column: $table.holdFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceWidth => $composableBuilder(
    column: $table.sourceWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceHeight => $composableBuilder(
    column: $table.sourceHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get missing => $composableBuilder(
    column: $table.missing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjustmentsJson => $composableBuilder(
    column: $table.adjustmentsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectRecordsTableFilterComposer get projectId {
    final $$ProjectRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableFilterComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FrameRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FrameRecordsTable> {
  $$FrameRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get relativeSourcePath => $composableBuilder(
    column: $table.relativeSourcePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get holdFrames => $composableBuilder(
    column: $table.holdFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceWidth => $composableBuilder(
    column: $table.sourceWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceHeight => $composableBuilder(
    column: $table.sourceHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get missing => $composableBuilder(
    column: $table.missing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustmentsJson => $composableBuilder(
    column: $table.adjustmentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectRecordsTableOrderingComposer get projectId {
    final $$ProjectRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FrameRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FrameRecordsTable> {
  $$FrameRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativeSourcePath => $composableBuilder(
    column: $table.relativeSourcePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get holdFrames => $composableBuilder(
    column: $table.holdFrames,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sourceWidth => $composableBuilder(
    column: $table.sourceWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceHeight => $composableBuilder(
    column: $table.sourceHeight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get missing =>
      $composableBuilder(column: $table.missing, builder: (column) => column);

  GeneratedColumn<String> get adjustmentsJson => $composableBuilder(
    column: $table.adjustmentsJson,
    builder: (column) => column,
  );

  $$ProjectRecordsTableAnnotationComposer get projectId {
    final $$ProjectRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FrameRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FrameRecordsTable,
          FrameRecord,
          $$FrameRecordsTableFilterComposer,
          $$FrameRecordsTableOrderingComposer,
          $$FrameRecordsTableAnnotationComposer,
          $$FrameRecordsTableCreateCompanionBuilder,
          $$FrameRecordsTableUpdateCompanionBuilder,
          (FrameRecord, $$FrameRecordsTableReferences),
          FrameRecord,
          PrefetchHooks Function({bool projectId})
        > {
  $$FrameRecordsTableTableManager(_$AppDatabase db, $FrameRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FrameRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FrameRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FrameRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> relativeSourcePath = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> holdFrames = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sourceWidth = const Value.absent(),
                Value<int> sourceHeight = const Value.absent(),
                Value<bool> missing = const Value.absent(),
                Value<String> adjustmentsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FrameRecordsCompanion(
                id: id,
                projectId: projectId,
                relativeSourcePath: relativeSourcePath,
                position: position,
                holdFrames: holdFrames,
                createdAt: createdAt,
                sourceWidth: sourceWidth,
                sourceHeight: sourceHeight,
                missing: missing,
                adjustmentsJson: adjustmentsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String relativeSourcePath,
                required int position,
                Value<int> holdFrames = const Value.absent(),
                required DateTime createdAt,
                required int sourceWidth,
                required int sourceHeight,
                Value<bool> missing = const Value.absent(),
                Value<String> adjustmentsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FrameRecordsCompanion.insert(
                id: id,
                projectId: projectId,
                relativeSourcePath: relativeSourcePath,
                position: position,
                holdFrames: holdFrames,
                createdAt: createdAt,
                sourceWidth: sourceWidth,
                sourceHeight: sourceHeight,
                missing: missing,
                adjustmentsJson: adjustmentsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FrameRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$FrameRecordsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$FrameRecordsTableReferences
                                    ._projectIdTable(db)
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

typedef $$FrameRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FrameRecordsTable,
      FrameRecord,
      $$FrameRecordsTableFilterComposer,
      $$FrameRecordsTableOrderingComposer,
      $$FrameRecordsTableAnnotationComposer,
      $$FrameRecordsTableCreateCompanionBuilder,
      $$FrameRecordsTableUpdateCompanionBuilder,
      (FrameRecord, $$FrameRecordsTableReferences),
      FrameRecord,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$AudioClipRecordsTableCreateCompanionBuilder =
    AudioClipRecordsCompanion Function({
      required String id,
      required String projectId,
      required String relativeSourcePath,
      required String name,
      required String trackType,
      required int startMilliseconds,
      required int trimStartMilliseconds,
      required int trimEndMilliseconds,
      Value<double> volume,
      Value<int> fadeInMilliseconds,
      Value<int> fadeOutMilliseconds,
      Value<bool> muted,
      Value<bool> missing,
      Value<int> rowid,
    });
typedef $$AudioClipRecordsTableUpdateCompanionBuilder =
    AudioClipRecordsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> relativeSourcePath,
      Value<String> name,
      Value<String> trackType,
      Value<int> startMilliseconds,
      Value<int> trimStartMilliseconds,
      Value<int> trimEndMilliseconds,
      Value<double> volume,
      Value<int> fadeInMilliseconds,
      Value<int> fadeOutMilliseconds,
      Value<bool> muted,
      Value<bool> missing,
      Value<int> rowid,
    });

final class $$AudioClipRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AudioClipRecordsTable, AudioClipRecord> {
  $$AudioClipRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) => db
      .projectRecords
      .createAlias('audio_clip_records__project_id__project_records__id');

  $$ProjectRecordsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectRecordsTableTableManager(
      $_db,
      $_db.projectRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudioClipRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioClipRecordsTable> {
  $$AudioClipRecordsTableFilterComposer({
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

  ColumnFilters<String> get relativeSourcePath => $composableBuilder(
    column: $table.relativeSourcePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackType => $composableBuilder(
    column: $table.trackType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMilliseconds => $composableBuilder(
    column: $table.startMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trimStartMilliseconds => $composableBuilder(
    column: $table.trimStartMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trimEndMilliseconds => $composableBuilder(
    column: $table.trimEndMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fadeInMilliseconds => $composableBuilder(
    column: $table.fadeInMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fadeOutMilliseconds => $composableBuilder(
    column: $table.fadeOutMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get missing => $composableBuilder(
    column: $table.missing,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectRecordsTableFilterComposer get projectId {
    final $$ProjectRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableFilterComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioClipRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioClipRecordsTable> {
  $$AudioClipRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get relativeSourcePath => $composableBuilder(
    column: $table.relativeSourcePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackType => $composableBuilder(
    column: $table.trackType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMilliseconds => $composableBuilder(
    column: $table.startMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trimStartMilliseconds => $composableBuilder(
    column: $table.trimStartMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trimEndMilliseconds => $composableBuilder(
    column: $table.trimEndMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fadeInMilliseconds => $composableBuilder(
    column: $table.fadeInMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fadeOutMilliseconds => $composableBuilder(
    column: $table.fadeOutMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get missing => $composableBuilder(
    column: $table.missing,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectRecordsTableOrderingComposer get projectId {
    final $$ProjectRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioClipRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioClipRecordsTable> {
  $$AudioClipRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativeSourcePath => $composableBuilder(
    column: $table.relativeSourcePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get trackType =>
      $composableBuilder(column: $table.trackType, builder: (column) => column);

  GeneratedColumn<int> get startMilliseconds => $composableBuilder(
    column: $table.startMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trimStartMilliseconds => $composableBuilder(
    column: $table.trimStartMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trimEndMilliseconds => $composableBuilder(
    column: $table.trimEndMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<int> get fadeInMilliseconds => $composableBuilder(
    column: $table.fadeInMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fadeOutMilliseconds => $composableBuilder(
    column: $table.fadeOutMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<bool> get missing =>
      $composableBuilder(column: $table.missing, builder: (column) => column);

  $$ProjectRecordsTableAnnotationComposer get projectId {
    final $$ProjectRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioClipRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioClipRecordsTable,
          AudioClipRecord,
          $$AudioClipRecordsTableFilterComposer,
          $$AudioClipRecordsTableOrderingComposer,
          $$AudioClipRecordsTableAnnotationComposer,
          $$AudioClipRecordsTableCreateCompanionBuilder,
          $$AudioClipRecordsTableUpdateCompanionBuilder,
          (AudioClipRecord, $$AudioClipRecordsTableReferences),
          AudioClipRecord,
          PrefetchHooks Function({bool projectId})
        > {
  $$AudioClipRecordsTableTableManager(
    _$AppDatabase db,
    $AudioClipRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioClipRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioClipRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioClipRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> relativeSourcePath = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> trackType = const Value.absent(),
                Value<int> startMilliseconds = const Value.absent(),
                Value<int> trimStartMilliseconds = const Value.absent(),
                Value<int> trimEndMilliseconds = const Value.absent(),
                Value<double> volume = const Value.absent(),
                Value<int> fadeInMilliseconds = const Value.absent(),
                Value<int> fadeOutMilliseconds = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<bool> missing = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioClipRecordsCompanion(
                id: id,
                projectId: projectId,
                relativeSourcePath: relativeSourcePath,
                name: name,
                trackType: trackType,
                startMilliseconds: startMilliseconds,
                trimStartMilliseconds: trimStartMilliseconds,
                trimEndMilliseconds: trimEndMilliseconds,
                volume: volume,
                fadeInMilliseconds: fadeInMilliseconds,
                fadeOutMilliseconds: fadeOutMilliseconds,
                muted: muted,
                missing: missing,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String relativeSourcePath,
                required String name,
                required String trackType,
                required int startMilliseconds,
                required int trimStartMilliseconds,
                required int trimEndMilliseconds,
                Value<double> volume = const Value.absent(),
                Value<int> fadeInMilliseconds = const Value.absent(),
                Value<int> fadeOutMilliseconds = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<bool> missing = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioClipRecordsCompanion.insert(
                id: id,
                projectId: projectId,
                relativeSourcePath: relativeSourcePath,
                name: name,
                trackType: trackType,
                startMilliseconds: startMilliseconds,
                trimStartMilliseconds: trimStartMilliseconds,
                trimEndMilliseconds: trimEndMilliseconds,
                volume: volume,
                fadeInMilliseconds: fadeInMilliseconds,
                fadeOutMilliseconds: fadeOutMilliseconds,
                muted: muted,
                missing: missing,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudioClipRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable:
                                    $$AudioClipRecordsTableReferences
                                        ._projectIdTable(db),
                                referencedColumn:
                                    $$AudioClipRecordsTableReferences
                                        ._projectIdTable(db)
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

typedef $$AudioClipRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioClipRecordsTable,
      AudioClipRecord,
      $$AudioClipRecordsTableFilterComposer,
      $$AudioClipRecordsTableOrderingComposer,
      $$AudioClipRecordsTableAnnotationComposer,
      $$AudioClipRecordsTableCreateCompanionBuilder,
      $$AudioClipRecordsTableUpdateCompanionBuilder,
      (AudioClipRecord, $$AudioClipRecordsTableReferences),
      AudioClipRecord,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$ExportRecordsTableCreateCompanionBuilder =
    ExportRecordsCompanion Function({
      required String id,
      required String projectId,
      required String format,
      required String status,
      required int revision,
      required DateTime createdAt,
      Value<String?> relativeOutputPath,
      Value<String?> errorCode,
      Value<int> rowid,
    });
typedef $$ExportRecordsTableUpdateCompanionBuilder =
    ExportRecordsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> format,
      Value<String> status,
      Value<int> revision,
      Value<DateTime> createdAt,
      Value<String?> relativeOutputPath,
      Value<String?> errorCode,
      Value<int> rowid,
    });

final class $$ExportRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ExportRecordsTable, ExportRecord> {
  $$ExportRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectRecordsTable _projectIdTable(_$AppDatabase db) => db
      .projectRecords
      .createAlias('export_records__project_id__project_records__id');

  $$ProjectRecordsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectRecordsTableTableManager(
      $_db,
      $_db.projectRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExportRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableFilterComposer({
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

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativeOutputPath => $composableBuilder(
    column: $table.relativeOutputPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectRecordsTableFilterComposer get projectId {
    final $$ProjectRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableFilterComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativeOutputPath => $composableBuilder(
    column: $table.relativeOutputPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectRecordsTableOrderingComposer get projectId {
    final $$ProjectRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get relativeOutputPath => $composableBuilder(
    column: $table.relativeOutputPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  $$ProjectRecordsTableAnnotationComposer get projectId {
    final $$ProjectRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportRecordsTable,
          ExportRecord,
          $$ExportRecordsTableFilterComposer,
          $$ExportRecordsTableOrderingComposer,
          $$ExportRecordsTableAnnotationComposer,
          $$ExportRecordsTableCreateCompanionBuilder,
          $$ExportRecordsTableUpdateCompanionBuilder,
          (ExportRecord, $$ExportRecordsTableReferences),
          ExportRecord,
          PrefetchHooks Function({bool projectId})
        > {
  $$ExportRecordsTableTableManager(_$AppDatabase db, $ExportRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> relativeOutputPath = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportRecordsCompanion(
                id: id,
                projectId: projectId,
                format: format,
                status: status,
                revision: revision,
                createdAt: createdAt,
                relativeOutputPath: relativeOutputPath,
                errorCode: errorCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String format,
                required String status,
                required int revision,
                required DateTime createdAt,
                Value<String?> relativeOutputPath = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportRecordsCompanion.insert(
                id: id,
                projectId: projectId,
                format: format,
                status: status,
                revision: revision,
                createdAt: createdAt,
                relativeOutputPath: relativeOutputPath,
                errorCode: errorCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExportRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$ExportRecordsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$ExportRecordsTableReferences
                                    ._projectIdTable(db)
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

typedef $$ExportRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportRecordsTable,
      ExportRecord,
      $$ExportRecordsTableFilterComposer,
      $$ExportRecordsTableOrderingComposer,
      $$ExportRecordsTableAnnotationComposer,
      $$ExportRecordsTableCreateCompanionBuilder,
      $$ExportRecordsTableUpdateCompanionBuilder,
      (ExportRecord, $$ExportRecordsTableReferences),
      ExportRecord,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$OperationJournalsTableCreateCompanionBuilder =
    OperationJournalsCompanion Function({
      required String id,
      required String type,
      required String state,
      required String projectId,
      Value<String?> destinationProjectId,
      Value<String?> temporaryPath,
      Value<String?> finalPath,
      Value<String?> errorCode,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OperationJournalsTableUpdateCompanionBuilder =
    OperationJournalsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> state,
      Value<String> projectId,
      Value<String?> destinationProjectId,
      Value<String?> temporaryPath,
      Value<String?> finalPath,
      Value<String?> errorCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$OperationJournalsTableFilterComposer
    extends Composer<_$AppDatabase, $OperationJournalsTable> {
  $$OperationJournalsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationProjectId => $composableBuilder(
    column: $table.destinationProjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get temporaryPath => $composableBuilder(
    column: $table.temporaryPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalPath => $composableBuilder(
    column: $table.finalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
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
}

class $$OperationJournalsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationJournalsTable> {
  $$OperationJournalsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationProjectId => $composableBuilder(
    column: $table.destinationProjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get temporaryPath => $composableBuilder(
    column: $table.temporaryPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalPath => $composableBuilder(
    column: $table.finalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
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
}

class $$OperationJournalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationJournalsTable> {
  $$OperationJournalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get destinationProjectId => $composableBuilder(
    column: $table.destinationProjectId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get temporaryPath => $composableBuilder(
    column: $table.temporaryPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finalPath =>
      $composableBuilder(column: $table.finalPath, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OperationJournalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationJournalsTable,
          OperationJournal,
          $$OperationJournalsTableFilterComposer,
          $$OperationJournalsTableOrderingComposer,
          $$OperationJournalsTableAnnotationComposer,
          $$OperationJournalsTableCreateCompanionBuilder,
          $$OperationJournalsTableUpdateCompanionBuilder,
          (
            OperationJournal,
            BaseReferences<
              _$AppDatabase,
              $OperationJournalsTable,
              OperationJournal
            >,
          ),
          OperationJournal,
          PrefetchHooks Function()
        > {
  $$OperationJournalsTableTableManager(
    _$AppDatabase db,
    $OperationJournalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationJournalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationJournalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationJournalsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> destinationProjectId = const Value.absent(),
                Value<String?> temporaryPath = const Value.absent(),
                Value<String?> finalPath = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationJournalsCompanion(
                id: id,
                type: type,
                state: state,
                projectId: projectId,
                destinationProjectId: destinationProjectId,
                temporaryPath: temporaryPath,
                finalPath: finalPath,
                errorCode: errorCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String state,
                required String projectId,
                Value<String?> destinationProjectId = const Value.absent(),
                Value<String?> temporaryPath = const Value.absent(),
                Value<String?> finalPath = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OperationJournalsCompanion.insert(
                id: id,
                type: type,
                state: state,
                projectId: projectId,
                destinationProjectId: destinationProjectId,
                temporaryPath: temporaryPath,
                finalPath: finalPath,
                errorCode: errorCode,
                createdAt: createdAt,
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

typedef $$OperationJournalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationJournalsTable,
      OperationJournal,
      $$OperationJournalsTableFilterComposer,
      $$OperationJournalsTableOrderingComposer,
      $$OperationJournalsTableAnnotationComposer,
      $$OperationJournalsTableCreateCompanionBuilder,
      $$OperationJournalsTableUpdateCompanionBuilder,
      (
        OperationJournal,
        BaseReferences<
          _$AppDatabase,
          $OperationJournalsTable,
          OperationJournal
        >,
      ),
      OperationJournal,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectRecordsTableTableManager get projectRecords =>
      $$ProjectRecordsTableTableManager(_db, _db.projectRecords);
  $$FrameRecordsTableTableManager get frameRecords =>
      $$FrameRecordsTableTableManager(_db, _db.frameRecords);
  $$AudioClipRecordsTableTableManager get audioClipRecords =>
      $$AudioClipRecordsTableTableManager(_db, _db.audioClipRecords);
  $$ExportRecordsTableTableManager get exportRecords =>
      $$ExportRecordsTableTableManager(_db, _db.exportRecords);
  $$OperationJournalsTableTableManager get operationJournals =>
      $$OperationJournalsTableTableManager(_db, _db.operationJournals);
}
