import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/department_service.dart';

class DepartmentFormDialog extends StatefulWidget {
  const DepartmentFormDialog({
    required this.service,
    required this.companyId,
    this.department,
    super.key,
  });

  final DepartmentService service;
  final int companyId;
  final Department? department;

  @override
  State<DepartmentFormDialog> createState() => _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends State<DepartmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _active = true;
  bool _isSaving = false;

  bool get _isEditing => widget.department != null;

  @override
  void initState() {
    super.initState();
    final department = widget.department;
    if (department == null) {
      return;
    }

    _nameController.text = department.name;
    _descriptionController.text = department.description ?? '';
    _active = department.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
        await widget.service.updateDepartment(
          currentDepartment: widget.department!,
          name: _nameController.text,
          description: _descriptionController.text,
          active: _active,
        );
      } else {
        await widget.service.createDepartment(
          companyId: widget.companyId,
          name: _nameController.text,
          description: _descriptionController.text,
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
      _showError(_mapError(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _mapError(Object error) {
    final normalized = error.toString().toUpperCase();
    if (normalized.contains('UNIQUE')) {
      return 'Ya existe un departamento con ese nombre en la empresa.';
    }
    return 'No se pudo guardar el departamento.';
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
      title: Text(_isEditing ? 'Editar departamento' : 'Nuevo departamento'),
      content: SizedBox(
        width: 480,
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
                      return 'Ingrese el nombre del departamento.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripcion (opcional)',
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
                  title: const Text('Departamento activo'),
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
