import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/department_service.dart';

class SectorFormDialog extends StatefulWidget {
  const SectorFormDialog({
    required this.service,
    required this.departmentId,
    this.sector,
    super.key,
  });

  final DepartmentService service;
  final int departmentId;
  final DepartmentSector? sector;

  @override
  State<SectorFormDialog> createState() => _SectorFormDialogState();
}

class _SectorFormDialogState extends State<SectorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _active = true;
  bool _isSaving = false;

  bool get _isEditing => widget.sector != null;

  @override
  void initState() {
    super.initState();
    final sector = widget.sector;
    if (sector == null) {
      return;
    }

    _nameController.text = sector.name;
    _active = sector.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await widget.service.updateSector(
          currentSector: widget.sector!,
          name: _nameController.text,
          active: _active,
        );
      } else {
        await widget.service.createSector(
          departmentId: widget.departmentId,
          name: _nameController.text,
          active: _active,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Datos invalidos.');
    } catch (error) {
      final normalized = error.toString().toUpperCase();
      if (normalized.contains('UNIQUE')) {
        _showError('Ya existe un sector con ese nombre en el departamento.');
      } else {
        _showError('No se pudo guardar el sector.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
      title: Text(_isEditing ? 'Editar sector' : 'Nuevo sector'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el nombre del sector.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _active,
                  onChanged: (value) {
                    setState(() {
                      _active = value;
                    });
                  },
                  title: const Text('Sector activo'),
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
