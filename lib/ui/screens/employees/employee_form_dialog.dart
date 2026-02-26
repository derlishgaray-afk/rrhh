import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/database/app_database.dart';
import '../../../services/department_service.dart';
import '../../../services/employee_name_formatter.dart';
import '../../../services/employees_service.dart';
import '../../utils/guarani_currency.dart';
import '../../utils/thousands_separator_input_formatter.dart';

class EmployeeFormDialog extends StatefulWidget {
  const EmployeeFormDialog({
    required this.service,
    required this.departmentService,
    required this.companyId,
    required this.companyName,
    this.employee,
    super.key,
  });

  final EmployeesService service;
  final DepartmentService departmentService;
  final int companyId;
  final String companyName;
  final Employee? employee;

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _documentFocusNode = FocusNode();
  final _firstNamesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _workLocationController = TextEditingController();
  final _baseSalaryController = TextEditingController();
  final _childrenCountController = TextEditingController(text: '0');
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _embargoAccountController = TextEditingController();
  final _embargoAmountController = TextEditingController();
  final _workStartTime1Controller = TextEditingController(text: '06:00');
  final _workStartTime2Controller = TextEditingController(text: '15:00');
  final _workStartTime3Controller = TextEditingController(text: '18:00');
  final _workStartTimeSaturdayController = TextEditingController();
  final _workEndTimeSaturdayController = TextEditingController();

  String _employeeType = _employeeTypes.first;
  DateTime? _hireDate;
  int? _selectedDepartmentId;
  int? _selectedSectorId;
  List<Department> _departments = const [];
  List<DepartmentSector> _sectors = const [];
  bool _isLoadingOrganization = false;
  bool _active = true;
  bool _ipsEnabled = true;
  bool _allowOvertime = true;
  bool _biometricClockEnabled = true;
  bool _hasEmbargo = false;
  bool _isSaving = false;
  String? _documentDuplicateError;

  static const List<String> _employeeTypes = [
    'mensual',
    'jornalero',
    'servicio',
  ];

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    _documentFocusNode.addListener(_onDocumentFocusChange);

    final employee = widget.employee;
    if (employee != null) {
      final normalizedFirstNames = employee.firstNames.trim();
      final normalizedLastNames = employee.lastNames.trim();
      if (normalizedFirstNames.isNotEmpty || normalizedLastNames.isNotEmpty) {
        _firstNamesController.text = normalizedFirstNames;
        _lastNamesController.text = normalizedLastNames;
      } else {
        final split = _splitLegacyFullName(employee.fullName);
        _firstNamesController.text = split.$1;
        _lastNamesController.text = split.$2;
      }
      _documentNumberController.text = employee.documentNumber;
      _jobTitleController.text = employee.jobTitle ?? '';
      _workLocationController.text = employee.workLocation ?? '';
      _baseSalaryController.text = GuaraniCurrency.formatPlain(
        employee.baseSalary,
      );
      _childrenCountController.text = employee.childrenCount.toString();
      _phoneController.text = employee.phone ?? '';
      _addressController.text = employee.address ?? '';
      _embargoAccountController.text = employee.embargoAccount ?? '';
      _embargoAmountController.text = employee.embargoAmount == null
          ? ''
          : GuaraniCurrency.formatPlain(employee.embargoAmount!);
      _employeeType = employee.employeeType;
      _hireDate = employee.hireDate;
      _active = employee.active;
      _ipsEnabled = employee.ipsEnabled;
      _allowOvertime = employee.allowOvertime;
      _biometricClockEnabled = employee.biometricClockEnabled;
      _hasEmbargo = employee.hasEmbargo;
      _workStartTime1Controller.text = employee.workStartTime1;
      _workStartTime2Controller.text = employee.workStartTime2;
      _workStartTime3Controller.text = employee.workStartTime3;
      _workStartTimeSaturdayController.text =
          employee.workStartTimeSaturday ?? '';
      _workEndTimeSaturdayController.text = employee.workEndTimeSaturday ?? '';
      _selectedDepartmentId = employee.departmentId;
      _selectedSectorId = employee.sectorId;
    }

    _loadOrganizationData();
  }

  @override
  void dispose() {
    _documentFocusNode
      ..removeListener(_onDocumentFocusChange)
      ..dispose();
    _firstNamesController.dispose();
    _lastNamesController.dispose();
    _documentNumberController.dispose();
    _jobTitleController.dispose();
    _workLocationController.dispose();
    _baseSalaryController.dispose();
    _childrenCountController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _embargoAccountController.dispose();
    _embargoAmountController.dispose();
    _workStartTime1Controller.dispose();
    _workStartTime2Controller.dispose();
    _workStartTime3Controller.dispose();
    _workStartTimeSaturdayController.dispose();
    _workEndTimeSaturdayController.dispose();
    super.dispose();
  }

  void _onDocumentFocusChange() {
    if (_documentFocusNode.hasFocus) {
      return;
    }
    _checkDuplicateDocumentInCompany();
  }

  Future<void> _checkDuplicateDocumentInCompany() async {
    final document = _documentNumberController.text.trim();
    if (document.isEmpty) {
      if (_documentDuplicateError != null && mounted) {
        setState(() {
          _documentDuplicateError = null;
        });
      }
      return;
    }

    try {
      final duplicate = await widget.service.findEmployeeByDocumentInCompany(
        companyId: widget.companyId,
        documentNumber: document,
        excludeEmployeeId: widget.employee?.id,
      );
      if (!mounted) {
        return;
      }
      if (_documentNumberController.text.trim() != document) {
        return;
      }

      final duplicateMessage = duplicate == null
          ? null
          : 'Documento ya registrado en esta empresa (${employeeDisplayName(duplicate)}).';
      if (_documentDuplicateError != duplicateMessage) {
        setState(() {
          _documentDuplicateError = duplicateMessage;
        });
      }
    } catch (_) {
      // Ignore lookup errors to avoid blocking typing/navigation.
    }
  }

  void _clearDocumentDuplicateError() {
    if (_documentDuplicateError == null) {
      return;
    }
    setState(() {
      _documentDuplicateError = null;
    });
  }

  Future<void> _loadOrganizationData() async {
    setState(() {
      _isLoadingOrganization = true;
    });

    try {
      final departments = await widget.departmentService
          .listDepartmentsByCompany(widget.companyId);
      var selectedDepartmentId = _selectedDepartmentId;
      var selectedSectorId = _selectedSectorId;

      if (selectedDepartmentId != null &&
          !departments.any(
            (department) => department.id == selectedDepartmentId,
          )) {
        selectedDepartmentId = null;
      }

      var sectors = <DepartmentSector>[];
      if (selectedDepartmentId != null) {
        sectors = await widget.departmentService.listSectorsByDepartment(
          selectedDepartmentId,
        );
        if (selectedSectorId != null &&
            !sectors.any((sector) => sector.id == selectedSectorId)) {
          selectedSectorId = null;
        }
      } else {
        selectedSectorId = null;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _departments = departments;
        _selectedDepartmentId = selectedDepartmentId;
        _sectors = sectors;
        _selectedSectorId = selectedSectorId;
      });
    } catch (_) {
      _showError(
        'No se pudieron cargar departamentos y sectores. Verifique el modulo de Empresas.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrganization = false;
        });
      }
    }
  }

  Future<void> _onDepartmentChanged(int? departmentId) async {
    setState(() {
      _selectedDepartmentId = departmentId;
      _selectedSectorId = null;
      _sectors = const [];
      _isLoadingOrganization = true;
    });

    if (departmentId == null) {
      setState(() {
        _isLoadingOrganization = false;
      });
      return;
    }

    try {
      final sectors = await widget.departmentService.listSectorsByDepartment(
        departmentId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _sectors = sectors;
      });
    } catch (_) {
      _showError('No se pudieron cargar los sectores del departamento.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrganization = false;
        });
      }
    }
  }

  Future<void> _save() async {
    await _checkDuplicateDocumentInCompany();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hireDate == null) {
      _showError('La fecha de ingreso es obligatoria.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final salary = GuaraniCurrency.parse(_baseSalaryController.text);
      if (salary == null) {
        throw const FormatException();
      }
      final childrenCount = int.parse(_childrenCountController.text.trim());
      final embargoAmount = _hasEmbargo
          ? GuaraniCurrency.parse(_embargoAmountController.text)
          : null;

      if (_isEditing) {
        await widget.service.updateEmployee(
          currentEmployee: widget.employee!,
          departmentId: _selectedDepartmentId,
          sectorId: _selectedSectorId,
          jobTitle: _jobTitleController.text,
          workLocation: _workLocationController.text,
          firstNames: _firstNamesController.text,
          lastNames: _lastNamesController.text,
          documentNumber: _documentNumberController.text,
          hireDate: _hireDate!,
          employeeType: _employeeType,
          baseSalary: salary,
          ipsEnabled: _ipsEnabled,
          childrenCount: childrenCount,
          allowOvertime: _allowOvertime,
          biometricClockEnabled: _biometricClockEnabled,
          hasEmbargo: _hasEmbargo,
          embargoAccount: _embargoAccountController.text,
          embargoAmount: embargoAmount,
          phone: _phoneController.text,
          address: _addressController.text,
          workStartTime1: _workStartTime1Controller.text,
          workStartTime2: _workStartTime2Controller.text,
          workStartTime3: _workStartTime3Controller.text,
          workStartTimeSaturday: _workStartTimeSaturdayController.text,
          workEndTimeSaturday: _workEndTimeSaturdayController.text,
          active: _active,
        );
      } else {
        await widget.service.createEmployee(
          companyId: widget.companyId,
          departmentId: _selectedDepartmentId,
          sectorId: _selectedSectorId,
          jobTitle: _jobTitleController.text,
          workLocation: _workLocationController.text,
          firstNames: _firstNamesController.text,
          lastNames: _lastNamesController.text,
          documentNumber: _documentNumberController.text,
          hireDate: _hireDate!,
          employeeType: _employeeType,
          baseSalary: salary,
          ipsEnabled: _ipsEnabled,
          childrenCount: childrenCount,
          allowOvertime: _allowOvertime,
          biometricClockEnabled: _biometricClockEnabled,
          hasEmbargo: _hasEmbargo,
          embargoAccount: _embargoAccountController.text,
          embargoAmount: embargoAmount,
          phone: _phoneController.text,
          address: _addressController.text,
          workStartTime1: _workStartTime1Controller.text,
          workStartTime2: _workStartTime2Controller.text,
          workStartTime3: _workStartTime3Controller.text,
          workStartTimeSaturday: _workStartTimeSaturdayController.text,
          workEndTimeSaturday: _workEndTimeSaturdayController.text,
          active: _active,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on FormatException {
      _showError('Verifique salario, cantidad de hijos o monto embargo.');
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Datos invalidos.');
    } catch (_) {
      _showError('No se pudo guardar el empleado.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickHireDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      locale: const Locale('es', 'PY'),
      initialDate: _hireDate ?? now,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 2, 12, 31),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _hireDate = selectedDate;
    });
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String? _validateTimeField(String? value, String label) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Ingrese $label.';
    }
    final parsedMinutes = _tryParseMinutes(normalized);
    if (parsedMinutes == null) {
      return '$label debe tener formato HH:mm, HH.mm, HHmm o HH.';
    }
    if (parsedMinutes < 0 || parsedMinutes >= (24 * 60)) {
      return '$label no es valido.';
    }
    return null;
  }

  int? _tryParseMinutes(String? value) {
    final normalized = value?.trim() ?? '';
    final parts = _parseTimeParts(normalized);
    if (parts == null) {
      return null;
    }
    final hour = parts.$1;
    final minute = parts.$2;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return (hour * 60) + minute;
  }

  (int, int)? _parseTimeParts(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length == 1 || digitsOnly.length == 2) {
      return (int.parse(digitsOnly), 0);
    }
    if (digitsOnly.length == 4) {
      return (
        int.parse(digitsOnly.substring(0, 2)),
        int.parse(digitsOnly.substring(2, 4)),
      );
    }
    if (digitsOnly.length == 3) {
      return (
        int.parse(digitsOnly.substring(0, 1)),
        int.parse(digitsOnly.substring(1, 3)),
      );
    }

    final match = _timeRegex.firstMatch(value);
    if (match == null) {
      return null;
    }
    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  (String, String) _splitLegacyFullName(String fullName) {
    final normalized = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return ('', '');
    }
    final parts = normalized.split(' ');
    if (parts.length == 1) {
      return (parts.first, '');
    }
    if (parts.length == 2) {
      return (parts.first, parts.last);
    }
    if (parts.length == 3) {
      return ('${parts[0]} ${parts[1]}', parts[2]);
    }
    return (
      parts.sublist(0, parts.length - 2).join(' '),
      parts.sublist(parts.length - 2).join(' '),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCompanyName = widget.companyName.trim().isEmpty
        ? 'Empresa'
        : widget.companyName.trim();

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_isEditing ? 'Editar empleado' : 'Nuevo empleado'),
          const SizedBox(height: 4),
          Text(
            'Empresa: $effectiveCompanyName',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoadingOrganization)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNamesController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre(s)',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese nombre(s).';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNamesController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido(s)',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese apellido(s).';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _documentNumberController,
                  focusNode: _documentFocusNode,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(labelText: 'Documento'),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _clearDocumentDuplicateError(),
                  onFieldSubmitted: (_) => _checkDuplicateDocumentInCompany(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el documento.';
                    }
                    if (_documentDuplicateError != null) {
                      return _documentDuplicateError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: ValueKey(
                    'department-${_selectedDepartmentId ?? 0}-${_departments.length}',
                  ),
                  initialValue: _selectedDepartmentId,
                  decoration: const InputDecoration(labelText: 'Departamento'),
                  items: _departments
                      .map(
                        (department) => DropdownMenuItem<int>(
                          value: department.id,
                          child: Text(department.name),
                        ),
                      )
                      .toList(),
                  onChanged: _isLoadingOrganization
                      ? null
                      : (value) {
                          _onDepartmentChanged(value);
                        },
                  validator: (value) {
                    if (_departments.isEmpty) {
                      return 'No hay departamentos. Cree uno en Empresas > Departamentos.';
                    }
                    if (value == null) {
                      return 'Seleccione un departamento.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: ValueKey(
                    'sector-${_selectedDepartmentId ?? 0}-${_selectedSectorId ?? 0}-${_sectors.length}',
                  ),
                  initialValue: _selectedSectorId,
                  decoration: const InputDecoration(labelText: 'Sector'),
                  items: _sectors
                      .map(
                        (sector) => DropdownMenuItem<int>(
                          value: sector.id,
                          child: Text(sector.name),
                        ),
                      )
                      .toList(),
                  onChanged:
                      _isLoadingOrganization || _selectedDepartmentId == null
                      ? null
                      : (value) {
                          setState(() {
                            _selectedSectorId = value;
                          });
                        },
                  validator: (value) {
                    if (_selectedDepartmentId == null) {
                      return 'Seleccione primero un departamento.';
                    }
                    if (_sectors.isEmpty) {
                      return 'No hay sectores en el departamento seleccionado.';
                    }
                    if (value == null) {
                      return 'Seleccione un sector.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(labelText: 'Cargo'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el cargo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _workLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Lugar de trabajo',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el lugar de trabajo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickHireDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de ingreso',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    child: Text(
                      _hireDate == null
                          ? 'Seleccione una fecha'
                          : _formatDate(_hireDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _employeeType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de empleado',
                  ),
                  items: _employeeTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _employeeType = value;
                      if (!_isEditing && value == 'servicio') {
                        _ipsEnabled = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _baseSalaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salario base (Gs.)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [ThousandsSeparatorInputFormatter()],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el salario base.';
                    }
                    final parsedValue = GuaraniCurrency.parse(value);
                    if (parsedValue == null || parsedValue <= 0) {
                      return 'Ingrese un salario mayor que cero.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _childrenCountController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad hijos',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese la cantidad de hijos.';
                    }
                    final parsedValue = int.tryParse(value.trim());
                    if (parsedValue == null || parsedValue < 0) {
                      return 'Ingrese un numero valido mayor o igual a cero.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Horarios de inicio laboral (3 opciones)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _workStartTime1Controller,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9:.,]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Inicio 1 (HH:mm)',
                        ),
                        validator: (value) =>
                            _validateTimeField(value, 'inicio 1'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _workStartTime2Controller,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9:.,]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Inicio 2 (HH:mm)',
                        ),
                        validator: (value) =>
                            _validateTimeField(value, 'inicio 2'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _workStartTime3Controller,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9:.,]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Inicio 3 (HH:mm)',
                        ),
                        validator: (value) =>
                            _validateTimeField(value, 'inicio 3'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _allowOvertime,
                  onChanged: (value) {
                    setState(() {
                      _allowOvertime = value;
                      if (value) {
                        _workStartTimeSaturdayController.clear();
                        _workEndTimeSaturdayController.clear();
                      }
                    });
                  },
                  title: const Text('Permite horas extra'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                if (!_allowOvertime) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _workStartTimeSaturdayController,
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9:.,]'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Inicio sabado (HH:mm)',
                          ),
                          validator: (value) {
                            if (_allowOvertime) {
                              return null;
                            }
                            return _validateTimeField(value, 'inicio sabado');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _workEndTimeSaturdayController,
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9:.,]'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Salida sabado (HH:mm)',
                          ),
                          validator: (value) {
                            if (_allowOvertime) {
                              return null;
                            }
                            final baseError = _validateTimeField(
                              value,
                              'salida sabado',
                            );
                            if (baseError != null) {
                              return baseError;
                            }

                            final startMinutes = _tryParseMinutes(
                              _workStartTimeSaturdayController.text,
                            );
                            final endMinutes = _tryParseMinutes(value);
                            if (startMinutes != null &&
                                endMinutes != null &&
                                endMinutes <= startMinutes) {
                              return 'Salida sabado debe ser mayor al inicio.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                SwitchListTile(
                  value: _biometricClockEnabled,
                  onChanged: (value) {
                    setState(() {
                      _biometricClockEnabled = value;
                    });
                  },
                  title: const Text('Con marcacion en reloj biometrico'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _ipsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _ipsEnabled = value;
                    });
                  },
                  title: const Text('Aporta IPS'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _hasEmbargo,
                  onChanged: (value) {
                    setState(() {
                      _hasEmbargo = value;
                      if (!value) {
                        _embargoAccountController.clear();
                        _embargoAmountController.clear();
                      }
                    });
                  },
                  title: const Text('Tiene embargo judicial'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _embargoAccountController,
                  enabled: _hasEmbargo,
                  decoration: const InputDecoration(
                    labelText: 'Cuenta embargo (opcional)',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _embargoAmountController,
                  enabled: _hasEmbargo,
                  decoration: const InputDecoration(
                    labelText: 'Monto embargo mensual (Gs.)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: const [ThousandsSeparatorInputFormatter()],
                  validator: (value) {
                    if (!_hasEmbargo) {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el monto de embargo.';
                    }
                    final parsedValue = GuaraniCurrency.parse(value);
                    if (parsedValue == null || parsedValue <= 0) {
                      return 'Ingrese un monto valido mayor a cero.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefono (opcional)',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Direccion (opcional)',
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _active,
                  onChanged: (value) {
                    setState(() {
                      _active = value;
                    });
                  },
                  title: const Text('Empleado activo'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Guardando...' : 'Guardar'),
        ),
      ],
    );
  }
}

final RegExp _timeRegex = RegExp(r'^(\d{1,2})[:.,](\d{2})$');
