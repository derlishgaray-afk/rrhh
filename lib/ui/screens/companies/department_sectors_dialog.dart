import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/department_service.dart';
import 'sector_form_dialog.dart';

class DepartmentSectorsDialog extends StatefulWidget {
  const DepartmentSectorsDialog({
    required this.service,
    required this.department,
    super.key,
  });

  final DepartmentService service;
  final Department department;

  @override
  State<DepartmentSectorsDialog> createState() =>
      _DepartmentSectorsDialogState();
}

class _DepartmentSectorsDialogState extends State<DepartmentSectorsDialog> {
  List<DepartmentSector> _sectors = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSectors();
  }

  Future<void> _loadSectors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sectors = await widget.service.listSectorsByDepartment(
        widget.department.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _sectors = sectors;
      });
    } catch (_) {
      _showError('No se pudieron cargar los sectores.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openSectorForm({DepartmentSector? sector}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => SectorFormDialog(
        service: widget.service,
        departmentId: widget.department.id,
        sector: sector,
      ),
    );

    if (saved == true) {
      await _loadSectors();
    }
  }

  Future<void> _deleteSector(DepartmentSector sector) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar sector'),
        content: Text('Desea eliminar ${sector.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await widget.service.deleteSector(sector.id);
      if (!mounted) {
        return;
      }
      await _loadSectors();
    } catch (_) {
      _showError('No se pudo eliminar el sector.');
    }
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
      title: Text('Sectores - ${widget.department.name}'),
      content: SizedBox(
        width: 720,
        height: 420,
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sectores del departamento',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _openSectorForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo sector'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _sectors.isEmpty
                  ? const Center(child: Text('No hay sectores registrados.'))
                  : SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: _sectors
                            .map(
                              (sector) => DataRow(
                                cells: [
                                  DataCell(Text(sector.name)),
                                  DataCell(
                                    Text(sector.active ? 'Activo' : 'Inactivo'),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Editar',
                                          onPressed: () =>
                                              _openSectorForm(sector: sector),
                                          icon: const Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          tooltip: 'Eliminar',
                                          onPressed: () =>
                                              _deleteSector(sector),
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
