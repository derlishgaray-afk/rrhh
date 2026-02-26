import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/attendance_service.dart';
import '../../../services/employee_name_formatter.dart';

class AttendanceFormDialog extends StatefulWidget {
  const AttendanceFormDialog({
    required this.service,
    required this.companyId,
    required this.employees,
    this.event,
    super.key,
  });

  final AttendanceService service;
  final int companyId;
  final List<Employee> employees;
  final AttendanceEvent? event;

  @override
  State<AttendanceFormDialog> createState() => _AttendanceFormDialogState();
}

class _AttendanceFormDialogState extends State<AttendanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _minutesLateController = TextEditingController();
  final _hoursWorkedController = TextEditingController();
  final _overtimeHoursController = TextEditingController();
  final _notesController = TextEditingController();

  late int _employeeId;
  late String _eventType;
  String? _overtimeType;
  DateTime? _date;
  bool _hasOvertime = false;
  bool _isSaving = false;

  static const List<String> _eventTypes = [
    'presente',
    'ausente',
    'permiso_remunerado',
    'permiso_no_remunerado',
    'vacaciones',
    'paternidad',
    'duelo',
    'reposo',
    'tardanza',
  ];
  static const List<String> _overtimeTypes = ['diurna', 'nocturna'];

  bool get _isEditing => widget.event != null;

  bool get _employeeAllowsOvertime {
    for (final employee in widget.employees) {
      if (employee.id == _employeeId) {
        return employee.allowOvertime;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    final event = widget.event;
    if (event != null) {
      _employeeId = event.employeeId;
      _eventType = event.eventType;
      _date = event.date;
      _minutesLateController.text = event.minutesLate?.toString() ?? '';
      _hoursWorkedController.text = event.hoursWorked?.toStringAsFixed(2) ?? '';
      _overtimeHoursController.text =
          event.overtimeHours?.toStringAsFixed(2) ?? '';
      _overtimeType = event.overtimeType;
      _hasOvertime = (event.overtimeHours ?? 0) > 0;
      _notesController.text = event.notes ?? '';

      if (!_employeeAllowsOvertime) {
        _clearOvertime();
      }
      return;
    }

    _employeeId = widget.employees.first.id;
    _eventType = _eventTypes.first;
  }

  @override
  void dispose() {
    _minutesLateController.dispose();
    _hoursWorkedController.dispose();
    _overtimeHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      locale: const Locale('es', 'PY'),
      initialDate: _date ?? now,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 2, 12, 31),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _date = selectedDate;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_date == null) {
      _showError('La fecha es obligatoria.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final minutesLate = _parseIntOrNull(_minutesLateController.text);
      final hoursWorked = _parseDoubleOrNull(_hoursWorkedController.text);
      final overtimeHours = _hasOvertime && _employeeAllowsOvertime
          ? _parseDoubleOrNull(_overtimeHoursController.text)
          : null;
      final overtimeType = _hasOvertime && _employeeAllowsOvertime
          ? _overtimeType
          : null;

      if (_isEditing) {
        await widget.service.updateAttendanceEvent(
          currentEvent: widget.event!,
          employeeId: _employeeId,
          date: _date!,
          eventType: _eventType,
          minutesLate: minutesLate,
          hoursWorked: hoursWorked,
          overtimeHours: overtimeHours,
          overtimeType: overtimeType,
          notes: _notesController.text,
        );
      } else {
        await widget.service.createAttendanceEvent(
          companyId: widget.companyId,
          employeeId: _employeeId,
          date: _date!,
          eventType: _eventType,
          minutesLate: minutesLate,
          hoursWorked: hoursWorked,
          overtimeHours: overtimeHours,
          overtimeType: overtimeType,
          notes: _notesController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Datos invalidos.');
    } catch (_) {
      _showError('No se pudo guardar la asistencia.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  int? _parseIntOrNull(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return int.parse(normalized);
  }

  double? _parseDoubleOrNull(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.parse(normalized);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _clearOvertime() {
    _hasOvertime = false;
    _overtimeType = null;
    _overtimeHoursController.clear();
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar asistencia' : 'Nueva asistencia'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _employeeId,
                  decoration: const InputDecoration(labelText: 'Empleado'),
                  items: widget.employees
                      .map(
                        (employee) => DropdownMenuItem<int>(
                          value: employee.id,
                          child: Text(employeeDisplayName(employee)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _employeeId = value;
                      if (!_employeeAllowsOvertime) {
                        _clearOvertime();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    child: Text(
                      _date == null
                          ? 'Seleccione una fecha'
                          : _formatDate(_date!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _eventType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de evento',
                  ),
                  items: _eventTypes
                      .map(
                        (eventType) => DropdownMenuItem<String>(
                          value: eventType,
                          child: Text(eventType),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _eventType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minutesLateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutos tardanza (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hoursWorkedController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Horas trabajadas (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _overtimeHoursController,
                  enabled: _hasOvertime && _employeeAllowsOvertime,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Horas extra'),
                  validator: (value) {
                    if (!_hasOvertime || !_employeeAllowsOvertime) {
                      return null;
                    }
                    final parsed = double.tryParse(
                      value?.trim().replaceAll(',', '.') ?? '',
                    );
                    if (parsed == null || parsed <= 0) {
                      return 'Ingrese horas extra mayores a cero.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _hasOvertime,
                  onChanged: _employeeAllowsOvertime
                      ? (value) {
                          setState(() {
                            _hasOvertime = value;
                            if (!value) {
                              _clearOvertime();
                            }
                          });
                        }
                      : null,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tiene horas extra'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _overtimeType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo horas extra',
                  ),
                  items: _overtimeTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: _hasOvertime && _employeeAllowsOvertime
                      ? (value) {
                          setState(() {
                            _overtimeType = value;
                          });
                        }
                      : null,
                  validator: (value) {
                    if (!_hasOvertime || !_employeeAllowsOvertime) {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return 'Seleccione tipo de hora extra.';
                    }
                    return null;
                  },
                ),
                if (!_employeeAllowsOvertime)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Este empleado no permite registrar horas extra.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                  ),
                  minLines: 2,
                  maxLines: 3,
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
