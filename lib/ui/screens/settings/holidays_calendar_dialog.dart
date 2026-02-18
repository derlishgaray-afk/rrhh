import 'package:flutter/material.dart';

class HolidaysCalendarDialog extends StatefulWidget {
  const HolidaysCalendarDialog({required this.initialDates, super.key});

  final Set<DateTime> initialDates;

  @override
  State<HolidaysCalendarDialog> createState() => _HolidaysCalendarDialogState();
}

class _HolidaysCalendarDialogState extends State<HolidaysCalendarDialog> {
  static const List<String> _monthNames = <String>[
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  static const List<String> _weekdayNames = <String>[
    'Lun',
    'Mar',
    'Mie',
    'Jue',
    'Vie',
    'Sab',
    'Dom',
  ];

  late Set<DateTime> _selectedDates;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.initialDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();

    final seedDate = _selectedDates.isNotEmpty
        ? _selectedDates.reduce(
            (left, right) => left.isBefore(right) ? left : right,
          )
        : DateTime.now();
    _focusedMonth = DateTime(seedDate.year, seedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstWeekdayOffset =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday - 1;
    final totalCells = ((firstWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    return AlertDialog(
      title: const Text('Configurar feriados'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mes anterior',
                  onPressed: _goToPreviousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Mes siguiente',
                  onPressed: _goToNextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _weekdayNames.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    _weekdayNames[index],
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final day = index - firstWeekdayOffset + 1;
                if (day < 1 || day > daysInMonth) {
                  return const SizedBox.shrink();
                }
                final date = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month,
                  day,
                );
                final isSelected = _selectedDates.contains(date);

                return InkWell(
                  onTap: () => _toggleDate(date),
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dias marcados: ${_selectedDates.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _selectedDates.isEmpty
              ? null
              : () {
                  setState(() {
                    _selectedDates.clear();
                  });
                },
          child: const Text('Limpiar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedDates),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _toggleDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    setState(() {
      if (_selectedDates.contains(normalized)) {
        _selectedDates.remove(normalized);
      } else {
        _selectedDates.add(normalized);
      }
    });
  }
}
