import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/company_settings_service.dart';
import 'holidays_calendar_dialog.dart';
import '../../utils/guarani_currency.dart';
import '../../utils/thousands_separator_input_formatter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.service,
    required this.companyId,
    required this.canUpdateSettings,
    super.key,
  });

  final CompanySettingsService service;
  final int companyId;
  final bool canUpdateSettings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipsEmployeeRateController = TextEditingController();
  final _ipsEmployerRateController = TextEditingController();
  final _minimumWageController = TextEditingController();
  final _familyBonusRateController = TextEditingController();
  final _overtimeDayRateController = TextEditingController();
  final _overtimeNightRateController = TextEditingController();
  final _ordinaryNightSurchargeRateController = TextEditingController();
  final _ordinaryNightStartController = TextEditingController();
  final _ordinaryNightEndController = TextEditingController();
  final _overtimeDayStartController = TextEditingController();
  final _overtimeDayEndController = TextEditingController();
  final _overtimeNightStartController = TextEditingController();
  final _overtimeNightEndController = TextEditingController();
  final _lateArrivalToleranceMinutesController = TextEditingController();
  final _lateArrivalAllowedTimesPerMonthController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isSavingHolidays = false;
  Set<DateTime> _holidayDates = <DateTime>{};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadSettings();
    }
  }

  @override
  void dispose() {
    _ipsEmployeeRateController.dispose();
    _ipsEmployerRateController.dispose();
    _minimumWageController.dispose();
    _familyBonusRateController.dispose();
    _overtimeDayRateController.dispose();
    _overtimeNightRateController.dispose();
    _ordinaryNightSurchargeRateController.dispose();
    _ordinaryNightStartController.dispose();
    _ordinaryNightEndController.dispose();
    _overtimeDayStartController.dispose();
    _overtimeDayEndController.dispose();
    _overtimeNightStartController.dispose();
    _overtimeNightEndController.dispose();
    _lateArrivalToleranceMinutesController.dispose();
    _lateArrivalAllowedTimesPerMonthController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = await widget.service.getOrCreateSettings(
        widget.companyId,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _ipsEmployeeRateController.text = _formatPercent(
          settings.ipsEmployeeRate,
        );
        _ipsEmployerRateController.text = _formatPercent(
          settings.ipsEmployerRate,
        );
        _minimumWageController.text = GuaraniCurrency.formatPlain(
          settings.minimumWage,
        );
        _familyBonusRateController.text = _formatPercent(
          settings.familyBonusRate,
        );
        _overtimeDayRateController.text = _formatPercent(
          settings.overtimeDayRate,
        );
        _overtimeNightRateController.text = _formatPercent(
          settings.overtimeNightRate,
        );
        _ordinaryNightSurchargeRateController.text = _formatPercent(
          settings.ordinaryNightSurchargeRate,
        );
        _ordinaryNightStartController.text = settings.ordinaryNightStart;
        _ordinaryNightEndController.text = settings.ordinaryNightEnd;
        _overtimeDayStartController.text = settings.overtimeDayStart;
        _overtimeDayEndController.text = settings.overtimeDayEnd;
        _overtimeNightStartController.text = settings.overtimeNightStart;
        _overtimeNightEndController.text = settings.overtimeNightEnd;
        _lateArrivalToleranceMinutesController.text = settings
            .lateArrivalToleranceMinutes
            .toString();
        _lateArrivalAllowedTimesPerMonthController.text = settings
            .lateArrivalAllowedTimesPerMonth
            .toString();
        _holidayDates = widget.service.parseHolidayDates(settings.holidayDates);
      });
    } catch (_) {
      _showError('No se pudo cargar configuracion.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!widget.canUpdateSettings) {
      _showError('No tiene permiso para actualizar configuracion.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final minimumWage =
          GuaraniCurrency.parse(_minimumWageController.text) ?? 0;
      final lateArrivalToleranceMinutes = int.parse(
        _lateArrivalToleranceMinutesController.text.trim(),
      );
      final lateArrivalAllowedTimesPerMonth = int.parse(
        _lateArrivalAllowedTimesPerMonthController.text.trim(),
      );

      await widget.service.updateSettings(
        companyId: widget.companyId,
        ipsEmployeeRate: _parsePercent(_ipsEmployeeRateController.text),
        ipsEmployerRate: _parsePercent(_ipsEmployerRateController.text),
        minimumWage: minimumWage,
        familyBonusRate: _parsePercent(_familyBonusRateController.text),
        overtimeDayRate: _parsePercent(_overtimeDayRateController.text),
        overtimeNightRate: _parsePercent(_overtimeNightRateController.text),
        ordinaryNightSurchargeRate: _parsePercent(
          _ordinaryNightSurchargeRateController.text,
        ),
        ordinaryNightStart: _ordinaryNightStartController.text,
        ordinaryNightEnd: _ordinaryNightEndController.text,
        overtimeDayStart: _overtimeDayStartController.text,
        overtimeDayEnd: _overtimeDayEndController.text,
        overtimeNightStart: _overtimeNightStartController.text,
        overtimeNightEnd: _overtimeNightEndController.text,
        lateArrivalToleranceMinutes: lateArrivalToleranceMinutes,
        lateArrivalAllowedTimesPerMonth: lateArrivalAllowedTimesPerMonth,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Configuracion guardada correctamente.'),
          ),
        );
      await _loadSettings();
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Datos invalidos.');
    } catch (_) {
      _showError('No se pudo guardar configuracion.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatPercent(double value) {
    final percentage = value * 100;
    final text = percentage.toStringAsFixed(4);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double _parsePercent(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    final value = double.parse(normalized);
    return value / 100;
  }

  String? _validatePercentField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese $label.';
    }

    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return '$label debe ser un numero positivo.';
    }

    return null;
  }

  String? _validateMoneyField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese $label.';
    }

    final parsed = GuaraniCurrency.parse(value);
    if (parsed == null || parsed < 0) {
      return '$label debe ser un monto valido.';
    }

    return null;
  }

  String? _validateTimeField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese $label.';
    }

    final match = _timeRegex.firstMatch(value.trim());
    if (match == null) {
      return '$label debe tener formato HH:mm.';
    }

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) {
      return '$label no es valido.';
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return '$label no es valido.';
    }

    return null;
  }

  String? _validateNonNegativeIntField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese $label.';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return '$label debe ser un entero positivo.';
    }

    return null;
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openHolidaysCalendar() async {
    if (!widget.canUpdateSettings) {
      _showError('No tiene permiso para actualizar configuracion.');
      return;
    }

    if (_isSaving || _isSavingHolidays) {
      return;
    }

    final selected = await showDialog<Set<DateTime>>(
      context: context,
      builder: (context) => HolidaysCalendarDialog(initialDates: _holidayDates),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _isSavingHolidays = true;
    });

    try {
      final saved = await widget.service.updateHolidays(
        companyId: widget.companyId,
        holidayDates: selected,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _holidayDates = widget.service.parseHolidayDates(saved.holidayDates);
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Feriados guardados correctamente.')),
        );
    } catch (_) {
      _showError('No se pudo guardar feriados.');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingHolidays = false;
        });
      }
    }
  }

  List<DateTime> _sortedHolidayDatesForYear(int year) {
    final sorted = _holidayDates.where((date) => date.year == year).toList()
      ..sort((left, right) => left.compareTo(right));
    return sorted;
  }

  String _formatHolidayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final currentYear = DateTime.now().year;
    final currentYearHolidayDates = _sortedHolidayDatesForYear(currentYear);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.canUpdateSettings)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          border: Border.all(color: Colors.amber.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Modo solo lectura: este usuario no puede editar la configuracion.',
                        ),
                      ),
                    const Text(
                      'Configuracion de nomina por empresa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ipsEmployeeRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'IPS empleado (%)',
                      ),
                      validator: (value) =>
                          _validatePercentField(value, 'IPS empleado'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ipsEmployerRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'IPS empleador (%)',
                      ),
                      validator: (value) =>
                          _validatePercentField(value, 'IPS empleador'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _minimumWageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [
                        ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Salario minimo (Gs.)',
                      ),
                      validator: (value) =>
                          _validateMoneyField(value, 'salario minimo'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _familyBonusRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Bonificacion familiar (%)',
                      ),
                      validator: (value) =>
                          _validatePercentField(value, 'bonificacion familiar'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _overtimeDayRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Recargo hora extra diurna (%)',
                      ),
                      validator: (value) =>
                          _validatePercentField(value, 'hora extra diurna'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _overtimeNightRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Recargo hora extra nocturna (%)',
                      ),
                      validator: (value) =>
                          _validatePercentField(value, 'hora extra nocturna'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ordinaryNightSurchargeRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Recargo nocturno ordinario (%)',
                      ),
                      validator: (value) => _validatePercentField(
                        value,
                        'recargo nocturno ordinario',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rango recargo nocturno ordinario',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ordinaryNightStartController,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Desde (HH:mm)',
                            ),
                            validator: (value) => _validateTimeField(
                              value,
                              'horario desde recargo nocturno',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _ordinaryNightEndController,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Hasta (HH:mm)',
                            ),
                            validator: (value) => _validateTimeField(
                              value,
                              'horario hasta recargo nocturno',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rangos hora extra',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeDayStartController,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Extra diurna desde (HH:mm)',
                            ),
                            validator: (value) =>
                                _validateTimeField(value, 'extra diurna desde'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeDayEndController,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Extra diurna hasta (HH:mm)',
                            ),
                            validator: (value) =>
                                _validateTimeField(value, 'extra diurna hasta'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeNightStartController,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Extra nocturna desde (HH:mm)',
                            ),
                            validator: (value) => _validateTimeField(
                              value,
                              'extra nocturna desde',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeNightEndController,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9:.,]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Extra nocturna hasta (HH:mm)',
                            ),
                            validator: (value) => _validateTimeField(
                              value,
                              'extra nocturna hasta',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tardanza (sin hora extra)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lateArrivalToleranceMinutesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Tolerancia de llegada tardia (min)',
                      ),
                      validator: (value) => _validateNonNegativeIntField(
                        value,
                        'tolerancia de llegada tardia',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lateArrivalAllowedTimesPerMonthController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Cantidad de veces permitidas en el mes',
                      ),
                      validator: (value) => _validateNonNegativeIntField(
                        value,
                        'cantidad de veces permitidas en el mes',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Feriados',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              !widget.canUpdateSettings ||
                                  _isSaving ||
                                  _isSavingHolidays
                              ? null
                              : _openHolidaysCalendar,
                          icon: const Icon(Icons.calendar_month),
                          label: Text(
                            _isSavingHolidays
                                ? 'Guardando...'
                                : 'Configurar feriados',
                          ),
                        ),
                        Text(
                          currentYearHolidayDates.isEmpty
                              ? 'Sin dias marcados en $currentYear'
                              : '${currentYearHolidayDates.length} dia(s) marcado(s) en $currentYear',
                        ),
                      ],
                    ),
                    if (currentYearHolidayDates.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: currentYearHolidayDates
                            .map(
                              (date) => Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(_formatHolidayDate(date)),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: !widget.canUpdateSettings || _isSaving
                            ? null
                            : _save,
                        icon: const Icon(Icons.save),
                        label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final RegExp _timeRegex = RegExp(r'^(\d{1,2})[:.,](\d{2})$');
