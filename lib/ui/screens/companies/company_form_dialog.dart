import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
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
  final _abbreviationController = TextEditingController();
  final _rucController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mjtEmployerNumberController = TextEditingController();

  bool _active = true;
  bool _isSaving = false;
  Uint8List? _logoPng;

  bool get _isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();

    final company = widget.company;
    if (company == null) {
      return;
    }

    _nameController.text = company.name;
    _abbreviationController.text = company.abbreviation ?? '';
    _rucController.text = company.ruc ?? '';
    _addressController.text = company.address ?? '';
    _phoneController.text = company.phone ?? '';
    _mjtEmployerNumberController.text = company.mjtEmployerNumber ?? '';
    _active = company.active;
    _logoPng = company.logoPng;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _abbreviationController.dispose();
    _rucController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _mjtEmployerNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

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
          abbreviation: _abbreviationController.text,
          ruc: _rucController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          mjtEmployerNumber: _mjtEmployerNumberController.text,
          logoPng: _logoPng,
          active: _active,
        );
      } else {
        await widget.service.createCompany(
          name: _nameController.text,
          abbreviation: _abbreviationController.text,
          ruc: _rucController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          mjtEmployerNumber: _mjtEmployerNumberController.text,
          logoPng: _logoPng,
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
      _showError('No se pudo guardar la empresa: $error');
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

  Future<void> _pickLogoPng() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showError('No se pudo leer el archivo PNG seleccionado.');
        return;
      }

      setState(() {
        _logoPng = bytes;
      });
    } catch (_) {
      _showError('No se pudo importar el logotipo PNG.');
    }
  }

  void _removeLogo() {
    setState(() {
      _logoPng = null;
    });
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
                  controller: _abbreviationController,
                  decoration: const InputDecoration(
                    labelText: 'Abreviatura (opcional)',
                  ),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mjtEmployerNumberController,
                  decoration: const InputDecoration(
                    labelText: 'N° Patronal MJT (opcional)',
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Logotipo PNG (opcional)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _logoPng == null
                          ? const Center(
                              child: Icon(Icons.image_not_supported_outlined),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(_logoPng!, fit: BoxFit.cover),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _pickLogoPng,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Importar PNG'),
                          ),
                          const SizedBox(height: 8),
                          if (_logoPng != null)
                            TextButton.icon(
                              onPressed: _isSaving ? null : _removeLogo,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Quitar logotipo'),
                            ),
                        ],
                      ),
                    ),
                  ],
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
