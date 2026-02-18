import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/company_service.dart';

class CompanyFormDialog extends StatefulWidget {
  const CompanyFormDialog({required this.service, this.company, super.key});

  final CompanyService service;
  final Company? company;

  @override
  State<CompanyFormDialog> createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends State<CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rucController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _active = true;
  bool _isSaving = false;

  bool get _isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();

    final company = widget.company;
    if (company == null) {
      return;
    }

    _nameController.text = company.name;
    _rucController.text = company.ruc ?? '';
    _addressController.text = company.address ?? '';
    _phoneController.text = company.phone ?? '';
    _active = company.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rucController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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
        await widget.service.updateCompany(
          currentCompany: widget.company!,
          name: _nameController.text,
          ruc: _rucController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          active: _active,
        );
      } else {
        await widget.service.createCompany(
          name: _nameController.text,
          ruc: _rucController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          active: _active,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Datos invalidos.');
    } catch (_) {
      _showError('No se pudo guardar la empresa.');
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
      title: Text(_isEditing ? 'Editar empresa' : 'Nueva empresa'),
      content: SizedBox(
        width: 500,
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
                      return 'Ingrese el nombre de la empresa.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rucController,
                  decoration: const InputDecoration(
                    labelText: 'RUC (opcional)',
                  ),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefono (opcional)',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _active,
                  onChanged: (value) {
                    setState(() {
                      _active = value;
                    });
                  },
                  title: const Text('Empresa activa'),
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
