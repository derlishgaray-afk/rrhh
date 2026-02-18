import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/advances_service.dart';
import '../../utils/guarani_currency.dart';
import '../../utils/thousands_separator_input_formatter.dart';

class AdvanceFormDialog extends StatefulWidget {
  const AdvanceFormDialog({
    required this.service,
    required this.companyId,
    required this.employees,
    this.advance,
    super.key,
  });

  final AdvancesService service;
  final int companyId;
  final List<Employee> employees;
  final Advance? advance;

  @override
  State<AdvanceFormDialog> createState() => _AdvanceFormDialogState();
}

class _AdvanceFormDialogState extends State<AdvanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  late int _employeeId;
  DateTime? _date;
  bool _isSaving = false;

  bool get _isEditing => widget.advance != null;

  @override
  void initState() {
    super.initState();

    final advance = widget.advance;
    if (advance != null) {
      _employeeId = advance.employeeId;
      _date = advance.date;
      _amountController.text = GuaraniCurrency.formatPlain(advance.amount);
      _reasonController.text = advance.reason ?? '';
      return;
    }

    _employeeId = widget.employees.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
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
      final amount = GuaraniCurrency.parse(_amountController.text);
      if (amount == null) {
        throw const FormatException();
      }

      if (_isEditing) {
        await widget.service.updateAdvance(
          currentAdvance: widget.advance!,
          employeeId: _employeeId,
          date: _date!,
          amount: amount,
          reason: _reasonController.text,
        );
      } else {
        await widget.service.createAdvance(
          companyId: widget.companyId,
          employeeId: _employeeId,
          date: _date!,
          amount: amount,
          reason: _reasonController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on FormatException {
      _showError('El monto no es valido.');
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Datos invalidos.');
    } catch (_) {
      _showError('No se pudo guardar el anticipo.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
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
      title: Text(_isEditing ? 'Editar anticipo' : 'Nuevo anticipo'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
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
                        child: Text(employee.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _employeeId = value;
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
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: const [ThousandsSeparatorInputFormatter()],
                decoration: const InputDecoration(labelText: 'Monto (Gs.)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el monto.';
                  }
                  final parsed = GuaraniCurrency.parse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Ingrese un monto valido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo (opcional)',
                ),
                minLines: 2,
                maxLines: 3,
              ),
            ],
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
