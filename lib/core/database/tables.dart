import 'package:drift/drift.dart';

class ProjectRecords extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get aspectRatio => text()();
  TextColumn get resolution => text()();
  IntColumn get framesPerSecond => integer()();
  IntColumn get backgroundColor => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get status => text()();
  IntColumn get currentRevision => integer().withDefault(const Constant(0))();
  IntColumn get lastExportedRevision => integer().nullable()();
  RealColumn get masterVolume => real().withDefault(const Constant(1.0))();
  BoolColumn get audioMuted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class FrameRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId =>
      text().references(ProjectRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get relativeSourcePath => text()();
  IntColumn get position => integer()();
  IntColumn get holdFrames => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sourceWidth => integer()();
  IntColumn get sourceHeight => integer()();
  BoolColumn get missing => boolean().withDefault(const Constant(false))();
  TextColumn get adjustmentsJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class AudioClipRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId =>
      text().references(ProjectRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get relativeSourcePath => text()();
  TextColumn get name => text()();
  TextColumn get trackType => text()();
  IntColumn get startMilliseconds => integer()();
  IntColumn get trimStartMilliseconds => integer()();
  IntColumn get trimEndMilliseconds => integer()();
  RealColumn get volume => real().withDefault(const Constant(1.0))();
  IntColumn get fadeInMilliseconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get fadeOutMilliseconds =>
      integer().withDefault(const Constant(0))();
  BoolColumn get muted => boolean().withDefault(const Constant(false))();
  BoolColumn get missing => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class ExportRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId =>
      text().references(ProjectRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get format => text()();
  TextColumn get status => text()();
  IntColumn get revision => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get settingsJson => text().withDefault(const Constant('{}'))();
  TextColumn get relativeOutputPath => text().nullable()();
  IntColumn get outputBytes => integer().nullable()();
  TextColumn get errorCode => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class OperationJournals extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get state => text()();
  TextColumn get projectId => text()();
  TextColumn get destinationProjectId => text().nullable()();
  TextColumn get temporaryPath => text().nullable()();
  TextColumn get finalPath => text().nullable()();
  TextColumn get errorCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
