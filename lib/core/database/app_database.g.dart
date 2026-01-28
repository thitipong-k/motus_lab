// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
      'vin', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
      'make', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _protocolMeta =
      const VerificationMeta('protocol');
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
      'protocol', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, vin, make, model, year, protocol, isSynced, updatedAt, isDeleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(Insertable<Vehicle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vin')) {
      context.handle(
          _vinMeta, vin.isAcceptableOrUnknown(data['vin']!, _vinMeta));
    } else if (isInserting) {
      context.missing(_vinMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
          _makeMeta, make.isAcceptableOrUnknown(data['make']!, _makeMeta));
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('protocol')) {
      context.handle(_protocolMeta,
          protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vin'])!,
      make: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}make']),
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      protocol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}protocol']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final int id;
  final String vin;
  final String? make;
  final String? model;
  final int? year;
  final String? protocol;
  final bool isSynced;
  final DateTime updatedAt;
  final bool isDeleted;
  const Vehicle(
      {required this.id,
      required this.vin,
      this.make,
      this.model,
      this.year,
      this.protocol,
      required this.isSynced,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vin'] = Variable<String>(vin);
    if (!nullToAbsent || make != null) {
      map['make'] = Variable<String>(make);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || protocol != null) {
      map['protocol'] = Variable<String>(protocol);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      vin: Value(vin),
      make: make == null && nullToAbsent ? const Value.absent() : Value(make),
      model:
          model == null && nullToAbsent ? const Value.absent() : Value(model),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      protocol: protocol == null && nullToAbsent
          ? const Value.absent()
          : Value(protocol),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      vin: serializer.fromJson<String>(json['vin']),
      make: serializer.fromJson<String?>(json['make']),
      model: serializer.fromJson<String?>(json['model']),
      year: serializer.fromJson<int?>(json['year']),
      protocol: serializer.fromJson<String?>(json['protocol']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vin': serializer.toJson<String>(vin),
      'make': serializer.toJson<String?>(make),
      'model': serializer.toJson<String?>(model),
      'year': serializer.toJson<int?>(year),
      'protocol': serializer.toJson<String?>(protocol),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Vehicle copyWith(
          {int? id,
          String? vin,
          Value<String?> make = const Value.absent(),
          Value<String?> model = const Value.absent(),
          Value<int?> year = const Value.absent(),
          Value<String?> protocol = const Value.absent(),
          bool? isSynced,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      Vehicle(
        id: id ?? this.id,
        vin: vin ?? this.vin,
        make: make.present ? make.value : this.make,
        model: model.present ? model.value : this.model,
        year: year.present ? year.value : this.year,
        protocol: protocol.present ? protocol.value : this.protocol,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      vin: data.vin.present ? data.vin.value : this.vin,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('vin: $vin, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('protocol: $protocol, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, vin, make, model, year, protocol, isSynced, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.vin == this.vin &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.protocol == this.protocol &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> vin;
  final Value<String?> make;
  final Value<String?> model;
  final Value<int?> year;
  final Value<String?> protocol;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.vin = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.protocol = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String vin,
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.protocol = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : vin = Value(vin);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? vin,
    Expression<String>? make,
    Expression<String>? model,
    Expression<int>? year,
    Expression<String>? protocol,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vin != null) 'vin': vin,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (protocol != null) 'protocol': protocol,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  VehiclesCompanion copyWith(
      {Value<int>? id,
      Value<String>? vin,
      Value<String?>? make,
      Value<String?>? model,
      Value<int?>? year,
      Value<String?>? protocol,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted}) {
    return VehiclesCompanion(
      id: id ?? this.id,
      vin: vin ?? this.vin,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      protocol: protocol ?? this.protocol,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('vin: $vin, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('protocol: $protocol, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $ScanHistoryTable extends ScanHistory
    with TableInfo<$ScanHistoryTable, ScanHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES vehicles (id)'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _dtcCodesMeta =
      const VerificationMeta('dtcCodes');
  @override
  late final GeneratedColumn<String> dtcCodes = GeneratedColumn<String>(
      'dtc_codes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('completed'));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        vehicleId,
        timestamp,
        dtcCodes,
        status,
        isSynced,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_history';
  @override
  VerificationContext validateIntegrity(Insertable<ScanHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('dtc_codes')) {
      context.handle(_dtcCodesMeta,
          dtcCodes.isAcceptableOrUnknown(data['dtc_codes']!, _dtcCodesMeta));
    } else if (isInserting) {
      context.missing(_dtcCodesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vehicle_id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      dtcCodes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dtc_codes'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $ScanHistoryTable createAlias(String alias) {
    return $ScanHistoryTable(attachedDatabase, alias);
  }
}

class ScanHistoryData extends DataClass implements Insertable<ScanHistoryData> {
  final int id;
  final int vehicleId;
  final DateTime timestamp;
  final String dtcCodes;
  final String status;
  final bool isSynced;
  final DateTime updatedAt;
  final bool isDeleted;
  const ScanHistoryData(
      {required this.id,
      required this.vehicleId,
      required this.timestamp,
      required this.dtcCodes,
      required this.status,
      required this.isSynced,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['dtc_codes'] = Variable<String>(dtcCodes);
    map['status'] = Variable<String>(status);
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  ScanHistoryCompanion toCompanion(bool nullToAbsent) {
    return ScanHistoryCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      timestamp: Value(timestamp),
      dtcCodes: Value(dtcCodes),
      status: Value(status),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory ScanHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanHistoryData(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      dtcCodes: serializer.fromJson<String>(json['dtcCodes']),
      status: serializer.fromJson<String>(json['status']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'dtcCodes': serializer.toJson<String>(dtcCodes),
      'status': serializer.toJson<String>(status),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  ScanHistoryData copyWith(
          {int? id,
          int? vehicleId,
          DateTime? timestamp,
          String? dtcCodes,
          String? status,
          bool? isSynced,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      ScanHistoryData(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        timestamp: timestamp ?? this.timestamp,
        dtcCodes: dtcCodes ?? this.dtcCodes,
        status: status ?? this.status,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  ScanHistoryData copyWithCompanion(ScanHistoryCompanion data) {
    return ScanHistoryData(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      dtcCodes: data.dtcCodes.present ? data.dtcCodes.value : this.dtcCodes,
      status: data.status.present ? data.status.value : this.status,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoryData(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('timestamp: $timestamp, ')
          ..write('dtcCodes: $dtcCodes, ')
          ..write('status: $status, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vehicleId, timestamp, dtcCodes, status,
      isSynced, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanHistoryData &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.timestamp == this.timestamp &&
          other.dtcCodes == this.dtcCodes &&
          other.status == this.status &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class ScanHistoryCompanion extends UpdateCompanion<ScanHistoryData> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<DateTime> timestamp;
  final Value<String> dtcCodes;
  final Value<String> status;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  const ScanHistoryCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.dtcCodes = const Value.absent(),
    this.status = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  ScanHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    this.timestamp = const Value.absent(),
    required String dtcCodes,
    this.status = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  })  : vehicleId = Value(vehicleId),
        dtcCodes = Value(dtcCodes);
  static Insertable<ScanHistoryData> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<DateTime>? timestamp,
    Expression<String>? dtcCodes,
    Expression<String>? status,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (timestamp != null) 'timestamp': timestamp,
      if (dtcCodes != null) 'dtc_codes': dtcCodes,
      if (status != null) 'status': status,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  ScanHistoryCompanion copyWith(
      {Value<int>? id,
      Value<int>? vehicleId,
      Value<DateTime>? timestamp,
      Value<String>? dtcCodes,
      Value<String>? status,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted}) {
    return ScanHistoryCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      timestamp: timestamp ?? this.timestamp,
      dtcCodes: dtcCodes ?? this.dtcCodes,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (dtcCodes.present) {
      map['dtc_codes'] = Variable<String>(dtcCodes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoryCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('timestamp: $timestamp, ')
          ..write('dtcCodes: $dtcCodes, ')
          ..write('status: $status, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $DtcLibraryTable extends DtcLibrary
    with TableInfo<$DtcLibraryTable, DtcLibraryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DtcLibraryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _possibleCausesMeta =
      const VerificationMeta('possibleCauses');
  @override
  late final GeneratedColumn<String> possibleCauses = GeneratedColumn<String>(
      'possible_causes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, code, description, possibleCauses, isSynced, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dtc_library';
  @override
  VerificationContext validateIntegrity(Insertable<DtcLibraryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('possible_causes')) {
      context.handle(
          _possibleCausesMeta,
          possibleCauses.isAcceptableOrUnknown(
              data['possible_causes']!, _possibleCausesMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DtcLibraryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DtcLibraryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      possibleCauses: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}possible_causes']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DtcLibraryTable createAlias(String alias) {
    return $DtcLibraryTable(attachedDatabase, alias);
  }
}

class DtcLibraryData extends DataClass implements Insertable<DtcLibraryData> {
  final int id;
  final String code;
  final String description;
  final String? possibleCauses;
  final bool isSynced;
  final DateTime updatedAt;
  const DtcLibraryData(
      {required this.id,
      required this.code,
      required this.description,
      this.possibleCauses,
      required this.isSynced,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || possibleCauses != null) {
      map['possible_causes'] = Variable<String>(possibleCauses);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DtcLibraryCompanion toCompanion(bool nullToAbsent) {
    return DtcLibraryCompanion(
      id: Value(id),
      code: Value(code),
      description: Value(description),
      possibleCauses: possibleCauses == null && nullToAbsent
          ? const Value.absent()
          : Value(possibleCauses),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory DtcLibraryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DtcLibraryData(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String>(json['description']),
      possibleCauses: serializer.fromJson<String?>(json['possibleCauses']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String>(description),
      'possibleCauses': serializer.toJson<String?>(possibleCauses),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DtcLibraryData copyWith(
          {int? id,
          String? code,
          String? description,
          Value<String?> possibleCauses = const Value.absent(),
          bool? isSynced,
          DateTime? updatedAt}) =>
      DtcLibraryData(
        id: id ?? this.id,
        code: code ?? this.code,
        description: description ?? this.description,
        possibleCauses:
            possibleCauses.present ? possibleCauses.value : this.possibleCauses,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DtcLibraryData copyWithCompanion(DtcLibraryCompanion data) {
    return DtcLibraryData(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      description:
          data.description.present ? data.description.value : this.description,
      possibleCauses: data.possibleCauses.present
          ? data.possibleCauses.value
          : this.possibleCauses,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DtcLibraryData(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('possibleCauses: $possibleCauses, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, description, possibleCauses, isSynced, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DtcLibraryData &&
          other.id == this.id &&
          other.code == this.code &&
          other.description == this.description &&
          other.possibleCauses == this.possibleCauses &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class DtcLibraryCompanion extends UpdateCompanion<DtcLibraryData> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> description;
  final Value<String?> possibleCauses;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  const DtcLibraryCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.possibleCauses = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DtcLibraryCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String description,
    this.possibleCauses = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : code = Value(code),
        description = Value(description);
  static Insertable<DtcLibraryData> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? description,
    Expression<String>? possibleCauses,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (possibleCauses != null) 'possible_causes': possibleCauses,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DtcLibraryCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String>? description,
      Value<String?>? possibleCauses,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt}) {
    return DtcLibraryCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      possibleCauses: possibleCauses ?? this.possibleCauses,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (possibleCauses.present) {
      map['possible_causes'] = Variable<String>(possibleCauses.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DtcLibraryCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('possibleCauses: $possibleCauses, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PossibleCausesTable extends PossibleCauses
    with TableInfo<$PossibleCausesTable, PossibleCause> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PossibleCausesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _difficultyLevelMeta =
      const VerificationMeta('difficultyLevel');
  @override
  late final GeneratedColumn<int> difficultyLevel = GeneratedColumn<int>(
      'difficulty_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, description, difficultyLevel, isSynced, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'possible_causes';
  @override
  VerificationContext validateIntegrity(Insertable<PossibleCause> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('difficulty_level')) {
      context.handle(
          _difficultyLevelMeta,
          difficultyLevel.isAcceptableOrUnknown(
              data['difficulty_level']!, _difficultyLevelMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PossibleCause map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PossibleCause(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      difficultyLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty_level'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PossibleCausesTable createAlias(String alias) {
    return $PossibleCausesTable(attachedDatabase, alias);
  }
}

class PossibleCause extends DataClass implements Insertable<PossibleCause> {
  final int id;
  final String title;
  final String? description;
  final int difficultyLevel;
  final bool isSynced;
  final DateTime updatedAt;
  const PossibleCause(
      {required this.id,
      required this.title,
      this.description,
      required this.difficultyLevel,
      required this.isSynced,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['difficulty_level'] = Variable<int>(difficultyLevel);
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PossibleCausesCompanion toCompanion(bool nullToAbsent) {
    return PossibleCausesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      difficultyLevel: Value(difficultyLevel),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory PossibleCause.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PossibleCause(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      difficultyLevel: serializer.fromJson<int>(json['difficultyLevel']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'difficultyLevel': serializer.toJson<int>(difficultyLevel),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PossibleCause copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          int? difficultyLevel,
          bool? isSynced,
          DateTime? updatedAt}) =>
      PossibleCause(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        difficultyLevel: difficultyLevel ?? this.difficultyLevel,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PossibleCause copyWithCompanion(PossibleCausesCompanion data) {
    return PossibleCause(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      difficultyLevel: data.difficultyLevel.present
          ? data.difficultyLevel.value
          : this.difficultyLevel,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PossibleCause(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, difficultyLevel, isSynced, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PossibleCause &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.difficultyLevel == this.difficultyLevel &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class PossibleCausesCompanion extends UpdateCompanion<PossibleCause> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> difficultyLevel;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  const PossibleCausesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PossibleCausesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<PossibleCause> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? difficultyLevel,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PossibleCausesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? difficultyLevel,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt}) {
    return PossibleCausesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (difficultyLevel.present) {
      map['difficulty_level'] = Variable<int>(difficultyLevel.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PossibleCausesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SolutionsTable extends Solutions
    with TableInfo<$SolutionsTable, Solution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SolutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _causeIdMeta =
      const VerificationMeta('causeId');
  @override
  late final GeneratedColumn<int> causeId = GeneratedColumn<int>(
      'cause_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES possible_causes (id)'));
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
      'steps', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estimatedCostMeta =
      const VerificationMeta('estimatedCost');
  @override
  late final GeneratedColumn<double> estimatedCost = GeneratedColumn<double>(
      'estimated_cost', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, causeId, steps, estimatedCost, isSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'solutions';
  @override
  VerificationContext validateIntegrity(Insertable<Solution> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cause_id')) {
      context.handle(_causeIdMeta,
          causeId.isAcceptableOrUnknown(data['cause_id']!, _causeIdMeta));
    } else if (isInserting) {
      context.missing(_causeIdMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
          _stepsMeta, steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta));
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('estimated_cost')) {
      context.handle(
          _estimatedCostMeta,
          estimatedCost.isAcceptableOrUnknown(
              data['estimated_cost']!, _estimatedCostMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Solution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Solution(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      causeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cause_id'])!,
      steps: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}steps'])!,
      estimatedCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}estimated_cost']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $SolutionsTable createAlias(String alias) {
    return $SolutionsTable(attachedDatabase, alias);
  }
}

class Solution extends DataClass implements Insertable<Solution> {
  final int id;
  final int causeId;
  final String steps;
  final double? estimatedCost;
  final bool isSynced;
  const Solution(
      {required this.id,
      required this.causeId,
      required this.steps,
      this.estimatedCost,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cause_id'] = Variable<int>(causeId);
    map['steps'] = Variable<String>(steps);
    if (!nullToAbsent || estimatedCost != null) {
      map['estimated_cost'] = Variable<double>(estimatedCost);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  SolutionsCompanion toCompanion(bool nullToAbsent) {
    return SolutionsCompanion(
      id: Value(id),
      causeId: Value(causeId),
      steps: Value(steps),
      estimatedCost: estimatedCost == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedCost),
      isSynced: Value(isSynced),
    );
  }

  factory Solution.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Solution(
      id: serializer.fromJson<int>(json['id']),
      causeId: serializer.fromJson<int>(json['causeId']),
      steps: serializer.fromJson<String>(json['steps']),
      estimatedCost: serializer.fromJson<double?>(json['estimatedCost']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'causeId': serializer.toJson<int>(causeId),
      'steps': serializer.toJson<String>(steps),
      'estimatedCost': serializer.toJson<double?>(estimatedCost),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Solution copyWith(
          {int? id,
          int? causeId,
          String? steps,
          Value<double?> estimatedCost = const Value.absent(),
          bool? isSynced}) =>
      Solution(
        id: id ?? this.id,
        causeId: causeId ?? this.causeId,
        steps: steps ?? this.steps,
        estimatedCost:
            estimatedCost.present ? estimatedCost.value : this.estimatedCost,
        isSynced: isSynced ?? this.isSynced,
      );
  Solution copyWithCompanion(SolutionsCompanion data) {
    return Solution(
      id: data.id.present ? data.id.value : this.id,
      causeId: data.causeId.present ? data.causeId.value : this.causeId,
      steps: data.steps.present ? data.steps.value : this.steps,
      estimatedCost: data.estimatedCost.present
          ? data.estimatedCost.value
          : this.estimatedCost,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Solution(')
          ..write('id: $id, ')
          ..write('causeId: $causeId, ')
          ..write('steps: $steps, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, causeId, steps, estimatedCost, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Solution &&
          other.id == this.id &&
          other.causeId == this.causeId &&
          other.steps == this.steps &&
          other.estimatedCost == this.estimatedCost &&
          other.isSynced == this.isSynced);
}

class SolutionsCompanion extends UpdateCompanion<Solution> {
  final Value<int> id;
  final Value<int> causeId;
  final Value<String> steps;
  final Value<double?> estimatedCost;
  final Value<bool> isSynced;
  const SolutionsCompanion({
    this.id = const Value.absent(),
    this.causeId = const Value.absent(),
    this.steps = const Value.absent(),
    this.estimatedCost = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  SolutionsCompanion.insert({
    this.id = const Value.absent(),
    required int causeId,
    required String steps,
    this.estimatedCost = const Value.absent(),
    this.isSynced = const Value.absent(),
  })  : causeId = Value(causeId),
        steps = Value(steps);
  static Insertable<Solution> custom({
    Expression<int>? id,
    Expression<int>? causeId,
    Expression<String>? steps,
    Expression<double>? estimatedCost,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (causeId != null) 'cause_id': causeId,
      if (steps != null) 'steps': steps,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  SolutionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? causeId,
      Value<String>? steps,
      Value<double?>? estimatedCost,
      Value<bool>? isSynced}) {
    return SolutionsCompanion(
      id: id ?? this.id,
      causeId: causeId ?? this.causeId,
      steps: steps ?? this.steps,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (causeId.present) {
      map['cause_id'] = Variable<int>(causeId.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (estimatedCost.present) {
      map['estimated_cost'] = Variable<double>(estimatedCost.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SolutionsCompanion(')
          ..write('id: $id, ')
          ..write('causeId: $causeId, ')
          ..write('steps: $steps, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $DiagnosticIntelligenceTable extends DiagnosticIntelligence
    with TableInfo<$DiagnosticIntelligenceTable, DiagnosticIntelligenceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticIntelligenceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dtcCodeMeta =
      const VerificationMeta('dtcCode');
  @override
  late final GeneratedColumn<String> dtcCode = GeneratedColumn<String>(
      'dtc_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleModelMeta =
      const VerificationMeta('vehicleModel');
  @override
  late final GeneratedColumn<String> vehicleModel = GeneratedColumn<String>(
      'vehicle_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _causeIdMeta =
      const VerificationMeta('causeId');
  @override
  late final GeneratedColumn<int> causeId = GeneratedColumn<int>(
      'cause_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES possible_causes (id)'));
  static const VerificationMeta _likelihoodScoreMeta =
      const VerificationMeta('likelihoodScore');
  @override
  late final GeneratedColumn<int> likelihoodScore = GeneratedColumn<int>(
      'likelihood_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _verifiedByMechanicMeta =
      const VerificationMeta('verifiedByMechanic');
  @override
  late final GeneratedColumn<bool> verifiedByMechanic = GeneratedColumn<bool>(
      'verified_by_mechanic', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("verified_by_mechanic" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dtcCode,
        vehicleModel,
        causeId,
        likelihoodScore,
        verifiedByMechanic,
        isSynced,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnostic_intelligence';
  @override
  VerificationContext validateIntegrity(
      Insertable<DiagnosticIntelligenceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dtc_code')) {
      context.handle(_dtcCodeMeta,
          dtcCode.isAcceptableOrUnknown(data['dtc_code']!, _dtcCodeMeta));
    } else if (isInserting) {
      context.missing(_dtcCodeMeta);
    }
    if (data.containsKey('vehicle_model')) {
      context.handle(
          _vehicleModelMeta,
          vehicleModel.isAcceptableOrUnknown(
              data['vehicle_model']!, _vehicleModelMeta));
    }
    if (data.containsKey('cause_id')) {
      context.handle(_causeIdMeta,
          causeId.isAcceptableOrUnknown(data['cause_id']!, _causeIdMeta));
    } else if (isInserting) {
      context.missing(_causeIdMeta);
    }
    if (data.containsKey('likelihood_score')) {
      context.handle(
          _likelihoodScoreMeta,
          likelihoodScore.isAcceptableOrUnknown(
              data['likelihood_score']!, _likelihoodScoreMeta));
    }
    if (data.containsKey('verified_by_mechanic')) {
      context.handle(
          _verifiedByMechanicMeta,
          verifiedByMechanic.isAcceptableOrUnknown(
              data['verified_by_mechanic']!, _verifiedByMechanicMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagnosticIntelligenceData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosticIntelligenceData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dtcCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dtc_code'])!,
      vehicleModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_model']),
      causeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cause_id'])!,
      likelihoodScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}likelihood_score'])!,
      verifiedByMechanic: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}verified_by_mechanic'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DiagnosticIntelligenceTable createAlias(String alias) {
    return $DiagnosticIntelligenceTable(attachedDatabase, alias);
  }
}

class DiagnosticIntelligenceData extends DataClass
    implements Insertable<DiagnosticIntelligenceData> {
  final int id;
  final String dtcCode;
  final String? vehicleModel;
  final int causeId;
  final int likelihoodScore;
  final bool verifiedByMechanic;
  final bool isSynced;
  final DateTime updatedAt;
  const DiagnosticIntelligenceData(
      {required this.id,
      required this.dtcCode,
      this.vehicleModel,
      required this.causeId,
      required this.likelihoodScore,
      required this.verifiedByMechanic,
      required this.isSynced,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dtc_code'] = Variable<String>(dtcCode);
    if (!nullToAbsent || vehicleModel != null) {
      map['vehicle_model'] = Variable<String>(vehicleModel);
    }
    map['cause_id'] = Variable<int>(causeId);
    map['likelihood_score'] = Variable<int>(likelihoodScore);
    map['verified_by_mechanic'] = Variable<bool>(verifiedByMechanic);
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DiagnosticIntelligenceCompanion toCompanion(bool nullToAbsent) {
    return DiagnosticIntelligenceCompanion(
      id: Value(id),
      dtcCode: Value(dtcCode),
      vehicleModel: vehicleModel == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleModel),
      causeId: Value(causeId),
      likelihoodScore: Value(likelihoodScore),
      verifiedByMechanic: Value(verifiedByMechanic),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory DiagnosticIntelligenceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosticIntelligenceData(
      id: serializer.fromJson<int>(json['id']),
      dtcCode: serializer.fromJson<String>(json['dtcCode']),
      vehicleModel: serializer.fromJson<String?>(json['vehicleModel']),
      causeId: serializer.fromJson<int>(json['causeId']),
      likelihoodScore: serializer.fromJson<int>(json['likelihoodScore']),
      verifiedByMechanic: serializer.fromJson<bool>(json['verifiedByMechanic']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dtcCode': serializer.toJson<String>(dtcCode),
      'vehicleModel': serializer.toJson<String?>(vehicleModel),
      'causeId': serializer.toJson<int>(causeId),
      'likelihoodScore': serializer.toJson<int>(likelihoodScore),
      'verifiedByMechanic': serializer.toJson<bool>(verifiedByMechanic),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DiagnosticIntelligenceData copyWith(
          {int? id,
          String? dtcCode,
          Value<String?> vehicleModel = const Value.absent(),
          int? causeId,
          int? likelihoodScore,
          bool? verifiedByMechanic,
          bool? isSynced,
          DateTime? updatedAt}) =>
      DiagnosticIntelligenceData(
        id: id ?? this.id,
        dtcCode: dtcCode ?? this.dtcCode,
        vehicleModel:
            vehicleModel.present ? vehicleModel.value : this.vehicleModel,
        causeId: causeId ?? this.causeId,
        likelihoodScore: likelihoodScore ?? this.likelihoodScore,
        verifiedByMechanic: verifiedByMechanic ?? this.verifiedByMechanic,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DiagnosticIntelligenceData copyWithCompanion(
      DiagnosticIntelligenceCompanion data) {
    return DiagnosticIntelligenceData(
      id: data.id.present ? data.id.value : this.id,
      dtcCode: data.dtcCode.present ? data.dtcCode.value : this.dtcCode,
      vehicleModel: data.vehicleModel.present
          ? data.vehicleModel.value
          : this.vehicleModel,
      causeId: data.causeId.present ? data.causeId.value : this.causeId,
      likelihoodScore: data.likelihoodScore.present
          ? data.likelihoodScore.value
          : this.likelihoodScore,
      verifiedByMechanic: data.verifiedByMechanic.present
          ? data.verifiedByMechanic.value
          : this.verifiedByMechanic,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticIntelligenceData(')
          ..write('id: $id, ')
          ..write('dtcCode: $dtcCode, ')
          ..write('vehicleModel: $vehicleModel, ')
          ..write('causeId: $causeId, ')
          ..write('likelihoodScore: $likelihoodScore, ')
          ..write('verifiedByMechanic: $verifiedByMechanic, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dtcCode, vehicleModel, causeId,
      likelihoodScore, verifiedByMechanic, isSynced, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticIntelligenceData &&
          other.id == this.id &&
          other.dtcCode == this.dtcCode &&
          other.vehicleModel == this.vehicleModel &&
          other.causeId == this.causeId &&
          other.likelihoodScore == this.likelihoodScore &&
          other.verifiedByMechanic == this.verifiedByMechanic &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class DiagnosticIntelligenceCompanion
    extends UpdateCompanion<DiagnosticIntelligenceData> {
  final Value<int> id;
  final Value<String> dtcCode;
  final Value<String?> vehicleModel;
  final Value<int> causeId;
  final Value<int> likelihoodScore;
  final Value<bool> verifiedByMechanic;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  const DiagnosticIntelligenceCompanion({
    this.id = const Value.absent(),
    this.dtcCode = const Value.absent(),
    this.vehicleModel = const Value.absent(),
    this.causeId = const Value.absent(),
    this.likelihoodScore = const Value.absent(),
    this.verifiedByMechanic = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DiagnosticIntelligenceCompanion.insert({
    this.id = const Value.absent(),
    required String dtcCode,
    this.vehicleModel = const Value.absent(),
    required int causeId,
    this.likelihoodScore = const Value.absent(),
    this.verifiedByMechanic = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : dtcCode = Value(dtcCode),
        causeId = Value(causeId);
  static Insertable<DiagnosticIntelligenceData> custom({
    Expression<int>? id,
    Expression<String>? dtcCode,
    Expression<String>? vehicleModel,
    Expression<int>? causeId,
    Expression<int>? likelihoodScore,
    Expression<bool>? verifiedByMechanic,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dtcCode != null) 'dtc_code': dtcCode,
      if (vehicleModel != null) 'vehicle_model': vehicleModel,
      if (causeId != null) 'cause_id': causeId,
      if (likelihoodScore != null) 'likelihood_score': likelihoodScore,
      if (verifiedByMechanic != null)
        'verified_by_mechanic': verifiedByMechanic,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DiagnosticIntelligenceCompanion copyWith(
      {Value<int>? id,
      Value<String>? dtcCode,
      Value<String?>? vehicleModel,
      Value<int>? causeId,
      Value<int>? likelihoodScore,
      Value<bool>? verifiedByMechanic,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt}) {
    return DiagnosticIntelligenceCompanion(
      id: id ?? this.id,
      dtcCode: dtcCode ?? this.dtcCode,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      causeId: causeId ?? this.causeId,
      likelihoodScore: likelihoodScore ?? this.likelihoodScore,
      verifiedByMechanic: verifiedByMechanic ?? this.verifiedByMechanic,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dtcCode.present) {
      map['dtc_code'] = Variable<String>(dtcCode.value);
    }
    if (vehicleModel.present) {
      map['vehicle_model'] = Variable<String>(vehicleModel.value);
    }
    if (causeId.present) {
      map['cause_id'] = Variable<int>(causeId.value);
    }
    if (likelihoodScore.present) {
      map['likelihood_score'] = Variable<int>(likelihoodScore.value);
    }
    if (verifiedByMechanic.present) {
      map['verified_by_mechanic'] = Variable<bool>(verifiedByMechanic.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticIntelligenceCompanion(')
          ..write('id: $id, ')
          ..write('dtcCode: $dtcCode, ')
          ..write('vehicleModel: $vehicleModel, ')
          ..write('causeId: $causeId, ')
          ..write('likelihoodScore: $likelihoodScore, ')
          ..write('verifiedByMechanic: $verifiedByMechanic, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $ScanHistoryTable scanHistory = $ScanHistoryTable(this);
  late final $DtcLibraryTable dtcLibrary = $DtcLibraryTable(this);
  late final $PossibleCausesTable possibleCauses = $PossibleCausesTable(this);
  late final $SolutionsTable solutions = $SolutionsTable(this);
  late final $DiagnosticIntelligenceTable diagnosticIntelligence =
      $DiagnosticIntelligenceTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        vehicles,
        scanHistory,
        dtcLibrary,
        possibleCauses,
        solutions,
        diagnosticIntelligence
      ];
}

typedef $$VehiclesTableCreateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  required String vin,
  Value<String?> make,
  Value<String?> model,
  Value<int?> year,
  Value<String?> protocol,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
});
typedef $$VehiclesTableUpdateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  Value<String> vin,
  Value<String?> make,
  Value<String?> model,
  Value<int?> year,
  Value<String?> protocol,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
});

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScanHistoryTable, List<ScanHistoryData>>
      _scanHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.scanHistory,
          aliasName:
              $_aliasNameGenerator(db.vehicles.id, db.scanHistory.vehicleId));

  $$ScanHistoryTableProcessedTableManager get scanHistoryRefs {
    final manager = $$ScanHistoryTableTableManager($_db, $_db.scanHistory)
        .filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanHistoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vin => $composableBuilder(
      column: $table.vin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get make => $composableBuilder(
      column: $table.make, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get protocol => $composableBuilder(
      column: $table.protocol, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  Expression<bool> scanHistoryRefs(
      Expression<bool> Function($$ScanHistoryTableFilterComposer f) f) {
    final $$ScanHistoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scanHistory,
        getReferencedColumn: (t) => t.vehicleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScanHistoryTableFilterComposer(
              $db: $db,
              $table: $db.scanHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vin => $composableBuilder(
      column: $table.vin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get make => $composableBuilder(
      column: $table.make, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get protocol => $composableBuilder(
      column: $table.protocol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vin =>
      $composableBuilder(column: $table.vin, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> scanHistoryRefs<T extends Object>(
      Expression<T> Function($$ScanHistoryTableAnnotationComposer a) f) {
    final $$ScanHistoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scanHistory,
        getReferencedColumn: (t) => t.vehicleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScanHistoryTableAnnotationComposer(
              $db: $db,
              $table: $db.scanHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VehiclesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VehiclesTable,
    Vehicle,
    $$VehiclesTableFilterComposer,
    $$VehiclesTableOrderingComposer,
    $$VehiclesTableAnnotationComposer,
    $$VehiclesTableCreateCompanionBuilder,
    $$VehiclesTableUpdateCompanionBuilder,
    (Vehicle, $$VehiclesTableReferences),
    Vehicle,
    PrefetchHooks Function({bool scanHistoryRefs})> {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> vin = const Value.absent(),
            Value<String?> make = const Value.absent(),
            Value<String?> model = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> protocol = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              VehiclesCompanion(
            id: id,
            vin: vin,
            make: make,
            model: model,
            year: year,
            protocol: protocol,
            isSynced: isSynced,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String vin,
            Value<String?> make = const Value.absent(),
            Value<String?> model = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> protocol = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              VehiclesCompanion.insert(
            id: id,
            vin: vin,
            make: make,
            model: model,
            year: year,
            protocol: protocol,
            isSynced: isSynced,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VehiclesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({scanHistoryRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scanHistoryRefs) db.scanHistory],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scanHistoryRefs)
                    await $_getPrefetchedData<Vehicle, $VehiclesTable,
                            ScanHistoryData>(
                        currentTable: table,
                        referencedTable:
                            $$VehiclesTableReferences._scanHistoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VehiclesTableReferences(db, table, p0)
                                .scanHistoryRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vehicleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VehiclesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VehiclesTable,
    Vehicle,
    $$VehiclesTableFilterComposer,
    $$VehiclesTableOrderingComposer,
    $$VehiclesTableAnnotationComposer,
    $$VehiclesTableCreateCompanionBuilder,
    $$VehiclesTableUpdateCompanionBuilder,
    (Vehicle, $$VehiclesTableReferences),
    Vehicle,
    PrefetchHooks Function({bool scanHistoryRefs})>;
typedef $$ScanHistoryTableCreateCompanionBuilder = ScanHistoryCompanion
    Function({
  Value<int> id,
  required int vehicleId,
  Value<DateTime> timestamp,
  required String dtcCodes,
  Value<String> status,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
});
typedef $$ScanHistoryTableUpdateCompanionBuilder = ScanHistoryCompanion
    Function({
  Value<int> id,
  Value<int> vehicleId,
  Value<DateTime> timestamp,
  Value<String> dtcCodes,
  Value<String> status,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
});

final class $$ScanHistoryTableReferences
    extends BaseReferences<_$AppDatabase, $ScanHistoryTable, ScanHistoryData> {
  $$ScanHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
          $_aliasNameGenerator(db.scanHistory.vehicleId, db.vehicles.id));

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager($_db, $_db.vehicles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ScanHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ScanHistoryTable> {
  $$ScanHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dtcCodes => $composableBuilder(
      column: $table.dtcCodes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableFilterComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScanHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanHistoryTable> {
  $$ScanHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dtcCodes => $composableBuilder(
      column: $table.dtcCodes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableOrderingComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScanHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanHistoryTable> {
  $$ScanHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get dtcCodes =>
      $composableBuilder(column: $table.dtcCodes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vehicleId,
        referencedTable: $db.vehicles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VehiclesTableAnnotationComposer(
              $db: $db,
              $table: $db.vehicles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScanHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanHistoryTable,
    ScanHistoryData,
    $$ScanHistoryTableFilterComposer,
    $$ScanHistoryTableOrderingComposer,
    $$ScanHistoryTableAnnotationComposer,
    $$ScanHistoryTableCreateCompanionBuilder,
    $$ScanHistoryTableUpdateCompanionBuilder,
    (ScanHistoryData, $$ScanHistoryTableReferences),
    ScanHistoryData,
    PrefetchHooks Function({bool vehicleId})> {
  $$ScanHistoryTableTableManager(_$AppDatabase db, $ScanHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> vehicleId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> dtcCodes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              ScanHistoryCompanion(
            id: id,
            vehicleId: vehicleId,
            timestamp: timestamp,
            dtcCodes: dtcCodes,
            status: status,
            isSynced: isSynced,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int vehicleId,
            Value<DateTime> timestamp = const Value.absent(),
            required String dtcCodes,
            Value<String> status = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              ScanHistoryCompanion.insert(
            id: id,
            vehicleId: vehicleId,
            timestamp: timestamp,
            dtcCodes: dtcCodes,
            status: status,
            isSynced: isSynced,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ScanHistoryTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (vehicleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vehicleId,
                    referencedTable:
                        $$ScanHistoryTableReferences._vehicleIdTable(db),
                    referencedColumn:
                        $$ScanHistoryTableReferences._vehicleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ScanHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScanHistoryTable,
    ScanHistoryData,
    $$ScanHistoryTableFilterComposer,
    $$ScanHistoryTableOrderingComposer,
    $$ScanHistoryTableAnnotationComposer,
    $$ScanHistoryTableCreateCompanionBuilder,
    $$ScanHistoryTableUpdateCompanionBuilder,
    (ScanHistoryData, $$ScanHistoryTableReferences),
    ScanHistoryData,
    PrefetchHooks Function({bool vehicleId})>;
typedef $$DtcLibraryTableCreateCompanionBuilder = DtcLibraryCompanion Function({
  Value<int> id,
  required String code,
  required String description,
  Value<String?> possibleCauses,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});
typedef $$DtcLibraryTableUpdateCompanionBuilder = DtcLibraryCompanion Function({
  Value<int> id,
  Value<String> code,
  Value<String> description,
  Value<String?> possibleCauses,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});

class $$DtcLibraryTableFilterComposer
    extends Composer<_$AppDatabase, $DtcLibraryTable> {
  $$DtcLibraryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get possibleCauses => $composableBuilder(
      column: $table.possibleCauses,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DtcLibraryTableOrderingComposer
    extends Composer<_$AppDatabase, $DtcLibraryTable> {
  $$DtcLibraryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get possibleCauses => $composableBuilder(
      column: $table.possibleCauses,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DtcLibraryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DtcLibraryTable> {
  $$DtcLibraryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get possibleCauses => $composableBuilder(
      column: $table.possibleCauses, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DtcLibraryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DtcLibraryTable,
    DtcLibraryData,
    $$DtcLibraryTableFilterComposer,
    $$DtcLibraryTableOrderingComposer,
    $$DtcLibraryTableAnnotationComposer,
    $$DtcLibraryTableCreateCompanionBuilder,
    $$DtcLibraryTableUpdateCompanionBuilder,
    (
      DtcLibraryData,
      BaseReferences<_$AppDatabase, $DtcLibraryTable, DtcLibraryData>
    ),
    DtcLibraryData,
    PrefetchHooks Function()> {
  $$DtcLibraryTableTableManager(_$AppDatabase db, $DtcLibraryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DtcLibraryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DtcLibraryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DtcLibraryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> possibleCauses = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DtcLibraryCompanion(
            id: id,
            code: code,
            description: description,
            possibleCauses: possibleCauses,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            required String description,
            Value<String?> possibleCauses = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DtcLibraryCompanion.insert(
            id: id,
            code: code,
            description: description,
            possibleCauses: possibleCauses,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DtcLibraryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DtcLibraryTable,
    DtcLibraryData,
    $$DtcLibraryTableFilterComposer,
    $$DtcLibraryTableOrderingComposer,
    $$DtcLibraryTableAnnotationComposer,
    $$DtcLibraryTableCreateCompanionBuilder,
    $$DtcLibraryTableUpdateCompanionBuilder,
    (
      DtcLibraryData,
      BaseReferences<_$AppDatabase, $DtcLibraryTable, DtcLibraryData>
    ),
    DtcLibraryData,
    PrefetchHooks Function()>;
typedef $$PossibleCausesTableCreateCompanionBuilder = PossibleCausesCompanion
    Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  Value<int> difficultyLevel,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});
typedef $$PossibleCausesTableUpdateCompanionBuilder = PossibleCausesCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<int> difficultyLevel,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});

final class $$PossibleCausesTableReferences
    extends BaseReferences<_$AppDatabase, $PossibleCausesTable, PossibleCause> {
  $$PossibleCausesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SolutionsTable, List<Solution>>
      _solutionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.solutions,
          aliasName:
              $_aliasNameGenerator(db.possibleCauses.id, db.solutions.causeId));

  $$SolutionsTableProcessedTableManager get solutionsRefs {
    final manager = $$SolutionsTableTableManager($_db, $_db.solutions)
        .filter((f) => f.causeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_solutionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DiagnosticIntelligenceTable,
      List<DiagnosticIntelligenceData>> _diagnosticIntelligenceRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.diagnosticIntelligence,
          aliasName: $_aliasNameGenerator(
              db.possibleCauses.id, db.diagnosticIntelligence.causeId));

  $$DiagnosticIntelligenceTableProcessedTableManager
      get diagnosticIntelligenceRefs {
    final manager = $$DiagnosticIntelligenceTableTableManager(
            $_db, $_db.diagnosticIntelligence)
        .filter((f) => f.causeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_diagnosticIntelligenceRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PossibleCausesTableFilterComposer
    extends Composer<_$AppDatabase, $PossibleCausesTable> {
  $$PossibleCausesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> solutionsRefs(
      Expression<bool> Function($$SolutionsTableFilterComposer f) f) {
    final $$SolutionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.solutions,
        getReferencedColumn: (t) => t.causeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SolutionsTableFilterComposer(
              $db: $db,
              $table: $db.solutions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> diagnosticIntelligenceRefs(
      Expression<bool> Function($$DiagnosticIntelligenceTableFilterComposer f)
          f) {
    final $$DiagnosticIntelligenceTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.diagnosticIntelligence,
            getReferencedColumn: (t) => t.causeId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DiagnosticIntelligenceTableFilterComposer(
                  $db: $db,
                  $table: $db.diagnosticIntelligence,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PossibleCausesTableOrderingComposer
    extends Composer<_$AppDatabase, $PossibleCausesTable> {
  $$PossibleCausesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PossibleCausesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PossibleCausesTable> {
  $$PossibleCausesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> solutionsRefs<T extends Object>(
      Expression<T> Function($$SolutionsTableAnnotationComposer a) f) {
    final $$SolutionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.solutions,
        getReferencedColumn: (t) => t.causeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SolutionsTableAnnotationComposer(
              $db: $db,
              $table: $db.solutions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> diagnosticIntelligenceRefs<T extends Object>(
      Expression<T> Function($$DiagnosticIntelligenceTableAnnotationComposer a)
          f) {
    final $$DiagnosticIntelligenceTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.diagnosticIntelligence,
            getReferencedColumn: (t) => t.causeId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DiagnosticIntelligenceTableAnnotationComposer(
                  $db: $db,
                  $table: $db.diagnosticIntelligence,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PossibleCausesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PossibleCausesTable,
    PossibleCause,
    $$PossibleCausesTableFilterComposer,
    $$PossibleCausesTableOrderingComposer,
    $$PossibleCausesTableAnnotationComposer,
    $$PossibleCausesTableCreateCompanionBuilder,
    $$PossibleCausesTableUpdateCompanionBuilder,
    (PossibleCause, $$PossibleCausesTableReferences),
    PossibleCause,
    PrefetchHooks Function(
        {bool solutionsRefs, bool diagnosticIntelligenceRefs})> {
  $$PossibleCausesTableTableManager(
      _$AppDatabase db, $PossibleCausesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PossibleCausesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PossibleCausesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PossibleCausesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> difficultyLevel = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PossibleCausesCompanion(
            id: id,
            title: title,
            description: description,
            difficultyLevel: difficultyLevel,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<int> difficultyLevel = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PossibleCausesCompanion.insert(
            id: id,
            title: title,
            description: description,
            difficultyLevel: difficultyLevel,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PossibleCausesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {solutionsRefs = false, diagnosticIntelligenceRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (solutionsRefs) db.solutions,
                if (diagnosticIntelligenceRefs) db.diagnosticIntelligence
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (solutionsRefs)
                    await $_getPrefetchedData<PossibleCause,
                            $PossibleCausesTable, Solution>(
                        currentTable: table,
                        referencedTable: $$PossibleCausesTableReferences
                            ._solutionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PossibleCausesTableReferences(db, table, p0)
                                .solutionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.causeId == item.id),
                        typedResults: items),
                  if (diagnosticIntelligenceRefs)
                    await $_getPrefetchedData<PossibleCause,
                            $PossibleCausesTable, DiagnosticIntelligenceData>(
                        currentTable: table,
                        referencedTable: $$PossibleCausesTableReferences
                            ._diagnosticIntelligenceRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PossibleCausesTableReferences(db, table, p0)
                                .diagnosticIntelligenceRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.causeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PossibleCausesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PossibleCausesTable,
    PossibleCause,
    $$PossibleCausesTableFilterComposer,
    $$PossibleCausesTableOrderingComposer,
    $$PossibleCausesTableAnnotationComposer,
    $$PossibleCausesTableCreateCompanionBuilder,
    $$PossibleCausesTableUpdateCompanionBuilder,
    (PossibleCause, $$PossibleCausesTableReferences),
    PossibleCause,
    PrefetchHooks Function(
        {bool solutionsRefs, bool diagnosticIntelligenceRefs})>;
typedef $$SolutionsTableCreateCompanionBuilder = SolutionsCompanion Function({
  Value<int> id,
  required int causeId,
  required String steps,
  Value<double?> estimatedCost,
  Value<bool> isSynced,
});
typedef $$SolutionsTableUpdateCompanionBuilder = SolutionsCompanion Function({
  Value<int> id,
  Value<int> causeId,
  Value<String> steps,
  Value<double?> estimatedCost,
  Value<bool> isSynced,
});

final class $$SolutionsTableReferences
    extends BaseReferences<_$AppDatabase, $SolutionsTable, Solution> {
  $$SolutionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PossibleCausesTable _causeIdTable(_$AppDatabase db) =>
      db.possibleCauses.createAlias(
          $_aliasNameGenerator(db.solutions.causeId, db.possibleCauses.id));

  $$PossibleCausesTableProcessedTableManager get causeId {
    final $_column = $_itemColumn<int>('cause_id')!;

    final manager = $$PossibleCausesTableTableManager($_db, $_db.possibleCauses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_causeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SolutionsTableFilterComposer
    extends Composer<_$AppDatabase, $SolutionsTable> {
  $$SolutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedCost => $composableBuilder(
      column: $table.estimatedCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  $$PossibleCausesTableFilterComposer get causeId {
    final $$PossibleCausesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.causeId,
        referencedTable: $db.possibleCauses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PossibleCausesTableFilterComposer(
              $db: $db,
              $table: $db.possibleCauses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SolutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SolutionsTable> {
  $$SolutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedCost => $composableBuilder(
      column: $table.estimatedCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  $$PossibleCausesTableOrderingComposer get causeId {
    final $$PossibleCausesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.causeId,
        referencedTable: $db.possibleCauses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PossibleCausesTableOrderingComposer(
              $db: $db,
              $table: $db.possibleCauses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SolutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SolutionsTable> {
  $$SolutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<double> get estimatedCost => $composableBuilder(
      column: $table.estimatedCost, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$PossibleCausesTableAnnotationComposer get causeId {
    final $$PossibleCausesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.causeId,
        referencedTable: $db.possibleCauses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PossibleCausesTableAnnotationComposer(
              $db: $db,
              $table: $db.possibleCauses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SolutionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SolutionsTable,
    Solution,
    $$SolutionsTableFilterComposer,
    $$SolutionsTableOrderingComposer,
    $$SolutionsTableAnnotationComposer,
    $$SolutionsTableCreateCompanionBuilder,
    $$SolutionsTableUpdateCompanionBuilder,
    (Solution, $$SolutionsTableReferences),
    Solution,
    PrefetchHooks Function({bool causeId})> {
  $$SolutionsTableTableManager(_$AppDatabase db, $SolutionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SolutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SolutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SolutionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> causeId = const Value.absent(),
            Value<String> steps = const Value.absent(),
            Value<double?> estimatedCost = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              SolutionsCompanion(
            id: id,
            causeId: causeId,
            steps: steps,
            estimatedCost: estimatedCost,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int causeId,
            required String steps,
            Value<double?> estimatedCost = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              SolutionsCompanion.insert(
            id: id,
            causeId: causeId,
            steps: steps,
            estimatedCost: estimatedCost,
            isSynced: isSynced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SolutionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({causeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (causeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.causeId,
                    referencedTable:
                        $$SolutionsTableReferences._causeIdTable(db),
                    referencedColumn:
                        $$SolutionsTableReferences._causeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SolutionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SolutionsTable,
    Solution,
    $$SolutionsTableFilterComposer,
    $$SolutionsTableOrderingComposer,
    $$SolutionsTableAnnotationComposer,
    $$SolutionsTableCreateCompanionBuilder,
    $$SolutionsTableUpdateCompanionBuilder,
    (Solution, $$SolutionsTableReferences),
    Solution,
    PrefetchHooks Function({bool causeId})>;
typedef $$DiagnosticIntelligenceTableCreateCompanionBuilder
    = DiagnosticIntelligenceCompanion Function({
  Value<int> id,
  required String dtcCode,
  Value<String?> vehicleModel,
  required int causeId,
  Value<int> likelihoodScore,
  Value<bool> verifiedByMechanic,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});
typedef $$DiagnosticIntelligenceTableUpdateCompanionBuilder
    = DiagnosticIntelligenceCompanion Function({
  Value<int> id,
  Value<String> dtcCode,
  Value<String?> vehicleModel,
  Value<int> causeId,
  Value<int> likelihoodScore,
  Value<bool> verifiedByMechanic,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});

final class $$DiagnosticIntelligenceTableReferences extends BaseReferences<
    _$AppDatabase, $DiagnosticIntelligenceTable, DiagnosticIntelligenceData> {
  $$DiagnosticIntelligenceTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PossibleCausesTable _causeIdTable(_$AppDatabase db) =>
      db.possibleCauses.createAlias($_aliasNameGenerator(
          db.diagnosticIntelligence.causeId, db.possibleCauses.id));

  $$PossibleCausesTableProcessedTableManager get causeId {
    final $_column = $_itemColumn<int>('cause_id')!;

    final manager = $$PossibleCausesTableTableManager($_db, $_db.possibleCauses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_causeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DiagnosticIntelligenceTableFilterComposer
    extends Composer<_$AppDatabase, $DiagnosticIntelligenceTable> {
  $$DiagnosticIntelligenceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dtcCode => $composableBuilder(
      column: $table.dtcCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get likelihoodScore => $composableBuilder(
      column: $table.likelihoodScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get verifiedByMechanic => $composableBuilder(
      column: $table.verifiedByMechanic,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$PossibleCausesTableFilterComposer get causeId {
    final $$PossibleCausesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.causeId,
        referencedTable: $db.possibleCauses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PossibleCausesTableFilterComposer(
              $db: $db,
              $table: $db.possibleCauses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DiagnosticIntelligenceTableOrderingComposer
    extends Composer<_$AppDatabase, $DiagnosticIntelligenceTable> {
  $$DiagnosticIntelligenceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dtcCode => $composableBuilder(
      column: $table.dtcCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get likelihoodScore => $composableBuilder(
      column: $table.likelihoodScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get verifiedByMechanic => $composableBuilder(
      column: $table.verifiedByMechanic,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$PossibleCausesTableOrderingComposer get causeId {
    final $$PossibleCausesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.causeId,
        referencedTable: $db.possibleCauses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PossibleCausesTableOrderingComposer(
              $db: $db,
              $table: $db.possibleCauses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DiagnosticIntelligenceTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiagnosticIntelligenceTable> {
  $$DiagnosticIntelligenceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dtcCode =>
      $composableBuilder(column: $table.dtcCode, builder: (column) => column);

  GeneratedColumn<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel, builder: (column) => column);

  GeneratedColumn<int> get likelihoodScore => $composableBuilder(
      column: $table.likelihoodScore, builder: (column) => column);

  GeneratedColumn<bool> get verifiedByMechanic => $composableBuilder(
      column: $table.verifiedByMechanic, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PossibleCausesTableAnnotationComposer get causeId {
    final $$PossibleCausesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.causeId,
        referencedTable: $db.possibleCauses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PossibleCausesTableAnnotationComposer(
              $db: $db,
              $table: $db.possibleCauses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DiagnosticIntelligenceTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DiagnosticIntelligenceTable,
    DiagnosticIntelligenceData,
    $$DiagnosticIntelligenceTableFilterComposer,
    $$DiagnosticIntelligenceTableOrderingComposer,
    $$DiagnosticIntelligenceTableAnnotationComposer,
    $$DiagnosticIntelligenceTableCreateCompanionBuilder,
    $$DiagnosticIntelligenceTableUpdateCompanionBuilder,
    (DiagnosticIntelligenceData, $$DiagnosticIntelligenceTableReferences),
    DiagnosticIntelligenceData,
    PrefetchHooks Function({bool causeId})> {
  $$DiagnosticIntelligenceTableTableManager(
      _$AppDatabase db, $DiagnosticIntelligenceTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosticIntelligenceTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosticIntelligenceTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosticIntelligenceTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> dtcCode = const Value.absent(),
            Value<String?> vehicleModel = const Value.absent(),
            Value<int> causeId = const Value.absent(),
            Value<int> likelihoodScore = const Value.absent(),
            Value<bool> verifiedByMechanic = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DiagnosticIntelligenceCompanion(
            id: id,
            dtcCode: dtcCode,
            vehicleModel: vehicleModel,
            causeId: causeId,
            likelihoodScore: likelihoodScore,
            verifiedByMechanic: verifiedByMechanic,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String dtcCode,
            Value<String?> vehicleModel = const Value.absent(),
            required int causeId,
            Value<int> likelihoodScore = const Value.absent(),
            Value<bool> verifiedByMechanic = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DiagnosticIntelligenceCompanion.insert(
            id: id,
            dtcCode: dtcCode,
            vehicleModel: vehicleModel,
            causeId: causeId,
            likelihoodScore: likelihoodScore,
            verifiedByMechanic: verifiedByMechanic,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DiagnosticIntelligenceTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({causeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (causeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.causeId,
                    referencedTable: $$DiagnosticIntelligenceTableReferences
                        ._causeIdTable(db),
                    referencedColumn: $$DiagnosticIntelligenceTableReferences
                        ._causeIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DiagnosticIntelligenceTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DiagnosticIntelligenceTable,
        DiagnosticIntelligenceData,
        $$DiagnosticIntelligenceTableFilterComposer,
        $$DiagnosticIntelligenceTableOrderingComposer,
        $$DiagnosticIntelligenceTableAnnotationComposer,
        $$DiagnosticIntelligenceTableCreateCompanionBuilder,
        $$DiagnosticIntelligenceTableUpdateCompanionBuilder,
        (DiagnosticIntelligenceData, $$DiagnosticIntelligenceTableReferences),
        DiagnosticIntelligenceData,
        PrefetchHooks Function({bool causeId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$ScanHistoryTableTableManager get scanHistory =>
      $$ScanHistoryTableTableManager(_db, _db.scanHistory);
  $$DtcLibraryTableTableManager get dtcLibrary =>
      $$DtcLibraryTableTableManager(_db, _db.dtcLibrary);
  $$PossibleCausesTableTableManager get possibleCauses =>
      $$PossibleCausesTableTableManager(_db, _db.possibleCauses);
  $$SolutionsTableTableManager get solutions =>
      $$SolutionsTableTableManager(_db, _db.solutions);
  $$DiagnosticIntelligenceTableTableManager get diagnosticIntelligence =>
      $$DiagnosticIntelligenceTableTableManager(
          _db, _db.diagnosticIntelligence);
}
