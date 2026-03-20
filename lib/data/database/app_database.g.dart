// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, Company> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _abbreviationMeta = const VerificationMeta(
    'abbreviation',
  );
  @override
  late final GeneratedColumn<String> abbreviation = GeneratedColumn<String>(
    'abbreviation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rucMeta = const VerificationMeta('ruc');
  @override
  late final GeneratedColumn<String> ruc = GeneratedColumn<String>(
    'ruc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mjtEmployerNumberMeta = const VerificationMeta(
    'mjtEmployerNumber',
  );
  @override
  late final GeneratedColumn<String> mjtEmployerNumber =
      GeneratedColumn<String>(
        'mjt_employer_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _logoPngMeta = const VerificationMeta(
    'logoPng',
  );
  @override
  late final GeneratedColumn<Uint8List> logoPng = GeneratedColumn<Uint8List>(
    'logo_png',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("active" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    abbreviation,
    ruc,
    address,
    phone,
    mjtEmployerNumber,
    logoPng,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Company> instance, {
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
    if (data.containsKey('abbreviation')) {
      context.handle(
        _abbreviationMeta,
        abbreviation.isAcceptableOrUnknown(
          data['abbreviation']!,
          _abbreviationMeta,
        ),
      );
    }
    if (data.containsKey('ruc')) {
      context.handle(
        _rucMeta,
        ruc.isAcceptableOrUnknown(data['ruc']!, _rucMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('mjt_employer_number')) {
      context.handle(
        _mjtEmployerNumberMeta,
        mjtEmployerNumber.isAcceptableOrUnknown(
          data['mjt_employer_number']!,
          _mjtEmployerNumberMeta,
        ),
      );
    }
    if (data.containsKey('logo_png')) {
      context.handle(
        _logoPngMeta,
        logoPng.isAcceptableOrUnknown(data['logo_png']!, _logoPngMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
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
  Company map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Company(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      abbreviation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abbreviation'],
      ),
      ruc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruc'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      mjtEmployerNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mjt_employer_number'],
      ),
      logoPng: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}logo_png'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
  }
}

class Company extends DataClass implements Insertable<Company> {
  final int id;
  final String name;
  final String? abbreviation;
  final String? ruc;
  final String? address;
  final String? phone;
  final String? mjtEmployerNumber;
  final Uint8List? logoPng;
  final bool active;
  final DateTime createdAt;
  const Company({
    required this.id,
    required this.name,
    this.abbreviation,
    this.ruc,
    this.address,
    this.phone,
    this.mjtEmployerNumber,
    this.logoPng,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || abbreviation != null) {
      map['abbreviation'] = Variable<String>(abbreviation);
    }
    if (!nullToAbsent || ruc != null) {
      map['ruc'] = Variable<String>(ruc);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || mjtEmployerNumber != null) {
      map['mjt_employer_number'] = Variable<String>(mjtEmployerNumber);
    }
    if (!nullToAbsent || logoPng != null) {
      map['logo_png'] = Variable<Uint8List>(logoPng);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      name: Value(name),
      abbreviation: abbreviation == null && nullToAbsent
          ? const Value.absent()
          : Value(abbreviation),
      ruc: ruc == null && nullToAbsent ? const Value.absent() : Value(ruc),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      mjtEmployerNumber: mjtEmployerNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(mjtEmployerNumber),
      logoPng: logoPng == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPng),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory Company.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Company(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      abbreviation: serializer.fromJson<String?>(json['abbreviation']),
      ruc: serializer.fromJson<String?>(json['ruc']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      mjtEmployerNumber: serializer.fromJson<String?>(
        json['mjtEmployerNumber'],
      ),
      logoPng: serializer.fromJson<Uint8List?>(json['logoPng']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'abbreviation': serializer.toJson<String?>(abbreviation),
      'ruc': serializer.toJson<String?>(ruc),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'mjtEmployerNumber': serializer.toJson<String?>(mjtEmployerNumber),
      'logoPng': serializer.toJson<Uint8List?>(logoPng),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Company copyWith({
    int? id,
    String? name,
    Value<String?> abbreviation = const Value.absent(),
    Value<String?> ruc = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> mjtEmployerNumber = const Value.absent(),
    Value<Uint8List?> logoPng = const Value.absent(),
    bool? active,
    DateTime? createdAt,
  }) => Company(
    id: id ?? this.id,
    name: name ?? this.name,
    abbreviation: abbreviation.present ? abbreviation.value : this.abbreviation,
    ruc: ruc.present ? ruc.value : this.ruc,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    mjtEmployerNumber: mjtEmployerNumber.present
        ? mjtEmployerNumber.value
        : this.mjtEmployerNumber,
    logoPng: logoPng.present ? logoPng.value : this.logoPng,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  Company copyWithCompanion(CompaniesCompanion data) {
    return Company(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      abbreviation: data.abbreviation.present
          ? data.abbreviation.value
          : this.abbreviation,
      ruc: data.ruc.present ? data.ruc.value : this.ruc,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      mjtEmployerNumber: data.mjtEmployerNumber.present
          ? data.mjtEmployerNumber.value
          : this.mjtEmployerNumber,
      logoPng: data.logoPng.present ? data.logoPng.value : this.logoPng,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Company(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('abbreviation: $abbreviation, ')
          ..write('ruc: $ruc, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('mjtEmployerNumber: $mjtEmployerNumber, ')
          ..write('logoPng: $logoPng, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    abbreviation,
    ruc,
    address,
    phone,
    mjtEmployerNumber,
    $driftBlobEquality.hash(logoPng),
    active,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Company &&
          other.id == this.id &&
          other.name == this.name &&
          other.abbreviation == this.abbreviation &&
          other.ruc == this.ruc &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.mjtEmployerNumber == this.mjtEmployerNumber &&
          $driftBlobEquality.equals(other.logoPng, this.logoPng) &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class CompaniesCompanion extends UpdateCompanion<Company> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> abbreviation;
  final Value<String?> ruc;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> mjtEmployerNumber;
  final Value<Uint8List?> logoPng;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.abbreviation = const Value.absent(),
    this.ruc = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.mjtEmployerNumber = const Value.absent(),
    this.logoPng = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CompaniesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.abbreviation = const Value.absent(),
    this.ruc = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.mjtEmployerNumber = const Value.absent(),
    this.logoPng = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Company> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? abbreviation,
    Expression<String>? ruc,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? mjtEmployerNumber,
    Expression<Uint8List>? logoPng,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (abbreviation != null) 'abbreviation': abbreviation,
      if (ruc != null) 'ruc': ruc,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (mjtEmployerNumber != null) 'mjt_employer_number': mjtEmployerNumber,
      if (logoPng != null) 'logo_png': logoPng,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CompaniesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? abbreviation,
    Value<String?>? ruc,
    Value<String?>? address,
    Value<String?>? phone,
    Value<String?>? mjtEmployerNumber,
    Value<Uint8List?>? logoPng,
    Value<bool>? active,
    Value<DateTime>? createdAt,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      ruc: ruc ?? this.ruc,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      mjtEmployerNumber: mjtEmployerNumber ?? this.mjtEmployerNumber,
      logoPng: logoPng ?? this.logoPng,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
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
    if (abbreviation.present) {
      map['abbreviation'] = Variable<String>(abbreviation.value);
    }
    if (ruc.present) {
      map['ruc'] = Variable<String>(ruc.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (mjtEmployerNumber.present) {
      map['mjt_employer_number'] = Variable<String>(mjtEmployerNumber.value);
    }
    if (logoPng.present) {
      map['logo_png'] = Variable<Uint8List>(logoPng.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('abbreviation: $abbreviation, ')
          ..write('ruc: $ruc, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('mjtEmployerNumber: $mjtEmployerNumber, ')
          ..write('logoPng: $logoPng, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DepartmentsTable extends Departments
    with TableInfo<$DepartmentsTable, Department> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepartmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
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
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("active" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    description,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'departments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Department> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, name},
  ];
  @override
  Department map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Department(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DepartmentsTable createAlias(String alias) {
    return $DepartmentsTable(attachedDatabase, alias);
  }
}

class Department extends DataClass implements Insertable<Department> {
  final int id;
  final int companyId;
  final String name;
  final String? description;
  final bool active;
  final DateTime createdAt;
  const Department({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DepartmentsCompanion toCompanion(bool nullToAbsent) {
    return DepartmentsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory Department.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Department(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Department copyWith({
    int? id,
    int? companyId,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? active,
    DateTime? createdAt,
  }) => Department(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  Department copyWithCompanion(DepartmentsCompanion data) {
    return Department(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Department(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, name, description, active, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Department &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.description == this.description &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class DepartmentsCompanion extends UpdateCompanion<Department> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  const DepartmentsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DepartmentsCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required String name,
    this.description = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : companyId = Value(companyId),
       name = Value(name);
  static Insertable<Department> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DepartmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? active,
    Value<DateTime>? createdAt,
  }) {
    return DepartmentsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: description ?? this.description,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepartmentsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DepartmentSectorsTable extends DepartmentSectors
    with TableInfo<$DepartmentSectorsTable, DepartmentSector> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepartmentSectorsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
    'department_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES departments (id) ON DELETE CASCADE',
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
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("active" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    departmentId,
    name,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'department_sectors';
  @override
  VerificationContext validateIntegrity(
    Insertable<DepartmentSector> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departmentIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {departmentId, name},
  ];
  @override
  DepartmentSector map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DepartmentSector(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}department_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DepartmentSectorsTable createAlias(String alias) {
    return $DepartmentSectorsTable(attachedDatabase, alias);
  }
}

class DepartmentSector extends DataClass
    implements Insertable<DepartmentSector> {
  final int id;
  final int departmentId;
  final String name;
  final bool active;
  final DateTime createdAt;
  const DepartmentSector({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['department_id'] = Variable<int>(departmentId);
    map['name'] = Variable<String>(name);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DepartmentSectorsCompanion toCompanion(bool nullToAbsent) {
    return DepartmentSectorsCompanion(
      id: Value(id),
      departmentId: Value(departmentId),
      name: Value(name),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory DepartmentSector.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DepartmentSector(
      id: serializer.fromJson<int>(json['id']),
      departmentId: serializer.fromJson<int>(json['departmentId']),
      name: serializer.fromJson<String>(json['name']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'departmentId': serializer.toJson<int>(departmentId),
      'name': serializer.toJson<String>(name),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DepartmentSector copyWith({
    int? id,
    int? departmentId,
    String? name,
    bool? active,
    DateTime? createdAt,
  }) => DepartmentSector(
    id: id ?? this.id,
    departmentId: departmentId ?? this.departmentId,
    name: name ?? this.name,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  DepartmentSector copyWithCompanion(DepartmentSectorsCompanion data) {
    return DepartmentSector(
      id: data.id.present ? data.id.value : this.id,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
      name: data.name.present ? data.name.value : this.name,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DepartmentSector(')
          ..write('id: $id, ')
          ..write('departmentId: $departmentId, ')
          ..write('name: $name, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, departmentId, name, active, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DepartmentSector &&
          other.id == this.id &&
          other.departmentId == this.departmentId &&
          other.name == this.name &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class DepartmentSectorsCompanion extends UpdateCompanion<DepartmentSector> {
  final Value<int> id;
  final Value<int> departmentId;
  final Value<String> name;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  const DepartmentSectorsCompanion({
    this.id = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.name = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DepartmentSectorsCompanion.insert({
    this.id = const Value.absent(),
    required int departmentId,
    required String name,
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : departmentId = Value(departmentId),
       name = Value(name);
  static Insertable<DepartmentSector> custom({
    Expression<int>? id,
    Expression<int>? departmentId,
    Expression<String>? name,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (departmentId != null) 'department_id': departmentId,
      if (name != null) 'name': name,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DepartmentSectorsCompanion copyWith({
    Value<int>? id,
    Value<int>? departmentId,
    Value<String>? name,
    Value<bool>? active,
    Value<DateTime>? createdAt,
  }) {
    return DepartmentSectorsCompanion(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      name: name ?? this.name,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepartmentSectorsCompanion(')
          ..write('id: $id, ')
          ..write('departmentId: $departmentId, ')
          ..write('name: $name, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String? value;
  const AppSetting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, Employee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _firstNamesMeta = const VerificationMeta(
    'firstNames',
  );
  @override
  late final GeneratedColumn<String> firstNames = GeneratedColumn<String>(
    'first_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastNamesMeta = const VerificationMeta(
    'lastNames',
  );
  @override
  late final GeneratedColumn<String> lastNames = GeneratedColumn<String>(
    'last_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentNumberMeta = const VerificationMeta(
    'documentNumber',
  );
  @override
  late final GeneratedColumn<String> documentNumber = GeneratedColumn<String>(
    'document_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departmentIdMeta = const VerificationMeta(
    'departmentId',
  );
  @override
  late final GeneratedColumn<int> departmentId = GeneratedColumn<int>(
    'department_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES departments (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<int> sectorId = GeneratedColumn<int>(
    'sector_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES department_sectors (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _jobTitleMeta = const VerificationMeta(
    'jobTitle',
  );
  @override
  late final GeneratedColumn<String> jobTitle = GeneratedColumn<String>(
    'job_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workLocationMeta = const VerificationMeta(
    'workLocation',
  );
  @override
  late final GeneratedColumn<String> workLocation = GeneratedColumn<String>(
    'work_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hireDateMeta = const VerificationMeta(
    'hireDate',
  );
  @override
  late final GeneratedColumn<DateTime> hireDate = GeneratedColumn<DateTime>(
    'hire_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeTypeMeta = const VerificationMeta(
    'employeeType',
  );
  @override
  late final GeneratedColumn<String> employeeType = GeneratedColumn<String>(
    'employee_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (employee_type IN (\'mensual\', \'jornalero\', \'servicio\'))',
  );
  static const VerificationMeta _baseSalaryMeta = const VerificationMeta(
    'baseSalary',
  );
  @override
  late final GeneratedColumn<double> baseSalary = GeneratedColumn<double>(
    'base_salary',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipsEnabledMeta = const VerificationMeta(
    'ipsEnabled',
  );
  @override
  late final GeneratedColumn<bool> ipsEnabled = GeneratedColumn<bool>(
    'ips_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("ips_enabled" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _childrenCountMeta = const VerificationMeta(
    'childrenCount',
  );
  @override
  late final GeneratedColumn<int> childrenCount = GeneratedColumn<int>(
    'children_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _allowOvertimeMeta = const VerificationMeta(
    'allowOvertime',
  );
  @override
  late final GeneratedColumn<bool> allowOvertime = GeneratedColumn<bool>(
    'allow_overtime',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("allow_overtime" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _biometricClockEnabledMeta =
      const VerificationMeta('biometricClockEnabled');
  @override
  late final GeneratedColumn<bool> biometricClockEnabled =
      GeneratedColumn<bool>(
        'biometric_clock_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
          SqlDialect.sqlite: 'CHECK ("biometric_clock_enabled" IN (0, 1))',
          SqlDialect.postgres: '',
        }),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _hasEmbargoMeta = const VerificationMeta(
    'hasEmbargo',
  );
  @override
  late final GeneratedColumn<bool> hasEmbargo = GeneratedColumn<bool>(
    'has_embargo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("has_embargo" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _embargoAccountMeta = const VerificationMeta(
    'embargoAccount',
  );
  @override
  late final GeneratedColumn<String> embargoAccount = GeneratedColumn<String>(
    'embargo_account',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embargoAmountMeta = const VerificationMeta(
    'embargoAmount',
  );
  @override
  late final GeneratedColumn<double> embargoAmount = GeneratedColumn<double>(
    'embargo_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workStartTime1Meta = const VerificationMeta(
    'workStartTime1',
  );
  @override
  late final GeneratedColumn<String> workStartTime1 = GeneratedColumn<String>(
    'work_start_time_1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('06:00'),
  );
  static const VerificationMeta _workStartTime2Meta = const VerificationMeta(
    'workStartTime2',
  );
  @override
  late final GeneratedColumn<String> workStartTime2 = GeneratedColumn<String>(
    'work_start_time_2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('14:00'),
  );
  static const VerificationMeta _workStartTime3Meta = const VerificationMeta(
    'workStartTime3',
  );
  @override
  late final GeneratedColumn<String> workStartTime3 = GeneratedColumn<String>(
    'work_start_time_3',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('18:00'),
  );
  static const VerificationMeta _workStartTimeSaturdayMeta =
      const VerificationMeta('workStartTimeSaturday');
  @override
  late final GeneratedColumn<String> workStartTimeSaturday =
      GeneratedColumn<String>(
        'work_start_time_saturday',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _workEndTimeSaturdayMeta =
      const VerificationMeta('workEndTimeSaturday');
  @override
  late final GeneratedColumn<String> workEndTimeSaturday =
      GeneratedColumn<String>(
        'work_end_time_saturday',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("active" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    firstNames,
    lastNames,
    fullName,
    documentNumber,
    departmentId,
    sectorId,
    jobTitle,
    workLocation,
    hireDate,
    employeeType,
    baseSalary,
    ipsEnabled,
    childrenCount,
    allowOvertime,
    biometricClockEnabled,
    hasEmbargo,
    embargoAccount,
    embargoAmount,
    phone,
    address,
    workStartTime1,
    workStartTime2,
    workStartTime3,
    workStartTimeSaturday,
    workEndTimeSaturday,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<Employee> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('first_names')) {
      context.handle(
        _firstNamesMeta,
        firstNames.isAcceptableOrUnknown(data['first_names']!, _firstNamesMeta),
      );
    }
    if (data.containsKey('last_names')) {
      context.handle(
        _lastNamesMeta,
        lastNames.isAcceptableOrUnknown(data['last_names']!, _lastNamesMeta),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('document_number')) {
      context.handle(
        _documentNumberMeta,
        documentNumber.isAcceptableOrUnknown(
          data['document_number']!,
          _documentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentNumberMeta);
    }
    if (data.containsKey('department_id')) {
      context.handle(
        _departmentIdMeta,
        departmentId.isAcceptableOrUnknown(
          data['department_id']!,
          _departmentIdMeta,
        ),
      );
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    }
    if (data.containsKey('job_title')) {
      context.handle(
        _jobTitleMeta,
        jobTitle.isAcceptableOrUnknown(data['job_title']!, _jobTitleMeta),
      );
    }
    if (data.containsKey('work_location')) {
      context.handle(
        _workLocationMeta,
        workLocation.isAcceptableOrUnknown(
          data['work_location']!,
          _workLocationMeta,
        ),
      );
    }
    if (data.containsKey('hire_date')) {
      context.handle(
        _hireDateMeta,
        hireDate.isAcceptableOrUnknown(data['hire_date']!, _hireDateMeta),
      );
    } else if (isInserting) {
      context.missing(_hireDateMeta);
    }
    if (data.containsKey('employee_type')) {
      context.handle(
        _employeeTypeMeta,
        employeeType.isAcceptableOrUnknown(
          data['employee_type']!,
          _employeeTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeTypeMeta);
    }
    if (data.containsKey('base_salary')) {
      context.handle(
        _baseSalaryMeta,
        baseSalary.isAcceptableOrUnknown(data['base_salary']!, _baseSalaryMeta),
      );
    } else if (isInserting) {
      context.missing(_baseSalaryMeta);
    }
    if (data.containsKey('ips_enabled')) {
      context.handle(
        _ipsEnabledMeta,
        ipsEnabled.isAcceptableOrUnknown(data['ips_enabled']!, _ipsEnabledMeta),
      );
    }
    if (data.containsKey('children_count')) {
      context.handle(
        _childrenCountMeta,
        childrenCount.isAcceptableOrUnknown(
          data['children_count']!,
          _childrenCountMeta,
        ),
      );
    }
    if (data.containsKey('allow_overtime')) {
      context.handle(
        _allowOvertimeMeta,
        allowOvertime.isAcceptableOrUnknown(
          data['allow_overtime']!,
          _allowOvertimeMeta,
        ),
      );
    }
    if (data.containsKey('biometric_clock_enabled')) {
      context.handle(
        _biometricClockEnabledMeta,
        biometricClockEnabled.isAcceptableOrUnknown(
          data['biometric_clock_enabled']!,
          _biometricClockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('has_embargo')) {
      context.handle(
        _hasEmbargoMeta,
        hasEmbargo.isAcceptableOrUnknown(data['has_embargo']!, _hasEmbargoMeta),
      );
    }
    if (data.containsKey('embargo_account')) {
      context.handle(
        _embargoAccountMeta,
        embargoAccount.isAcceptableOrUnknown(
          data['embargo_account']!,
          _embargoAccountMeta,
        ),
      );
    }
    if (data.containsKey('embargo_amount')) {
      context.handle(
        _embargoAmountMeta,
        embargoAmount.isAcceptableOrUnknown(
          data['embargo_amount']!,
          _embargoAmountMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('work_start_time_1')) {
      context.handle(
        _workStartTime1Meta,
        workStartTime1.isAcceptableOrUnknown(
          data['work_start_time_1']!,
          _workStartTime1Meta,
        ),
      );
    }
    if (data.containsKey('work_start_time_2')) {
      context.handle(
        _workStartTime2Meta,
        workStartTime2.isAcceptableOrUnknown(
          data['work_start_time_2']!,
          _workStartTime2Meta,
        ),
      );
    }
    if (data.containsKey('work_start_time_3')) {
      context.handle(
        _workStartTime3Meta,
        workStartTime3.isAcceptableOrUnknown(
          data['work_start_time_3']!,
          _workStartTime3Meta,
        ),
      );
    }
    if (data.containsKey('work_start_time_saturday')) {
      context.handle(
        _workStartTimeSaturdayMeta,
        workStartTimeSaturday.isAcceptableOrUnknown(
          data['work_start_time_saturday']!,
          _workStartTimeSaturdayMeta,
        ),
      );
    }
    if (data.containsKey('work_end_time_saturday')) {
      context.handle(
        _workEndTimeSaturdayMeta,
        workEndTimeSaturday.isAcceptableOrUnknown(
          data['work_end_time_saturday']!,
          _workEndTimeSaturdayMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
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
  Employee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Employee(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      firstNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_names'],
      )!,
      lastNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_names'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      documentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_number'],
      )!,
      departmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}department_id'],
      ),
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sector_id'],
      ),
      jobTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_title'],
      ),
      workLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_location'],
      ),
      hireDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hire_date'],
      )!,
      employeeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_type'],
      )!,
      baseSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_salary'],
      )!,
      ipsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ips_enabled'],
      )!,
      childrenCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}children_count'],
      )!,
      allowOvertime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_overtime'],
      )!,
      biometricClockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}biometric_clock_enabled'],
      )!,
      hasEmbargo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_embargo'],
      )!,
      embargoAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embargo_account'],
      ),
      embargoAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}embargo_amount'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      workStartTime1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_start_time_1'],
      )!,
      workStartTime2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_start_time_2'],
      )!,
      workStartTime3: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_start_time_3'],
      )!,
      workStartTimeSaturday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_start_time_saturday'],
      ),
      workEndTimeSaturday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_end_time_saturday'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class Employee extends DataClass implements Insertable<Employee> {
  final int id;
  final int companyId;
  final String firstNames;
  final String lastNames;
  final String fullName;
  final String documentNumber;
  final int? departmentId;
  final int? sectorId;
  final String? jobTitle;
  final String? workLocation;
  final DateTime hireDate;
  final String employeeType;
  final double baseSalary;
  final bool ipsEnabled;
  final int childrenCount;
  final bool allowOvertime;
  final bool biometricClockEnabled;
  final bool hasEmbargo;
  final String? embargoAccount;
  final double? embargoAmount;
  final String? phone;
  final String? address;
  final String workStartTime1;
  final String workStartTime2;
  final String workStartTime3;
  final String? workStartTimeSaturday;
  final String? workEndTimeSaturday;
  final bool active;
  final DateTime createdAt;
  const Employee({
    required this.id,
    required this.companyId,
    required this.firstNames,
    required this.lastNames,
    required this.fullName,
    required this.documentNumber,
    this.departmentId,
    this.sectorId,
    this.jobTitle,
    this.workLocation,
    required this.hireDate,
    required this.employeeType,
    required this.baseSalary,
    required this.ipsEnabled,
    required this.childrenCount,
    required this.allowOvertime,
    required this.biometricClockEnabled,
    required this.hasEmbargo,
    this.embargoAccount,
    this.embargoAmount,
    this.phone,
    this.address,
    required this.workStartTime1,
    required this.workStartTime2,
    required this.workStartTime3,
    this.workStartTimeSaturday,
    this.workEndTimeSaturday,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['first_names'] = Variable<String>(firstNames);
    map['last_names'] = Variable<String>(lastNames);
    map['full_name'] = Variable<String>(fullName);
    map['document_number'] = Variable<String>(documentNumber);
    if (!nullToAbsent || departmentId != null) {
      map['department_id'] = Variable<int>(departmentId);
    }
    if (!nullToAbsent || sectorId != null) {
      map['sector_id'] = Variable<int>(sectorId);
    }
    if (!nullToAbsent || jobTitle != null) {
      map['job_title'] = Variable<String>(jobTitle);
    }
    if (!nullToAbsent || workLocation != null) {
      map['work_location'] = Variable<String>(workLocation);
    }
    map['hire_date'] = Variable<DateTime>(hireDate);
    map['employee_type'] = Variable<String>(employeeType);
    map['base_salary'] = Variable<double>(baseSalary);
    map['ips_enabled'] = Variable<bool>(ipsEnabled);
    map['children_count'] = Variable<int>(childrenCount);
    map['allow_overtime'] = Variable<bool>(allowOvertime);
    map['biometric_clock_enabled'] = Variable<bool>(biometricClockEnabled);
    map['has_embargo'] = Variable<bool>(hasEmbargo);
    if (!nullToAbsent || embargoAccount != null) {
      map['embargo_account'] = Variable<String>(embargoAccount);
    }
    if (!nullToAbsent || embargoAmount != null) {
      map['embargo_amount'] = Variable<double>(embargoAmount);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['work_start_time_1'] = Variable<String>(workStartTime1);
    map['work_start_time_2'] = Variable<String>(workStartTime2);
    map['work_start_time_3'] = Variable<String>(workStartTime3);
    if (!nullToAbsent || workStartTimeSaturday != null) {
      map['work_start_time_saturday'] = Variable<String>(workStartTimeSaturday);
    }
    if (!nullToAbsent || workEndTimeSaturday != null) {
      map['work_end_time_saturday'] = Variable<String>(workEndTimeSaturday);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      firstNames: Value(firstNames),
      lastNames: Value(lastNames),
      fullName: Value(fullName),
      documentNumber: Value(documentNumber),
      departmentId: departmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(departmentId),
      sectorId: sectorId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectorId),
      jobTitle: jobTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(jobTitle),
      workLocation: workLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(workLocation),
      hireDate: Value(hireDate),
      employeeType: Value(employeeType),
      baseSalary: Value(baseSalary),
      ipsEnabled: Value(ipsEnabled),
      childrenCount: Value(childrenCount),
      allowOvertime: Value(allowOvertime),
      biometricClockEnabled: Value(biometricClockEnabled),
      hasEmbargo: Value(hasEmbargo),
      embargoAccount: embargoAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(embargoAccount),
      embargoAmount: embargoAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(embargoAmount),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      workStartTime1: Value(workStartTime1),
      workStartTime2: Value(workStartTime2),
      workStartTime3: Value(workStartTime3),
      workStartTimeSaturday: workStartTimeSaturday == null && nullToAbsent
          ? const Value.absent()
          : Value(workStartTimeSaturday),
      workEndTimeSaturday: workEndTimeSaturday == null && nullToAbsent
          ? const Value.absent()
          : Value(workEndTimeSaturday),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory Employee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Employee(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      firstNames: serializer.fromJson<String>(json['firstNames']),
      lastNames: serializer.fromJson<String>(json['lastNames']),
      fullName: serializer.fromJson<String>(json['fullName']),
      documentNumber: serializer.fromJson<String>(json['documentNumber']),
      departmentId: serializer.fromJson<int?>(json['departmentId']),
      sectorId: serializer.fromJson<int?>(json['sectorId']),
      jobTitle: serializer.fromJson<String?>(json['jobTitle']),
      workLocation: serializer.fromJson<String?>(json['workLocation']),
      hireDate: serializer.fromJson<DateTime>(json['hireDate']),
      employeeType: serializer.fromJson<String>(json['employeeType']),
      baseSalary: serializer.fromJson<double>(json['baseSalary']),
      ipsEnabled: serializer.fromJson<bool>(json['ipsEnabled']),
      childrenCount: serializer.fromJson<int>(json['childrenCount']),
      allowOvertime: serializer.fromJson<bool>(json['allowOvertime']),
      biometricClockEnabled: serializer.fromJson<bool>(
        json['biometricClockEnabled'],
      ),
      hasEmbargo: serializer.fromJson<bool>(json['hasEmbargo']),
      embargoAccount: serializer.fromJson<String?>(json['embargoAccount']),
      embargoAmount: serializer.fromJson<double?>(json['embargoAmount']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      workStartTime1: serializer.fromJson<String>(json['workStartTime1']),
      workStartTime2: serializer.fromJson<String>(json['workStartTime2']),
      workStartTime3: serializer.fromJson<String>(json['workStartTime3']),
      workStartTimeSaturday: serializer.fromJson<String?>(
        json['workStartTimeSaturday'],
      ),
      workEndTimeSaturday: serializer.fromJson<String?>(
        json['workEndTimeSaturday'],
      ),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'firstNames': serializer.toJson<String>(firstNames),
      'lastNames': serializer.toJson<String>(lastNames),
      'fullName': serializer.toJson<String>(fullName),
      'documentNumber': serializer.toJson<String>(documentNumber),
      'departmentId': serializer.toJson<int?>(departmentId),
      'sectorId': serializer.toJson<int?>(sectorId),
      'jobTitle': serializer.toJson<String?>(jobTitle),
      'workLocation': serializer.toJson<String?>(workLocation),
      'hireDate': serializer.toJson<DateTime>(hireDate),
      'employeeType': serializer.toJson<String>(employeeType),
      'baseSalary': serializer.toJson<double>(baseSalary),
      'ipsEnabled': serializer.toJson<bool>(ipsEnabled),
      'childrenCount': serializer.toJson<int>(childrenCount),
      'allowOvertime': serializer.toJson<bool>(allowOvertime),
      'biometricClockEnabled': serializer.toJson<bool>(biometricClockEnabled),
      'hasEmbargo': serializer.toJson<bool>(hasEmbargo),
      'embargoAccount': serializer.toJson<String?>(embargoAccount),
      'embargoAmount': serializer.toJson<double?>(embargoAmount),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'workStartTime1': serializer.toJson<String>(workStartTime1),
      'workStartTime2': serializer.toJson<String>(workStartTime2),
      'workStartTime3': serializer.toJson<String>(workStartTime3),
      'workStartTimeSaturday': serializer.toJson<String?>(
        workStartTimeSaturday,
      ),
      'workEndTimeSaturday': serializer.toJson<String?>(workEndTimeSaturday),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Employee copyWith({
    int? id,
    int? companyId,
    String? firstNames,
    String? lastNames,
    String? fullName,
    String? documentNumber,
    Value<int?> departmentId = const Value.absent(),
    Value<int?> sectorId = const Value.absent(),
    Value<String?> jobTitle = const Value.absent(),
    Value<String?> workLocation = const Value.absent(),
    DateTime? hireDate,
    String? employeeType,
    double? baseSalary,
    bool? ipsEnabled,
    int? childrenCount,
    bool? allowOvertime,
    bool? biometricClockEnabled,
    bool? hasEmbargo,
    Value<String?> embargoAccount = const Value.absent(),
    Value<double?> embargoAmount = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    String? workStartTime1,
    String? workStartTime2,
    String? workStartTime3,
    Value<String?> workStartTimeSaturday = const Value.absent(),
    Value<String?> workEndTimeSaturday = const Value.absent(),
    bool? active,
    DateTime? createdAt,
  }) => Employee(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    firstNames: firstNames ?? this.firstNames,
    lastNames: lastNames ?? this.lastNames,
    fullName: fullName ?? this.fullName,
    documentNumber: documentNumber ?? this.documentNumber,
    departmentId: departmentId.present ? departmentId.value : this.departmentId,
    sectorId: sectorId.present ? sectorId.value : this.sectorId,
    jobTitle: jobTitle.present ? jobTitle.value : this.jobTitle,
    workLocation: workLocation.present ? workLocation.value : this.workLocation,
    hireDate: hireDate ?? this.hireDate,
    employeeType: employeeType ?? this.employeeType,
    baseSalary: baseSalary ?? this.baseSalary,
    ipsEnabled: ipsEnabled ?? this.ipsEnabled,
    childrenCount: childrenCount ?? this.childrenCount,
    allowOvertime: allowOvertime ?? this.allowOvertime,
    biometricClockEnabled: biometricClockEnabled ?? this.biometricClockEnabled,
    hasEmbargo: hasEmbargo ?? this.hasEmbargo,
    embargoAccount: embargoAccount.present
        ? embargoAccount.value
        : this.embargoAccount,
    embargoAmount: embargoAmount.present
        ? embargoAmount.value
        : this.embargoAmount,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    workStartTime1: workStartTime1 ?? this.workStartTime1,
    workStartTime2: workStartTime2 ?? this.workStartTime2,
    workStartTime3: workStartTime3 ?? this.workStartTime3,
    workStartTimeSaturday: workStartTimeSaturday.present
        ? workStartTimeSaturday.value
        : this.workStartTimeSaturday,
    workEndTimeSaturday: workEndTimeSaturday.present
        ? workEndTimeSaturday.value
        : this.workEndTimeSaturday,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  Employee copyWithCompanion(EmployeesCompanion data) {
    return Employee(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      firstNames: data.firstNames.present
          ? data.firstNames.value
          : this.firstNames,
      lastNames: data.lastNames.present ? data.lastNames.value : this.lastNames,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      documentNumber: data.documentNumber.present
          ? data.documentNumber.value
          : this.documentNumber,
      departmentId: data.departmentId.present
          ? data.departmentId.value
          : this.departmentId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      jobTitle: data.jobTitle.present ? data.jobTitle.value : this.jobTitle,
      workLocation: data.workLocation.present
          ? data.workLocation.value
          : this.workLocation,
      hireDate: data.hireDate.present ? data.hireDate.value : this.hireDate,
      employeeType: data.employeeType.present
          ? data.employeeType.value
          : this.employeeType,
      baseSalary: data.baseSalary.present
          ? data.baseSalary.value
          : this.baseSalary,
      ipsEnabled: data.ipsEnabled.present
          ? data.ipsEnabled.value
          : this.ipsEnabled,
      childrenCount: data.childrenCount.present
          ? data.childrenCount.value
          : this.childrenCount,
      allowOvertime: data.allowOvertime.present
          ? data.allowOvertime.value
          : this.allowOvertime,
      biometricClockEnabled: data.biometricClockEnabled.present
          ? data.biometricClockEnabled.value
          : this.biometricClockEnabled,
      hasEmbargo: data.hasEmbargo.present
          ? data.hasEmbargo.value
          : this.hasEmbargo,
      embargoAccount: data.embargoAccount.present
          ? data.embargoAccount.value
          : this.embargoAccount,
      embargoAmount: data.embargoAmount.present
          ? data.embargoAmount.value
          : this.embargoAmount,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      workStartTime1: data.workStartTime1.present
          ? data.workStartTime1.value
          : this.workStartTime1,
      workStartTime2: data.workStartTime2.present
          ? data.workStartTime2.value
          : this.workStartTime2,
      workStartTime3: data.workStartTime3.present
          ? data.workStartTime3.value
          : this.workStartTime3,
      workStartTimeSaturday: data.workStartTimeSaturday.present
          ? data.workStartTimeSaturday.value
          : this.workStartTimeSaturday,
      workEndTimeSaturday: data.workEndTimeSaturday.present
          ? data.workEndTimeSaturday.value
          : this.workEndTimeSaturday,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Employee(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('firstNames: $firstNames, ')
          ..write('lastNames: $lastNames, ')
          ..write('fullName: $fullName, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('departmentId: $departmentId, ')
          ..write('sectorId: $sectorId, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('workLocation: $workLocation, ')
          ..write('hireDate: $hireDate, ')
          ..write('employeeType: $employeeType, ')
          ..write('baseSalary: $baseSalary, ')
          ..write('ipsEnabled: $ipsEnabled, ')
          ..write('childrenCount: $childrenCount, ')
          ..write('allowOvertime: $allowOvertime, ')
          ..write('biometricClockEnabled: $biometricClockEnabled, ')
          ..write('hasEmbargo: $hasEmbargo, ')
          ..write('embargoAccount: $embargoAccount, ')
          ..write('embargoAmount: $embargoAmount, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('workStartTime1: $workStartTime1, ')
          ..write('workStartTime2: $workStartTime2, ')
          ..write('workStartTime3: $workStartTime3, ')
          ..write('workStartTimeSaturday: $workStartTimeSaturday, ')
          ..write('workEndTimeSaturday: $workEndTimeSaturday, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    firstNames,
    lastNames,
    fullName,
    documentNumber,
    departmentId,
    sectorId,
    jobTitle,
    workLocation,
    hireDate,
    employeeType,
    baseSalary,
    ipsEnabled,
    childrenCount,
    allowOvertime,
    biometricClockEnabled,
    hasEmbargo,
    embargoAccount,
    embargoAmount,
    phone,
    address,
    workStartTime1,
    workStartTime2,
    workStartTime3,
    workStartTimeSaturday,
    workEndTimeSaturday,
    active,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.firstNames == this.firstNames &&
          other.lastNames == this.lastNames &&
          other.fullName == this.fullName &&
          other.documentNumber == this.documentNumber &&
          other.departmentId == this.departmentId &&
          other.sectorId == this.sectorId &&
          other.jobTitle == this.jobTitle &&
          other.workLocation == this.workLocation &&
          other.hireDate == this.hireDate &&
          other.employeeType == this.employeeType &&
          other.baseSalary == this.baseSalary &&
          other.ipsEnabled == this.ipsEnabled &&
          other.childrenCount == this.childrenCount &&
          other.allowOvertime == this.allowOvertime &&
          other.biometricClockEnabled == this.biometricClockEnabled &&
          other.hasEmbargo == this.hasEmbargo &&
          other.embargoAccount == this.embargoAccount &&
          other.embargoAmount == this.embargoAmount &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.workStartTime1 == this.workStartTime1 &&
          other.workStartTime2 == this.workStartTime2 &&
          other.workStartTime3 == this.workStartTime3 &&
          other.workStartTimeSaturday == this.workStartTimeSaturday &&
          other.workEndTimeSaturday == this.workEndTimeSaturday &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<String> firstNames;
  final Value<String> lastNames;
  final Value<String> fullName;
  final Value<String> documentNumber;
  final Value<int?> departmentId;
  final Value<int?> sectorId;
  final Value<String?> jobTitle;
  final Value<String?> workLocation;
  final Value<DateTime> hireDate;
  final Value<String> employeeType;
  final Value<double> baseSalary;
  final Value<bool> ipsEnabled;
  final Value<int> childrenCount;
  final Value<bool> allowOvertime;
  final Value<bool> biometricClockEnabled;
  final Value<bool> hasEmbargo;
  final Value<String?> embargoAccount;
  final Value<double?> embargoAmount;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String> workStartTime1;
  final Value<String> workStartTime2;
  final Value<String> workStartTime3;
  final Value<String?> workStartTimeSaturday;
  final Value<String?> workEndTimeSaturday;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.firstNames = const Value.absent(),
    this.lastNames = const Value.absent(),
    this.fullName = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.departmentId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.workLocation = const Value.absent(),
    this.hireDate = const Value.absent(),
    this.employeeType = const Value.absent(),
    this.baseSalary = const Value.absent(),
    this.ipsEnabled = const Value.absent(),
    this.childrenCount = const Value.absent(),
    this.allowOvertime = const Value.absent(),
    this.biometricClockEnabled = const Value.absent(),
    this.hasEmbargo = const Value.absent(),
    this.embargoAccount = const Value.absent(),
    this.embargoAmount = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.workStartTime1 = const Value.absent(),
    this.workStartTime2 = const Value.absent(),
    this.workStartTime3 = const Value.absent(),
    this.workStartTimeSaturday = const Value.absent(),
    this.workEndTimeSaturday = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EmployeesCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    this.firstNames = const Value.absent(),
    this.lastNames = const Value.absent(),
    required String fullName,
    required String documentNumber,
    this.departmentId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.workLocation = const Value.absent(),
    required DateTime hireDate,
    required String employeeType,
    required double baseSalary,
    this.ipsEnabled = const Value.absent(),
    this.childrenCount = const Value.absent(),
    this.allowOvertime = const Value.absent(),
    this.biometricClockEnabled = const Value.absent(),
    this.hasEmbargo = const Value.absent(),
    this.embargoAccount = const Value.absent(),
    this.embargoAmount = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.workStartTime1 = const Value.absent(),
    this.workStartTime2 = const Value.absent(),
    this.workStartTime3 = const Value.absent(),
    this.workStartTimeSaturday = const Value.absent(),
    this.workEndTimeSaturday = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : companyId = Value(companyId),
       fullName = Value(fullName),
       documentNumber = Value(documentNumber),
       hireDate = Value(hireDate),
       employeeType = Value(employeeType),
       baseSalary = Value(baseSalary);
  static Insertable<Employee> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<String>? firstNames,
    Expression<String>? lastNames,
    Expression<String>? fullName,
    Expression<String>? documentNumber,
    Expression<int>? departmentId,
    Expression<int>? sectorId,
    Expression<String>? jobTitle,
    Expression<String>? workLocation,
    Expression<DateTime>? hireDate,
    Expression<String>? employeeType,
    Expression<double>? baseSalary,
    Expression<bool>? ipsEnabled,
    Expression<int>? childrenCount,
    Expression<bool>? allowOvertime,
    Expression<bool>? biometricClockEnabled,
    Expression<bool>? hasEmbargo,
    Expression<String>? embargoAccount,
    Expression<double>? embargoAmount,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? workStartTime1,
    Expression<String>? workStartTime2,
    Expression<String>? workStartTime3,
    Expression<String>? workStartTimeSaturday,
    Expression<String>? workEndTimeSaturday,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (firstNames != null) 'first_names': firstNames,
      if (lastNames != null) 'last_names': lastNames,
      if (fullName != null) 'full_name': fullName,
      if (documentNumber != null) 'document_number': documentNumber,
      if (departmentId != null) 'department_id': departmentId,
      if (sectorId != null) 'sector_id': sectorId,
      if (jobTitle != null) 'job_title': jobTitle,
      if (workLocation != null) 'work_location': workLocation,
      if (hireDate != null) 'hire_date': hireDate,
      if (employeeType != null) 'employee_type': employeeType,
      if (baseSalary != null) 'base_salary': baseSalary,
      if (ipsEnabled != null) 'ips_enabled': ipsEnabled,
      if (childrenCount != null) 'children_count': childrenCount,
      if (allowOvertime != null) 'allow_overtime': allowOvertime,
      if (biometricClockEnabled != null)
        'biometric_clock_enabled': biometricClockEnabled,
      if (hasEmbargo != null) 'has_embargo': hasEmbargo,
      if (embargoAccount != null) 'embargo_account': embargoAccount,
      if (embargoAmount != null) 'embargo_amount': embargoAmount,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (workStartTime1 != null) 'work_start_time_1': workStartTime1,
      if (workStartTime2 != null) 'work_start_time_2': workStartTime2,
      if (workStartTime3 != null) 'work_start_time_3': workStartTime3,
      if (workStartTimeSaturday != null)
        'work_start_time_saturday': workStartTimeSaturday,
      if (workEndTimeSaturday != null)
        'work_end_time_saturday': workEndTimeSaturday,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EmployeesCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<String>? firstNames,
    Value<String>? lastNames,
    Value<String>? fullName,
    Value<String>? documentNumber,
    Value<int?>? departmentId,
    Value<int?>? sectorId,
    Value<String?>? jobTitle,
    Value<String?>? workLocation,
    Value<DateTime>? hireDate,
    Value<String>? employeeType,
    Value<double>? baseSalary,
    Value<bool>? ipsEnabled,
    Value<int>? childrenCount,
    Value<bool>? allowOvertime,
    Value<bool>? biometricClockEnabled,
    Value<bool>? hasEmbargo,
    Value<String?>? embargoAccount,
    Value<double?>? embargoAmount,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String>? workStartTime1,
    Value<String>? workStartTime2,
    Value<String>? workStartTime3,
    Value<String?>? workStartTimeSaturday,
    Value<String?>? workEndTimeSaturday,
    Value<bool>? active,
    Value<DateTime>? createdAt,
  }) {
    return EmployeesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      firstNames: firstNames ?? this.firstNames,
      lastNames: lastNames ?? this.lastNames,
      fullName: fullName ?? this.fullName,
      documentNumber: documentNumber ?? this.documentNumber,
      departmentId: departmentId ?? this.departmentId,
      sectorId: sectorId ?? this.sectorId,
      jobTitle: jobTitle ?? this.jobTitle,
      workLocation: workLocation ?? this.workLocation,
      hireDate: hireDate ?? this.hireDate,
      employeeType: employeeType ?? this.employeeType,
      baseSalary: baseSalary ?? this.baseSalary,
      ipsEnabled: ipsEnabled ?? this.ipsEnabled,
      childrenCount: childrenCount ?? this.childrenCount,
      allowOvertime: allowOvertime ?? this.allowOvertime,
      biometricClockEnabled:
          biometricClockEnabled ?? this.biometricClockEnabled,
      hasEmbargo: hasEmbargo ?? this.hasEmbargo,
      embargoAccount: embargoAccount ?? this.embargoAccount,
      embargoAmount: embargoAmount ?? this.embargoAmount,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      workStartTime1: workStartTime1 ?? this.workStartTime1,
      workStartTime2: workStartTime2 ?? this.workStartTime2,
      workStartTime3: workStartTime3 ?? this.workStartTime3,
      workStartTimeSaturday:
          workStartTimeSaturday ?? this.workStartTimeSaturday,
      workEndTimeSaturday: workEndTimeSaturday ?? this.workEndTimeSaturday,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (firstNames.present) {
      map['first_names'] = Variable<String>(firstNames.value);
    }
    if (lastNames.present) {
      map['last_names'] = Variable<String>(lastNames.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (documentNumber.present) {
      map['document_number'] = Variable<String>(documentNumber.value);
    }
    if (departmentId.present) {
      map['department_id'] = Variable<int>(departmentId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<int>(sectorId.value);
    }
    if (jobTitle.present) {
      map['job_title'] = Variable<String>(jobTitle.value);
    }
    if (workLocation.present) {
      map['work_location'] = Variable<String>(workLocation.value);
    }
    if (hireDate.present) {
      map['hire_date'] = Variable<DateTime>(hireDate.value);
    }
    if (employeeType.present) {
      map['employee_type'] = Variable<String>(employeeType.value);
    }
    if (baseSalary.present) {
      map['base_salary'] = Variable<double>(baseSalary.value);
    }
    if (ipsEnabled.present) {
      map['ips_enabled'] = Variable<bool>(ipsEnabled.value);
    }
    if (childrenCount.present) {
      map['children_count'] = Variable<int>(childrenCount.value);
    }
    if (allowOvertime.present) {
      map['allow_overtime'] = Variable<bool>(allowOvertime.value);
    }
    if (biometricClockEnabled.present) {
      map['biometric_clock_enabled'] = Variable<bool>(
        biometricClockEnabled.value,
      );
    }
    if (hasEmbargo.present) {
      map['has_embargo'] = Variable<bool>(hasEmbargo.value);
    }
    if (embargoAccount.present) {
      map['embargo_account'] = Variable<String>(embargoAccount.value);
    }
    if (embargoAmount.present) {
      map['embargo_amount'] = Variable<double>(embargoAmount.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (workStartTime1.present) {
      map['work_start_time_1'] = Variable<String>(workStartTime1.value);
    }
    if (workStartTime2.present) {
      map['work_start_time_2'] = Variable<String>(workStartTime2.value);
    }
    if (workStartTime3.present) {
      map['work_start_time_3'] = Variable<String>(workStartTime3.value);
    }
    if (workStartTimeSaturday.present) {
      map['work_start_time_saturday'] = Variable<String>(
        workStartTimeSaturday.value,
      );
    }
    if (workEndTimeSaturday.present) {
      map['work_end_time_saturday'] = Variable<String>(
        workEndTimeSaturday.value,
      );
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('firstNames: $firstNames, ')
          ..write('lastNames: $lastNames, ')
          ..write('fullName: $fullName, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('departmentId: $departmentId, ')
          ..write('sectorId: $sectorId, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('workLocation: $workLocation, ')
          ..write('hireDate: $hireDate, ')
          ..write('employeeType: $employeeType, ')
          ..write('baseSalary: $baseSalary, ')
          ..write('ipsEnabled: $ipsEnabled, ')
          ..write('childrenCount: $childrenCount, ')
          ..write('allowOvertime: $allowOvertime, ')
          ..write('biometricClockEnabled: $biometricClockEnabled, ')
          ..write('hasEmbargo: $hasEmbargo, ')
          ..write('embargoAccount: $embargoAccount, ')
          ..write('embargoAmount: $embargoAmount, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('workStartTime1: $workStartTime1, ')
          ..write('workStartTime2: $workStartTime2, ')
          ..write('workStartTime3: $workStartTime3, ')
          ..write('workStartTimeSaturday: $workStartTimeSaturday, ')
          ..write('workEndTimeSaturday: $workEndTimeSaturday, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AttendanceEventsTable extends AttendanceEvents
    with TableInfo<$AttendanceEventsTable, AttendanceEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES employees (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (event_type IN (\'presente\', \'ausente\', \'permiso_remunerado\', \'permiso_no_remunerado\', \'vacaciones\', \'paternidad\', \'duelo\', \'reposo\', \'tardanza\'))',
  );
  static const VerificationMeta _minutesLateMeta = const VerificationMeta(
    'minutesLate',
  );
  @override
  late final GeneratedColumn<int> minutesLate = GeneratedColumn<int>(
    'minutes_late',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hoursWorkedMeta = const VerificationMeta(
    'hoursWorked',
  );
  @override
  late final GeneratedColumn<double> hoursWorked = GeneratedColumn<double>(
    'hours_worked',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overtimeHoursMeta = const VerificationMeta(
    'overtimeHours',
  );
  @override
  late final GeneratedColumn<double> overtimeHours = GeneratedColumn<double>(
    'overtime_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overtimeTypeMeta = const VerificationMeta(
    'overtimeType',
  );
  @override
  late final GeneratedColumn<String> overtimeType = GeneratedColumn<String>(
    'overtime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkInTimeMeta = const VerificationMeta(
    'checkInTime',
  );
  @override
  late final GeneratedColumn<String> checkInTime = GeneratedColumn<String>(
    'check_in_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkOutTimeMeta = const VerificationMeta(
    'checkOutTime',
  );
  @override
  late final GeneratedColumn<String> checkOutTime = GeneratedColumn<String>(
    'check_out_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakMinutesMeta = const VerificationMeta(
    'breakMinutes',
  );
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
    'break_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    employeeId,
    date,
    eventType,
    minutesLate,
    hoursWorked,
    overtimeHours,
    overtimeType,
    checkInTime,
    checkOutTime,
    breakMinutes,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('minutes_late')) {
      context.handle(
        _minutesLateMeta,
        minutesLate.isAcceptableOrUnknown(
          data['minutes_late']!,
          _minutesLateMeta,
        ),
      );
    }
    if (data.containsKey('hours_worked')) {
      context.handle(
        _hoursWorkedMeta,
        hoursWorked.isAcceptableOrUnknown(
          data['hours_worked']!,
          _hoursWorkedMeta,
        ),
      );
    }
    if (data.containsKey('overtime_hours')) {
      context.handle(
        _overtimeHoursMeta,
        overtimeHours.isAcceptableOrUnknown(
          data['overtime_hours']!,
          _overtimeHoursMeta,
        ),
      );
    }
    if (data.containsKey('overtime_type')) {
      context.handle(
        _overtimeTypeMeta,
        overtimeType.isAcceptableOrUnknown(
          data['overtime_type']!,
          _overtimeTypeMeta,
        ),
      );
    }
    if (data.containsKey('check_in_time')) {
      context.handle(
        _checkInTimeMeta,
        checkInTime.isAcceptableOrUnknown(
          data['check_in_time']!,
          _checkInTimeMeta,
        ),
      );
    }
    if (data.containsKey('check_out_time')) {
      context.handle(
        _checkOutTimeMeta,
        checkOutTime.isAcceptableOrUnknown(
          data['check_out_time']!,
          _checkOutTimeMeta,
        ),
      );
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
        _breakMinutesMeta,
        breakMinutes.isAcceptableOrUnknown(
          data['break_minutes']!,
          _breakMinutesMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
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
  AttendanceEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employee_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      minutesLate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_late'],
      ),
      hoursWorked: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hours_worked'],
      ),
      overtimeHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overtime_hours'],
      ),
      overtimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overtime_type'],
      ),
      checkInTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_in_time'],
      ),
      checkOutTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_out_time'],
      ),
      breakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_minutes'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttendanceEventsTable createAlias(String alias) {
    return $AttendanceEventsTable(attachedDatabase, alias);
  }
}

class AttendanceEvent extends DataClass implements Insertable<AttendanceEvent> {
  final int id;
  final int companyId;
  final int employeeId;
  final DateTime date;
  final String eventType;
  final int? minutesLate;
  final double? hoursWorked;
  final double? overtimeHours;
  final String? overtimeType;
  final String? checkInTime;
  final String? checkOutTime;
  final int? breakMinutes;
  final String? notes;
  final DateTime createdAt;
  const AttendanceEvent({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.date,
    required this.eventType,
    this.minutesLate,
    this.hoursWorked,
    this.overtimeHours,
    this.overtimeType,
    this.checkInTime,
    this.checkOutTime,
    this.breakMinutes,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['employee_id'] = Variable<int>(employeeId);
    map['date'] = Variable<DateTime>(date);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || minutesLate != null) {
      map['minutes_late'] = Variable<int>(minutesLate);
    }
    if (!nullToAbsent || hoursWorked != null) {
      map['hours_worked'] = Variable<double>(hoursWorked);
    }
    if (!nullToAbsent || overtimeHours != null) {
      map['overtime_hours'] = Variable<double>(overtimeHours);
    }
    if (!nullToAbsent || overtimeType != null) {
      map['overtime_type'] = Variable<String>(overtimeType);
    }
    if (!nullToAbsent || checkInTime != null) {
      map['check_in_time'] = Variable<String>(checkInTime);
    }
    if (!nullToAbsent || checkOutTime != null) {
      map['check_out_time'] = Variable<String>(checkOutTime);
    }
    if (!nullToAbsent || breakMinutes != null) {
      map['break_minutes'] = Variable<int>(breakMinutes);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttendanceEventsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceEventsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      employeeId: Value(employeeId),
      date: Value(date),
      eventType: Value(eventType),
      minutesLate: minutesLate == null && nullToAbsent
          ? const Value.absent()
          : Value(minutesLate),
      hoursWorked: hoursWorked == null && nullToAbsent
          ? const Value.absent()
          : Value(hoursWorked),
      overtimeHours: overtimeHours == null && nullToAbsent
          ? const Value.absent()
          : Value(overtimeHours),
      overtimeType: overtimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(overtimeType),
      checkInTime: checkInTime == null && nullToAbsent
          ? const Value.absent()
          : Value(checkInTime),
      checkOutTime: checkOutTime == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutTime),
      breakMinutes: breakMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(breakMinutes),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory AttendanceEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceEvent(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      employeeId: serializer.fromJson<int>(json['employeeId']),
      date: serializer.fromJson<DateTime>(json['date']),
      eventType: serializer.fromJson<String>(json['eventType']),
      minutesLate: serializer.fromJson<int?>(json['minutesLate']),
      hoursWorked: serializer.fromJson<double?>(json['hoursWorked']),
      overtimeHours: serializer.fromJson<double?>(json['overtimeHours']),
      overtimeType: serializer.fromJson<String?>(json['overtimeType']),
      checkInTime: serializer.fromJson<String?>(json['checkInTime']),
      checkOutTime: serializer.fromJson<String?>(json['checkOutTime']),
      breakMinutes: serializer.fromJson<int?>(json['breakMinutes']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'employeeId': serializer.toJson<int>(employeeId),
      'date': serializer.toJson<DateTime>(date),
      'eventType': serializer.toJson<String>(eventType),
      'minutesLate': serializer.toJson<int?>(minutesLate),
      'hoursWorked': serializer.toJson<double?>(hoursWorked),
      'overtimeHours': serializer.toJson<double?>(overtimeHours),
      'overtimeType': serializer.toJson<String?>(overtimeType),
      'checkInTime': serializer.toJson<String?>(checkInTime),
      'checkOutTime': serializer.toJson<String?>(checkOutTime),
      'breakMinutes': serializer.toJson<int?>(breakMinutes),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttendanceEvent copyWith({
    int? id,
    int? companyId,
    int? employeeId,
    DateTime? date,
    String? eventType,
    Value<int?> minutesLate = const Value.absent(),
    Value<double?> hoursWorked = const Value.absent(),
    Value<double?> overtimeHours = const Value.absent(),
    Value<String?> overtimeType = const Value.absent(),
    Value<String?> checkInTime = const Value.absent(),
    Value<String?> checkOutTime = const Value.absent(),
    Value<int?> breakMinutes = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => AttendanceEvent(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    employeeId: employeeId ?? this.employeeId,
    date: date ?? this.date,
    eventType: eventType ?? this.eventType,
    minutesLate: minutesLate.present ? minutesLate.value : this.minutesLate,
    hoursWorked: hoursWorked.present ? hoursWorked.value : this.hoursWorked,
    overtimeHours: overtimeHours.present
        ? overtimeHours.value
        : this.overtimeHours,
    overtimeType: overtimeType.present ? overtimeType.value : this.overtimeType,
    checkInTime: checkInTime.present ? checkInTime.value : this.checkInTime,
    checkOutTime: checkOutTime.present ? checkOutTime.value : this.checkOutTime,
    breakMinutes: breakMinutes.present ? breakMinutes.value : this.breakMinutes,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  AttendanceEvent copyWithCompanion(AttendanceEventsCompanion data) {
    return AttendanceEvent(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      date: data.date.present ? data.date.value : this.date,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      minutesLate: data.minutesLate.present
          ? data.minutesLate.value
          : this.minutesLate,
      hoursWorked: data.hoursWorked.present
          ? data.hoursWorked.value
          : this.hoursWorked,
      overtimeHours: data.overtimeHours.present
          ? data.overtimeHours.value
          : this.overtimeHours,
      overtimeType: data.overtimeType.present
          ? data.overtimeType.value
          : this.overtimeType,
      checkInTime: data.checkInTime.present
          ? data.checkInTime.value
          : this.checkInTime,
      checkOutTime: data.checkOutTime.present
          ? data.checkOutTime.value
          : this.checkOutTime,
      breakMinutes: data.breakMinutes.present
          ? data.breakMinutes.value
          : this.breakMinutes,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEvent(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('employeeId: $employeeId, ')
          ..write('date: $date, ')
          ..write('eventType: $eventType, ')
          ..write('minutesLate: $minutesLate, ')
          ..write('hoursWorked: $hoursWorked, ')
          ..write('overtimeHours: $overtimeHours, ')
          ..write('overtimeType: $overtimeType, ')
          ..write('checkInTime: $checkInTime, ')
          ..write('checkOutTime: $checkOutTime, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    employeeId,
    date,
    eventType,
    minutesLate,
    hoursWorked,
    overtimeHours,
    overtimeType,
    checkInTime,
    checkOutTime,
    breakMinutes,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceEvent &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.employeeId == this.employeeId &&
          other.date == this.date &&
          other.eventType == this.eventType &&
          other.minutesLate == this.minutesLate &&
          other.hoursWorked == this.hoursWorked &&
          other.overtimeHours == this.overtimeHours &&
          other.overtimeType == this.overtimeType &&
          other.checkInTime == this.checkInTime &&
          other.checkOutTime == this.checkOutTime &&
          other.breakMinutes == this.breakMinutes &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class AttendanceEventsCompanion extends UpdateCompanion<AttendanceEvent> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<int> employeeId;
  final Value<DateTime> date;
  final Value<String> eventType;
  final Value<int?> minutesLate;
  final Value<double?> hoursWorked;
  final Value<double?> overtimeHours;
  final Value<String?> overtimeType;
  final Value<String?> checkInTime;
  final Value<String?> checkOutTime;
  final Value<int?> breakMinutes;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const AttendanceEventsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.date = const Value.absent(),
    this.eventType = const Value.absent(),
    this.minutesLate = const Value.absent(),
    this.hoursWorked = const Value.absent(),
    this.overtimeHours = const Value.absent(),
    this.overtimeType = const Value.absent(),
    this.checkInTime = const Value.absent(),
    this.checkOutTime = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AttendanceEventsCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required int employeeId,
    required DateTime date,
    required String eventType,
    this.minutesLate = const Value.absent(),
    this.hoursWorked = const Value.absent(),
    this.overtimeHours = const Value.absent(),
    this.overtimeType = const Value.absent(),
    this.checkInTime = const Value.absent(),
    this.checkOutTime = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : companyId = Value(companyId),
       employeeId = Value(employeeId),
       date = Value(date),
       eventType = Value(eventType);
  static Insertable<AttendanceEvent> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? employeeId,
    Expression<DateTime>? date,
    Expression<String>? eventType,
    Expression<int>? minutesLate,
    Expression<double>? hoursWorked,
    Expression<double>? overtimeHours,
    Expression<String>? overtimeType,
    Expression<String>? checkInTime,
    Expression<String>? checkOutTime,
    Expression<int>? breakMinutes,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (employeeId != null) 'employee_id': employeeId,
      if (date != null) 'date': date,
      if (eventType != null) 'event_type': eventType,
      if (minutesLate != null) 'minutes_late': minutesLate,
      if (hoursWorked != null) 'hours_worked': hoursWorked,
      if (overtimeHours != null) 'overtime_hours': overtimeHours,
      if (overtimeType != null) 'overtime_type': overtimeType,
      if (checkInTime != null) 'check_in_time': checkInTime,
      if (checkOutTime != null) 'check_out_time': checkOutTime,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AttendanceEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<int>? employeeId,
    Value<DateTime>? date,
    Value<String>? eventType,
    Value<int?>? minutesLate,
    Value<double?>? hoursWorked,
    Value<double?>? overtimeHours,
    Value<String?>? overtimeType,
    Value<String?>? checkInTime,
    Value<String?>? checkOutTime,
    Value<int?>? breakMinutes,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return AttendanceEventsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      eventType: eventType ?? this.eventType,
      minutesLate: minutesLate ?? this.minutesLate,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      overtimeType: overtimeType ?? this.overtimeType,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<int>(employeeId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (minutesLate.present) {
      map['minutes_late'] = Variable<int>(minutesLate.value);
    }
    if (hoursWorked.present) {
      map['hours_worked'] = Variable<double>(hoursWorked.value);
    }
    if (overtimeHours.present) {
      map['overtime_hours'] = Variable<double>(overtimeHours.value);
    }
    if (overtimeType.present) {
      map['overtime_type'] = Variable<String>(overtimeType.value);
    }
    if (checkInTime.present) {
      map['check_in_time'] = Variable<String>(checkInTime.value);
    }
    if (checkOutTime.present) {
      map['check_out_time'] = Variable<String>(checkOutTime.value);
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEventsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('employeeId: $employeeId, ')
          ..write('date: $date, ')
          ..write('eventType: $eventType, ')
          ..write('minutesLate: $minutesLate, ')
          ..write('hoursWorked: $hoursWorked, ')
          ..write('overtimeHours: $overtimeHours, ')
          ..write('overtimeType: $overtimeType, ')
          ..write('checkInTime: $checkInTime, ')
          ..write('checkOutTime: $checkOutTime, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CompanySettingsTable extends CompanySettings
    with TableInfo<$CompanySettingsTable, CompanySetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanySettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ipsEmployeeRateMeta = const VerificationMeta(
    'ipsEmployeeRate',
  );
  @override
  late final GeneratedColumn<double> ipsEmployeeRate = GeneratedColumn<double>(
    'ips_employee_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.09),
  );
  static const VerificationMeta _ipsEmployerRateMeta = const VerificationMeta(
    'ipsEmployerRate',
  );
  @override
  late final GeneratedColumn<double> ipsEmployerRate = GeneratedColumn<double>(
    'ips_employer_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.165),
  );
  static const VerificationMeta _minimumWageMeta = const VerificationMeta(
    'minimumWage',
  );
  @override
  late final GeneratedColumn<double> minimumWage = GeneratedColumn<double>(
    'minimum_wage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _familyBonusRateMeta = const VerificationMeta(
    'familyBonusRate',
  );
  @override
  late final GeneratedColumn<double> familyBonusRate = GeneratedColumn<double>(
    'family_bonus_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _overtimeDayRateMeta = const VerificationMeta(
    'overtimeDayRate',
  );
  @override
  late final GeneratedColumn<double> overtimeDayRate = GeneratedColumn<double>(
    'overtime_day_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _overtimeNightRateMeta = const VerificationMeta(
    'overtimeNightRate',
  );
  @override
  late final GeneratedColumn<double> overtimeNightRate =
      GeneratedColumn<double>(
        'overtime_night_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _ordinaryNightSurchargeRateMeta =
      const VerificationMeta('ordinaryNightSurchargeRate');
  @override
  late final GeneratedColumn<double> ordinaryNightSurchargeRate =
      GeneratedColumn<double>(
        'ordinary_night_surcharge_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.3),
      );
  static const VerificationMeta _ordinaryNightStartMeta =
      const VerificationMeta('ordinaryNightStart');
  @override
  late final GeneratedColumn<String> ordinaryNightStart =
      GeneratedColumn<String>(
        'ordinary_night_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('20:00'),
      );
  static const VerificationMeta _ordinaryNightEndMeta = const VerificationMeta(
    'ordinaryNightEnd',
  );
  @override
  late final GeneratedColumn<String> ordinaryNightEnd = GeneratedColumn<String>(
    'ordinary_night_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('06:00'),
  );
  static const VerificationMeta _overtimeDayStartMeta = const VerificationMeta(
    'overtimeDayStart',
  );
  @override
  late final GeneratedColumn<String> overtimeDayStart = GeneratedColumn<String>(
    'overtime_day_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('06:00'),
  );
  static const VerificationMeta _overtimeDayEndMeta = const VerificationMeta(
    'overtimeDayEnd',
  );
  @override
  late final GeneratedColumn<String> overtimeDayEnd = GeneratedColumn<String>(
    'overtime_day_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('20:00'),
  );
  static const VerificationMeta _overtimeNightStartMeta =
      const VerificationMeta('overtimeNightStart');
  @override
  late final GeneratedColumn<String> overtimeNightStart =
      GeneratedColumn<String>(
        'overtime_night_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('20:00'),
      );
  static const VerificationMeta _overtimeNightEndMeta = const VerificationMeta(
    'overtimeNightEnd',
  );
  @override
  late final GeneratedColumn<String> overtimeNightEnd = GeneratedColumn<String>(
    'overtime_night_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('06:00'),
  );
  static const VerificationMeta _holidayDatesMeta = const VerificationMeta(
    'holidayDates',
  );
  @override
  late final GeneratedColumn<String> holidayDates = GeneratedColumn<String>(
    'holiday_dates',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _lateArrivalToleranceMinutesMeta =
      const VerificationMeta('lateArrivalToleranceMinutes');
  @override
  late final GeneratedColumn<int> lateArrivalToleranceMinutes =
      GeneratedColumn<int>(
        'late_arrival_tolerance_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lateArrivalAllowedTimesPerMonthMeta =
      const VerificationMeta('lateArrivalAllowedTimesPerMonth');
  @override
  late final GeneratedColumn<int> lateArrivalAllowedTimesPerMonth =
      GeneratedColumn<int>(
        'late_arrival_allowed_times_per_month',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
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
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    companyId,
    ipsEmployeeRate,
    ipsEmployerRate,
    minimumWage,
    familyBonusRate,
    overtimeDayRate,
    overtimeNightRate,
    ordinaryNightSurchargeRate,
    ordinaryNightStart,
    ordinaryNightEnd,
    overtimeDayStart,
    overtimeDayEnd,
    overtimeNightStart,
    overtimeNightEnd,
    holidayDates,
    lateArrivalToleranceMinutes,
    lateArrivalAllowedTimesPerMonth,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'company_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanySetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    }
    if (data.containsKey('ips_employee_rate')) {
      context.handle(
        _ipsEmployeeRateMeta,
        ipsEmployeeRate.isAcceptableOrUnknown(
          data['ips_employee_rate']!,
          _ipsEmployeeRateMeta,
        ),
      );
    }
    if (data.containsKey('ips_employer_rate')) {
      context.handle(
        _ipsEmployerRateMeta,
        ipsEmployerRate.isAcceptableOrUnknown(
          data['ips_employer_rate']!,
          _ipsEmployerRateMeta,
        ),
      );
    }
    if (data.containsKey('minimum_wage')) {
      context.handle(
        _minimumWageMeta,
        minimumWage.isAcceptableOrUnknown(
          data['minimum_wage']!,
          _minimumWageMeta,
        ),
      );
    }
    if (data.containsKey('family_bonus_rate')) {
      context.handle(
        _familyBonusRateMeta,
        familyBonusRate.isAcceptableOrUnknown(
          data['family_bonus_rate']!,
          _familyBonusRateMeta,
        ),
      );
    }
    if (data.containsKey('overtime_day_rate')) {
      context.handle(
        _overtimeDayRateMeta,
        overtimeDayRate.isAcceptableOrUnknown(
          data['overtime_day_rate']!,
          _overtimeDayRateMeta,
        ),
      );
    }
    if (data.containsKey('overtime_night_rate')) {
      context.handle(
        _overtimeNightRateMeta,
        overtimeNightRate.isAcceptableOrUnknown(
          data['overtime_night_rate']!,
          _overtimeNightRateMeta,
        ),
      );
    }
    if (data.containsKey('ordinary_night_surcharge_rate')) {
      context.handle(
        _ordinaryNightSurchargeRateMeta,
        ordinaryNightSurchargeRate.isAcceptableOrUnknown(
          data['ordinary_night_surcharge_rate']!,
          _ordinaryNightSurchargeRateMeta,
        ),
      );
    }
    if (data.containsKey('ordinary_night_start')) {
      context.handle(
        _ordinaryNightStartMeta,
        ordinaryNightStart.isAcceptableOrUnknown(
          data['ordinary_night_start']!,
          _ordinaryNightStartMeta,
        ),
      );
    }
    if (data.containsKey('ordinary_night_end')) {
      context.handle(
        _ordinaryNightEndMeta,
        ordinaryNightEnd.isAcceptableOrUnknown(
          data['ordinary_night_end']!,
          _ordinaryNightEndMeta,
        ),
      );
    }
    if (data.containsKey('overtime_day_start')) {
      context.handle(
        _overtimeDayStartMeta,
        overtimeDayStart.isAcceptableOrUnknown(
          data['overtime_day_start']!,
          _overtimeDayStartMeta,
        ),
      );
    }
    if (data.containsKey('overtime_day_end')) {
      context.handle(
        _overtimeDayEndMeta,
        overtimeDayEnd.isAcceptableOrUnknown(
          data['overtime_day_end']!,
          _overtimeDayEndMeta,
        ),
      );
    }
    if (data.containsKey('overtime_night_start')) {
      context.handle(
        _overtimeNightStartMeta,
        overtimeNightStart.isAcceptableOrUnknown(
          data['overtime_night_start']!,
          _overtimeNightStartMeta,
        ),
      );
    }
    if (data.containsKey('overtime_night_end')) {
      context.handle(
        _overtimeNightEndMeta,
        overtimeNightEnd.isAcceptableOrUnknown(
          data['overtime_night_end']!,
          _overtimeNightEndMeta,
        ),
      );
    }
    if (data.containsKey('holiday_dates')) {
      context.handle(
        _holidayDatesMeta,
        holidayDates.isAcceptableOrUnknown(
          data['holiday_dates']!,
          _holidayDatesMeta,
        ),
      );
    }
    if (data.containsKey('late_arrival_tolerance_minutes')) {
      context.handle(
        _lateArrivalToleranceMinutesMeta,
        lateArrivalToleranceMinutes.isAcceptableOrUnknown(
          data['late_arrival_tolerance_minutes']!,
          _lateArrivalToleranceMinutesMeta,
        ),
      );
    }
    if (data.containsKey('late_arrival_allowed_times_per_month')) {
      context.handle(
        _lateArrivalAllowedTimesPerMonthMeta,
        lateArrivalAllowedTimesPerMonth.isAcceptableOrUnknown(
          data['late_arrival_allowed_times_per_month']!,
          _lateArrivalAllowedTimesPerMonthMeta,
        ),
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
  Set<GeneratedColumn> get $primaryKey => {companyId};
  @override
  CompanySetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanySetting(
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      ipsEmployeeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ips_employee_rate'],
      )!,
      ipsEmployerRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ips_employer_rate'],
      )!,
      minimumWage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_wage'],
      )!,
      familyBonusRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}family_bonus_rate'],
      )!,
      overtimeDayRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overtime_day_rate'],
      )!,
      overtimeNightRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overtime_night_rate'],
      )!,
      ordinaryNightSurchargeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ordinary_night_surcharge_rate'],
      )!,
      ordinaryNightStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ordinary_night_start'],
      )!,
      ordinaryNightEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ordinary_night_end'],
      )!,
      overtimeDayStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overtime_day_start'],
      )!,
      overtimeDayEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overtime_day_end'],
      )!,
      overtimeNightStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overtime_night_start'],
      )!,
      overtimeNightEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overtime_night_end'],
      )!,
      holidayDates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holiday_dates'],
      )!,
      lateArrivalToleranceMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_arrival_tolerance_minutes'],
      )!,
      lateArrivalAllowedTimesPerMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_arrival_allowed_times_per_month'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CompanySettingsTable createAlias(String alias) {
    return $CompanySettingsTable(attachedDatabase, alias);
  }
}

class CompanySetting extends DataClass implements Insertable<CompanySetting> {
  final int companyId;
  final double ipsEmployeeRate;
  final double ipsEmployerRate;
  final double minimumWage;
  final double familyBonusRate;
  final double overtimeDayRate;
  final double overtimeNightRate;
  final double ordinaryNightSurchargeRate;
  final String ordinaryNightStart;
  final String ordinaryNightEnd;
  final String overtimeDayStart;
  final String overtimeDayEnd;
  final String overtimeNightStart;
  final String overtimeNightEnd;
  final String holidayDates;
  final int lateArrivalToleranceMinutes;
  final int lateArrivalAllowedTimesPerMonth;
  final DateTime updatedAt;
  const CompanySetting({
    required this.companyId,
    required this.ipsEmployeeRate,
    required this.ipsEmployerRate,
    required this.minimumWage,
    required this.familyBonusRate,
    required this.overtimeDayRate,
    required this.overtimeNightRate,
    required this.ordinaryNightSurchargeRate,
    required this.ordinaryNightStart,
    required this.ordinaryNightEnd,
    required this.overtimeDayStart,
    required this.overtimeDayEnd,
    required this.overtimeNightStart,
    required this.overtimeNightEnd,
    required this.holidayDates,
    required this.lateArrivalToleranceMinutes,
    required this.lateArrivalAllowedTimesPerMonth,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['company_id'] = Variable<int>(companyId);
    map['ips_employee_rate'] = Variable<double>(ipsEmployeeRate);
    map['ips_employer_rate'] = Variable<double>(ipsEmployerRate);
    map['minimum_wage'] = Variable<double>(minimumWage);
    map['family_bonus_rate'] = Variable<double>(familyBonusRate);
    map['overtime_day_rate'] = Variable<double>(overtimeDayRate);
    map['overtime_night_rate'] = Variable<double>(overtimeNightRate);
    map['ordinary_night_surcharge_rate'] = Variable<double>(
      ordinaryNightSurchargeRate,
    );
    map['ordinary_night_start'] = Variable<String>(ordinaryNightStart);
    map['ordinary_night_end'] = Variable<String>(ordinaryNightEnd);
    map['overtime_day_start'] = Variable<String>(overtimeDayStart);
    map['overtime_day_end'] = Variable<String>(overtimeDayEnd);
    map['overtime_night_start'] = Variable<String>(overtimeNightStart);
    map['overtime_night_end'] = Variable<String>(overtimeNightEnd);
    map['holiday_dates'] = Variable<String>(holidayDates);
    map['late_arrival_tolerance_minutes'] = Variable<int>(
      lateArrivalToleranceMinutes,
    );
    map['late_arrival_allowed_times_per_month'] = Variable<int>(
      lateArrivalAllowedTimesPerMonth,
    );
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CompanySettingsCompanion toCompanion(bool nullToAbsent) {
    return CompanySettingsCompanion(
      companyId: Value(companyId),
      ipsEmployeeRate: Value(ipsEmployeeRate),
      ipsEmployerRate: Value(ipsEmployerRate),
      minimumWage: Value(minimumWage),
      familyBonusRate: Value(familyBonusRate),
      overtimeDayRate: Value(overtimeDayRate),
      overtimeNightRate: Value(overtimeNightRate),
      ordinaryNightSurchargeRate: Value(ordinaryNightSurchargeRate),
      ordinaryNightStart: Value(ordinaryNightStart),
      ordinaryNightEnd: Value(ordinaryNightEnd),
      overtimeDayStart: Value(overtimeDayStart),
      overtimeDayEnd: Value(overtimeDayEnd),
      overtimeNightStart: Value(overtimeNightStart),
      overtimeNightEnd: Value(overtimeNightEnd),
      holidayDates: Value(holidayDates),
      lateArrivalToleranceMinutes: Value(lateArrivalToleranceMinutes),
      lateArrivalAllowedTimesPerMonth: Value(lateArrivalAllowedTimesPerMonth),
      updatedAt: Value(updatedAt),
    );
  }

  factory CompanySetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanySetting(
      companyId: serializer.fromJson<int>(json['companyId']),
      ipsEmployeeRate: serializer.fromJson<double>(json['ipsEmployeeRate']),
      ipsEmployerRate: serializer.fromJson<double>(json['ipsEmployerRate']),
      minimumWage: serializer.fromJson<double>(json['minimumWage']),
      familyBonusRate: serializer.fromJson<double>(json['familyBonusRate']),
      overtimeDayRate: serializer.fromJson<double>(json['overtimeDayRate']),
      overtimeNightRate: serializer.fromJson<double>(json['overtimeNightRate']),
      ordinaryNightSurchargeRate: serializer.fromJson<double>(
        json['ordinaryNightSurchargeRate'],
      ),
      ordinaryNightStart: serializer.fromJson<String>(
        json['ordinaryNightStart'],
      ),
      ordinaryNightEnd: serializer.fromJson<String>(json['ordinaryNightEnd']),
      overtimeDayStart: serializer.fromJson<String>(json['overtimeDayStart']),
      overtimeDayEnd: serializer.fromJson<String>(json['overtimeDayEnd']),
      overtimeNightStart: serializer.fromJson<String>(
        json['overtimeNightStart'],
      ),
      overtimeNightEnd: serializer.fromJson<String>(json['overtimeNightEnd']),
      holidayDates: serializer.fromJson<String>(json['holidayDates']),
      lateArrivalToleranceMinutes: serializer.fromJson<int>(
        json['lateArrivalToleranceMinutes'],
      ),
      lateArrivalAllowedTimesPerMonth: serializer.fromJson<int>(
        json['lateArrivalAllowedTimesPerMonth'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'companyId': serializer.toJson<int>(companyId),
      'ipsEmployeeRate': serializer.toJson<double>(ipsEmployeeRate),
      'ipsEmployerRate': serializer.toJson<double>(ipsEmployerRate),
      'minimumWage': serializer.toJson<double>(minimumWage),
      'familyBonusRate': serializer.toJson<double>(familyBonusRate),
      'overtimeDayRate': serializer.toJson<double>(overtimeDayRate),
      'overtimeNightRate': serializer.toJson<double>(overtimeNightRate),
      'ordinaryNightSurchargeRate': serializer.toJson<double>(
        ordinaryNightSurchargeRate,
      ),
      'ordinaryNightStart': serializer.toJson<String>(ordinaryNightStart),
      'ordinaryNightEnd': serializer.toJson<String>(ordinaryNightEnd),
      'overtimeDayStart': serializer.toJson<String>(overtimeDayStart),
      'overtimeDayEnd': serializer.toJson<String>(overtimeDayEnd),
      'overtimeNightStart': serializer.toJson<String>(overtimeNightStart),
      'overtimeNightEnd': serializer.toJson<String>(overtimeNightEnd),
      'holidayDates': serializer.toJson<String>(holidayDates),
      'lateArrivalToleranceMinutes': serializer.toJson<int>(
        lateArrivalToleranceMinutes,
      ),
      'lateArrivalAllowedTimesPerMonth': serializer.toJson<int>(
        lateArrivalAllowedTimesPerMonth,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CompanySetting copyWith({
    int? companyId,
    double? ipsEmployeeRate,
    double? ipsEmployerRate,
    double? minimumWage,
    double? familyBonusRate,
    double? overtimeDayRate,
    double? overtimeNightRate,
    double? ordinaryNightSurchargeRate,
    String? ordinaryNightStart,
    String? ordinaryNightEnd,
    String? overtimeDayStart,
    String? overtimeDayEnd,
    String? overtimeNightStart,
    String? overtimeNightEnd,
    String? holidayDates,
    int? lateArrivalToleranceMinutes,
    int? lateArrivalAllowedTimesPerMonth,
    DateTime? updatedAt,
  }) => CompanySetting(
    companyId: companyId ?? this.companyId,
    ipsEmployeeRate: ipsEmployeeRate ?? this.ipsEmployeeRate,
    ipsEmployerRate: ipsEmployerRate ?? this.ipsEmployerRate,
    minimumWage: minimumWage ?? this.minimumWage,
    familyBonusRate: familyBonusRate ?? this.familyBonusRate,
    overtimeDayRate: overtimeDayRate ?? this.overtimeDayRate,
    overtimeNightRate: overtimeNightRate ?? this.overtimeNightRate,
    ordinaryNightSurchargeRate:
        ordinaryNightSurchargeRate ?? this.ordinaryNightSurchargeRate,
    ordinaryNightStart: ordinaryNightStart ?? this.ordinaryNightStart,
    ordinaryNightEnd: ordinaryNightEnd ?? this.ordinaryNightEnd,
    overtimeDayStart: overtimeDayStart ?? this.overtimeDayStart,
    overtimeDayEnd: overtimeDayEnd ?? this.overtimeDayEnd,
    overtimeNightStart: overtimeNightStart ?? this.overtimeNightStart,
    overtimeNightEnd: overtimeNightEnd ?? this.overtimeNightEnd,
    holidayDates: holidayDates ?? this.holidayDates,
    lateArrivalToleranceMinutes:
        lateArrivalToleranceMinutes ?? this.lateArrivalToleranceMinutes,
    lateArrivalAllowedTimesPerMonth:
        lateArrivalAllowedTimesPerMonth ?? this.lateArrivalAllowedTimesPerMonth,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CompanySetting copyWithCompanion(CompanySettingsCompanion data) {
    return CompanySetting(
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      ipsEmployeeRate: data.ipsEmployeeRate.present
          ? data.ipsEmployeeRate.value
          : this.ipsEmployeeRate,
      ipsEmployerRate: data.ipsEmployerRate.present
          ? data.ipsEmployerRate.value
          : this.ipsEmployerRate,
      minimumWage: data.minimumWage.present
          ? data.minimumWage.value
          : this.minimumWage,
      familyBonusRate: data.familyBonusRate.present
          ? data.familyBonusRate.value
          : this.familyBonusRate,
      overtimeDayRate: data.overtimeDayRate.present
          ? data.overtimeDayRate.value
          : this.overtimeDayRate,
      overtimeNightRate: data.overtimeNightRate.present
          ? data.overtimeNightRate.value
          : this.overtimeNightRate,
      ordinaryNightSurchargeRate: data.ordinaryNightSurchargeRate.present
          ? data.ordinaryNightSurchargeRate.value
          : this.ordinaryNightSurchargeRate,
      ordinaryNightStart: data.ordinaryNightStart.present
          ? data.ordinaryNightStart.value
          : this.ordinaryNightStart,
      ordinaryNightEnd: data.ordinaryNightEnd.present
          ? data.ordinaryNightEnd.value
          : this.ordinaryNightEnd,
      overtimeDayStart: data.overtimeDayStart.present
          ? data.overtimeDayStart.value
          : this.overtimeDayStart,
      overtimeDayEnd: data.overtimeDayEnd.present
          ? data.overtimeDayEnd.value
          : this.overtimeDayEnd,
      overtimeNightStart: data.overtimeNightStart.present
          ? data.overtimeNightStart.value
          : this.overtimeNightStart,
      overtimeNightEnd: data.overtimeNightEnd.present
          ? data.overtimeNightEnd.value
          : this.overtimeNightEnd,
      holidayDates: data.holidayDates.present
          ? data.holidayDates.value
          : this.holidayDates,
      lateArrivalToleranceMinutes: data.lateArrivalToleranceMinutes.present
          ? data.lateArrivalToleranceMinutes.value
          : this.lateArrivalToleranceMinutes,
      lateArrivalAllowedTimesPerMonth:
          data.lateArrivalAllowedTimesPerMonth.present
          ? data.lateArrivalAllowedTimesPerMonth.value
          : this.lateArrivalAllowedTimesPerMonth,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanySetting(')
          ..write('companyId: $companyId, ')
          ..write('ipsEmployeeRate: $ipsEmployeeRate, ')
          ..write('ipsEmployerRate: $ipsEmployerRate, ')
          ..write('minimumWage: $minimumWage, ')
          ..write('familyBonusRate: $familyBonusRate, ')
          ..write('overtimeDayRate: $overtimeDayRate, ')
          ..write('overtimeNightRate: $overtimeNightRate, ')
          ..write('ordinaryNightSurchargeRate: $ordinaryNightSurchargeRate, ')
          ..write('ordinaryNightStart: $ordinaryNightStart, ')
          ..write('ordinaryNightEnd: $ordinaryNightEnd, ')
          ..write('overtimeDayStart: $overtimeDayStart, ')
          ..write('overtimeDayEnd: $overtimeDayEnd, ')
          ..write('overtimeNightStart: $overtimeNightStart, ')
          ..write('overtimeNightEnd: $overtimeNightEnd, ')
          ..write('holidayDates: $holidayDates, ')
          ..write('lateArrivalToleranceMinutes: $lateArrivalToleranceMinutes, ')
          ..write(
            'lateArrivalAllowedTimesPerMonth: $lateArrivalAllowedTimesPerMonth, ',
          )
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    companyId,
    ipsEmployeeRate,
    ipsEmployerRate,
    minimumWage,
    familyBonusRate,
    overtimeDayRate,
    overtimeNightRate,
    ordinaryNightSurchargeRate,
    ordinaryNightStart,
    ordinaryNightEnd,
    overtimeDayStart,
    overtimeDayEnd,
    overtimeNightStart,
    overtimeNightEnd,
    holidayDates,
    lateArrivalToleranceMinutes,
    lateArrivalAllowedTimesPerMonth,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanySetting &&
          other.companyId == this.companyId &&
          other.ipsEmployeeRate == this.ipsEmployeeRate &&
          other.ipsEmployerRate == this.ipsEmployerRate &&
          other.minimumWage == this.minimumWage &&
          other.familyBonusRate == this.familyBonusRate &&
          other.overtimeDayRate == this.overtimeDayRate &&
          other.overtimeNightRate == this.overtimeNightRate &&
          other.ordinaryNightSurchargeRate == this.ordinaryNightSurchargeRate &&
          other.ordinaryNightStart == this.ordinaryNightStart &&
          other.ordinaryNightEnd == this.ordinaryNightEnd &&
          other.overtimeDayStart == this.overtimeDayStart &&
          other.overtimeDayEnd == this.overtimeDayEnd &&
          other.overtimeNightStart == this.overtimeNightStart &&
          other.overtimeNightEnd == this.overtimeNightEnd &&
          other.holidayDates == this.holidayDates &&
          other.lateArrivalToleranceMinutes ==
              this.lateArrivalToleranceMinutes &&
          other.lateArrivalAllowedTimesPerMonth ==
              this.lateArrivalAllowedTimesPerMonth &&
          other.updatedAt == this.updatedAt);
}

class CompanySettingsCompanion extends UpdateCompanion<CompanySetting> {
  final Value<int> companyId;
  final Value<double> ipsEmployeeRate;
  final Value<double> ipsEmployerRate;
  final Value<double> minimumWage;
  final Value<double> familyBonusRate;
  final Value<double> overtimeDayRate;
  final Value<double> overtimeNightRate;
  final Value<double> ordinaryNightSurchargeRate;
  final Value<String> ordinaryNightStart;
  final Value<String> ordinaryNightEnd;
  final Value<String> overtimeDayStart;
  final Value<String> overtimeDayEnd;
  final Value<String> overtimeNightStart;
  final Value<String> overtimeNightEnd;
  final Value<String> holidayDates;
  final Value<int> lateArrivalToleranceMinutes;
  final Value<int> lateArrivalAllowedTimesPerMonth;
  final Value<DateTime> updatedAt;
  const CompanySettingsCompanion({
    this.companyId = const Value.absent(),
    this.ipsEmployeeRate = const Value.absent(),
    this.ipsEmployerRate = const Value.absent(),
    this.minimumWage = const Value.absent(),
    this.familyBonusRate = const Value.absent(),
    this.overtimeDayRate = const Value.absent(),
    this.overtimeNightRate = const Value.absent(),
    this.ordinaryNightSurchargeRate = const Value.absent(),
    this.ordinaryNightStart = const Value.absent(),
    this.ordinaryNightEnd = const Value.absent(),
    this.overtimeDayStart = const Value.absent(),
    this.overtimeDayEnd = const Value.absent(),
    this.overtimeNightStart = const Value.absent(),
    this.overtimeNightEnd = const Value.absent(),
    this.holidayDates = const Value.absent(),
    this.lateArrivalToleranceMinutes = const Value.absent(),
    this.lateArrivalAllowedTimesPerMonth = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CompanySettingsCompanion.insert({
    this.companyId = const Value.absent(),
    this.ipsEmployeeRate = const Value.absent(),
    this.ipsEmployerRate = const Value.absent(),
    this.minimumWage = const Value.absent(),
    this.familyBonusRate = const Value.absent(),
    this.overtimeDayRate = const Value.absent(),
    this.overtimeNightRate = const Value.absent(),
    this.ordinaryNightSurchargeRate = const Value.absent(),
    this.ordinaryNightStart = const Value.absent(),
    this.ordinaryNightEnd = const Value.absent(),
    this.overtimeDayStart = const Value.absent(),
    this.overtimeDayEnd = const Value.absent(),
    this.overtimeNightStart = const Value.absent(),
    this.overtimeNightEnd = const Value.absent(),
    this.holidayDates = const Value.absent(),
    this.lateArrivalToleranceMinutes = const Value.absent(),
    this.lateArrivalAllowedTimesPerMonth = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<CompanySetting> custom({
    Expression<int>? companyId,
    Expression<double>? ipsEmployeeRate,
    Expression<double>? ipsEmployerRate,
    Expression<double>? minimumWage,
    Expression<double>? familyBonusRate,
    Expression<double>? overtimeDayRate,
    Expression<double>? overtimeNightRate,
    Expression<double>? ordinaryNightSurchargeRate,
    Expression<String>? ordinaryNightStart,
    Expression<String>? ordinaryNightEnd,
    Expression<String>? overtimeDayStart,
    Expression<String>? overtimeDayEnd,
    Expression<String>? overtimeNightStart,
    Expression<String>? overtimeNightEnd,
    Expression<String>? holidayDates,
    Expression<int>? lateArrivalToleranceMinutes,
    Expression<int>? lateArrivalAllowedTimesPerMonth,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (companyId != null) 'company_id': companyId,
      if (ipsEmployeeRate != null) 'ips_employee_rate': ipsEmployeeRate,
      if (ipsEmployerRate != null) 'ips_employer_rate': ipsEmployerRate,
      if (minimumWage != null) 'minimum_wage': minimumWage,
      if (familyBonusRate != null) 'family_bonus_rate': familyBonusRate,
      if (overtimeDayRate != null) 'overtime_day_rate': overtimeDayRate,
      if (overtimeNightRate != null) 'overtime_night_rate': overtimeNightRate,
      if (ordinaryNightSurchargeRate != null)
        'ordinary_night_surcharge_rate': ordinaryNightSurchargeRate,
      if (ordinaryNightStart != null)
        'ordinary_night_start': ordinaryNightStart,
      if (ordinaryNightEnd != null) 'ordinary_night_end': ordinaryNightEnd,
      if (overtimeDayStart != null) 'overtime_day_start': overtimeDayStart,
      if (overtimeDayEnd != null) 'overtime_day_end': overtimeDayEnd,
      if (overtimeNightStart != null)
        'overtime_night_start': overtimeNightStart,
      if (overtimeNightEnd != null) 'overtime_night_end': overtimeNightEnd,
      if (holidayDates != null) 'holiday_dates': holidayDates,
      if (lateArrivalToleranceMinutes != null)
        'late_arrival_tolerance_minutes': lateArrivalToleranceMinutes,
      if (lateArrivalAllowedTimesPerMonth != null)
        'late_arrival_allowed_times_per_month': lateArrivalAllowedTimesPerMonth,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CompanySettingsCompanion copyWith({
    Value<int>? companyId,
    Value<double>? ipsEmployeeRate,
    Value<double>? ipsEmployerRate,
    Value<double>? minimumWage,
    Value<double>? familyBonusRate,
    Value<double>? overtimeDayRate,
    Value<double>? overtimeNightRate,
    Value<double>? ordinaryNightSurchargeRate,
    Value<String>? ordinaryNightStart,
    Value<String>? ordinaryNightEnd,
    Value<String>? overtimeDayStart,
    Value<String>? overtimeDayEnd,
    Value<String>? overtimeNightStart,
    Value<String>? overtimeNightEnd,
    Value<String>? holidayDates,
    Value<int>? lateArrivalToleranceMinutes,
    Value<int>? lateArrivalAllowedTimesPerMonth,
    Value<DateTime>? updatedAt,
  }) {
    return CompanySettingsCompanion(
      companyId: companyId ?? this.companyId,
      ipsEmployeeRate: ipsEmployeeRate ?? this.ipsEmployeeRate,
      ipsEmployerRate: ipsEmployerRate ?? this.ipsEmployerRate,
      minimumWage: minimumWage ?? this.minimumWage,
      familyBonusRate: familyBonusRate ?? this.familyBonusRate,
      overtimeDayRate: overtimeDayRate ?? this.overtimeDayRate,
      overtimeNightRate: overtimeNightRate ?? this.overtimeNightRate,
      ordinaryNightSurchargeRate:
          ordinaryNightSurchargeRate ?? this.ordinaryNightSurchargeRate,
      ordinaryNightStart: ordinaryNightStart ?? this.ordinaryNightStart,
      ordinaryNightEnd: ordinaryNightEnd ?? this.ordinaryNightEnd,
      overtimeDayStart: overtimeDayStart ?? this.overtimeDayStart,
      overtimeDayEnd: overtimeDayEnd ?? this.overtimeDayEnd,
      overtimeNightStart: overtimeNightStart ?? this.overtimeNightStart,
      overtimeNightEnd: overtimeNightEnd ?? this.overtimeNightEnd,
      holidayDates: holidayDates ?? this.holidayDates,
      lateArrivalToleranceMinutes:
          lateArrivalToleranceMinutes ?? this.lateArrivalToleranceMinutes,
      lateArrivalAllowedTimesPerMonth:
          lateArrivalAllowedTimesPerMonth ??
          this.lateArrivalAllowedTimesPerMonth,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (ipsEmployeeRate.present) {
      map['ips_employee_rate'] = Variable<double>(ipsEmployeeRate.value);
    }
    if (ipsEmployerRate.present) {
      map['ips_employer_rate'] = Variable<double>(ipsEmployerRate.value);
    }
    if (minimumWage.present) {
      map['minimum_wage'] = Variable<double>(minimumWage.value);
    }
    if (familyBonusRate.present) {
      map['family_bonus_rate'] = Variable<double>(familyBonusRate.value);
    }
    if (overtimeDayRate.present) {
      map['overtime_day_rate'] = Variable<double>(overtimeDayRate.value);
    }
    if (overtimeNightRate.present) {
      map['overtime_night_rate'] = Variable<double>(overtimeNightRate.value);
    }
    if (ordinaryNightSurchargeRate.present) {
      map['ordinary_night_surcharge_rate'] = Variable<double>(
        ordinaryNightSurchargeRate.value,
      );
    }
    if (ordinaryNightStart.present) {
      map['ordinary_night_start'] = Variable<String>(ordinaryNightStart.value);
    }
    if (ordinaryNightEnd.present) {
      map['ordinary_night_end'] = Variable<String>(ordinaryNightEnd.value);
    }
    if (overtimeDayStart.present) {
      map['overtime_day_start'] = Variable<String>(overtimeDayStart.value);
    }
    if (overtimeDayEnd.present) {
      map['overtime_day_end'] = Variable<String>(overtimeDayEnd.value);
    }
    if (overtimeNightStart.present) {
      map['overtime_night_start'] = Variable<String>(overtimeNightStart.value);
    }
    if (overtimeNightEnd.present) {
      map['overtime_night_end'] = Variable<String>(overtimeNightEnd.value);
    }
    if (holidayDates.present) {
      map['holiday_dates'] = Variable<String>(holidayDates.value);
    }
    if (lateArrivalToleranceMinutes.present) {
      map['late_arrival_tolerance_minutes'] = Variable<int>(
        lateArrivalToleranceMinutes.value,
      );
    }
    if (lateArrivalAllowedTimesPerMonth.present) {
      map['late_arrival_allowed_times_per_month'] = Variable<int>(
        lateArrivalAllowedTimesPerMonth.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanySettingsCompanion(')
          ..write('companyId: $companyId, ')
          ..write('ipsEmployeeRate: $ipsEmployeeRate, ')
          ..write('ipsEmployerRate: $ipsEmployerRate, ')
          ..write('minimumWage: $minimumWage, ')
          ..write('familyBonusRate: $familyBonusRate, ')
          ..write('overtimeDayRate: $overtimeDayRate, ')
          ..write('overtimeNightRate: $overtimeNightRate, ')
          ..write('ordinaryNightSurchargeRate: $ordinaryNightSurchargeRate, ')
          ..write('ordinaryNightStart: $ordinaryNightStart, ')
          ..write('ordinaryNightEnd: $ordinaryNightEnd, ')
          ..write('overtimeDayStart: $overtimeDayStart, ')
          ..write('overtimeDayEnd: $overtimeDayEnd, ')
          ..write('overtimeNightStart: $overtimeNightStart, ')
          ..write('overtimeNightEnd: $overtimeNightEnd, ')
          ..write('holidayDates: $holidayDates, ')
          ..write('lateArrivalToleranceMinutes: $lateArrivalToleranceMinutes, ')
          ..write(
            'lateArrivalAllowedTimesPerMonth: $lateArrivalAllowedTimesPerMonth, ',
          )
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AdvancesTable extends Advances with TableInfo<$AdvancesTable, Advance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdvancesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES employees (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    employeeId,
    date,
    amount,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'advances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Advance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
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
  Advance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Advance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employee_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AdvancesTable createAlias(String alias) {
    return $AdvancesTable(attachedDatabase, alias);
  }
}

class Advance extends DataClass implements Insertable<Advance> {
  final int id;
  final int companyId;
  final int employeeId;
  final DateTime date;
  final double amount;
  final String? reason;
  final DateTime createdAt;
  const Advance({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.date,
    required this.amount,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['employee_id'] = Variable<int>(employeeId);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AdvancesCompanion toCompanion(bool nullToAbsent) {
    return AdvancesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      employeeId: Value(employeeId),
      date: Value(date),
      amount: Value(amount),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory Advance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Advance(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      employeeId: serializer.fromJson<int>(json['employeeId']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'employeeId': serializer.toJson<int>(employeeId),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<double>(amount),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Advance copyWith({
    int? id,
    int? companyId,
    int? employeeId,
    DateTime? date,
    double? amount,
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => Advance(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    employeeId: employeeId ?? this.employeeId,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  Advance copyWithCompanion(AdvancesCompanion data) {
    return Advance(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Advance(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('employeeId: $employeeId, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, employeeId, date, amount, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Advance &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.employeeId == this.employeeId &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class AdvancesCompanion extends UpdateCompanion<Advance> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<int> employeeId;
  final Value<DateTime> date;
  final Value<double> amount;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  const AdvancesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AdvancesCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required int employeeId,
    required DateTime date,
    required double amount,
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : companyId = Value(companyId),
       employeeId = Value(employeeId),
       date = Value(date),
       amount = Value(amount);
  static Insertable<Advance> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? employeeId,
    Expression<DateTime>? date,
    Expression<double>? amount,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (employeeId != null) 'employee_id': employeeId,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AdvancesCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<int>? employeeId,
    Value<DateTime>? date,
    Value<double>? amount,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
  }) {
    return AdvancesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<int>(employeeId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdvancesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('employeeId: $employeeId, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("active" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
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
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    passwordHash,
    fullName,
    active,
    createdAt,
    lastLoginAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String username;
  final String passwordHash;
  final String fullName;
  final bool active;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  const User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.fullName,
    required this.active,
    required this.createdAt,
    this.lastLoginAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['full_name'] = Variable<String>(fullName);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      fullName: Value(fullName),
      active: Value(active),
      createdAt: Value(createdAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      fullName: serializer.fromJson<String>(json['fullName']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'fullName': serializer.toJson<String>(fullName),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? fullName,
    bool? active,
    DateTime? createdAt,
    Value<DateTime?> lastLoginAt = const Value.absent(),
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    fullName: fullName ?? this.fullName,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('fullName: $fullName, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    passwordHash,
    fullName,
    active,
    createdAt,
    lastLoginAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.fullName == this.fullName &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.lastLoginAt == this.lastLoginAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> fullName;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastLoginAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.fullName = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String passwordHash,
    required String fullName,
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
  }) : username = Value(username),
       passwordHash = Value(passwordHash),
       fullName = Value(fullName);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? fullName,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastLoginAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (fullName != null) 'full_name': fullName,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? passwordHash,
    Value<String>? fullName,
    Value<bool>? active,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastLoginAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('fullName: $fullName, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }
}

class $PayrollRunsTable extends PayrollRuns
    with TableInfo<$PayrollRunsTable, PayrollRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayrollRunsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
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
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("is_locked" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lockedAtMeta = const VerificationMeta(
    'lockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lockedAt = GeneratedColumn<DateTime>(
    'locked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lockedByUserIdMeta = const VerificationMeta(
    'lockedByUserId',
  );
  @override
  late final GeneratedColumn<int> lockedByUserId = GeneratedColumn<int>(
    'locked_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    year,
    month,
    generatedAt,
    notes,
    isLocked,
    lockedAt,
    lockedByUserId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payroll_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayrollRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    if (data.containsKey('locked_at')) {
      context.handle(
        _lockedAtMeta,
        lockedAt.isAcceptableOrUnknown(data['locked_at']!, _lockedAtMeta),
      );
    }
    if (data.containsKey('locked_by_user_id')) {
      context.handle(
        _lockedByUserIdMeta,
        lockedByUserId.isAcceptableOrUnknown(
          data['locked_by_user_id']!,
          _lockedByUserIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, year, month},
  ];
  @override
  PayrollRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayrollRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      lockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_at'],
      ),
      lockedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}locked_by_user_id'],
      ),
    );
  }

  @override
  $PayrollRunsTable createAlias(String alias) {
    return $PayrollRunsTable(attachedDatabase, alias);
  }
}

class PayrollRun extends DataClass implements Insertable<PayrollRun> {
  final int id;
  final int companyId;
  final int year;
  final int month;
  final DateTime generatedAt;
  final String? notes;
  final bool isLocked;
  final DateTime? lockedAt;
  final int? lockedByUserId;
  const PayrollRun({
    required this.id,
    required this.companyId,
    required this.year,
    required this.month,
    required this.generatedAt,
    this.notes,
    required this.isLocked,
    this.lockedAt,
    this.lockedByUserId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || lockedAt != null) {
      map['locked_at'] = Variable<DateTime>(lockedAt);
    }
    if (!nullToAbsent || lockedByUserId != null) {
      map['locked_by_user_id'] = Variable<int>(lockedByUserId);
    }
    return map;
  }

  PayrollRunsCompanion toCompanion(bool nullToAbsent) {
    return PayrollRunsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      year: Value(year),
      month: Value(month),
      generatedAt: Value(generatedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isLocked: Value(isLocked),
      lockedAt: lockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedAt),
      lockedByUserId: lockedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedByUserId),
    );
  }

  factory PayrollRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayrollRun(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      lockedAt: serializer.fromJson<DateTime?>(json['lockedAt']),
      lockedByUserId: serializer.fromJson<int?>(json['lockedByUserId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'notes': serializer.toJson<String?>(notes),
      'isLocked': serializer.toJson<bool>(isLocked),
      'lockedAt': serializer.toJson<DateTime?>(lockedAt),
      'lockedByUserId': serializer.toJson<int?>(lockedByUserId),
    };
  }

  PayrollRun copyWith({
    int? id,
    int? companyId,
    int? year,
    int? month,
    DateTime? generatedAt,
    Value<String?> notes = const Value.absent(),
    bool? isLocked,
    Value<DateTime?> lockedAt = const Value.absent(),
    Value<int?> lockedByUserId = const Value.absent(),
  }) => PayrollRun(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    year: year ?? this.year,
    month: month ?? this.month,
    generatedAt: generatedAt ?? this.generatedAt,
    notes: notes.present ? notes.value : this.notes,
    isLocked: isLocked ?? this.isLocked,
    lockedAt: lockedAt.present ? lockedAt.value : this.lockedAt,
    lockedByUserId: lockedByUserId.present
        ? lockedByUserId.value
        : this.lockedByUserId,
  );
  PayrollRun copyWithCompanion(PayrollRunsCompanion data) {
    return PayrollRun(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      lockedAt: data.lockedAt.present ? data.lockedAt.value : this.lockedAt,
      lockedByUserId: data.lockedByUserId.present
          ? data.lockedByUserId.value
          : this.lockedByUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayrollRun(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('notes: $notes, ')
          ..write('isLocked: $isLocked, ')
          ..write('lockedAt: $lockedAt, ')
          ..write('lockedByUserId: $lockedByUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    year,
    month,
    generatedAt,
    notes,
    isLocked,
    lockedAt,
    lockedByUserId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayrollRun &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.year == this.year &&
          other.month == this.month &&
          other.generatedAt == this.generatedAt &&
          other.notes == this.notes &&
          other.isLocked == this.isLocked &&
          other.lockedAt == this.lockedAt &&
          other.lockedByUserId == this.lockedByUserId);
}

class PayrollRunsCompanion extends UpdateCompanion<PayrollRun> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<int> year;
  final Value<int> month;
  final Value<DateTime> generatedAt;
  final Value<String?> notes;
  final Value<bool> isLocked;
  final Value<DateTime?> lockedAt;
  final Value<int?> lockedByUserId;
  const PayrollRunsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.lockedAt = const Value.absent(),
    this.lockedByUserId = const Value.absent(),
  });
  PayrollRunsCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required int year,
    required int month,
    this.generatedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.lockedAt = const Value.absent(),
    this.lockedByUserId = const Value.absent(),
  }) : companyId = Value(companyId),
       year = Value(year),
       month = Value(month);
  static Insertable<PayrollRun> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? year,
    Expression<int>? month,
    Expression<DateTime>? generatedAt,
    Expression<String>? notes,
    Expression<bool>? isLocked,
    Expression<DateTime>? lockedAt,
    Expression<int>? lockedByUserId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (notes != null) 'notes': notes,
      if (isLocked != null) 'is_locked': isLocked,
      if (lockedAt != null) 'locked_at': lockedAt,
      if (lockedByUserId != null) 'locked_by_user_id': lockedByUserId,
    });
  }

  PayrollRunsCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<int>? year,
    Value<int>? month,
    Value<DateTime>? generatedAt,
    Value<String?>? notes,
    Value<bool>? isLocked,
    Value<DateTime?>? lockedAt,
    Value<int?>? lockedByUserId,
  }) {
    return PayrollRunsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      year: year ?? this.year,
      month: month ?? this.month,
      generatedAt: generatedAt ?? this.generatedAt,
      notes: notes ?? this.notes,
      isLocked: isLocked ?? this.isLocked,
      lockedAt: lockedAt ?? this.lockedAt,
      lockedByUserId: lockedByUserId ?? this.lockedByUserId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (lockedAt.present) {
      map['locked_at'] = Variable<DateTime>(lockedAt.value);
    }
    if (lockedByUserId.present) {
      map['locked_by_user_id'] = Variable<int>(lockedByUserId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayrollRunsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('notes: $notes, ')
          ..write('isLocked: $isLocked, ')
          ..write('lockedAt: $lockedAt, ')
          ..write('lockedByUserId: $lockedByUserId')
          ..write(')'))
        .toString();
  }
}

class $PayrollItemsTable extends PayrollItems
    with TableInfo<$PayrollItemsTable, PayrollItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayrollItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _payrollRunIdMeta = const VerificationMeta(
    'payrollRunId',
  );
  @override
  late final GeneratedColumn<int> payrollRunId = GeneratedColumn<int>(
    'payroll_run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payroll_runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES employees (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _employeeTypeMeta = const VerificationMeta(
    'employeeType',
  );
  @override
  late final GeneratedColumn<String> employeeType = GeneratedColumn<String>(
    'employee_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseSalaryMeta = const VerificationMeta(
    'baseSalary',
  );
  @override
  late final GeneratedColumn<double> baseSalary = GeneratedColumn<double>(
    'base_salary',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workedDaysMeta = const VerificationMeta(
    'workedDays',
  );
  @override
  late final GeneratedColumn<double> workedDays = GeneratedColumn<double>(
    'worked_days',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workedHoursMeta = const VerificationMeta(
    'workedHours',
  );
  @override
  late final GeneratedColumn<double> workedHours = GeneratedColumn<double>(
    'worked_hours',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overtimeHoursMeta = const VerificationMeta(
    'overtimeHours',
  );
  @override
  late final GeneratedColumn<double> overtimeHours = GeneratedColumn<double>(
    'overtime_hours',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overtimePayMeta = const VerificationMeta(
    'overtimePay',
  );
  @override
  late final GeneratedColumn<double> overtimePay = GeneratedColumn<double>(
    'overtime_pay',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ordinaryNightHoursMeta =
      const VerificationMeta('ordinaryNightHours');
  @override
  late final GeneratedColumn<double> ordinaryNightHours =
      GeneratedColumn<double>(
        'ordinary_night_hours',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _ordinaryNightSurchargePayMeta =
      const VerificationMeta('ordinaryNightSurchargePay');
  @override
  late final GeneratedColumn<double> ordinaryNightSurchargePay =
      GeneratedColumn<double>(
        'ordinary_night_surcharge_pay',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _grossPayMeta = const VerificationMeta(
    'grossPay',
  );
  @override
  late final GeneratedColumn<double> grossPay = GeneratedColumn<double>(
    'gross_pay',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyBonusMeta = const VerificationMeta(
    'familyBonus',
  );
  @override
  late final GeneratedColumn<double> familyBonus = GeneratedColumn<double>(
    'family_bonus',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ipsEmployeeMeta = const VerificationMeta(
    'ipsEmployee',
  );
  @override
  late final GeneratedColumn<double> ipsEmployee = GeneratedColumn<double>(
    'ips_employee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipsEmployerMeta = const VerificationMeta(
    'ipsEmployer',
  );
  @override
  late final GeneratedColumn<double> ipsEmployer = GeneratedColumn<double>(
    'ips_employer',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _advancesTotalMeta = const VerificationMeta(
    'advancesTotal',
  );
  @override
  late final GeneratedColumn<double> advancesTotal = GeneratedColumn<double>(
    'advances_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendanceDiscountMeta =
      const VerificationMeta('attendanceDiscount');
  @override
  late final GeneratedColumn<double> attendanceDiscount =
      GeneratedColumn<double>(
        'attendance_discount',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _otherDiscountMeta = const VerificationMeta(
    'otherDiscount',
  );
  @override
  late final GeneratedColumn<double> otherDiscount = GeneratedColumn<double>(
    'other_discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _embargoAmountMeta = const VerificationMeta(
    'embargoAmount',
  );
  @override
  late final GeneratedColumn<double> embargoAmount = GeneratedColumn<double>(
    'embargo_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embargoAccountMeta = const VerificationMeta(
    'embargoAccount',
  );
  @override
  late final GeneratedColumn<String> embargoAccount = GeneratedColumn<String>(
    'embargo_account',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _netPayMeta = const VerificationMeta('netPay');
  @override
  late final GeneratedColumn<double> netPay = GeneratedColumn<double>(
    'net_pay',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    payrollRunId,
    employeeId,
    employeeType,
    baseSalary,
    workedDays,
    workedHours,
    overtimeHours,
    overtimePay,
    ordinaryNightHours,
    ordinaryNightSurchargePay,
    grossPay,
    familyBonus,
    ipsEmployee,
    ipsEmployer,
    advancesTotal,
    attendanceDiscount,
    otherDiscount,
    embargoAmount,
    embargoAccount,
    netPay,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payroll_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayrollItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('payroll_run_id')) {
      context.handle(
        _payrollRunIdMeta,
        payrollRunId.isAcceptableOrUnknown(
          data['payroll_run_id']!,
          _payrollRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payrollRunIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('employee_type')) {
      context.handle(
        _employeeTypeMeta,
        employeeType.isAcceptableOrUnknown(
          data['employee_type']!,
          _employeeTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeTypeMeta);
    }
    if (data.containsKey('base_salary')) {
      context.handle(
        _baseSalaryMeta,
        baseSalary.isAcceptableOrUnknown(data['base_salary']!, _baseSalaryMeta),
      );
    } else if (isInserting) {
      context.missing(_baseSalaryMeta);
    }
    if (data.containsKey('worked_days')) {
      context.handle(
        _workedDaysMeta,
        workedDays.isAcceptableOrUnknown(data['worked_days']!, _workedDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_workedDaysMeta);
    }
    if (data.containsKey('worked_hours')) {
      context.handle(
        _workedHoursMeta,
        workedHours.isAcceptableOrUnknown(
          data['worked_hours']!,
          _workedHoursMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workedHoursMeta);
    }
    if (data.containsKey('overtime_hours')) {
      context.handle(
        _overtimeHoursMeta,
        overtimeHours.isAcceptableOrUnknown(
          data['overtime_hours']!,
          _overtimeHoursMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overtimeHoursMeta);
    }
    if (data.containsKey('overtime_pay')) {
      context.handle(
        _overtimePayMeta,
        overtimePay.isAcceptableOrUnknown(
          data['overtime_pay']!,
          _overtimePayMeta,
        ),
      );
    }
    if (data.containsKey('ordinary_night_hours')) {
      context.handle(
        _ordinaryNightHoursMeta,
        ordinaryNightHours.isAcceptableOrUnknown(
          data['ordinary_night_hours']!,
          _ordinaryNightHoursMeta,
        ),
      );
    }
    if (data.containsKey('ordinary_night_surcharge_pay')) {
      context.handle(
        _ordinaryNightSurchargePayMeta,
        ordinaryNightSurchargePay.isAcceptableOrUnknown(
          data['ordinary_night_surcharge_pay']!,
          _ordinaryNightSurchargePayMeta,
        ),
      );
    }
    if (data.containsKey('gross_pay')) {
      context.handle(
        _grossPayMeta,
        grossPay.isAcceptableOrUnknown(data['gross_pay']!, _grossPayMeta),
      );
    } else if (isInserting) {
      context.missing(_grossPayMeta);
    }
    if (data.containsKey('family_bonus')) {
      context.handle(
        _familyBonusMeta,
        familyBonus.isAcceptableOrUnknown(
          data['family_bonus']!,
          _familyBonusMeta,
        ),
      );
    }
    if (data.containsKey('ips_employee')) {
      context.handle(
        _ipsEmployeeMeta,
        ipsEmployee.isAcceptableOrUnknown(
          data['ips_employee']!,
          _ipsEmployeeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ipsEmployeeMeta);
    }
    if (data.containsKey('ips_employer')) {
      context.handle(
        _ipsEmployerMeta,
        ipsEmployer.isAcceptableOrUnknown(
          data['ips_employer']!,
          _ipsEmployerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ipsEmployerMeta);
    }
    if (data.containsKey('advances_total')) {
      context.handle(
        _advancesTotalMeta,
        advancesTotal.isAcceptableOrUnknown(
          data['advances_total']!,
          _advancesTotalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_advancesTotalMeta);
    }
    if (data.containsKey('attendance_discount')) {
      context.handle(
        _attendanceDiscountMeta,
        attendanceDiscount.isAcceptableOrUnknown(
          data['attendance_discount']!,
          _attendanceDiscountMeta,
        ),
      );
    }
    if (data.containsKey('other_discount')) {
      context.handle(
        _otherDiscountMeta,
        otherDiscount.isAcceptableOrUnknown(
          data['other_discount']!,
          _otherDiscountMeta,
        ),
      );
    }
    if (data.containsKey('embargo_amount')) {
      context.handle(
        _embargoAmountMeta,
        embargoAmount.isAcceptableOrUnknown(
          data['embargo_amount']!,
          _embargoAmountMeta,
        ),
      );
    }
    if (data.containsKey('embargo_account')) {
      context.handle(
        _embargoAccountMeta,
        embargoAccount.isAcceptableOrUnknown(
          data['embargo_account']!,
          _embargoAccountMeta,
        ),
      );
    }
    if (data.containsKey('net_pay')) {
      context.handle(
        _netPayMeta,
        netPay.isAcceptableOrUnknown(data['net_pay']!, _netPayMeta),
      );
    } else if (isInserting) {
      context.missing(_netPayMeta);
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
  PayrollItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayrollItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      payrollRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payroll_run_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employee_id'],
      )!,
      employeeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_type'],
      )!,
      baseSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_salary'],
      )!,
      workedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}worked_days'],
      )!,
      workedHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}worked_hours'],
      )!,
      overtimeHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overtime_hours'],
      )!,
      overtimePay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overtime_pay'],
      )!,
      ordinaryNightHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ordinary_night_hours'],
      )!,
      ordinaryNightSurchargePay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ordinary_night_surcharge_pay'],
      )!,
      grossPay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_pay'],
      )!,
      familyBonus: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}family_bonus'],
      )!,
      ipsEmployee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ips_employee'],
      )!,
      ipsEmployer: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ips_employer'],
      )!,
      advancesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}advances_total'],
      )!,
      attendanceDiscount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}attendance_discount'],
      )!,
      otherDiscount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}other_discount'],
      )!,
      embargoAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}embargo_amount'],
      ),
      embargoAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embargo_account'],
      ),
      netPay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_pay'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PayrollItemsTable createAlias(String alias) {
    return $PayrollItemsTable(attachedDatabase, alias);
  }
}

class PayrollItem extends DataClass implements Insertable<PayrollItem> {
  final int id;
  final int companyId;
  final int payrollRunId;
  final int employeeId;
  final String employeeType;
  final double baseSalary;
  final double workedDays;
  final double workedHours;
  final double overtimeHours;
  final double overtimePay;
  final double ordinaryNightHours;
  final double ordinaryNightSurchargePay;
  final double grossPay;
  final double familyBonus;
  final double ipsEmployee;
  final double ipsEmployer;
  final double advancesTotal;
  final double attendanceDiscount;
  final double otherDiscount;
  final double? embargoAmount;
  final String? embargoAccount;
  final double netPay;
  final DateTime createdAt;
  const PayrollItem({
    required this.id,
    required this.companyId,
    required this.payrollRunId,
    required this.employeeId,
    required this.employeeType,
    required this.baseSalary,
    required this.workedDays,
    required this.workedHours,
    required this.overtimeHours,
    required this.overtimePay,
    required this.ordinaryNightHours,
    required this.ordinaryNightSurchargePay,
    required this.grossPay,
    required this.familyBonus,
    required this.ipsEmployee,
    required this.ipsEmployer,
    required this.advancesTotal,
    required this.attendanceDiscount,
    required this.otherDiscount,
    this.embargoAmount,
    this.embargoAccount,
    required this.netPay,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    map['payroll_run_id'] = Variable<int>(payrollRunId);
    map['employee_id'] = Variable<int>(employeeId);
    map['employee_type'] = Variable<String>(employeeType);
    map['base_salary'] = Variable<double>(baseSalary);
    map['worked_days'] = Variable<double>(workedDays);
    map['worked_hours'] = Variable<double>(workedHours);
    map['overtime_hours'] = Variable<double>(overtimeHours);
    map['overtime_pay'] = Variable<double>(overtimePay);
    map['ordinary_night_hours'] = Variable<double>(ordinaryNightHours);
    map['ordinary_night_surcharge_pay'] = Variable<double>(
      ordinaryNightSurchargePay,
    );
    map['gross_pay'] = Variable<double>(grossPay);
    map['family_bonus'] = Variable<double>(familyBonus);
    map['ips_employee'] = Variable<double>(ipsEmployee);
    map['ips_employer'] = Variable<double>(ipsEmployer);
    map['advances_total'] = Variable<double>(advancesTotal);
    map['attendance_discount'] = Variable<double>(attendanceDiscount);
    map['other_discount'] = Variable<double>(otherDiscount);
    if (!nullToAbsent || embargoAmount != null) {
      map['embargo_amount'] = Variable<double>(embargoAmount);
    }
    if (!nullToAbsent || embargoAccount != null) {
      map['embargo_account'] = Variable<String>(embargoAccount);
    }
    map['net_pay'] = Variable<double>(netPay);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PayrollItemsCompanion toCompanion(bool nullToAbsent) {
    return PayrollItemsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      payrollRunId: Value(payrollRunId),
      employeeId: Value(employeeId),
      employeeType: Value(employeeType),
      baseSalary: Value(baseSalary),
      workedDays: Value(workedDays),
      workedHours: Value(workedHours),
      overtimeHours: Value(overtimeHours),
      overtimePay: Value(overtimePay),
      ordinaryNightHours: Value(ordinaryNightHours),
      ordinaryNightSurchargePay: Value(ordinaryNightSurchargePay),
      grossPay: Value(grossPay),
      familyBonus: Value(familyBonus),
      ipsEmployee: Value(ipsEmployee),
      ipsEmployer: Value(ipsEmployer),
      advancesTotal: Value(advancesTotal),
      attendanceDiscount: Value(attendanceDiscount),
      otherDiscount: Value(otherDiscount),
      embargoAmount: embargoAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(embargoAmount),
      embargoAccount: embargoAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(embargoAccount),
      netPay: Value(netPay),
      createdAt: Value(createdAt),
    );
  }

  factory PayrollItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayrollItem(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      payrollRunId: serializer.fromJson<int>(json['payrollRunId']),
      employeeId: serializer.fromJson<int>(json['employeeId']),
      employeeType: serializer.fromJson<String>(json['employeeType']),
      baseSalary: serializer.fromJson<double>(json['baseSalary']),
      workedDays: serializer.fromJson<double>(json['workedDays']),
      workedHours: serializer.fromJson<double>(json['workedHours']),
      overtimeHours: serializer.fromJson<double>(json['overtimeHours']),
      overtimePay: serializer.fromJson<double>(json['overtimePay']),
      ordinaryNightHours: serializer.fromJson<double>(
        json['ordinaryNightHours'],
      ),
      ordinaryNightSurchargePay: serializer.fromJson<double>(
        json['ordinaryNightSurchargePay'],
      ),
      grossPay: serializer.fromJson<double>(json['grossPay']),
      familyBonus: serializer.fromJson<double>(json['familyBonus']),
      ipsEmployee: serializer.fromJson<double>(json['ipsEmployee']),
      ipsEmployer: serializer.fromJson<double>(json['ipsEmployer']),
      advancesTotal: serializer.fromJson<double>(json['advancesTotal']),
      attendanceDiscount: serializer.fromJson<double>(
        json['attendanceDiscount'],
      ),
      otherDiscount: serializer.fromJson<double>(json['otherDiscount']),
      embargoAmount: serializer.fromJson<double?>(json['embargoAmount']),
      embargoAccount: serializer.fromJson<String?>(json['embargoAccount']),
      netPay: serializer.fromJson<double>(json['netPay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'payrollRunId': serializer.toJson<int>(payrollRunId),
      'employeeId': serializer.toJson<int>(employeeId),
      'employeeType': serializer.toJson<String>(employeeType),
      'baseSalary': serializer.toJson<double>(baseSalary),
      'workedDays': serializer.toJson<double>(workedDays),
      'workedHours': serializer.toJson<double>(workedHours),
      'overtimeHours': serializer.toJson<double>(overtimeHours),
      'overtimePay': serializer.toJson<double>(overtimePay),
      'ordinaryNightHours': serializer.toJson<double>(ordinaryNightHours),
      'ordinaryNightSurchargePay': serializer.toJson<double>(
        ordinaryNightSurchargePay,
      ),
      'grossPay': serializer.toJson<double>(grossPay),
      'familyBonus': serializer.toJson<double>(familyBonus),
      'ipsEmployee': serializer.toJson<double>(ipsEmployee),
      'ipsEmployer': serializer.toJson<double>(ipsEmployer),
      'advancesTotal': serializer.toJson<double>(advancesTotal),
      'attendanceDiscount': serializer.toJson<double>(attendanceDiscount),
      'otherDiscount': serializer.toJson<double>(otherDiscount),
      'embargoAmount': serializer.toJson<double?>(embargoAmount),
      'embargoAccount': serializer.toJson<String?>(embargoAccount),
      'netPay': serializer.toJson<double>(netPay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PayrollItem copyWith({
    int? id,
    int? companyId,
    int? payrollRunId,
    int? employeeId,
    String? employeeType,
    double? baseSalary,
    double? workedDays,
    double? workedHours,
    double? overtimeHours,
    double? overtimePay,
    double? ordinaryNightHours,
    double? ordinaryNightSurchargePay,
    double? grossPay,
    double? familyBonus,
    double? ipsEmployee,
    double? ipsEmployer,
    double? advancesTotal,
    double? attendanceDiscount,
    double? otherDiscount,
    Value<double?> embargoAmount = const Value.absent(),
    Value<String?> embargoAccount = const Value.absent(),
    double? netPay,
    DateTime? createdAt,
  }) => PayrollItem(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    payrollRunId: payrollRunId ?? this.payrollRunId,
    employeeId: employeeId ?? this.employeeId,
    employeeType: employeeType ?? this.employeeType,
    baseSalary: baseSalary ?? this.baseSalary,
    workedDays: workedDays ?? this.workedDays,
    workedHours: workedHours ?? this.workedHours,
    overtimeHours: overtimeHours ?? this.overtimeHours,
    overtimePay: overtimePay ?? this.overtimePay,
    ordinaryNightHours: ordinaryNightHours ?? this.ordinaryNightHours,
    ordinaryNightSurchargePay:
        ordinaryNightSurchargePay ?? this.ordinaryNightSurchargePay,
    grossPay: grossPay ?? this.grossPay,
    familyBonus: familyBonus ?? this.familyBonus,
    ipsEmployee: ipsEmployee ?? this.ipsEmployee,
    ipsEmployer: ipsEmployer ?? this.ipsEmployer,
    advancesTotal: advancesTotal ?? this.advancesTotal,
    attendanceDiscount: attendanceDiscount ?? this.attendanceDiscount,
    otherDiscount: otherDiscount ?? this.otherDiscount,
    embargoAmount: embargoAmount.present
        ? embargoAmount.value
        : this.embargoAmount,
    embargoAccount: embargoAccount.present
        ? embargoAccount.value
        : this.embargoAccount,
    netPay: netPay ?? this.netPay,
    createdAt: createdAt ?? this.createdAt,
  );
  PayrollItem copyWithCompanion(PayrollItemsCompanion data) {
    return PayrollItem(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      payrollRunId: data.payrollRunId.present
          ? data.payrollRunId.value
          : this.payrollRunId,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      employeeType: data.employeeType.present
          ? data.employeeType.value
          : this.employeeType,
      baseSalary: data.baseSalary.present
          ? data.baseSalary.value
          : this.baseSalary,
      workedDays: data.workedDays.present
          ? data.workedDays.value
          : this.workedDays,
      workedHours: data.workedHours.present
          ? data.workedHours.value
          : this.workedHours,
      overtimeHours: data.overtimeHours.present
          ? data.overtimeHours.value
          : this.overtimeHours,
      overtimePay: data.overtimePay.present
          ? data.overtimePay.value
          : this.overtimePay,
      ordinaryNightHours: data.ordinaryNightHours.present
          ? data.ordinaryNightHours.value
          : this.ordinaryNightHours,
      ordinaryNightSurchargePay: data.ordinaryNightSurchargePay.present
          ? data.ordinaryNightSurchargePay.value
          : this.ordinaryNightSurchargePay,
      grossPay: data.grossPay.present ? data.grossPay.value : this.grossPay,
      familyBonus: data.familyBonus.present
          ? data.familyBonus.value
          : this.familyBonus,
      ipsEmployee: data.ipsEmployee.present
          ? data.ipsEmployee.value
          : this.ipsEmployee,
      ipsEmployer: data.ipsEmployer.present
          ? data.ipsEmployer.value
          : this.ipsEmployer,
      advancesTotal: data.advancesTotal.present
          ? data.advancesTotal.value
          : this.advancesTotal,
      attendanceDiscount: data.attendanceDiscount.present
          ? data.attendanceDiscount.value
          : this.attendanceDiscount,
      otherDiscount: data.otherDiscount.present
          ? data.otherDiscount.value
          : this.otherDiscount,
      embargoAmount: data.embargoAmount.present
          ? data.embargoAmount.value
          : this.embargoAmount,
      embargoAccount: data.embargoAccount.present
          ? data.embargoAccount.value
          : this.embargoAccount,
      netPay: data.netPay.present ? data.netPay.value : this.netPay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayrollItem(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('payrollRunId: $payrollRunId, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeType: $employeeType, ')
          ..write('baseSalary: $baseSalary, ')
          ..write('workedDays: $workedDays, ')
          ..write('workedHours: $workedHours, ')
          ..write('overtimeHours: $overtimeHours, ')
          ..write('overtimePay: $overtimePay, ')
          ..write('ordinaryNightHours: $ordinaryNightHours, ')
          ..write('ordinaryNightSurchargePay: $ordinaryNightSurchargePay, ')
          ..write('grossPay: $grossPay, ')
          ..write('familyBonus: $familyBonus, ')
          ..write('ipsEmployee: $ipsEmployee, ')
          ..write('ipsEmployer: $ipsEmployer, ')
          ..write('advancesTotal: $advancesTotal, ')
          ..write('attendanceDiscount: $attendanceDiscount, ')
          ..write('otherDiscount: $otherDiscount, ')
          ..write('embargoAmount: $embargoAmount, ')
          ..write('embargoAccount: $embargoAccount, ')
          ..write('netPay: $netPay, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    payrollRunId,
    employeeId,
    employeeType,
    baseSalary,
    workedDays,
    workedHours,
    overtimeHours,
    overtimePay,
    ordinaryNightHours,
    ordinaryNightSurchargePay,
    grossPay,
    familyBonus,
    ipsEmployee,
    ipsEmployer,
    advancesTotal,
    attendanceDiscount,
    otherDiscount,
    embargoAmount,
    embargoAccount,
    netPay,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayrollItem &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.payrollRunId == this.payrollRunId &&
          other.employeeId == this.employeeId &&
          other.employeeType == this.employeeType &&
          other.baseSalary == this.baseSalary &&
          other.workedDays == this.workedDays &&
          other.workedHours == this.workedHours &&
          other.overtimeHours == this.overtimeHours &&
          other.overtimePay == this.overtimePay &&
          other.ordinaryNightHours == this.ordinaryNightHours &&
          other.ordinaryNightSurchargePay == this.ordinaryNightSurchargePay &&
          other.grossPay == this.grossPay &&
          other.familyBonus == this.familyBonus &&
          other.ipsEmployee == this.ipsEmployee &&
          other.ipsEmployer == this.ipsEmployer &&
          other.advancesTotal == this.advancesTotal &&
          other.attendanceDiscount == this.attendanceDiscount &&
          other.otherDiscount == this.otherDiscount &&
          other.embargoAmount == this.embargoAmount &&
          other.embargoAccount == this.embargoAccount &&
          other.netPay == this.netPay &&
          other.createdAt == this.createdAt);
}

class PayrollItemsCompanion extends UpdateCompanion<PayrollItem> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<int> payrollRunId;
  final Value<int> employeeId;
  final Value<String> employeeType;
  final Value<double> baseSalary;
  final Value<double> workedDays;
  final Value<double> workedHours;
  final Value<double> overtimeHours;
  final Value<double> overtimePay;
  final Value<double> ordinaryNightHours;
  final Value<double> ordinaryNightSurchargePay;
  final Value<double> grossPay;
  final Value<double> familyBonus;
  final Value<double> ipsEmployee;
  final Value<double> ipsEmployer;
  final Value<double> advancesTotal;
  final Value<double> attendanceDiscount;
  final Value<double> otherDiscount;
  final Value<double?> embargoAmount;
  final Value<String?> embargoAccount;
  final Value<double> netPay;
  final Value<DateTime> createdAt;
  const PayrollItemsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.payrollRunId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.employeeType = const Value.absent(),
    this.baseSalary = const Value.absent(),
    this.workedDays = const Value.absent(),
    this.workedHours = const Value.absent(),
    this.overtimeHours = const Value.absent(),
    this.overtimePay = const Value.absent(),
    this.ordinaryNightHours = const Value.absent(),
    this.ordinaryNightSurchargePay = const Value.absent(),
    this.grossPay = const Value.absent(),
    this.familyBonus = const Value.absent(),
    this.ipsEmployee = const Value.absent(),
    this.ipsEmployer = const Value.absent(),
    this.advancesTotal = const Value.absent(),
    this.attendanceDiscount = const Value.absent(),
    this.otherDiscount = const Value.absent(),
    this.embargoAmount = const Value.absent(),
    this.embargoAccount = const Value.absent(),
    this.netPay = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PayrollItemsCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required int payrollRunId,
    required int employeeId,
    required String employeeType,
    required double baseSalary,
    required double workedDays,
    required double workedHours,
    required double overtimeHours,
    this.overtimePay = const Value.absent(),
    this.ordinaryNightHours = const Value.absent(),
    this.ordinaryNightSurchargePay = const Value.absent(),
    required double grossPay,
    this.familyBonus = const Value.absent(),
    required double ipsEmployee,
    required double ipsEmployer,
    required double advancesTotal,
    this.attendanceDiscount = const Value.absent(),
    this.otherDiscount = const Value.absent(),
    this.embargoAmount = const Value.absent(),
    this.embargoAccount = const Value.absent(),
    required double netPay,
    this.createdAt = const Value.absent(),
  }) : companyId = Value(companyId),
       payrollRunId = Value(payrollRunId),
       employeeId = Value(employeeId),
       employeeType = Value(employeeType),
       baseSalary = Value(baseSalary),
       workedDays = Value(workedDays),
       workedHours = Value(workedHours),
       overtimeHours = Value(overtimeHours),
       grossPay = Value(grossPay),
       ipsEmployee = Value(ipsEmployee),
       ipsEmployer = Value(ipsEmployer),
       advancesTotal = Value(advancesTotal),
       netPay = Value(netPay);
  static Insertable<PayrollItem> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? payrollRunId,
    Expression<int>? employeeId,
    Expression<String>? employeeType,
    Expression<double>? baseSalary,
    Expression<double>? workedDays,
    Expression<double>? workedHours,
    Expression<double>? overtimeHours,
    Expression<double>? overtimePay,
    Expression<double>? ordinaryNightHours,
    Expression<double>? ordinaryNightSurchargePay,
    Expression<double>? grossPay,
    Expression<double>? familyBonus,
    Expression<double>? ipsEmployee,
    Expression<double>? ipsEmployer,
    Expression<double>? advancesTotal,
    Expression<double>? attendanceDiscount,
    Expression<double>? otherDiscount,
    Expression<double>? embargoAmount,
    Expression<String>? embargoAccount,
    Expression<double>? netPay,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (payrollRunId != null) 'payroll_run_id': payrollRunId,
      if (employeeId != null) 'employee_id': employeeId,
      if (employeeType != null) 'employee_type': employeeType,
      if (baseSalary != null) 'base_salary': baseSalary,
      if (workedDays != null) 'worked_days': workedDays,
      if (workedHours != null) 'worked_hours': workedHours,
      if (overtimeHours != null) 'overtime_hours': overtimeHours,
      if (overtimePay != null) 'overtime_pay': overtimePay,
      if (ordinaryNightHours != null)
        'ordinary_night_hours': ordinaryNightHours,
      if (ordinaryNightSurchargePay != null)
        'ordinary_night_surcharge_pay': ordinaryNightSurchargePay,
      if (grossPay != null) 'gross_pay': grossPay,
      if (familyBonus != null) 'family_bonus': familyBonus,
      if (ipsEmployee != null) 'ips_employee': ipsEmployee,
      if (ipsEmployer != null) 'ips_employer': ipsEmployer,
      if (advancesTotal != null) 'advances_total': advancesTotal,
      if (attendanceDiscount != null) 'attendance_discount': attendanceDiscount,
      if (otherDiscount != null) 'other_discount': otherDiscount,
      if (embargoAmount != null) 'embargo_amount': embargoAmount,
      if (embargoAccount != null) 'embargo_account': embargoAccount,
      if (netPay != null) 'net_pay': netPay,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PayrollItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<int>? payrollRunId,
    Value<int>? employeeId,
    Value<String>? employeeType,
    Value<double>? baseSalary,
    Value<double>? workedDays,
    Value<double>? workedHours,
    Value<double>? overtimeHours,
    Value<double>? overtimePay,
    Value<double>? ordinaryNightHours,
    Value<double>? ordinaryNightSurchargePay,
    Value<double>? grossPay,
    Value<double>? familyBonus,
    Value<double>? ipsEmployee,
    Value<double>? ipsEmployer,
    Value<double>? advancesTotal,
    Value<double>? attendanceDiscount,
    Value<double>? otherDiscount,
    Value<double?>? embargoAmount,
    Value<String?>? embargoAccount,
    Value<double>? netPay,
    Value<DateTime>? createdAt,
  }) {
    return PayrollItemsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      payrollRunId: payrollRunId ?? this.payrollRunId,
      employeeId: employeeId ?? this.employeeId,
      employeeType: employeeType ?? this.employeeType,
      baseSalary: baseSalary ?? this.baseSalary,
      workedDays: workedDays ?? this.workedDays,
      workedHours: workedHours ?? this.workedHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      overtimePay: overtimePay ?? this.overtimePay,
      ordinaryNightHours: ordinaryNightHours ?? this.ordinaryNightHours,
      ordinaryNightSurchargePay:
          ordinaryNightSurchargePay ?? this.ordinaryNightSurchargePay,
      grossPay: grossPay ?? this.grossPay,
      familyBonus: familyBonus ?? this.familyBonus,
      ipsEmployee: ipsEmployee ?? this.ipsEmployee,
      ipsEmployer: ipsEmployer ?? this.ipsEmployer,
      advancesTotal: advancesTotal ?? this.advancesTotal,
      attendanceDiscount: attendanceDiscount ?? this.attendanceDiscount,
      otherDiscount: otherDiscount ?? this.otherDiscount,
      embargoAmount: embargoAmount ?? this.embargoAmount,
      embargoAccount: embargoAccount ?? this.embargoAccount,
      netPay: netPay ?? this.netPay,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (payrollRunId.present) {
      map['payroll_run_id'] = Variable<int>(payrollRunId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<int>(employeeId.value);
    }
    if (employeeType.present) {
      map['employee_type'] = Variable<String>(employeeType.value);
    }
    if (baseSalary.present) {
      map['base_salary'] = Variable<double>(baseSalary.value);
    }
    if (workedDays.present) {
      map['worked_days'] = Variable<double>(workedDays.value);
    }
    if (workedHours.present) {
      map['worked_hours'] = Variable<double>(workedHours.value);
    }
    if (overtimeHours.present) {
      map['overtime_hours'] = Variable<double>(overtimeHours.value);
    }
    if (overtimePay.present) {
      map['overtime_pay'] = Variable<double>(overtimePay.value);
    }
    if (ordinaryNightHours.present) {
      map['ordinary_night_hours'] = Variable<double>(ordinaryNightHours.value);
    }
    if (ordinaryNightSurchargePay.present) {
      map['ordinary_night_surcharge_pay'] = Variable<double>(
        ordinaryNightSurchargePay.value,
      );
    }
    if (grossPay.present) {
      map['gross_pay'] = Variable<double>(grossPay.value);
    }
    if (familyBonus.present) {
      map['family_bonus'] = Variable<double>(familyBonus.value);
    }
    if (ipsEmployee.present) {
      map['ips_employee'] = Variable<double>(ipsEmployee.value);
    }
    if (ipsEmployer.present) {
      map['ips_employer'] = Variable<double>(ipsEmployer.value);
    }
    if (advancesTotal.present) {
      map['advances_total'] = Variable<double>(advancesTotal.value);
    }
    if (attendanceDiscount.present) {
      map['attendance_discount'] = Variable<double>(attendanceDiscount.value);
    }
    if (otherDiscount.present) {
      map['other_discount'] = Variable<double>(otherDiscount.value);
    }
    if (embargoAmount.present) {
      map['embargo_amount'] = Variable<double>(embargoAmount.value);
    }
    if (embargoAccount.present) {
      map['embargo_account'] = Variable<String>(embargoAccount.value);
    }
    if (netPay.present) {
      map['net_pay'] = Variable<double>(netPay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayrollItemsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('payrollRunId: $payrollRunId, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeType: $employeeType, ')
          ..write('baseSalary: $baseSalary, ')
          ..write('workedDays: $workedDays, ')
          ..write('workedHours: $workedHours, ')
          ..write('overtimeHours: $overtimeHours, ')
          ..write('overtimePay: $overtimePay, ')
          ..write('ordinaryNightHours: $ordinaryNightHours, ')
          ..write('ordinaryNightSurchargePay: $ordinaryNightSurchargePay, ')
          ..write('grossPay: $grossPay, ')
          ..write('familyBonus: $familyBonus, ')
          ..write('ipsEmployee: $ipsEmployee, ')
          ..write('ipsEmployer: $ipsEmployer, ')
          ..write('advancesTotal: $advancesTotal, ')
          ..write('attendanceDiscount: $attendanceDiscount, ')
          ..write('otherDiscount: $otherDiscount, ')
          ..write('embargoAmount: $embargoAmount, ')
          ..write('embargoAccount: $embargoAccount, ')
          ..write('netPay: $netPay, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RolesTable extends Roles with TableInfo<$RolesTable, Role> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
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
    $customConstraints: 'UNIQUE NOT NULL',
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
  @override
  List<GeneratedColumn> get $columns => [id, name, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Role> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Role map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Role(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }
}

class Role extends DataClass implements Insertable<Role> {
  final int id;
  final String name;
  final String? description;
  const Role({required this.id, required this.name, this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Role.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Role(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
    };
  }

  Role copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
  }) => Role(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
  );
  Role copyWithCompanion(RolesCompanion data) {
    return Role(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Role(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Role &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description);
}

class RolesCompanion extends UpdateCompanion<Role> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
  });
  RolesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Role> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    });
  }

  RolesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
  }) {
    return RolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $PermissionsTable extends Permissions
    with TableInfo<$PermissionsTable, Permission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PermissionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'permission_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
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
  @override
  List<GeneratedColumn> get $columns => [id, key, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Permission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('permission_key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['permission_key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Permission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Permission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_key'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $PermissionsTable createAlias(String alias) {
    return $PermissionsTable(attachedDatabase, alias);
  }
}

class Permission extends DataClass implements Insertable<Permission> {
  final int id;
  final String key;
  final String? description;
  const Permission({required this.id, required this.key, this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['permission_key'] = Variable<String>(key);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  PermissionsCompanion toCompanion(bool nullToAbsent) {
    return PermissionsCompanion(
      id: Value(id),
      key: Value(key),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Permission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Permission(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'description': serializer.toJson<String?>(description),
    };
  }

  Permission copyWith({
    int? id,
    String? key,
    Value<String?> description = const Value.absent(),
  }) => Permission(
    id: id ?? this.id,
    key: key ?? this.key,
    description: description.present ? description.value : this.description,
  );
  Permission copyWithCompanion(PermissionsCompanion data) {
    return Permission(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Permission(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Permission &&
          other.id == this.id &&
          other.key == this.key &&
          other.description == this.description);
}

class PermissionsCompanion extends UpdateCompanion<Permission> {
  final Value<int> id;
  final Value<String> key;
  final Value<String?> description;
  const PermissionsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.description = const Value.absent(),
  });
  PermissionsCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    this.description = const Value.absent(),
  }) : key = Value(key);
  static Insertable<Permission> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'permission_key': key,
      if (description != null) 'description': description,
    });
  }

  PermissionsCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String?>? description,
  }) {
    return PermissionsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['permission_key'] = Variable<String>(key.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PermissionsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $RolePermissionsTable extends RolePermissions
    with TableInfo<$RolePermissionsTable, RolePermission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolePermissionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES roles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _permissionIdMeta = const VerificationMeta(
    'permissionId',
  );
  @override
  late final GeneratedColumn<int> permissionId = GeneratedColumn<int>(
    'permission_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES permissions (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, roleId, permissionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'role_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RolePermission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('permission_id')) {
      context.handle(
        _permissionIdMeta,
        permissionId.isAcceptableOrUnknown(
          data['permission_id']!,
          _permissionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {roleId, permissionId},
  ];
  @override
  RolePermission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RolePermission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
      permissionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}permission_id'],
      )!,
    );
  }

  @override
  $RolePermissionsTable createAlias(String alias) {
    return $RolePermissionsTable(attachedDatabase, alias);
  }
}

class RolePermission extends DataClass implements Insertable<RolePermission> {
  final int id;
  final int roleId;
  final int permissionId;
  const RolePermission({
    required this.id,
    required this.roleId,
    required this.permissionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role_id'] = Variable<int>(roleId);
    map['permission_id'] = Variable<int>(permissionId);
    return map;
  }

  RolePermissionsCompanion toCompanion(bool nullToAbsent) {
    return RolePermissionsCompanion(
      id: Value(id),
      roleId: Value(roleId),
      permissionId: Value(permissionId),
    );
  }

  factory RolePermission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RolePermission(
      id: serializer.fromJson<int>(json['id']),
      roleId: serializer.fromJson<int>(json['roleId']),
      permissionId: serializer.fromJson<int>(json['permissionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roleId': serializer.toJson<int>(roleId),
      'permissionId': serializer.toJson<int>(permissionId),
    };
  }

  RolePermission copyWith({int? id, int? roleId, int? permissionId}) =>
      RolePermission(
        id: id ?? this.id,
        roleId: roleId ?? this.roleId,
        permissionId: permissionId ?? this.permissionId,
      );
  RolePermission copyWithCompanion(RolePermissionsCompanion data) {
    return RolePermission(
      id: data.id.present ? data.id.value : this.id,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      permissionId: data.permissionId.present
          ? data.permissionId.value
          : this.permissionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RolePermission(')
          ..write('id: $id, ')
          ..write('roleId: $roleId, ')
          ..write('permissionId: $permissionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roleId, permissionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RolePermission &&
          other.id == this.id &&
          other.roleId == this.roleId &&
          other.permissionId == this.permissionId);
}

class RolePermissionsCompanion extends UpdateCompanion<RolePermission> {
  final Value<int> id;
  final Value<int> roleId;
  final Value<int> permissionId;
  const RolePermissionsCompanion({
    this.id = const Value.absent(),
    this.roleId = const Value.absent(),
    this.permissionId = const Value.absent(),
  });
  RolePermissionsCompanion.insert({
    this.id = const Value.absent(),
    required int roleId,
    required int permissionId,
  }) : roleId = Value(roleId),
       permissionId = Value(permissionId);
  static Insertable<RolePermission> custom({
    Expression<int>? id,
    Expression<int>? roleId,
    Expression<int>? permissionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roleId != null) 'role_id': roleId,
      if (permissionId != null) 'permission_id': permissionId,
    });
  }

  RolePermissionsCompanion copyWith({
    Value<int>? id,
    Value<int>? roleId,
    Value<int>? permissionId,
  }) {
    return RolePermissionsCompanion(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      permissionId: permissionId ?? this.permissionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (permissionId.present) {
      map['permission_id'] = Variable<int>(permissionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolePermissionsCompanion(')
          ..write('id: $id, ')
          ..write('roleId: $roleId, ')
          ..write('permissionId: $permissionId')
          ..write(')'))
        .toString();
  }
}

class $UserCompanyAccessTable extends UserCompanyAccess
    with TableInfo<$UserCompanyAccessTable, UserCompanyAccessData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCompanyAccessTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES roles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("active" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, companyId, roleId, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_company_access';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCompanyAccessData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, companyId},
  ];
  @override
  UserCompanyAccessData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCompanyAccessData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $UserCompanyAccessTable createAlias(String alias) {
    return $UserCompanyAccessTable(attachedDatabase, alias);
  }
}

class UserCompanyAccessData extends DataClass
    implements Insertable<UserCompanyAccessData> {
  final int id;
  final int userId;
  final int companyId;
  final int roleId;
  final bool active;
  const UserCompanyAccessData({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.roleId,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['company_id'] = Variable<int>(companyId);
    map['role_id'] = Variable<int>(roleId);
    map['active'] = Variable<bool>(active);
    return map;
  }

  UserCompanyAccessCompanion toCompanion(bool nullToAbsent) {
    return UserCompanyAccessCompanion(
      id: Value(id),
      userId: Value(userId),
      companyId: Value(companyId),
      roleId: Value(roleId),
      active: Value(active),
    );
  }

  factory UserCompanyAccessData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCompanyAccessData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      companyId: serializer.fromJson<int>(json['companyId']),
      roleId: serializer.fromJson<int>(json['roleId']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'companyId': serializer.toJson<int>(companyId),
      'roleId': serializer.toJson<int>(roleId),
      'active': serializer.toJson<bool>(active),
    };
  }

  UserCompanyAccessData copyWith({
    int? id,
    int? userId,
    int? companyId,
    int? roleId,
    bool? active,
  }) => UserCompanyAccessData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    companyId: companyId ?? this.companyId,
    roleId: roleId ?? this.roleId,
    active: active ?? this.active,
  );
  UserCompanyAccessData copyWithCompanion(UserCompanyAccessCompanion data) {
    return UserCompanyAccessData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCompanyAccessData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('companyId: $companyId, ')
          ..write('roleId: $roleId, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, companyId, roleId, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCompanyAccessData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.companyId == this.companyId &&
          other.roleId == this.roleId &&
          other.active == this.active);
}

class UserCompanyAccessCompanion
    extends UpdateCompanion<UserCompanyAccessData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> companyId;
  final Value<int> roleId;
  final Value<bool> active;
  const UserCompanyAccessCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.roleId = const Value.absent(),
    this.active = const Value.absent(),
  });
  UserCompanyAccessCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int companyId,
    required int roleId,
    this.active = const Value.absent(),
  }) : userId = Value(userId),
       companyId = Value(companyId),
       roleId = Value(roleId);
  static Insertable<UserCompanyAccessData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? companyId,
    Expression<int>? roleId,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (companyId != null) 'company_id': companyId,
      if (roleId != null) 'role_id': roleId,
      if (active != null) 'active': active,
    });
  }

  UserCompanyAccessCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? companyId,
    Value<int>? roleId,
    Value<bool>? active,
  }) {
    return UserCompanyAccessCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      roleId: roleId ?? this.roleId,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCompanyAccessCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('companyId: $companyId, ')
          ..write('roleId: $roleId, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  late final $DepartmentsTable departments = $DepartmentsTable(this);
  late final $DepartmentSectorsTable departmentSectors =
      $DepartmentSectorsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $AttendanceEventsTable attendanceEvents = $AttendanceEventsTable(
    this,
  );
  late final $CompanySettingsTable companySettings = $CompanySettingsTable(
    this,
  );
  late final $AdvancesTable advances = $AdvancesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $PayrollRunsTable payrollRuns = $PayrollRunsTable(this);
  late final $PayrollItemsTable payrollItems = $PayrollItemsTable(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $PermissionsTable permissions = $PermissionsTable(this);
  late final $RolePermissionsTable rolePermissions = $RolePermissionsTable(
    this,
  );
  late final $UserCompanyAccessTable userCompanyAccess =
      $UserCompanyAccessTable(this);
  late final CompaniesDao companiesDao = CompaniesDao(this as AppDatabase);
  late final DepartmentsDao departmentsDao = DepartmentsDao(
    this as AppDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final EmployeesDao employeesDao = EmployeesDao(this as AppDatabase);
  late final AttendanceDao attendanceDao = AttendanceDao(this as AppDatabase);
  late final CompanySettingsDao companySettingsDao = CompanySettingsDao(
    this as AppDatabase,
  );
  late final AdvancesDao advancesDao = AdvancesDao(this as AppDatabase);
  late final PayrollDao payrollDao = PayrollDao(this as AppDatabase);
  late final SecurityDao securityDao = SecurityDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    companies,
    departments,
    departmentSectors,
    appSettings,
    employees,
    attendanceEvents,
    companySettings,
    advances,
    users,
    payrollRuns,
    payrollItems,
    roles,
    permissions,
    rolePermissions,
    userCompanyAccess,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('departments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'departments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('department_sectors', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('employees', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'departments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('employees', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'department_sectors',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('employees', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'employees',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('company_settings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('advances', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'employees',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('advances', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payroll_runs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payroll_runs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payroll_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'payroll_runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payroll_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'employees',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payroll_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'roles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('role_permissions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'permissions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('role_permissions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_company_access', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_company_access', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CompaniesTableCreateCompanionBuilder =
    CompaniesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> abbreviation,
      Value<String?> ruc,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> mjtEmployerNumber,
      Value<Uint8List?> logoPng,
      Value<bool> active,
      Value<DateTime> createdAt,
    });
typedef $$CompaniesTableUpdateCompanionBuilder =
    CompaniesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> abbreviation,
      Value<String?> ruc,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> mjtEmployerNumber,
      Value<Uint8List?> logoPng,
      Value<bool> active,
      Value<DateTime> createdAt,
    });

final class $$CompaniesTableReferences
    extends BaseReferences<_$AppDatabase, $CompaniesTable, Company> {
  $$CompaniesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DepartmentsTable, List<Department>>
  _departmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.departments,
    aliasName: $_aliasNameGenerator(db.companies.id, db.departments.companyId),
  );

  $$DepartmentsTableProcessedTableManager get departmentsRefs {
    final manager = $$DepartmentsTableTableManager(
      $_db,
      $_db.departments,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_departmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EmployeesTable, List<Employee>>
  _employeesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.employees,
    aliasName: $_aliasNameGenerator(db.companies.id, db.employees.companyId),
  );

  $$EmployeesTableProcessedTableManager get employeesRefs {
    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_employeesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendanceEventsTable, List<AttendanceEvent>>
  _attendanceEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendanceEvents,
    aliasName: $_aliasNameGenerator(
      db.companies.id,
      db.attendanceEvents.companyId,
    ),
  );

  $$AttendanceEventsTableProcessedTableManager get attendanceEventsRefs {
    final manager = $$AttendanceEventsTableTableManager(
      $_db,
      $_db.attendanceEvents,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompanySettingsTable, List<CompanySetting>>
  _companySettingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.companySettings,
    aliasName: $_aliasNameGenerator(
      db.companies.id,
      db.companySettings.companyId,
    ),
  );

  $$CompanySettingsTableProcessedTableManager get companySettingsRefs {
    final manager = $$CompanySettingsTableTableManager(
      $_db,
      $_db.companySettings,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _companySettingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdvancesTable, List<Advance>> _advancesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.advances,
    aliasName: $_aliasNameGenerator(db.companies.id, db.advances.companyId),
  );

  $$AdvancesTableProcessedTableManager get advancesRefs {
    final manager = $$AdvancesTableTableManager(
      $_db,
      $_db.advances,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_advancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PayrollRunsTable, List<PayrollRun>>
  _payrollRunsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payrollRuns,
    aliasName: $_aliasNameGenerator(db.companies.id, db.payrollRuns.companyId),
  );

  $$PayrollRunsTableProcessedTableManager get payrollRunsRefs {
    final manager = $$PayrollRunsTableTableManager(
      $_db,
      $_db.payrollRuns,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_payrollRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PayrollItemsTable, List<PayrollItem>>
  _payrollItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payrollItems,
    aliasName: $_aliasNameGenerator(db.companies.id, db.payrollItems.companyId),
  );

  $$PayrollItemsTableProcessedTableManager get payrollItemsRefs {
    final manager = $$PayrollItemsTableTableManager(
      $_db,
      $_db.payrollItems,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_payrollItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $UserCompanyAccessTable,
    List<UserCompanyAccessData>
  >
  _userCompanyAccessRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userCompanyAccess,
        aliasName: $_aliasNameGenerator(
          db.companies.id,
          db.userCompanyAccess.companyId,
        ),
      );

  $$UserCompanyAccessTableProcessedTableManager get userCompanyAccessRefs {
    final manager = $$UserCompanyAccessTableTableManager(
      $_db,
      $_db.userCompanyAccess,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userCompanyAccessRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
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

  ColumnFilters<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mjtEmployerNumber => $composableBuilder(
    column: $table.mjtEmployerNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get logoPng => $composableBuilder(
    column: $table.logoPng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> departmentsRefs(
    Expression<bool> Function($$DepartmentsTableFilterComposer f) f,
  ) {
    final $$DepartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.departments,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentsTableFilterComposer(
            $db: $db,
            $table: $db.departments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> employeesRefs(
    Expression<bool> Function($$EmployeesTableFilterComposer f) f,
  ) {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendanceEventsRefs(
    Expression<bool> Function($$AttendanceEventsTableFilterComposer f) f,
  ) {
    final $$AttendanceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceEvents,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceEventsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> companySettingsRefs(
    Expression<bool> Function($$CompanySettingsTableFilterComposer f) f,
  ) {
    final $$CompanySettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companySettings,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanySettingsTableFilterComposer(
            $db: $db,
            $table: $db.companySettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> advancesRefs(
    Expression<bool> Function($$AdvancesTableFilterComposer f) f,
  ) {
    final $$AdvancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableFilterComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> payrollRunsRefs(
    Expression<bool> Function($$PayrollRunsTableFilterComposer f) f,
  ) {
    final $$PayrollRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollRuns,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollRunsTableFilterComposer(
            $db: $db,
            $table: $db.payrollRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> payrollItemsRefs(
    Expression<bool> Function($$PayrollItemsTableFilterComposer f) f,
  ) {
    final $$PayrollItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollItems,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollItemsTableFilterComposer(
            $db: $db,
            $table: $db.payrollItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userCompanyAccessRefs(
    Expression<bool> Function($$UserCompanyAccessTableFilterComposer f) f,
  ) {
    final $$UserCompanyAccessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCompanyAccess,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCompanyAccessTableFilterComposer(
            $db: $db,
            $table: $db.userCompanyAccess,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
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

  ColumnOrderings<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mjtEmployerNumber => $composableBuilder(
    column: $table.mjtEmployerNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get logoPng => $composableBuilder(
    column: $table.logoPng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
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

  GeneratedColumn<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruc =>
      $composableBuilder(column: $table.ruc, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get mjtEmployerNumber => $composableBuilder(
    column: $table.mjtEmployerNumber,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get logoPng =>
      $composableBuilder(column: $table.logoPng, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> departmentsRefs<T extends Object>(
    Expression<T> Function($$DepartmentsTableAnnotationComposer a) f,
  ) {
    final $$DepartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.departments,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.departments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> employeesRefs<T extends Object>(
    Expression<T> Function($$EmployeesTableAnnotationComposer a) f,
  ) {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendanceEventsRefs<T extends Object>(
    Expression<T> Function($$AttendanceEventsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceEvents,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.attendanceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> companySettingsRefs<T extends Object>(
    Expression<T> Function($$CompanySettingsTableAnnotationComposer a) f,
  ) {
    final $$CompanySettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companySettings,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanySettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.companySettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> advancesRefs<T extends Object>(
    Expression<T> Function($$AdvancesTableAnnotationComposer a) f,
  ) {
    final $$AdvancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableAnnotationComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> payrollRunsRefs<T extends Object>(
    Expression<T> Function($$PayrollRunsTableAnnotationComposer a) f,
  ) {
    final $$PayrollRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollRuns,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.payrollRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> payrollItemsRefs<T extends Object>(
    Expression<T> Function($$PayrollItemsTableAnnotationComposer a) f,
  ) {
    final $$PayrollItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollItems,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.payrollItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userCompanyAccessRefs<T extends Object>(
    Expression<T> Function($$UserCompanyAccessTableAnnotationComposer a) f,
  ) {
    final $$UserCompanyAccessTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.userCompanyAccess,
          getReferencedColumn: (t) => t.companyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserCompanyAccessTableAnnotationComposer(
                $db: $db,
                $table: $db.userCompanyAccess,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTable,
          Company,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (Company, $$CompaniesTableReferences),
          Company,
          PrefetchHooks Function({
            bool departmentsRefs,
            bool employeesRefs,
            bool attendanceEventsRefs,
            bool companySettingsRefs,
            bool advancesRefs,
            bool payrollRunsRefs,
            bool payrollItemsRefs,
            bool userCompanyAccessRefs,
          })
        > {
  $$CompaniesTableTableManager(_$AppDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> abbreviation = const Value.absent(),
                Value<String?> ruc = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> mjtEmployerNumber = const Value.absent(),
                Value<Uint8List?> logoPng = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                name: name,
                abbreviation: abbreviation,
                ruc: ruc,
                address: address,
                phone: phone,
                mjtEmployerNumber: mjtEmployerNumber,
                logoPng: logoPng,
                active: active,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> abbreviation = const Value.absent(),
                Value<String?> ruc = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> mjtEmployerNumber = const Value.absent(),
                Value<Uint8List?> logoPng = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                name: name,
                abbreviation: abbreviation,
                ruc: ruc,
                address: address,
                phone: phone,
                mjtEmployerNumber: mjtEmployerNumber,
                logoPng: logoPng,
                active: active,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                departmentsRefs = false,
                employeesRefs = false,
                attendanceEventsRefs = false,
                companySettingsRefs = false,
                advancesRefs = false,
                payrollRunsRefs = false,
                payrollItemsRefs = false,
                userCompanyAccessRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (departmentsRefs) db.departments,
                    if (employeesRefs) db.employees,
                    if (attendanceEventsRefs) db.attendanceEvents,
                    if (companySettingsRefs) db.companySettings,
                    if (advancesRefs) db.advances,
                    if (payrollRunsRefs) db.payrollRuns,
                    if (payrollItemsRefs) db.payrollItems,
                    if (userCompanyAccessRefs) db.userCompanyAccess,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (departmentsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Department
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._departmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).departmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (employeesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Employee
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._employeesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).employeesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendanceEventsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          AttendanceEvent
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._attendanceEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (companySettingsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          CompanySetting
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._companySettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).companySettingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (advancesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Advance
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._advancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).advancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (payrollRunsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          PayrollRun
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._payrollRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).payrollRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (payrollItemsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          PayrollItem
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._payrollItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).payrollItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userCompanyAccessRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          UserCompanyAccessData
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._userCompanyAccessRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).userCompanyAccessRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
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

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTable,
      Company,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (Company, $$CompaniesTableReferences),
      Company,
      PrefetchHooks Function({
        bool departmentsRefs,
        bool employeesRefs,
        bool attendanceEventsRefs,
        bool companySettingsRefs,
        bool advancesRefs,
        bool payrollRunsRefs,
        bool payrollItemsRefs,
        bool userCompanyAccessRefs,
      })
    >;
typedef $$DepartmentsTableCreateCompanionBuilder =
    DepartmentsCompanion Function({
      Value<int> id,
      required int companyId,
      required String name,
      Value<String?> description,
      Value<bool> active,
      Value<DateTime> createdAt,
    });
typedef $$DepartmentsTableUpdateCompanionBuilder =
    DepartmentsCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> name,
      Value<String?> description,
      Value<bool> active,
      Value<DateTime> createdAt,
    });

final class $$DepartmentsTableReferences
    extends BaseReferences<_$AppDatabase, $DepartmentsTable, Department> {
  $$DepartmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.departments.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DepartmentSectorsTable, List<DepartmentSector>>
  _departmentSectorsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.departmentSectors,
        aliasName: $_aliasNameGenerator(
          db.departments.id,
          db.departmentSectors.departmentId,
        ),
      );

  $$DepartmentSectorsTableProcessedTableManager get departmentSectorsRefs {
    final manager = $$DepartmentSectorsTableTableManager(
      $_db,
      $_db.departmentSectors,
    ).filter((f) => f.departmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _departmentSectorsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EmployeesTable, List<Employee>>
  _employeesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.employees,
    aliasName: $_aliasNameGenerator(
      db.departments.id,
      db.employees.departmentId,
    ),
  );

  $$EmployeesTableProcessedTableManager get employeesRefs {
    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.departmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_employeesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DepartmentsTableFilterComposer
    extends Composer<_$AppDatabase, $DepartmentsTable> {
  $$DepartmentsTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> departmentSectorsRefs(
    Expression<bool> Function($$DepartmentSectorsTableFilterComposer f) f,
  ) {
    final $$DepartmentSectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.departmentSectors,
      getReferencedColumn: (t) => t.departmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentSectorsTableFilterComposer(
            $db: $db,
            $table: $db.departmentSectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> employeesRefs(
    Expression<bool> Function($$EmployeesTableFilterComposer f) f,
  ) {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.departmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DepartmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DepartmentsTable> {
  $$DepartmentsTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DepartmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DepartmentsTable> {
  $$DepartmentsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> departmentSectorsRefs<T extends Object>(
    Expression<T> Function($$DepartmentSectorsTableAnnotationComposer a) f,
  ) {
    final $$DepartmentSectorsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.departmentSectors,
          getReferencedColumn: (t) => t.departmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DepartmentSectorsTableAnnotationComposer(
                $db: $db,
                $table: $db.departmentSectors,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> employeesRefs<T extends Object>(
    Expression<T> Function($$EmployeesTableAnnotationComposer a) f,
  ) {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.departmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DepartmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DepartmentsTable,
          Department,
          $$DepartmentsTableFilterComposer,
          $$DepartmentsTableOrderingComposer,
          $$DepartmentsTableAnnotationComposer,
          $$DepartmentsTableCreateCompanionBuilder,
          $$DepartmentsTableUpdateCompanionBuilder,
          (Department, $$DepartmentsTableReferences),
          Department,
          PrefetchHooks Function({
            bool companyId,
            bool departmentSectorsRefs,
            bool employeesRefs,
          })
        > {
  $$DepartmentsTableTableManager(_$AppDatabase db, $DepartmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepartmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepartmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepartmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DepartmentsCompanion(
                id: id,
                companyId: companyId,
                name: name,
                description: description,
                active: active,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DepartmentsCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                description: description,
                active: active,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DepartmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                departmentSectorsRefs = false,
                employeesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (departmentSectorsRefs) db.departmentSectors,
                    if (employeesRefs) db.employees,
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
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$DepartmentsTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$DepartmentsTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (departmentSectorsRefs)
                        await $_getPrefetchedData<
                          Department,
                          $DepartmentsTable,
                          DepartmentSector
                        >(
                          currentTable: table,
                          referencedTable: $$DepartmentsTableReferences
                              ._departmentSectorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DepartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).departmentSectorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.departmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (employeesRefs)
                        await $_getPrefetchedData<
                          Department,
                          $DepartmentsTable,
                          Employee
                        >(
                          currentTable: table,
                          referencedTable: $$DepartmentsTableReferences
                              ._employeesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DepartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).employeesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.departmentId == item.id,
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

typedef $$DepartmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DepartmentsTable,
      Department,
      $$DepartmentsTableFilterComposer,
      $$DepartmentsTableOrderingComposer,
      $$DepartmentsTableAnnotationComposer,
      $$DepartmentsTableCreateCompanionBuilder,
      $$DepartmentsTableUpdateCompanionBuilder,
      (Department, $$DepartmentsTableReferences),
      Department,
      PrefetchHooks Function({
        bool companyId,
        bool departmentSectorsRefs,
        bool employeesRefs,
      })
    >;
typedef $$DepartmentSectorsTableCreateCompanionBuilder =
    DepartmentSectorsCompanion Function({
      Value<int> id,
      required int departmentId,
      required String name,
      Value<bool> active,
      Value<DateTime> createdAt,
    });
typedef $$DepartmentSectorsTableUpdateCompanionBuilder =
    DepartmentSectorsCompanion Function({
      Value<int> id,
      Value<int> departmentId,
      Value<String> name,
      Value<bool> active,
      Value<DateTime> createdAt,
    });

final class $$DepartmentSectorsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DepartmentSectorsTable,
          DepartmentSector
        > {
  $$DepartmentSectorsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DepartmentsTable _departmentIdTable(_$AppDatabase db) =>
      db.departments.createAlias(
        $_aliasNameGenerator(
          db.departmentSectors.departmentId,
          db.departments.id,
        ),
      );

  $$DepartmentsTableProcessedTableManager get departmentId {
    final $_column = $_itemColumn<int>('department_id')!;

    final manager = $$DepartmentsTableTableManager(
      $_db,
      $_db.departments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_departmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EmployeesTable, List<Employee>>
  _employeesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.employees,
    aliasName: $_aliasNameGenerator(
      db.departmentSectors.id,
      db.employees.sectorId,
    ),
  );

  $$EmployeesTableProcessedTableManager get employeesRefs {
    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.sectorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_employeesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DepartmentSectorsTableFilterComposer
    extends Composer<_$AppDatabase, $DepartmentSectorsTable> {
  $$DepartmentSectorsTableFilterComposer({
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

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DepartmentsTableFilterComposer get departmentId {
    final $$DepartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departmentId,
      referencedTable: $db.departments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentsTableFilterComposer(
            $db: $db,
            $table: $db.departments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> employeesRefs(
    Expression<bool> Function($$EmployeesTableFilterComposer f) f,
  ) {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DepartmentSectorsTableOrderingComposer
    extends Composer<_$AppDatabase, $DepartmentSectorsTable> {
  $$DepartmentSectorsTableOrderingComposer({
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

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DepartmentsTableOrderingComposer get departmentId {
    final $$DepartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departmentId,
      referencedTable: $db.departments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.departments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DepartmentSectorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DepartmentSectorsTable> {
  $$DepartmentSectorsTableAnnotationComposer({
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

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DepartmentsTableAnnotationComposer get departmentId {
    final $$DepartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departmentId,
      referencedTable: $db.departments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.departments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> employeesRefs<T extends Object>(
    Expression<T> Function($$EmployeesTableAnnotationComposer a) f,
  ) {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DepartmentSectorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DepartmentSectorsTable,
          DepartmentSector,
          $$DepartmentSectorsTableFilterComposer,
          $$DepartmentSectorsTableOrderingComposer,
          $$DepartmentSectorsTableAnnotationComposer,
          $$DepartmentSectorsTableCreateCompanionBuilder,
          $$DepartmentSectorsTableUpdateCompanionBuilder,
          (DepartmentSector, $$DepartmentSectorsTableReferences),
          DepartmentSector,
          PrefetchHooks Function({bool departmentId, bool employeesRefs})
        > {
  $$DepartmentSectorsTableTableManager(
    _$AppDatabase db,
    $DepartmentSectorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepartmentSectorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepartmentSectorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepartmentSectorsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> departmentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DepartmentSectorsCompanion(
                id: id,
                departmentId: departmentId,
                name: name,
                active: active,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int departmentId,
                required String name,
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DepartmentSectorsCompanion.insert(
                id: id,
                departmentId: departmentId,
                name: name,
                active: active,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DepartmentSectorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({departmentId = false, employeesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (employeesRefs) db.employees],
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
                        if (departmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.departmentId,
                                    referencedTable:
                                        $$DepartmentSectorsTableReferences
                                            ._departmentIdTable(db),
                                    referencedColumn:
                                        $$DepartmentSectorsTableReferences
                                            ._departmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (employeesRefs)
                        await $_getPrefetchedData<
                          DepartmentSector,
                          $DepartmentSectorsTable,
                          Employee
                        >(
                          currentTable: table,
                          referencedTable: $$DepartmentSectorsTableReferences
                              ._employeesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DepartmentSectorsTableReferences(
                                db,
                                table,
                                p0,
                              ).employeesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectorId == item.id,
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

typedef $$DepartmentSectorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DepartmentSectorsTable,
      DepartmentSector,
      $$DepartmentSectorsTableFilterComposer,
      $$DepartmentSectorsTableOrderingComposer,
      $$DepartmentSectorsTableAnnotationComposer,
      $$DepartmentSectorsTableCreateCompanionBuilder,
      $$DepartmentSectorsTableUpdateCompanionBuilder,
      (DepartmentSector, $$DepartmentSectorsTableReferences),
      DepartmentSector,
      PrefetchHooks Function({bool departmentId, bool employeesRefs})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$EmployeesTableCreateCompanionBuilder =
    EmployeesCompanion Function({
      Value<int> id,
      required int companyId,
      Value<String> firstNames,
      Value<String> lastNames,
      required String fullName,
      required String documentNumber,
      Value<int?> departmentId,
      Value<int?> sectorId,
      Value<String?> jobTitle,
      Value<String?> workLocation,
      required DateTime hireDate,
      required String employeeType,
      required double baseSalary,
      Value<bool> ipsEnabled,
      Value<int> childrenCount,
      Value<bool> allowOvertime,
      Value<bool> biometricClockEnabled,
      Value<bool> hasEmbargo,
      Value<String?> embargoAccount,
      Value<double?> embargoAmount,
      Value<String?> phone,
      Value<String?> address,
      Value<String> workStartTime1,
      Value<String> workStartTime2,
      Value<String> workStartTime3,
      Value<String?> workStartTimeSaturday,
      Value<String?> workEndTimeSaturday,
      Value<bool> active,
      Value<DateTime> createdAt,
    });
typedef $$EmployeesTableUpdateCompanionBuilder =
    EmployeesCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<String> firstNames,
      Value<String> lastNames,
      Value<String> fullName,
      Value<String> documentNumber,
      Value<int?> departmentId,
      Value<int?> sectorId,
      Value<String?> jobTitle,
      Value<String?> workLocation,
      Value<DateTime> hireDate,
      Value<String> employeeType,
      Value<double> baseSalary,
      Value<bool> ipsEnabled,
      Value<int> childrenCount,
      Value<bool> allowOvertime,
      Value<bool> biometricClockEnabled,
      Value<bool> hasEmbargo,
      Value<String?> embargoAccount,
      Value<double?> embargoAmount,
      Value<String?> phone,
      Value<String?> address,
      Value<String> workStartTime1,
      Value<String> workStartTime2,
      Value<String> workStartTime3,
      Value<String?> workStartTimeSaturday,
      Value<String?> workEndTimeSaturday,
      Value<bool> active,
      Value<DateTime> createdAt,
    });

final class $$EmployeesTableReferences
    extends BaseReferences<_$AppDatabase, $EmployeesTable, Employee> {
  $$EmployeesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.employees.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DepartmentsTable _departmentIdTable(_$AppDatabase db) =>
      db.departments.createAlias(
        $_aliasNameGenerator(db.employees.departmentId, db.departments.id),
      );

  $$DepartmentsTableProcessedTableManager? get departmentId {
    final $_column = $_itemColumn<int>('department_id');
    if ($_column == null) return null;
    final manager = $$DepartmentsTableTableManager(
      $_db,
      $_db.departments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_departmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DepartmentSectorsTable _sectorIdTable(_$AppDatabase db) =>
      db.departmentSectors.createAlias(
        $_aliasNameGenerator(db.employees.sectorId, db.departmentSectors.id),
      );

  $$DepartmentSectorsTableProcessedTableManager? get sectorId {
    final $_column = $_itemColumn<int>('sector_id');
    if ($_column == null) return null;
    final manager = $$DepartmentSectorsTableTableManager(
      $_db,
      $_db.departmentSectors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttendanceEventsTable, List<AttendanceEvent>>
  _attendanceEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendanceEvents,
    aliasName: $_aliasNameGenerator(
      db.employees.id,
      db.attendanceEvents.employeeId,
    ),
  );

  $$AttendanceEventsTableProcessedTableManager get attendanceEventsRefs {
    final manager = $$AttendanceEventsTableTableManager(
      $_db,
      $_db.attendanceEvents,
    ).filter((f) => f.employeeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdvancesTable, List<Advance>> _advancesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.advances,
    aliasName: $_aliasNameGenerator(db.employees.id, db.advances.employeeId),
  );

  $$AdvancesTableProcessedTableManager get advancesRefs {
    final manager = $$AdvancesTableTableManager(
      $_db,
      $_db.advances,
    ).filter((f) => f.employeeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_advancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PayrollItemsTable, List<PayrollItem>>
  _payrollItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payrollItems,
    aliasName: $_aliasNameGenerator(
      db.employees.id,
      db.payrollItems.employeeId,
    ),
  );

  $$PayrollItemsTableProcessedTableManager get payrollItemsRefs {
    final manager = $$PayrollItemsTableTableManager(
      $_db,
      $_db.payrollItems,
    ).filter((f) => f.employeeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_payrollItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
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

  ColumnFilters<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastNames => $composableBuilder(
    column: $table.lastNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workLocation => $composableBuilder(
    column: $table.workLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hireDate => $composableBuilder(
    column: $table.hireDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeType => $composableBuilder(
    column: $table.employeeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseSalary => $composableBuilder(
    column: $table.baseSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ipsEnabled => $composableBuilder(
    column: $table.ipsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get childrenCount => $composableBuilder(
    column: $table.childrenCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowOvertime => $composableBuilder(
    column: $table.allowOvertime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get biometricClockEnabled => $composableBuilder(
    column: $table.biometricClockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasEmbargo => $composableBuilder(
    column: $table.hasEmbargo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embargoAccount => $composableBuilder(
    column: $table.embargoAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get embargoAmount => $composableBuilder(
    column: $table.embargoAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workStartTime1 => $composableBuilder(
    column: $table.workStartTime1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workStartTime2 => $composableBuilder(
    column: $table.workStartTime2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workStartTime3 => $composableBuilder(
    column: $table.workStartTime3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workStartTimeSaturday => $composableBuilder(
    column: $table.workStartTimeSaturday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workEndTimeSaturday => $composableBuilder(
    column: $table.workEndTimeSaturday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DepartmentsTableFilterComposer get departmentId {
    final $$DepartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departmentId,
      referencedTable: $db.departments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentsTableFilterComposer(
            $db: $db,
            $table: $db.departments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DepartmentSectorsTableFilterComposer get sectorId {
    final $$DepartmentSectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.departmentSectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentSectorsTableFilterComposer(
            $db: $db,
            $table: $db.departmentSectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attendanceEventsRefs(
    Expression<bool> Function($$AttendanceEventsTableFilterComposer f) f,
  ) {
    final $$AttendanceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceEvents,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceEventsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> advancesRefs(
    Expression<bool> Function($$AdvancesTableFilterComposer f) f,
  ) {
    final $$AdvancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableFilterComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> payrollItemsRefs(
    Expression<bool> Function($$PayrollItemsTableFilterComposer f) f,
  ) {
    final $$PayrollItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollItems,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollItemsTableFilterComposer(
            $db: $db,
            $table: $db.payrollItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
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

  ColumnOrderings<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastNames => $composableBuilder(
    column: $table.lastNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workLocation => $composableBuilder(
    column: $table.workLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hireDate => $composableBuilder(
    column: $table.hireDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeType => $composableBuilder(
    column: $table.employeeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseSalary => $composableBuilder(
    column: $table.baseSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ipsEnabled => $composableBuilder(
    column: $table.ipsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get childrenCount => $composableBuilder(
    column: $table.childrenCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowOvertime => $composableBuilder(
    column: $table.allowOvertime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get biometricClockEnabled => $composableBuilder(
    column: $table.biometricClockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasEmbargo => $composableBuilder(
    column: $table.hasEmbargo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embargoAccount => $composableBuilder(
    column: $table.embargoAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get embargoAmount => $composableBuilder(
    column: $table.embargoAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workStartTime1 => $composableBuilder(
    column: $table.workStartTime1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workStartTime2 => $composableBuilder(
    column: $table.workStartTime2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workStartTime3 => $composableBuilder(
    column: $table.workStartTime3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workStartTimeSaturday => $composableBuilder(
    column: $table.workStartTimeSaturday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workEndTimeSaturday => $composableBuilder(
    column: $table.workEndTimeSaturday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DepartmentsTableOrderingComposer get departmentId {
    final $$DepartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departmentId,
      referencedTable: $db.departments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.departments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DepartmentSectorsTableOrderingComposer get sectorId {
    final $$DepartmentSectorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.departmentSectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentSectorsTableOrderingComposer(
            $db: $db,
            $table: $db.departmentSectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastNames =>
      $composableBuilder(column: $table.lastNames, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jobTitle =>
      $composableBuilder(column: $table.jobTitle, builder: (column) => column);

  GeneratedColumn<String> get workLocation => $composableBuilder(
    column: $table.workLocation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get hireDate =>
      $composableBuilder(column: $table.hireDate, builder: (column) => column);

  GeneratedColumn<String> get employeeType => $composableBuilder(
    column: $table.employeeType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baseSalary => $composableBuilder(
    column: $table.baseSalary,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ipsEnabled => $composableBuilder(
    column: $table.ipsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get childrenCount => $composableBuilder(
    column: $table.childrenCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowOvertime => $composableBuilder(
    column: $table.allowOvertime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get biometricClockEnabled => $composableBuilder(
    column: $table.biometricClockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasEmbargo => $composableBuilder(
    column: $table.hasEmbargo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embargoAccount => $composableBuilder(
    column: $table.embargoAccount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get embargoAmount => $composableBuilder(
    column: $table.embargoAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get workStartTime1 => $composableBuilder(
    column: $table.workStartTime1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workStartTime2 => $composableBuilder(
    column: $table.workStartTime2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workStartTime3 => $composableBuilder(
    column: $table.workStartTime3,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workStartTimeSaturday => $composableBuilder(
    column: $table.workStartTimeSaturday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workEndTimeSaturday => $composableBuilder(
    column: $table.workEndTimeSaturday,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DepartmentsTableAnnotationComposer get departmentId {
    final $$DepartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departmentId,
      referencedTable: $db.departments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.departments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DepartmentSectorsTableAnnotationComposer get sectorId {
    final $$DepartmentSectorsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sectorId,
          referencedTable: $db.departmentSectors,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DepartmentSectorsTableAnnotationComposer(
                $db: $db,
                $table: $db.departmentSectors,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> attendanceEventsRefs<T extends Object>(
    Expression<T> Function($$AttendanceEventsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceEvents,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.attendanceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> advancesRefs<T extends Object>(
    Expression<T> Function($$AdvancesTableAnnotationComposer a) f,
  ) {
    final $$AdvancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableAnnotationComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> payrollItemsRefs<T extends Object>(
    Expression<T> Function($$PayrollItemsTableAnnotationComposer a) f,
  ) {
    final $$PayrollItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollItems,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.payrollItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeesTable,
          Employee,
          $$EmployeesTableFilterComposer,
          $$EmployeesTableOrderingComposer,
          $$EmployeesTableAnnotationComposer,
          $$EmployeesTableCreateCompanionBuilder,
          $$EmployeesTableUpdateCompanionBuilder,
          (Employee, $$EmployeesTableReferences),
          Employee,
          PrefetchHooks Function({
            bool companyId,
            bool departmentId,
            bool sectorId,
            bool attendanceEventsRefs,
            bool advancesRefs,
            bool payrollItemsRefs,
          })
        > {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<String> firstNames = const Value.absent(),
                Value<String> lastNames = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> documentNumber = const Value.absent(),
                Value<int?> departmentId = const Value.absent(),
                Value<int?> sectorId = const Value.absent(),
                Value<String?> jobTitle = const Value.absent(),
                Value<String?> workLocation = const Value.absent(),
                Value<DateTime> hireDate = const Value.absent(),
                Value<String> employeeType = const Value.absent(),
                Value<double> baseSalary = const Value.absent(),
                Value<bool> ipsEnabled = const Value.absent(),
                Value<int> childrenCount = const Value.absent(),
                Value<bool> allowOvertime = const Value.absent(),
                Value<bool> biometricClockEnabled = const Value.absent(),
                Value<bool> hasEmbargo = const Value.absent(),
                Value<String?> embargoAccount = const Value.absent(),
                Value<double?> embargoAmount = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> workStartTime1 = const Value.absent(),
                Value<String> workStartTime2 = const Value.absent(),
                Value<String> workStartTime3 = const Value.absent(),
                Value<String?> workStartTimeSaturday = const Value.absent(),
                Value<String?> workEndTimeSaturday = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EmployeesCompanion(
                id: id,
                companyId: companyId,
                firstNames: firstNames,
                lastNames: lastNames,
                fullName: fullName,
                documentNumber: documentNumber,
                departmentId: departmentId,
                sectorId: sectorId,
                jobTitle: jobTitle,
                workLocation: workLocation,
                hireDate: hireDate,
                employeeType: employeeType,
                baseSalary: baseSalary,
                ipsEnabled: ipsEnabled,
                childrenCount: childrenCount,
                allowOvertime: allowOvertime,
                biometricClockEnabled: biometricClockEnabled,
                hasEmbargo: hasEmbargo,
                embargoAccount: embargoAccount,
                embargoAmount: embargoAmount,
                phone: phone,
                address: address,
                workStartTime1: workStartTime1,
                workStartTime2: workStartTime2,
                workStartTime3: workStartTime3,
                workStartTimeSaturday: workStartTimeSaturday,
                workEndTimeSaturday: workEndTimeSaturday,
                active: active,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                Value<String> firstNames = const Value.absent(),
                Value<String> lastNames = const Value.absent(),
                required String fullName,
                required String documentNumber,
                Value<int?> departmentId = const Value.absent(),
                Value<int?> sectorId = const Value.absent(),
                Value<String?> jobTitle = const Value.absent(),
                Value<String?> workLocation = const Value.absent(),
                required DateTime hireDate,
                required String employeeType,
                required double baseSalary,
                Value<bool> ipsEnabled = const Value.absent(),
                Value<int> childrenCount = const Value.absent(),
                Value<bool> allowOvertime = const Value.absent(),
                Value<bool> biometricClockEnabled = const Value.absent(),
                Value<bool> hasEmbargo = const Value.absent(),
                Value<String?> embargoAccount = const Value.absent(),
                Value<double?> embargoAmount = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> workStartTime1 = const Value.absent(),
                Value<String> workStartTime2 = const Value.absent(),
                Value<String> workStartTime3 = const Value.absent(),
                Value<String?> workStartTimeSaturday = const Value.absent(),
                Value<String?> workEndTimeSaturday = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EmployeesCompanion.insert(
                id: id,
                companyId: companyId,
                firstNames: firstNames,
                lastNames: lastNames,
                fullName: fullName,
                documentNumber: documentNumber,
                departmentId: departmentId,
                sectorId: sectorId,
                jobTitle: jobTitle,
                workLocation: workLocation,
                hireDate: hireDate,
                employeeType: employeeType,
                baseSalary: baseSalary,
                ipsEnabled: ipsEnabled,
                childrenCount: childrenCount,
                allowOvertime: allowOvertime,
                biometricClockEnabled: biometricClockEnabled,
                hasEmbargo: hasEmbargo,
                embargoAccount: embargoAccount,
                embargoAmount: embargoAmount,
                phone: phone,
                address: address,
                workStartTime1: workStartTime1,
                workStartTime2: workStartTime2,
                workStartTime3: workStartTime3,
                workStartTimeSaturday: workStartTimeSaturday,
                workEndTimeSaturday: workEndTimeSaturday,
                active: active,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmployeesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                departmentId = false,
                sectorId = false,
                attendanceEventsRefs = false,
                advancesRefs = false,
                payrollItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceEventsRefs) db.attendanceEvents,
                    if (advancesRefs) db.advances,
                    if (payrollItemsRefs) db.payrollItems,
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
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$EmployeesTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$EmployeesTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (departmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.departmentId,
                                    referencedTable: $$EmployeesTableReferences
                                        ._departmentIdTable(db),
                                    referencedColumn: $$EmployeesTableReferences
                                        ._departmentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (sectorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sectorId,
                                    referencedTable: $$EmployeesTableReferences
                                        ._sectorIdTable(db),
                                    referencedColumn: $$EmployeesTableReferences
                                        ._sectorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceEventsRefs)
                        await $_getPrefetchedData<
                          Employee,
                          $EmployeesTable,
                          AttendanceEvent
                        >(
                          currentTable: table,
                          referencedTable: $$EmployeesTableReferences
                              ._attendanceEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmployeesTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.employeeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (advancesRefs)
                        await $_getPrefetchedData<
                          Employee,
                          $EmployeesTable,
                          Advance
                        >(
                          currentTable: table,
                          referencedTable: $$EmployeesTableReferences
                              ._advancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmployeesTableReferences(
                                db,
                                table,
                                p0,
                              ).advancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.employeeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (payrollItemsRefs)
                        await $_getPrefetchedData<
                          Employee,
                          $EmployeesTable,
                          PayrollItem
                        >(
                          currentTable: table,
                          referencedTable: $$EmployeesTableReferences
                              ._payrollItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmployeesTableReferences(
                                db,
                                table,
                                p0,
                              ).payrollItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.employeeId == item.id,
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

typedef $$EmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeesTable,
      Employee,
      $$EmployeesTableFilterComposer,
      $$EmployeesTableOrderingComposer,
      $$EmployeesTableAnnotationComposer,
      $$EmployeesTableCreateCompanionBuilder,
      $$EmployeesTableUpdateCompanionBuilder,
      (Employee, $$EmployeesTableReferences),
      Employee,
      PrefetchHooks Function({
        bool companyId,
        bool departmentId,
        bool sectorId,
        bool attendanceEventsRefs,
        bool advancesRefs,
        bool payrollItemsRefs,
      })
    >;
typedef $$AttendanceEventsTableCreateCompanionBuilder =
    AttendanceEventsCompanion Function({
      Value<int> id,
      required int companyId,
      required int employeeId,
      required DateTime date,
      required String eventType,
      Value<int?> minutesLate,
      Value<double?> hoursWorked,
      Value<double?> overtimeHours,
      Value<String?> overtimeType,
      Value<String?> checkInTime,
      Value<String?> checkOutTime,
      Value<int?> breakMinutes,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$AttendanceEventsTableUpdateCompanionBuilder =
    AttendanceEventsCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<int> employeeId,
      Value<DateTime> date,
      Value<String> eventType,
      Value<int?> minutesLate,
      Value<double?> hoursWorked,
      Value<double?> overtimeHours,
      Value<String?> overtimeType,
      Value<String?> checkInTime,
      Value<String?> checkOutTime,
      Value<int?> breakMinutes,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$AttendanceEventsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AttendanceEventsTable, AttendanceEvent> {
  $$AttendanceEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.attendanceEvents.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EmployeesTable _employeeIdTable(_$AppDatabase db) =>
      db.employees.createAlias(
        $_aliasNameGenerator(db.attendanceEvents.employeeId, db.employees.id),
      );

  $$EmployeesTableProcessedTableManager get employeeId {
    final $_column = $_itemColumn<int>('employee_id')!;

    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesLate => $composableBuilder(
    column: $table.minutesLate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hoursWorked => $composableBuilder(
    column: $table.hoursWorked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overtimeHours => $composableBuilder(
    column: $table.overtimeHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overtimeType => $composableBuilder(
    column: $table.overtimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkInTime => $composableBuilder(
    column: $table.checkInTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkOutTime => $composableBuilder(
    column: $table.checkOutTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableFilterComposer get employeeId {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesLate => $composableBuilder(
    column: $table.minutesLate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hoursWorked => $composableBuilder(
    column: $table.hoursWorked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overtimeHours => $composableBuilder(
    column: $table.overtimeHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overtimeType => $composableBuilder(
    column: $table.overtimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkInTime => $composableBuilder(
    column: $table.checkInTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkOutTime => $composableBuilder(
    column: $table.checkOutTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableOrderingComposer get employeeId {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceEventsTable> {
  $$AttendanceEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get minutesLate => $composableBuilder(
    column: $table.minutesLate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hoursWorked => $composableBuilder(
    column: $table.hoursWorked,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overtimeHours => $composableBuilder(
    column: $table.overtimeHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overtimeType => $composableBuilder(
    column: $table.overtimeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checkInTime => $composableBuilder(
    column: $table.checkInTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checkOutTime => $composableBuilder(
    column: $table.checkOutTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableAnnotationComposer get employeeId {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceEventsTable,
          AttendanceEvent,
          $$AttendanceEventsTableFilterComposer,
          $$AttendanceEventsTableOrderingComposer,
          $$AttendanceEventsTableAnnotationComposer,
          $$AttendanceEventsTableCreateCompanionBuilder,
          $$AttendanceEventsTableUpdateCompanionBuilder,
          (AttendanceEvent, $$AttendanceEventsTableReferences),
          AttendanceEvent,
          PrefetchHooks Function({bool companyId, bool employeeId})
        > {
  $$AttendanceEventsTableTableManager(
    _$AppDatabase db,
    $AttendanceEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> employeeId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int?> minutesLate = const Value.absent(),
                Value<double?> hoursWorked = const Value.absent(),
                Value<double?> overtimeHours = const Value.absent(),
                Value<String?> overtimeType = const Value.absent(),
                Value<String?> checkInTime = const Value.absent(),
                Value<String?> checkOutTime = const Value.absent(),
                Value<int?> breakMinutes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AttendanceEventsCompanion(
                id: id,
                companyId: companyId,
                employeeId: employeeId,
                date: date,
                eventType: eventType,
                minutesLate: minutesLate,
                hoursWorked: hoursWorked,
                overtimeHours: overtimeHours,
                overtimeType: overtimeType,
                checkInTime: checkInTime,
                checkOutTime: checkOutTime,
                breakMinutes: breakMinutes,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required int employeeId,
                required DateTime date,
                required String eventType,
                Value<int?> minutesLate = const Value.absent(),
                Value<double?> hoursWorked = const Value.absent(),
                Value<double?> overtimeHours = const Value.absent(),
                Value<String?> overtimeType = const Value.absent(),
                Value<String?> checkInTime = const Value.absent(),
                Value<String?> checkOutTime = const Value.absent(),
                Value<int?> breakMinutes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AttendanceEventsCompanion.insert(
                id: id,
                companyId: companyId,
                employeeId: employeeId,
                date: date,
                eventType: eventType,
                minutesLate: minutesLate,
                hoursWorked: hoursWorked,
                overtimeHours: overtimeHours,
                overtimeType: overtimeType,
                checkInTime: checkInTime,
                checkOutTime: checkOutTime,
                breakMinutes: breakMinutes,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false, employeeId = false}) {
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
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable:
                                    $$AttendanceEventsTableReferences
                                        ._companyIdTable(db),
                                referencedColumn:
                                    $$AttendanceEventsTableReferences
                                        ._companyIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (employeeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.employeeId,
                                referencedTable:
                                    $$AttendanceEventsTableReferences
                                        ._employeeIdTable(db),
                                referencedColumn:
                                    $$AttendanceEventsTableReferences
                                        ._employeeIdTable(db)
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

typedef $$AttendanceEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceEventsTable,
      AttendanceEvent,
      $$AttendanceEventsTableFilterComposer,
      $$AttendanceEventsTableOrderingComposer,
      $$AttendanceEventsTableAnnotationComposer,
      $$AttendanceEventsTableCreateCompanionBuilder,
      $$AttendanceEventsTableUpdateCompanionBuilder,
      (AttendanceEvent, $$AttendanceEventsTableReferences),
      AttendanceEvent,
      PrefetchHooks Function({bool companyId, bool employeeId})
    >;
typedef $$CompanySettingsTableCreateCompanionBuilder =
    CompanySettingsCompanion Function({
      Value<int> companyId,
      Value<double> ipsEmployeeRate,
      Value<double> ipsEmployerRate,
      Value<double> minimumWage,
      Value<double> familyBonusRate,
      Value<double> overtimeDayRate,
      Value<double> overtimeNightRate,
      Value<double> ordinaryNightSurchargeRate,
      Value<String> ordinaryNightStart,
      Value<String> ordinaryNightEnd,
      Value<String> overtimeDayStart,
      Value<String> overtimeDayEnd,
      Value<String> overtimeNightStart,
      Value<String> overtimeNightEnd,
      Value<String> holidayDates,
      Value<int> lateArrivalToleranceMinutes,
      Value<int> lateArrivalAllowedTimesPerMonth,
      Value<DateTime> updatedAt,
    });
typedef $$CompanySettingsTableUpdateCompanionBuilder =
    CompanySettingsCompanion Function({
      Value<int> companyId,
      Value<double> ipsEmployeeRate,
      Value<double> ipsEmployerRate,
      Value<double> minimumWage,
      Value<double> familyBonusRate,
      Value<double> overtimeDayRate,
      Value<double> overtimeNightRate,
      Value<double> ordinaryNightSurchargeRate,
      Value<String> ordinaryNightStart,
      Value<String> ordinaryNightEnd,
      Value<String> overtimeDayStart,
      Value<String> overtimeDayEnd,
      Value<String> overtimeNightStart,
      Value<String> overtimeNightEnd,
      Value<String> holidayDates,
      Value<int> lateArrivalToleranceMinutes,
      Value<int> lateArrivalAllowedTimesPerMonth,
      Value<DateTime> updatedAt,
    });

final class $$CompanySettingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CompanySettingsTable, CompanySetting> {
  $$CompanySettingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.companySettings.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompanySettingsTableFilterComposer
    extends Composer<_$AppDatabase, $CompanySettingsTable> {
  $$CompanySettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get ipsEmployeeRate => $composableBuilder(
    column: $table.ipsEmployeeRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ipsEmployerRate => $composableBuilder(
    column: $table.ipsEmployerRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumWage => $composableBuilder(
    column: $table.minimumWage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get familyBonusRate => $composableBuilder(
    column: $table.familyBonusRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overtimeDayRate => $composableBuilder(
    column: $table.overtimeDayRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overtimeNightRate => $composableBuilder(
    column: $table.overtimeNightRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ordinaryNightSurchargeRate => $composableBuilder(
    column: $table.ordinaryNightSurchargeRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ordinaryNightStart => $composableBuilder(
    column: $table.ordinaryNightStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ordinaryNightEnd => $composableBuilder(
    column: $table.ordinaryNightEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overtimeDayStart => $composableBuilder(
    column: $table.overtimeDayStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overtimeDayEnd => $composableBuilder(
    column: $table.overtimeDayEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overtimeNightStart => $composableBuilder(
    column: $table.overtimeNightStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overtimeNightEnd => $composableBuilder(
    column: $table.overtimeNightEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holidayDates => $composableBuilder(
    column: $table.holidayDates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lateArrivalToleranceMinutes => $composableBuilder(
    column: $table.lateArrivalToleranceMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lateArrivalAllowedTimesPerMonth => $composableBuilder(
    column: $table.lateArrivalAllowedTimesPerMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanySettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanySettingsTable> {
  $$CompanySettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get ipsEmployeeRate => $composableBuilder(
    column: $table.ipsEmployeeRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ipsEmployerRate => $composableBuilder(
    column: $table.ipsEmployerRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumWage => $composableBuilder(
    column: $table.minimumWage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get familyBonusRate => $composableBuilder(
    column: $table.familyBonusRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overtimeDayRate => $composableBuilder(
    column: $table.overtimeDayRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overtimeNightRate => $composableBuilder(
    column: $table.overtimeNightRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ordinaryNightSurchargeRate => $composableBuilder(
    column: $table.ordinaryNightSurchargeRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ordinaryNightStart => $composableBuilder(
    column: $table.ordinaryNightStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ordinaryNightEnd => $composableBuilder(
    column: $table.ordinaryNightEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overtimeDayStart => $composableBuilder(
    column: $table.overtimeDayStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overtimeDayEnd => $composableBuilder(
    column: $table.overtimeDayEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overtimeNightStart => $composableBuilder(
    column: $table.overtimeNightStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overtimeNightEnd => $composableBuilder(
    column: $table.overtimeNightEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holidayDates => $composableBuilder(
    column: $table.holidayDates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lateArrivalToleranceMinutes => $composableBuilder(
    column: $table.lateArrivalToleranceMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lateArrivalAllowedTimesPerMonth =>
      $composableBuilder(
        column: $table.lateArrivalAllowedTimesPerMonth,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanySettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanySettingsTable> {
  $$CompanySettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get ipsEmployeeRate => $composableBuilder(
    column: $table.ipsEmployeeRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ipsEmployerRate => $composableBuilder(
    column: $table.ipsEmployerRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minimumWage => $composableBuilder(
    column: $table.minimumWage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get familyBonusRate => $composableBuilder(
    column: $table.familyBonusRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overtimeDayRate => $composableBuilder(
    column: $table.overtimeDayRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overtimeNightRate => $composableBuilder(
    column: $table.overtimeNightRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ordinaryNightSurchargeRate => $composableBuilder(
    column: $table.ordinaryNightSurchargeRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ordinaryNightStart => $composableBuilder(
    column: $table.ordinaryNightStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ordinaryNightEnd => $composableBuilder(
    column: $table.ordinaryNightEnd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overtimeDayStart => $composableBuilder(
    column: $table.overtimeDayStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overtimeDayEnd => $composableBuilder(
    column: $table.overtimeDayEnd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overtimeNightStart => $composableBuilder(
    column: $table.overtimeNightStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overtimeNightEnd => $composableBuilder(
    column: $table.overtimeNightEnd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get holidayDates => $composableBuilder(
    column: $table.holidayDates,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lateArrivalToleranceMinutes => $composableBuilder(
    column: $table.lateArrivalToleranceMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lateArrivalAllowedTimesPerMonth =>
      $composableBuilder(
        column: $table.lateArrivalAllowedTimesPerMonth,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanySettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanySettingsTable,
          CompanySetting,
          $$CompanySettingsTableFilterComposer,
          $$CompanySettingsTableOrderingComposer,
          $$CompanySettingsTableAnnotationComposer,
          $$CompanySettingsTableCreateCompanionBuilder,
          $$CompanySettingsTableUpdateCompanionBuilder,
          (CompanySetting, $$CompanySettingsTableReferences),
          CompanySetting,
          PrefetchHooks Function({bool companyId})
        > {
  $$CompanySettingsTableTableManager(
    _$AppDatabase db,
    $CompanySettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanySettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanySettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanySettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> companyId = const Value.absent(),
                Value<double> ipsEmployeeRate = const Value.absent(),
                Value<double> ipsEmployerRate = const Value.absent(),
                Value<double> minimumWage = const Value.absent(),
                Value<double> familyBonusRate = const Value.absent(),
                Value<double> overtimeDayRate = const Value.absent(),
                Value<double> overtimeNightRate = const Value.absent(),
                Value<double> ordinaryNightSurchargeRate = const Value.absent(),
                Value<String> ordinaryNightStart = const Value.absent(),
                Value<String> ordinaryNightEnd = const Value.absent(),
                Value<String> overtimeDayStart = const Value.absent(),
                Value<String> overtimeDayEnd = const Value.absent(),
                Value<String> overtimeNightStart = const Value.absent(),
                Value<String> overtimeNightEnd = const Value.absent(),
                Value<String> holidayDates = const Value.absent(),
                Value<int> lateArrivalToleranceMinutes = const Value.absent(),
                Value<int> lateArrivalAllowedTimesPerMonth =
                    const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CompanySettingsCompanion(
                companyId: companyId,
                ipsEmployeeRate: ipsEmployeeRate,
                ipsEmployerRate: ipsEmployerRate,
                minimumWage: minimumWage,
                familyBonusRate: familyBonusRate,
                overtimeDayRate: overtimeDayRate,
                overtimeNightRate: overtimeNightRate,
                ordinaryNightSurchargeRate: ordinaryNightSurchargeRate,
                ordinaryNightStart: ordinaryNightStart,
                ordinaryNightEnd: ordinaryNightEnd,
                overtimeDayStart: overtimeDayStart,
                overtimeDayEnd: overtimeDayEnd,
                overtimeNightStart: overtimeNightStart,
                overtimeNightEnd: overtimeNightEnd,
                holidayDates: holidayDates,
                lateArrivalToleranceMinutes: lateArrivalToleranceMinutes,
                lateArrivalAllowedTimesPerMonth:
                    lateArrivalAllowedTimesPerMonth,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> companyId = const Value.absent(),
                Value<double> ipsEmployeeRate = const Value.absent(),
                Value<double> ipsEmployerRate = const Value.absent(),
                Value<double> minimumWage = const Value.absent(),
                Value<double> familyBonusRate = const Value.absent(),
                Value<double> overtimeDayRate = const Value.absent(),
                Value<double> overtimeNightRate = const Value.absent(),
                Value<double> ordinaryNightSurchargeRate = const Value.absent(),
                Value<String> ordinaryNightStart = const Value.absent(),
                Value<String> ordinaryNightEnd = const Value.absent(),
                Value<String> overtimeDayStart = const Value.absent(),
                Value<String> overtimeDayEnd = const Value.absent(),
                Value<String> overtimeNightStart = const Value.absent(),
                Value<String> overtimeNightEnd = const Value.absent(),
                Value<String> holidayDates = const Value.absent(),
                Value<int> lateArrivalToleranceMinutes = const Value.absent(),
                Value<int> lateArrivalAllowedTimesPerMonth =
                    const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CompanySettingsCompanion.insert(
                companyId: companyId,
                ipsEmployeeRate: ipsEmployeeRate,
                ipsEmployerRate: ipsEmployerRate,
                minimumWage: minimumWage,
                familyBonusRate: familyBonusRate,
                overtimeDayRate: overtimeDayRate,
                overtimeNightRate: overtimeNightRate,
                ordinaryNightSurchargeRate: ordinaryNightSurchargeRate,
                ordinaryNightStart: ordinaryNightStart,
                ordinaryNightEnd: ordinaryNightEnd,
                overtimeDayStart: overtimeDayStart,
                overtimeDayEnd: overtimeDayEnd,
                overtimeNightStart: overtimeNightStart,
                overtimeNightEnd: overtimeNightEnd,
                holidayDates: holidayDates,
                lateArrivalToleranceMinutes: lateArrivalToleranceMinutes,
                lateArrivalAllowedTimesPerMonth:
                    lateArrivalAllowedTimesPerMonth,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompanySettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
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
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable:
                                    $$CompanySettingsTableReferences
                                        ._companyIdTable(db),
                                referencedColumn:
                                    $$CompanySettingsTableReferences
                                        ._companyIdTable(db)
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

typedef $$CompanySettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanySettingsTable,
      CompanySetting,
      $$CompanySettingsTableFilterComposer,
      $$CompanySettingsTableOrderingComposer,
      $$CompanySettingsTableAnnotationComposer,
      $$CompanySettingsTableCreateCompanionBuilder,
      $$CompanySettingsTableUpdateCompanionBuilder,
      (CompanySetting, $$CompanySettingsTableReferences),
      CompanySetting,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$AdvancesTableCreateCompanionBuilder =
    AdvancesCompanion Function({
      Value<int> id,
      required int companyId,
      required int employeeId,
      required DateTime date,
      required double amount,
      Value<String?> reason,
      Value<DateTime> createdAt,
    });
typedef $$AdvancesTableUpdateCompanionBuilder =
    AdvancesCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<int> employeeId,
      Value<DateTime> date,
      Value<double> amount,
      Value<String?> reason,
      Value<DateTime> createdAt,
    });

final class $$AdvancesTableReferences
    extends BaseReferences<_$AppDatabase, $AdvancesTable, Advance> {
  $$AdvancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.advances.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EmployeesTable _employeeIdTable(_$AppDatabase db) =>
      db.employees.createAlias(
        $_aliasNameGenerator(db.advances.employeeId, db.employees.id),
      );

  $$EmployeesTableProcessedTableManager get employeeId {
    final $_column = $_itemColumn<int>('employee_id')!;

    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdvancesTableFilterComposer
    extends Composer<_$AppDatabase, $AdvancesTable> {
  $$AdvancesTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableFilterComposer get employeeId {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdvancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AdvancesTable> {
  $$AdvancesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableOrderingComposer get employeeId {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdvancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdvancesTable> {
  $$AdvancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableAnnotationComposer get employeeId {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdvancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdvancesTable,
          Advance,
          $$AdvancesTableFilterComposer,
          $$AdvancesTableOrderingComposer,
          $$AdvancesTableAnnotationComposer,
          $$AdvancesTableCreateCompanionBuilder,
          $$AdvancesTableUpdateCompanionBuilder,
          (Advance, $$AdvancesTableReferences),
          Advance,
          PrefetchHooks Function({bool companyId, bool employeeId})
        > {
  $$AdvancesTableTableManager(_$AppDatabase db, $AdvancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdvancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdvancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdvancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> employeeId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AdvancesCompanion(
                id: id,
                companyId: companyId,
                employeeId: employeeId,
                date: date,
                amount: amount,
                reason: reason,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required int employeeId,
                required DateTime date,
                required double amount,
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AdvancesCompanion.insert(
                id: id,
                companyId: companyId,
                employeeId: employeeId,
                date: date,
                amount: amount,
                reason: reason,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdvancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false, employeeId = false}) {
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
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$AdvancesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$AdvancesTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (employeeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.employeeId,
                                referencedTable: $$AdvancesTableReferences
                                    ._employeeIdTable(db),
                                referencedColumn: $$AdvancesTableReferences
                                    ._employeeIdTable(db)
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

typedef $$AdvancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdvancesTable,
      Advance,
      $$AdvancesTableFilterComposer,
      $$AdvancesTableOrderingComposer,
      $$AdvancesTableAnnotationComposer,
      $$AdvancesTableCreateCompanionBuilder,
      $$AdvancesTableUpdateCompanionBuilder,
      (Advance, $$AdvancesTableReferences),
      Advance,
      PrefetchHooks Function({bool companyId, bool employeeId})
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String username,
      required String passwordHash,
      required String fullName,
      Value<bool> active,
      Value<DateTime> createdAt,
      Value<DateTime?> lastLoginAt,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> passwordHash,
      Value<String> fullName,
      Value<bool> active,
      Value<DateTime> createdAt,
      Value<DateTime?> lastLoginAt,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PayrollRunsTable, List<PayrollRun>>
  _payrollRunsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payrollRuns,
    aliasName: $_aliasNameGenerator(db.users.id, db.payrollRuns.lockedByUserId),
  );

  $$PayrollRunsTableProcessedTableManager get payrollRunsRefs {
    final manager = $$PayrollRunsTableTableManager(
      $_db,
      $_db.payrollRuns,
    ).filter((f) => f.lockedByUserId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_payrollRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $UserCompanyAccessTable,
    List<UserCompanyAccessData>
  >
  _userCompanyAccessRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userCompanyAccess,
        aliasName: $_aliasNameGenerator(
          db.users.id,
          db.userCompanyAccess.userId,
        ),
      );

  $$UserCompanyAccessTableProcessedTableManager get userCompanyAccessRefs {
    final manager = $$UserCompanyAccessTableTableManager(
      $_db,
      $_db.userCompanyAccess,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userCompanyAccessRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> payrollRunsRefs(
    Expression<bool> Function($$PayrollRunsTableFilterComposer f) f,
  ) {
    final $$PayrollRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollRuns,
      getReferencedColumn: (t) => t.lockedByUserId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollRunsTableFilterComposer(
            $db: $db,
            $table: $db.payrollRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userCompanyAccessRefs(
    Expression<bool> Function($$UserCompanyAccessTableFilterComposer f) f,
  ) {
    final $$UserCompanyAccessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCompanyAccess,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCompanyAccessTableFilterComposer(
            $db: $db,
            $table: $db.userCompanyAccess,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  Expression<T> payrollRunsRefs<T extends Object>(
    Expression<T> Function($$PayrollRunsTableAnnotationComposer a) f,
  ) {
    final $$PayrollRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollRuns,
      getReferencedColumn: (t) => t.lockedByUserId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.payrollRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userCompanyAccessRefs<T extends Object>(
    Expression<T> Function($$UserCompanyAccessTableAnnotationComposer a) f,
  ) {
    final $$UserCompanyAccessTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.userCompanyAccess,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserCompanyAccessTableAnnotationComposer(
                $db: $db,
                $table: $db.userCompanyAccess,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool payrollRunsRefs,
            bool userCompanyAccessRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                passwordHash: passwordHash,
                fullName: fullName,
                active: active,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String passwordHash,
                required String fullName,
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                passwordHash: passwordHash,
                fullName: fullName,
                active: active,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({payrollRunsRefs = false, userCompanyAccessRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (payrollRunsRefs) db.payrollRuns,
                    if (userCompanyAccessRefs) db.userCompanyAccess,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (payrollRunsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          PayrollRun
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._payrollRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).payrollRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lockedByUserId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userCompanyAccessRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          UserCompanyAccessData
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._userCompanyAccessRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userCompanyAccessRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
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

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool payrollRunsRefs, bool userCompanyAccessRefs})
    >;
typedef $$PayrollRunsTableCreateCompanionBuilder =
    PayrollRunsCompanion Function({
      Value<int> id,
      required int companyId,
      required int year,
      required int month,
      Value<DateTime> generatedAt,
      Value<String?> notes,
      Value<bool> isLocked,
      Value<DateTime?> lockedAt,
      Value<int?> lockedByUserId,
    });
typedef $$PayrollRunsTableUpdateCompanionBuilder =
    PayrollRunsCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<int> year,
      Value<int> month,
      Value<DateTime> generatedAt,
      Value<String?> notes,
      Value<bool> isLocked,
      Value<DateTime?> lockedAt,
      Value<int?> lockedByUserId,
    });

final class $$PayrollRunsTableReferences
    extends BaseReferences<_$AppDatabase, $PayrollRunsTable, PayrollRun> {
  $$PayrollRunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.payrollRuns.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _lockedByUserIdTable(_$AppDatabase db) =>
      db.users.createAlias(
        $_aliasNameGenerator(db.payrollRuns.lockedByUserId, db.users.id),
      );

  $$UsersTableProcessedTableManager? get lockedByUserId {
    final $_column = $_itemColumn<int>('locked_by_user_id');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lockedByUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PayrollItemsTable, List<PayrollItem>>
  _payrollItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payrollItems,
    aliasName: $_aliasNameGenerator(
      db.payrollRuns.id,
      db.payrollItems.payrollRunId,
    ),
  );

  $$PayrollItemsTableProcessedTableManager get payrollItemsRefs {
    final manager = $$PayrollItemsTableTableManager(
      $_db,
      $_db.payrollItems,
    ).filter((f) => f.payrollRunId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_payrollItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PayrollRunsTableFilterComposer
    extends Composer<_$AppDatabase, $PayrollRunsTable> {
  $$PayrollRunsTableFilterComposer({
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

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedAt => $composableBuilder(
    column: $table.lockedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get lockedByUserId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lockedByUserId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> payrollItemsRefs(
    Expression<bool> Function($$PayrollItemsTableFilterComposer f) f,
  ) {
    final $$PayrollItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollItems,
      getReferencedColumn: (t) => t.payrollRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollItemsTableFilterComposer(
            $db: $db,
            $table: $db.payrollItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PayrollRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayrollRunsTable> {
  $$PayrollRunsTableOrderingComposer({
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

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedAt => $composableBuilder(
    column: $table.lockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get lockedByUserId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lockedByUserId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayrollRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayrollRunsTable> {
  $$PayrollRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<DateTime> get lockedAt =>
      $composableBuilder(column: $table.lockedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get lockedByUserId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lockedByUserId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> payrollItemsRefs<T extends Object>(
    Expression<T> Function($$PayrollItemsTableAnnotationComposer a) f,
  ) {
    final $$PayrollItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollItems,
      getReferencedColumn: (t) => t.payrollRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.payrollItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PayrollRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayrollRunsTable,
          PayrollRun,
          $$PayrollRunsTableFilterComposer,
          $$PayrollRunsTableOrderingComposer,
          $$PayrollRunsTableAnnotationComposer,
          $$PayrollRunsTableCreateCompanionBuilder,
          $$PayrollRunsTableUpdateCompanionBuilder,
          (PayrollRun, $$PayrollRunsTableReferences),
          PayrollRun,
          PrefetchHooks Function({
            bool companyId,
            bool lockedByUserId,
            bool payrollItemsRefs,
          })
        > {
  $$PayrollRunsTableTableManager(_$AppDatabase db, $PayrollRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayrollRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayrollRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayrollRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<DateTime?> lockedAt = const Value.absent(),
                Value<int?> lockedByUserId = const Value.absent(),
              }) => PayrollRunsCompanion(
                id: id,
                companyId: companyId,
                year: year,
                month: month,
                generatedAt: generatedAt,
                notes: notes,
                isLocked: isLocked,
                lockedAt: lockedAt,
                lockedByUserId: lockedByUserId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required int year,
                required int month,
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<DateTime?> lockedAt = const Value.absent(),
                Value<int?> lockedByUserId = const Value.absent(),
              }) => PayrollRunsCompanion.insert(
                id: id,
                companyId: companyId,
                year: year,
                month: month,
                generatedAt: generatedAt,
                notes: notes,
                isLocked: isLocked,
                lockedAt: lockedAt,
                lockedByUserId: lockedByUserId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PayrollRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                lockedByUserId = false,
                payrollItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (payrollItemsRefs) db.payrollItems,
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
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$PayrollRunsTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$PayrollRunsTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (lockedByUserId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.lockedByUserId,
                                    referencedTable:
                                        $$PayrollRunsTableReferences
                                            ._lockedByUserIdTable(db),
                                    referencedColumn:
                                        $$PayrollRunsTableReferences
                                            ._lockedByUserIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (payrollItemsRefs)
                        await $_getPrefetchedData<
                          PayrollRun,
                          $PayrollRunsTable,
                          PayrollItem
                        >(
                          currentTable: table,
                          referencedTable: $$PayrollRunsTableReferences
                              ._payrollItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PayrollRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).payrollItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.payrollRunId == item.id,
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

typedef $$PayrollRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayrollRunsTable,
      PayrollRun,
      $$PayrollRunsTableFilterComposer,
      $$PayrollRunsTableOrderingComposer,
      $$PayrollRunsTableAnnotationComposer,
      $$PayrollRunsTableCreateCompanionBuilder,
      $$PayrollRunsTableUpdateCompanionBuilder,
      (PayrollRun, $$PayrollRunsTableReferences),
      PayrollRun,
      PrefetchHooks Function({
        bool companyId,
        bool lockedByUserId,
        bool payrollItemsRefs,
      })
    >;
typedef $$PayrollItemsTableCreateCompanionBuilder =
    PayrollItemsCompanion Function({
      Value<int> id,
      required int companyId,
      required int payrollRunId,
      required int employeeId,
      required String employeeType,
      required double baseSalary,
      required double workedDays,
      required double workedHours,
      required double overtimeHours,
      Value<double> overtimePay,
      Value<double> ordinaryNightHours,
      Value<double> ordinaryNightSurchargePay,
      required double grossPay,
      Value<double> familyBonus,
      required double ipsEmployee,
      required double ipsEmployer,
      required double advancesTotal,
      Value<double> attendanceDiscount,
      Value<double> otherDiscount,
      Value<double?> embargoAmount,
      Value<String?> embargoAccount,
      required double netPay,
      Value<DateTime> createdAt,
    });
typedef $$PayrollItemsTableUpdateCompanionBuilder =
    PayrollItemsCompanion Function({
      Value<int> id,
      Value<int> companyId,
      Value<int> payrollRunId,
      Value<int> employeeId,
      Value<String> employeeType,
      Value<double> baseSalary,
      Value<double> workedDays,
      Value<double> workedHours,
      Value<double> overtimeHours,
      Value<double> overtimePay,
      Value<double> ordinaryNightHours,
      Value<double> ordinaryNightSurchargePay,
      Value<double> grossPay,
      Value<double> familyBonus,
      Value<double> ipsEmployee,
      Value<double> ipsEmployer,
      Value<double> advancesTotal,
      Value<double> attendanceDiscount,
      Value<double> otherDiscount,
      Value<double?> embargoAmount,
      Value<String?> embargoAccount,
      Value<double> netPay,
      Value<DateTime> createdAt,
    });

final class $$PayrollItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PayrollItemsTable, PayrollItem> {
  $$PayrollItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.payrollItems.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PayrollRunsTable _payrollRunIdTable(_$AppDatabase db) =>
      db.payrollRuns.createAlias(
        $_aliasNameGenerator(db.payrollItems.payrollRunId, db.payrollRuns.id),
      );

  $$PayrollRunsTableProcessedTableManager get payrollRunId {
    final $_column = $_itemColumn<int>('payroll_run_id')!;

    final manager = $$PayrollRunsTableTableManager(
      $_db,
      $_db.payrollRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payrollRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EmployeesTable _employeeIdTable(_$AppDatabase db) =>
      db.employees.createAlias(
        $_aliasNameGenerator(db.payrollItems.employeeId, db.employees.id),
      );

  $$EmployeesTableProcessedTableManager get employeeId {
    final $_column = $_itemColumn<int>('employee_id')!;

    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PayrollItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PayrollItemsTable> {
  $$PayrollItemsTableFilterComposer({
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

  ColumnFilters<String> get employeeType => $composableBuilder(
    column: $table.employeeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseSalary => $composableBuilder(
    column: $table.baseSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get workedDays => $composableBuilder(
    column: $table.workedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get workedHours => $composableBuilder(
    column: $table.workedHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overtimeHours => $composableBuilder(
    column: $table.overtimeHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overtimePay => $composableBuilder(
    column: $table.overtimePay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ordinaryNightHours => $composableBuilder(
    column: $table.ordinaryNightHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ordinaryNightSurchargePay => $composableBuilder(
    column: $table.ordinaryNightSurchargePay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossPay => $composableBuilder(
    column: $table.grossPay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get familyBonus => $composableBuilder(
    column: $table.familyBonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ipsEmployee => $composableBuilder(
    column: $table.ipsEmployee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ipsEmployer => $composableBuilder(
    column: $table.ipsEmployer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get advancesTotal => $composableBuilder(
    column: $table.advancesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get attendanceDiscount => $composableBuilder(
    column: $table.attendanceDiscount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get otherDiscount => $composableBuilder(
    column: $table.otherDiscount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get embargoAmount => $composableBuilder(
    column: $table.embargoAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embargoAccount => $composableBuilder(
    column: $table.embargoAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netPay => $composableBuilder(
    column: $table.netPay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PayrollRunsTableFilterComposer get payrollRunId {
    final $$PayrollRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payrollRunId,
      referencedTable: $db.payrollRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollRunsTableFilterComposer(
            $db: $db,
            $table: $db.payrollRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableFilterComposer get employeeId {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayrollItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayrollItemsTable> {
  $$PayrollItemsTableOrderingComposer({
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

  ColumnOrderings<String> get employeeType => $composableBuilder(
    column: $table.employeeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseSalary => $composableBuilder(
    column: $table.baseSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get workedDays => $composableBuilder(
    column: $table.workedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get workedHours => $composableBuilder(
    column: $table.workedHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overtimeHours => $composableBuilder(
    column: $table.overtimeHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overtimePay => $composableBuilder(
    column: $table.overtimePay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ordinaryNightHours => $composableBuilder(
    column: $table.ordinaryNightHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ordinaryNightSurchargePay => $composableBuilder(
    column: $table.ordinaryNightSurchargePay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossPay => $composableBuilder(
    column: $table.grossPay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get familyBonus => $composableBuilder(
    column: $table.familyBonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ipsEmployee => $composableBuilder(
    column: $table.ipsEmployee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ipsEmployer => $composableBuilder(
    column: $table.ipsEmployer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get advancesTotal => $composableBuilder(
    column: $table.advancesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get attendanceDiscount => $composableBuilder(
    column: $table.attendanceDiscount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get otherDiscount => $composableBuilder(
    column: $table.otherDiscount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get embargoAmount => $composableBuilder(
    column: $table.embargoAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embargoAccount => $composableBuilder(
    column: $table.embargoAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netPay => $composableBuilder(
    column: $table.netPay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PayrollRunsTableOrderingComposer get payrollRunId {
    final $$PayrollRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payrollRunId,
      referencedTable: $db.payrollRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollRunsTableOrderingComposer(
            $db: $db,
            $table: $db.payrollRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableOrderingComposer get employeeId {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayrollItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayrollItemsTable> {
  $$PayrollItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeType => $composableBuilder(
    column: $table.employeeType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baseSalary => $composableBuilder(
    column: $table.baseSalary,
    builder: (column) => column,
  );

  GeneratedColumn<double> get workedDays => $composableBuilder(
    column: $table.workedDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get workedHours => $composableBuilder(
    column: $table.workedHours,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overtimeHours => $composableBuilder(
    column: $table.overtimeHours,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overtimePay => $composableBuilder(
    column: $table.overtimePay,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ordinaryNightHours => $composableBuilder(
    column: $table.ordinaryNightHours,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ordinaryNightSurchargePay => $composableBuilder(
    column: $table.ordinaryNightSurchargePay,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grossPay =>
      $composableBuilder(column: $table.grossPay, builder: (column) => column);

  GeneratedColumn<double> get familyBonus => $composableBuilder(
    column: $table.familyBonus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ipsEmployee => $composableBuilder(
    column: $table.ipsEmployee,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ipsEmployer => $composableBuilder(
    column: $table.ipsEmployer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get advancesTotal => $composableBuilder(
    column: $table.advancesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get attendanceDiscount => $composableBuilder(
    column: $table.attendanceDiscount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get otherDiscount => $composableBuilder(
    column: $table.otherDiscount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get embargoAmount => $composableBuilder(
    column: $table.embargoAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get embargoAccount => $composableBuilder(
    column: $table.embargoAccount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get netPay =>
      $composableBuilder(column: $table.netPay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PayrollRunsTableAnnotationComposer get payrollRunId {
    final $$PayrollRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payrollRunId,
      referencedTable: $db.payrollRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.payrollRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmployeesTableAnnotationComposer get employeeId {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayrollItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayrollItemsTable,
          PayrollItem,
          $$PayrollItemsTableFilterComposer,
          $$PayrollItemsTableOrderingComposer,
          $$PayrollItemsTableAnnotationComposer,
          $$PayrollItemsTableCreateCompanionBuilder,
          $$PayrollItemsTableUpdateCompanionBuilder,
          (PayrollItem, $$PayrollItemsTableReferences),
          PayrollItem,
          PrefetchHooks Function({
            bool companyId,
            bool payrollRunId,
            bool employeeId,
          })
        > {
  $$PayrollItemsTableTableManager(_$AppDatabase db, $PayrollItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayrollItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayrollItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayrollItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> payrollRunId = const Value.absent(),
                Value<int> employeeId = const Value.absent(),
                Value<String> employeeType = const Value.absent(),
                Value<double> baseSalary = const Value.absent(),
                Value<double> workedDays = const Value.absent(),
                Value<double> workedHours = const Value.absent(),
                Value<double> overtimeHours = const Value.absent(),
                Value<double> overtimePay = const Value.absent(),
                Value<double> ordinaryNightHours = const Value.absent(),
                Value<double> ordinaryNightSurchargePay = const Value.absent(),
                Value<double> grossPay = const Value.absent(),
                Value<double> familyBonus = const Value.absent(),
                Value<double> ipsEmployee = const Value.absent(),
                Value<double> ipsEmployer = const Value.absent(),
                Value<double> advancesTotal = const Value.absent(),
                Value<double> attendanceDiscount = const Value.absent(),
                Value<double> otherDiscount = const Value.absent(),
                Value<double?> embargoAmount = const Value.absent(),
                Value<String?> embargoAccount = const Value.absent(),
                Value<double> netPay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PayrollItemsCompanion(
                id: id,
                companyId: companyId,
                payrollRunId: payrollRunId,
                employeeId: employeeId,
                employeeType: employeeType,
                baseSalary: baseSalary,
                workedDays: workedDays,
                workedHours: workedHours,
                overtimeHours: overtimeHours,
                overtimePay: overtimePay,
                ordinaryNightHours: ordinaryNightHours,
                ordinaryNightSurchargePay: ordinaryNightSurchargePay,
                grossPay: grossPay,
                familyBonus: familyBonus,
                ipsEmployee: ipsEmployee,
                ipsEmployer: ipsEmployer,
                advancesTotal: advancesTotal,
                attendanceDiscount: attendanceDiscount,
                otherDiscount: otherDiscount,
                embargoAmount: embargoAmount,
                embargoAccount: embargoAccount,
                netPay: netPay,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required int payrollRunId,
                required int employeeId,
                required String employeeType,
                required double baseSalary,
                required double workedDays,
                required double workedHours,
                required double overtimeHours,
                Value<double> overtimePay = const Value.absent(),
                Value<double> ordinaryNightHours = const Value.absent(),
                Value<double> ordinaryNightSurchargePay = const Value.absent(),
                required double grossPay,
                Value<double> familyBonus = const Value.absent(),
                required double ipsEmployee,
                required double ipsEmployer,
                required double advancesTotal,
                Value<double> attendanceDiscount = const Value.absent(),
                Value<double> otherDiscount = const Value.absent(),
                Value<double?> embargoAmount = const Value.absent(),
                Value<String?> embargoAccount = const Value.absent(),
                required double netPay,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PayrollItemsCompanion.insert(
                id: id,
                companyId: companyId,
                payrollRunId: payrollRunId,
                employeeId: employeeId,
                employeeType: employeeType,
                baseSalary: baseSalary,
                workedDays: workedDays,
                workedHours: workedHours,
                overtimeHours: overtimeHours,
                overtimePay: overtimePay,
                ordinaryNightHours: ordinaryNightHours,
                ordinaryNightSurchargePay: ordinaryNightSurchargePay,
                grossPay: grossPay,
                familyBonus: familyBonus,
                ipsEmployee: ipsEmployee,
                ipsEmployer: ipsEmployer,
                advancesTotal: advancesTotal,
                attendanceDiscount: attendanceDiscount,
                otherDiscount: otherDiscount,
                embargoAmount: embargoAmount,
                embargoAccount: embargoAccount,
                netPay: netPay,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PayrollItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({companyId = false, payrollRunId = false, employeeId = false}) {
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
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$PayrollItemsTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$PayrollItemsTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (payrollRunId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.payrollRunId,
                                    referencedTable:
                                        $$PayrollItemsTableReferences
                                            ._payrollRunIdTable(db),
                                    referencedColumn:
                                        $$PayrollItemsTableReferences
                                            ._payrollRunIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (employeeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.employeeId,
                                    referencedTable:
                                        $$PayrollItemsTableReferences
                                            ._employeeIdTable(db),
                                    referencedColumn:
                                        $$PayrollItemsTableReferences
                                            ._employeeIdTable(db)
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

typedef $$PayrollItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayrollItemsTable,
      PayrollItem,
      $$PayrollItemsTableFilterComposer,
      $$PayrollItemsTableOrderingComposer,
      $$PayrollItemsTableAnnotationComposer,
      $$PayrollItemsTableCreateCompanionBuilder,
      $$PayrollItemsTableUpdateCompanionBuilder,
      (PayrollItem, $$PayrollItemsTableReferences),
      PayrollItem,
      PrefetchHooks Function({
        bool companyId,
        bool payrollRunId,
        bool employeeId,
      })
    >;
typedef $$RolesTableCreateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
    });
typedef $$RolesTableUpdateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
    });

final class $$RolesTableReferences
    extends BaseReferences<_$AppDatabase, $RolesTable, Role> {
  $$RolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RolePermissionsTable, List<RolePermission>>
  _rolePermissionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rolePermissions,
    aliasName: $_aliasNameGenerator(db.roles.id, db.rolePermissions.roleId),
  );

  $$RolePermissionsTableProcessedTableManager get rolePermissionsRefs {
    final manager = $$RolePermissionsTableTableManager(
      $_db,
      $_db.rolePermissions,
    ).filter((f) => f.roleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rolePermissionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $UserCompanyAccessTable,
    List<UserCompanyAccessData>
  >
  _userCompanyAccessRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userCompanyAccess,
        aliasName: $_aliasNameGenerator(
          db.roles.id,
          db.userCompanyAccess.roleId,
        ),
      );

  $$UserCompanyAccessTableProcessedTableManager get userCompanyAccessRefs {
    final manager = $$UserCompanyAccessTableTableManager(
      $_db,
      $_db.userCompanyAccess,
    ).filter((f) => f.roleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userCompanyAccessRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RolesTableFilterComposer extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rolePermissionsRefs(
    Expression<bool> Function($$RolePermissionsTableFilterComposer f) f,
  ) {
    final $$RolePermissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rolePermissions,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolePermissionsTableFilterComposer(
            $db: $db,
            $table: $db.rolePermissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userCompanyAccessRefs(
    Expression<bool> Function($$UserCompanyAccessTableFilterComposer f) f,
  ) {
    final $$UserCompanyAccessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCompanyAccess,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCompanyAccessTableFilterComposer(
            $db: $db,
            $table: $db.userCompanyAccess,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RolesTableOrderingComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  Expression<T> rolePermissionsRefs<T extends Object>(
    Expression<T> Function($$RolePermissionsTableAnnotationComposer a) f,
  ) {
    final $$RolePermissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rolePermissions,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolePermissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.rolePermissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userCompanyAccessRefs<T extends Object>(
    Expression<T> Function($$UserCompanyAccessTableAnnotationComposer a) f,
  ) {
    final $$UserCompanyAccessTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.userCompanyAccess,
          getReferencedColumn: (t) => t.roleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserCompanyAccessTableAnnotationComposer(
                $db: $db,
                $table: $db.userCompanyAccess,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolesTable,
          Role,
          $$RolesTableFilterComposer,
          $$RolesTableOrderingComposer,
          $$RolesTableAnnotationComposer,
          $$RolesTableCreateCompanionBuilder,
          $$RolesTableUpdateCompanionBuilder,
          (Role, $$RolesTableReferences),
          Role,
          PrefetchHooks Function({
            bool rolePermissionsRefs,
            bool userCompanyAccessRefs,
          })
        > {
  $$RolesTableTableManager(_$AppDatabase db, $RolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) =>
                  RolesCompanion(id: id, name: name, description: description),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
              }) => RolesCompanion.insert(
                id: id,
                name: name,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RolesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({rolePermissionsRefs = false, userCompanyAccessRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rolePermissionsRefs) db.rolePermissions,
                    if (userCompanyAccessRefs) db.userCompanyAccess,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rolePermissionsRefs)
                        await $_getPrefetchedData<
                          Role,
                          $RolesTable,
                          RolePermission
                        >(
                          currentTable: table,
                          referencedTable: $$RolesTableReferences
                              ._rolePermissionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RolesTableReferences(
                                db,
                                table,
                                p0,
                              ).rolePermissionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userCompanyAccessRefs)
                        await $_getPrefetchedData<
                          Role,
                          $RolesTable,
                          UserCompanyAccessData
                        >(
                          currentTable: table,
                          referencedTable: $$RolesTableReferences
                              ._userCompanyAccessRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RolesTableReferences(
                                db,
                                table,
                                p0,
                              ).userCompanyAccessRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roleId == item.id,
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

typedef $$RolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolesTable,
      Role,
      $$RolesTableFilterComposer,
      $$RolesTableOrderingComposer,
      $$RolesTableAnnotationComposer,
      $$RolesTableCreateCompanionBuilder,
      $$RolesTableUpdateCompanionBuilder,
      (Role, $$RolesTableReferences),
      Role,
      PrefetchHooks Function({
        bool rolePermissionsRefs,
        bool userCompanyAccessRefs,
      })
    >;
typedef $$PermissionsTableCreateCompanionBuilder =
    PermissionsCompanion Function({
      Value<int> id,
      required String key,
      Value<String?> description,
    });
typedef $$PermissionsTableUpdateCompanionBuilder =
    PermissionsCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String?> description,
    });

final class $$PermissionsTableReferences
    extends BaseReferences<_$AppDatabase, $PermissionsTable, Permission> {
  $$PermissionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RolePermissionsTable, List<RolePermission>>
  _rolePermissionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rolePermissions,
    aliasName: $_aliasNameGenerator(
      db.permissions.id,
      db.rolePermissions.permissionId,
    ),
  );

  $$RolePermissionsTableProcessedTableManager get rolePermissionsRefs {
    final manager = $$RolePermissionsTableTableManager(
      $_db,
      $_db.rolePermissions,
    ).filter((f) => f.permissionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rolePermissionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $PermissionsTable> {
  $$PermissionsTableFilterComposer({
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

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rolePermissionsRefs(
    Expression<bool> Function($$RolePermissionsTableFilterComposer f) f,
  ) {
    final $$RolePermissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rolePermissions,
      getReferencedColumn: (t) => t.permissionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolePermissionsTableFilterComposer(
            $db: $db,
            $table: $db.rolePermissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PermissionsTable> {
  $$PermissionsTableOrderingComposer({
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

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PermissionsTable> {
  $$PermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  Expression<T> rolePermissionsRefs<T extends Object>(
    Expression<T> Function($$RolePermissionsTableAnnotationComposer a) f,
  ) {
    final $$RolePermissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rolePermissions,
      getReferencedColumn: (t) => t.permissionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolePermissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.rolePermissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PermissionsTable,
          Permission,
          $$PermissionsTableFilterComposer,
          $$PermissionsTableOrderingComposer,
          $$PermissionsTableAnnotationComposer,
          $$PermissionsTableCreateCompanionBuilder,
          $$PermissionsTableUpdateCompanionBuilder,
          (Permission, $$PermissionsTableReferences),
          Permission,
          PrefetchHooks Function({bool rolePermissionsRefs})
        > {
  $$PermissionsTableTableManager(_$AppDatabase db, $PermissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => PermissionsCompanion(
                id: id,
                key: key,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                Value<String?> description = const Value.absent(),
              }) => PermissionsCompanion.insert(
                id: id,
                key: key,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PermissionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rolePermissionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (rolePermissionsRefs) db.rolePermissions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rolePermissionsRefs)
                    await $_getPrefetchedData<
                      Permission,
                      $PermissionsTable,
                      RolePermission
                    >(
                      currentTable: table,
                      referencedTable: $$PermissionsTableReferences
                          ._rolePermissionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PermissionsTableReferences(
                            db,
                            table,
                            p0,
                          ).rolePermissionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.permissionId == item.id,
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

typedef $$PermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PermissionsTable,
      Permission,
      $$PermissionsTableFilterComposer,
      $$PermissionsTableOrderingComposer,
      $$PermissionsTableAnnotationComposer,
      $$PermissionsTableCreateCompanionBuilder,
      $$PermissionsTableUpdateCompanionBuilder,
      (Permission, $$PermissionsTableReferences),
      Permission,
      PrefetchHooks Function({bool rolePermissionsRefs})
    >;
typedef $$RolePermissionsTableCreateCompanionBuilder =
    RolePermissionsCompanion Function({
      Value<int> id,
      required int roleId,
      required int permissionId,
    });
typedef $$RolePermissionsTableUpdateCompanionBuilder =
    RolePermissionsCompanion Function({
      Value<int> id,
      Value<int> roleId,
      Value<int> permissionId,
    });

final class $$RolePermissionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RolePermissionsTable, RolePermission> {
  $$RolePermissionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RolesTable _roleIdTable(_$AppDatabase db) => db.roles.createAlias(
    $_aliasNameGenerator(db.rolePermissions.roleId, db.roles.id),
  );

  $$RolesTableProcessedTableManager get roleId {
    final $_column = $_itemColumn<int>('role_id')!;

    final manager = $$RolesTableTableManager(
      $_db,
      $_db.roles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PermissionsTable _permissionIdTable(_$AppDatabase db) =>
      db.permissions.createAlias(
        $_aliasNameGenerator(
          db.rolePermissions.permissionId,
          db.permissions.id,
        ),
      );

  $$PermissionsTableProcessedTableManager get permissionId {
    final $_column = $_itemColumn<int>('permission_id')!;

    final manager = $$PermissionsTableTableManager(
      $_db,
      $_db.permissions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_permissionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RolePermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableFilterComposer({
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

  $$RolesTableFilterComposer get roleId {
    final $$RolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableFilterComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PermissionsTableFilterComposer get permissionId {
    final $$PermissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.permissionId,
      referencedTable: $db.permissions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PermissionsTableFilterComposer(
            $db: $db,
            $table: $db.permissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RolePermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableOrderingComposer({
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

  $$RolesTableOrderingComposer get roleId {
    final $$RolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableOrderingComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PermissionsTableOrderingComposer get permissionId {
    final $$PermissionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.permissionId,
      referencedTable: $db.permissions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PermissionsTableOrderingComposer(
            $db: $db,
            $table: $db.permissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RolePermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolePermissionsTable> {
  $$RolePermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$RolesTableAnnotationComposer get roleId {
    final $$RolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableAnnotationComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PermissionsTableAnnotationComposer get permissionId {
    final $$PermissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.permissionId,
      referencedTable: $db.permissions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PermissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.permissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RolePermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolePermissionsTable,
          RolePermission,
          $$RolePermissionsTableFilterComposer,
          $$RolePermissionsTableOrderingComposer,
          $$RolePermissionsTableAnnotationComposer,
          $$RolePermissionsTableCreateCompanionBuilder,
          $$RolePermissionsTableUpdateCompanionBuilder,
          (RolePermission, $$RolePermissionsTableReferences),
          RolePermission,
          PrefetchHooks Function({bool roleId, bool permissionId})
        > {
  $$RolePermissionsTableTableManager(
    _$AppDatabase db,
    $RolePermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolePermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolePermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolePermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> roleId = const Value.absent(),
                Value<int> permissionId = const Value.absent(),
              }) => RolePermissionsCompanion(
                id: id,
                roleId: roleId,
                permissionId: permissionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int roleId,
                required int permissionId,
              }) => RolePermissionsCompanion.insert(
                id: id,
                roleId: roleId,
                permissionId: permissionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RolePermissionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roleId = false, permissionId = false}) {
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
                    if (roleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roleId,
                                referencedTable:
                                    $$RolePermissionsTableReferences
                                        ._roleIdTable(db),
                                referencedColumn:
                                    $$RolePermissionsTableReferences
                                        ._roleIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (permissionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.permissionId,
                                referencedTable:
                                    $$RolePermissionsTableReferences
                                        ._permissionIdTable(db),
                                referencedColumn:
                                    $$RolePermissionsTableReferences
                                        ._permissionIdTable(db)
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

typedef $$RolePermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolePermissionsTable,
      RolePermission,
      $$RolePermissionsTableFilterComposer,
      $$RolePermissionsTableOrderingComposer,
      $$RolePermissionsTableAnnotationComposer,
      $$RolePermissionsTableCreateCompanionBuilder,
      $$RolePermissionsTableUpdateCompanionBuilder,
      (RolePermission, $$RolePermissionsTableReferences),
      RolePermission,
      PrefetchHooks Function({bool roleId, bool permissionId})
    >;
typedef $$UserCompanyAccessTableCreateCompanionBuilder =
    UserCompanyAccessCompanion Function({
      Value<int> id,
      required int userId,
      required int companyId,
      required int roleId,
      Value<bool> active,
    });
typedef $$UserCompanyAccessTableUpdateCompanionBuilder =
    UserCompanyAccessCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> companyId,
      Value<int> roleId,
      Value<bool> active,
    });

final class $$UserCompanyAccessTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UserCompanyAccessTable,
          UserCompanyAccessData
        > {
  $$UserCompanyAccessTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.userCompanyAccess.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.userCompanyAccess.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RolesTable _roleIdTable(_$AppDatabase db) => db.roles.createAlias(
    $_aliasNameGenerator(db.userCompanyAccess.roleId, db.roles.id),
  );

  $$RolesTableProcessedTableManager get roleId {
    final $_column = $_itemColumn<int>('role_id')!;

    final manager = $$RolesTableTableManager(
      $_db,
      $_db.roles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserCompanyAccessTableFilterComposer
    extends Composer<_$AppDatabase, $UserCompanyAccessTable> {
  $$UserCompanyAccessTableFilterComposer({
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

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RolesTableFilterComposer get roleId {
    final $$RolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableFilterComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCompanyAccessTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCompanyAccessTable> {
  $$UserCompanyAccessTableOrderingComposer({
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

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RolesTableOrderingComposer get roleId {
    final $$RolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableOrderingComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCompanyAccessTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCompanyAccessTable> {
  $$UserCompanyAccessTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RolesTableAnnotationComposer get roleId {
    final $$RolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableAnnotationComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCompanyAccessTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserCompanyAccessTable,
          UserCompanyAccessData,
          $$UserCompanyAccessTableFilterComposer,
          $$UserCompanyAccessTableOrderingComposer,
          $$UserCompanyAccessTableAnnotationComposer,
          $$UserCompanyAccessTableCreateCompanionBuilder,
          $$UserCompanyAccessTableUpdateCompanionBuilder,
          (UserCompanyAccessData, $$UserCompanyAccessTableReferences),
          UserCompanyAccessData,
          PrefetchHooks Function({bool userId, bool companyId, bool roleId})
        > {
  $$UserCompanyAccessTableTableManager(
    _$AppDatabase db,
    $UserCompanyAccessTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCompanyAccessTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCompanyAccessTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCompanyAccessTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<int> roleId = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => UserCompanyAccessCompanion(
                id: id,
                userId: userId,
                companyId: companyId,
                roleId: roleId,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required int companyId,
                required int roleId,
                Value<bool> active = const Value.absent(),
              }) => UserCompanyAccessCompanion.insert(
                id: id,
                userId: userId,
                companyId: companyId,
                roleId: roleId,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserCompanyAccessTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userId = false, companyId = false, roleId = false}) {
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
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$UserCompanyAccessTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$UserCompanyAccessTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$UserCompanyAccessTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$UserCompanyAccessTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (roleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roleId,
                                    referencedTable:
                                        $$UserCompanyAccessTableReferences
                                            ._roleIdTable(db),
                                    referencedColumn:
                                        $$UserCompanyAccessTableReferences
                                            ._roleIdTable(db)
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

typedef $$UserCompanyAccessTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserCompanyAccessTable,
      UserCompanyAccessData,
      $$UserCompanyAccessTableFilterComposer,
      $$UserCompanyAccessTableOrderingComposer,
      $$UserCompanyAccessTableAnnotationComposer,
      $$UserCompanyAccessTableCreateCompanionBuilder,
      $$UserCompanyAccessTableUpdateCompanionBuilder,
      (UserCompanyAccessData, $$UserCompanyAccessTableReferences),
      UserCompanyAccessData,
      PrefetchHooks Function({bool userId, bool companyId, bool roleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db, _db.departments);
  $$DepartmentSectorsTableTableManager get departmentSectors =>
      $$DepartmentSectorsTableTableManager(_db, _db.departmentSectors);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$AttendanceEventsTableTableManager get attendanceEvents =>
      $$AttendanceEventsTableTableManager(_db, _db.attendanceEvents);
  $$CompanySettingsTableTableManager get companySettings =>
      $$CompanySettingsTableTableManager(_db, _db.companySettings);
  $$AdvancesTableTableManager get advances =>
      $$AdvancesTableTableManager(_db, _db.advances);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$PayrollRunsTableTableManager get payrollRuns =>
      $$PayrollRunsTableTableManager(_db, _db.payrollRuns);
  $$PayrollItemsTableTableManager get payrollItems =>
      $$PayrollItemsTableTableManager(_db, _db.payrollItems);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$PermissionsTableTableManager get permissions =>
      $$PermissionsTableTableManager(_db, _db.permissions);
  $$RolePermissionsTableTableManager get rolePermissions =>
      $$RolePermissionsTableTableManager(_db, _db.rolePermissions);
  $$UserCompanyAccessTableTableManager get userCompanyAccess =>
      $$UserCompanyAccessTableTableManager(_db, _db.userCompanyAccess);
}

mixin _$CompaniesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CompaniesTable get companies => attachedDatabase.companies;
  CompaniesDaoManager get managers => CompaniesDaoManager(this);
}

class CompaniesDaoManager {
  final _$CompaniesDaoMixin _db;
  CompaniesDaoManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db.attachedDatabase, _db.companies);
}

mixin _$DepartmentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CompaniesTable get companies => attachedDatabase.companies;
  $DepartmentsTable get departments => attachedDatabase.departments;
  $DepartmentSectorsTable get departmentSectors =>
      attachedDatabase.departmentSectors;
  DepartmentsDaoManager get managers => DepartmentsDaoManager(this);
}

class DepartmentsDaoManager {
  final _$DepartmentsDaoMixin _db;
  DepartmentsDaoManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db.attachedDatabase, _db.companies);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db.attachedDatabase, _db.departments);
  $$DepartmentSectorsTableTableManager get departmentSectors =>
      $$DepartmentSectorsTableTableManager(
        _db.attachedDatabase,
        _db.departmentSectors,
      );
}

mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
}

mixin _$EmployeesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CompaniesTable get companies => attachedDatabase.companies;
  $DepartmentsTable get departments => attachedDatabase.departments;
  $DepartmentSectorsTable get departmentSectors =>
      attachedDatabase.departmentSectors;
  $EmployeesTable get employees => attachedDatabase.employees;
  EmployeesDaoManager get managers => EmployeesDaoManager(this);
}

class EmployeesDaoManager {
  final _$EmployeesDaoMixin _db;
  EmployeesDaoManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db.attachedDatabase, _db.companies);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db.attachedDatabase, _db.departments);
  $$DepartmentSectorsTableTableManager get departmentSectors =>
      $$DepartmentSectorsTableTableManager(
        _db.attachedDatabase,
        _db.departmentSectors,
      );
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db.attachedDatabase, _db.employees);
}

mixin _$AttendanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $CompaniesTable get companies => attachedDatabase.companies;
  $DepartmentsTable get departments => attachedDatabase.departments;
  $DepartmentSectorsTable get departmentSectors =>
      attachedDatabase.departmentSectors;
  $EmployeesTable get employees => attachedDatabase.employees;
  $AttendanceEventsTable get attendanceEvents =>
      attachedDatabase.attendanceEvents;
  AttendanceDaoManager get managers => AttendanceDaoManager(this);
}

class AttendanceDaoManager {
  final _$AttendanceDaoMixin _db;
  AttendanceDaoManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db.attachedDatabase, _db.companies);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db.attachedDatabase, _db.departments);
  $$DepartmentSectorsTableTableManager get departmentSectors =>
      $$DepartmentSectorsTableTableManager(
        _db.attachedDatabase,
        _db.departmentSectors,
      );
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db.attachedDatabase, _db.employees);
  $$AttendanceEventsTableTableManager get attendanceEvents =>
      $$AttendanceEventsTableTableManager(
        _db.attachedDatabase,
        _db.attendanceEvents,
      );
}

mixin _$CompanySettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CompaniesTable get companies => attachedDatabase.companies;
  $CompanySettingsTable get companySettings => attachedDatabase.companySettings;
  CompanySettingsDaoManager get managers => CompanySettingsDaoManager(this);
}

class CompanySettingsDaoManager {
  final _$CompanySettingsDaoMixin _db;
  CompanySettingsDaoManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db.attachedDatabase, _db.companies);
  $$CompanySettingsTableTableManager get companySettings =>
      $$CompanySettingsTableTableManager(
        _db.attachedDatabase,
        _db.companySettings,
      );
}

mixin _$AdvancesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CompaniesTable get companies => attachedDatabase.companies;
  $DepartmentsTable get departments => attachedDatabase.departments;
  $DepartmentSectorsTable get departmentSectors =>
      attachedDatabase.departmentSectors;
  $EmployeesTable get employees => attachedDatabase.employees;
  $AdvancesTable get advances => attachedDatabase.advances;
  AdvancesDaoManager get managers => AdvancesDaoManager(this);
}

class AdvancesDaoManager {
  final _$AdvancesDaoMixin _db;
  AdvancesDaoManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db.attachedDatabase, _db.companies);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db.attachedDatabase, _db.departments);
  $$DepartmentSectorsTableTableManager get departmentSectors =>
      $$DepartmentSectorsTableTableManager(
        _db.attachedDatabase,
        _db.departmentSectors,
      );
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db.attachedDatabase, _db.employees);
  $$AdvancesTableTableManager get advances =>
      $$AdvancesTableTableManager(_db.attachedDatabase, _db.advances);
}

mixin _$PayrollDaoMixin on DatabaseAccessor<AppDatabase> {
  $CompaniesTable get companies => attachedDatabase.companies;
  $UsersTable get users => attachedDatabase.users;
  $PayrollRunsTable get payrollRuns => attachedDatabase.payrollRuns;
  $DepartmentsTable get departments => attachedDatabase.departments;
  $DepartmentSectorsTable get departmentSectors =>
      attachedDatabase.departmentSectors;
  $EmployeesTable get employees => attachedDatabase.employees;
  $PayrollItemsTable get payrollItems => attachedDatabase.payrollItems;
  PayrollDaoManager get managers => PayrollDaoManager(this);
}

class PayrollDaoManager {
  final _$PayrollDaoMixin _db;
  PayrollDaoManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db.attachedDatabase, _db.companies);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$PayrollRunsTableTableManager get payrollRuns =>
      $$PayrollRunsTableTableManager(_db.attachedDatabase, _db.payrollRuns);
  $$DepartmentsTableTableManager get departments =>
      $$DepartmentsTableTableManager(_db.attachedDatabase, _db.departments);
  $$DepartmentSectorsTableTableManager get departmentSectors =>
      $$DepartmentSectorsTableTableManager(
        _db.attachedDatabase,
        _db.departmentSectors,
      );
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db.attachedDatabase, _db.employees);
  $$PayrollItemsTableTableManager get payrollItems =>
      $$PayrollItemsTableTableManager(_db.attachedDatabase, _db.payrollItems);
}

mixin _$SecurityDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $RolesTable get roles => attachedDatabase.roles;
  $PermissionsTable get permissions => attachedDatabase.permissions;
  $RolePermissionsTable get rolePermissions => attachedDatabase.rolePermissions;
  $CompaniesTable get companies => attachedDatabase.companies;
  $UserCompanyAccessTable get userCompanyAccess =>
      attachedDatabase.userCompanyAccess;
  SecurityDaoManager get managers => SecurityDaoManager(this);
}

class SecurityDaoManager {
  final _$SecurityDaoMixin _db;
  SecurityDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db.attachedDatabase, _db.roles);
  $$PermissionsTableTableManager get permissions =>
      $$PermissionsTableTableManager(_db.attachedDatabase, _db.permissions);
  $$RolePermissionsTableTableManager get rolePermissions =>
      $$RolePermissionsTableTableManager(
        _db.attachedDatabase,
        _db.rolePermissions,
      );
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db.attachedDatabase, _db.companies);
  $$UserCompanyAccessTableTableManager get userCompanyAccess =>
      $$UserCompanyAccessTableTableManager(
        _db.attachedDatabase,
        _db.userCompanyAccess,
      );
}
