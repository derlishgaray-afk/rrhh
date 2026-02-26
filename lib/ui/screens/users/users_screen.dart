import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../security/security_constants.dart';
import '../../../services/user_admin_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({required this.service, super.key});

  final UserAdminService service;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserWithAccess> _users = const [];
  List<RoleWithPermissions> _roles = const [];
  List<Permission> _permissions = const [];
  List<Company> _companies = const [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await widget.service.listUsersDetailed();
      final roles = await widget.service.listRolesDetailed();
      final permissions = await widget.service.listPermissions();
      final companies = await widget.service.listCompanies();
      if (!mounted) {
        return;
      }
      setState(() {
        _users = users;
        _roles = roles;
        _permissions = permissions;
        _companies = companies;
      });
    } catch (error) {
      _showError('No se pudo cargar usuarios/roles: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createUser() async {
    if (_roles.isEmpty || _companies.isEmpty) {
      _showError('Debe existir al menos un rol y una empresa.');
      return;
    }

    final payload = await showDialog<_CreateUserPayload>(
      context: context,
      builder: (_) => _CreateUserDialog(companies: _companies, roles: _roles),
    );
    if (payload == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      await widget.service.createUser(
        username: payload.username,
        password: payload.password,
        fullName: payload.fullName,
        active: payload.active,
        accesses: payload.assignments,
      );
      await _loadData();
      _showInfo('Usuario creado correctamente.');
    } catch (error) {
      _showError('No se pudo crear usuario: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _toggleUser(UserWithAccess userWithAccess) async {
    setState(() {
      _isSaving = true;
    });
    try {
      await widget.service.setUserActive(
        userId: userWithAccess.user.id,
        active: !userWithAccess.user.active,
      );
      await _loadData();
    } catch (error) {
      _showError('No se pudo actualizar usuario: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _editUser(UserWithAccess entry) async {
    if (_roles.isEmpty || _companies.isEmpty) {
      _showError('Debe existir al menos un rol y una empresa.');
      return;
    }

    final payload = await showDialog<_EditUserPayload>(
      context: context,
      builder: (_) => _EditUserDialog(
        user: entry.user,
        existingAccesses: entry.accesses,
        companies: _companies,
        roles: _roles,
      ),
    );
    if (payload == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      await widget.service.updateUser(
        userId: entry.user.id,
        fullName: payload.fullName,
        active: payload.active,
        accesses: payload.assignments,
      );
      await _loadData();
      _showInfo('Usuario actualizado correctamente.');
    } catch (error) {
      _showError('No se pudo actualizar usuario: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _resetPassword(User user) async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) => _ResetPasswordDialog(username: user.username),
    );
    if (newPassword == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      await widget.service.resetPassword(
        userId: user.id,
        newPassword: newPassword,
      );
      _showInfo('Contrasena actualizada.');
    } catch (error) {
      _showError('No se pudo resetear contrasena: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _createRole() async {
    final rolePayload = await showDialog<_CreateRolePayload>(
      context: context,
      builder: (_) => _CreateRoleDialog(permissions: _permissions),
    );
    if (rolePayload == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      await widget.service.createRole(
        name: rolePayload.name,
        description: rolePayload.description,
        permissionKeys: rolePayload.permissionKeys,
      );
      await _loadData();
      _showInfo('Rol creado correctamente.');
    } catch (error) {
      _showError('No se pudo crear rol: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _editRolePermissions(RoleWithPermissions roleDetail) async {
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _RolePermissionsDialog(
        role: roleDetail.role,
        permissions: _permissions,
        selectedKeys: roleDetail.permissions
            .map((permission) => permission.key)
            .toSet(),
      ),
    );
    if (selected == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      await widget.service.updateRolePermissions(
        roleId: roleDetail.role.id,
        permissionKeys: selected,
      );
      await _loadData();
      _showInfo('Permisos del rol actualizados.');
    } catch (error) {
      _showError('No se pudo actualizar el rol: $error');
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

  void _showInfo(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Usuarios'),
                Tab(text: 'Roles'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(children: [_buildUsersTab(), _buildRolesTab()]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: _isSaving ? null : _createUser,
              icon: const Icon(Icons.person_add),
              label: const Text('Nuevo usuario'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Recargar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _users.isEmpty
              ? const Center(child: Text('No hay usuarios registrados.'))
              : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Usuario')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Ultimo acceso')),
                      DataColumn(label: Text('Accesos')),
                      DataColumn(label: Text('Accion')),
                    ],
                    rows: _users.map((entry) {
                      final user = entry.user;
                      final accesses = entry.accesses
                          .map(
                            (access) =>
                                '${access.company.name}: ${roleDisplayName(access.role.name)}',
                          )
                          .join(' | ');
                      final lastLogin = user.lastLoginAt == null
                          ? '-'
                          : '${user.lastLoginAt!.day.toString().padLeft(2, '0')}/'
                                '${user.lastLoginAt!.month.toString().padLeft(2, '0')}/'
                                '${user.lastLoginAt!.year} '
                                '${user.lastLoginAt!.hour.toString().padLeft(2, '0')}:'
                                '${user.lastLoginAt!.minute.toString().padLeft(2, '0')}';
                      return DataRow(
                        cells: [
                          DataCell(Text(user.username)),
                          DataCell(Text(user.fullName)),
                          DataCell(Text(user.active ? 'Activo' : 'Inactivo')),
                          DataCell(Text(lastLogin)),
                          DataCell(
                            SizedBox(
                              width: 320,
                              child: Text(
                                accesses.isEmpty ? '-' : accesses,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => _editUser(entry),
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Editar usuario',
                                ),
                                IconButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => _toggleUser(entry),
                                  icon: Icon(
                                    user.active
                                        ? Icons.person_off
                                        : Icons.person,
                                  ),
                                  tooltip: user.active
                                      ? 'Desactivar'
                                      : 'Activar',
                                ),
                                IconButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => _resetPassword(user),
                                  icon: const Icon(Icons.password),
                                  tooltip: 'Resetear contrasena',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRolesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: _isSaving ? null : _createRole,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo rol'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Recargar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _roles.isEmpty
              ? const Center(child: Text('No hay roles disponibles.'))
              : ListView.separated(
                  itemBuilder: (context, index) {
                    final roleDetail = _roles[index];
                    final role = roleDetail.role;
                    final permissionKeys = roleDetail.permissions
                        .map((permission) => permission.key)
                        .toList();
                    permissionKeys.sort(
                      (a, b) => permissionDisplayName(
                        a,
                      ).compareTo(permissionDisplayName(b)),
                    );
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    roleDisplayName(role.name),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _isSaving
                                      ? null
                                      : () => _editRolePermissions(roleDetail),
                                  icon: const Icon(Icons.security),
                                  label: const Text('Permisos'),
                                ),
                              ],
                            ),
                            if ((role.description ?? '').trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(role.description!.trim()),
                              ),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: permissionKeys
                                  .map(
                                    (key) => Chip(
                                      label: Text(permissionDisplayName(key)),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemCount: _roles.length,
                ),
        ),
      ],
    );
  }
}

class _CreateUserPayload {
  const _CreateUserPayload({
    required this.username,
    required this.fullName,
    required this.password,
    required this.active,
    required this.assignments,
  });

  final String username;
  final String fullName;
  final String password;
  final bool active;
  final List<UserCompanyRoleAssignment> assignments;
}

class _EditUserPayload {
  const _EditUserPayload({
    required this.fullName,
    required this.active,
    required this.assignments,
  });

  final String fullName;
  final bool active;
  final List<UserCompanyRoleAssignment> assignments;
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog({required this.companies, required this.roles});

  final List<Company> companies;
  final List<RoleWithPermissions> roles;

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _active = true;
  late List<_AccessDraft> _accesses;

  @override
  void initState() {
    super.initState();
    _accesses = [
      _AccessDraft(
        companyId: widget.companies.first.id,
        roleId: widget.roles.first.role.id,
        active: true,
      ),
    ];
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final assignments = _accesses
        .map(
          (entry) => UserCompanyRoleAssignment(
            companyId: entry.companyId,
            roleId: entry.roleId,
            active: entry.active,
          ),
        )
        .toList();
    Navigator.of(context).pop(
      _CreateUserPayload(
        username: _usernameController.text,
        fullName: _fullNameController.text,
        password: _passwordController.text,
        active: _active,
        assignments: assignments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo usuario'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingrese usuario.'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingrese nombre completo.'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contrasena'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingrese contrasena.'
                      : null,
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: _active,
                  onChanged: (value) {
                    setState(() {
                      _active = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Usuario activo'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Accesos por empresa',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _accesses.add(
                              _AccessDraft(
                                companyId: widget.companies.first.id,
                                roleId: widget.roles.first.role.id,
                                active: true,
                              ),
                            );
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                ),
                ..._accesses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final draft = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: draft.companyId,
                          decoration: const InputDecoration(
                            labelText: 'Empresa',
                          ),
                          items: widget.companies
                              .map(
                                (company) => DropdownMenuItem<int>(
                                  value: company.id,
                                  child: Text(company.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _accesses[index] = draft.copyWith(
                                companyId: value,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: draft.roleId,
                          decoration: const InputDecoration(labelText: 'Rol'),
                          items: widget.roles
                              .map(
                                (role) => DropdownMenuItem<int>(
                                  value: role.role.id,
                                  child: Text(roleDisplayName(role.role.name)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _accesses[index] = draft.copyWith(roleId: value);
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _accesses.length <= 1
                            ? null
                            : () {
                                setState(() {
                                  _accesses.removeAt(index);
                                });
                              },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}

class _AccessDraft {
  const _AccessDraft({
    required this.companyId,
    required this.roleId,
    required this.active,
  });

  final int companyId;
  final int roleId;
  final bool active;

  _AccessDraft copyWith({int? companyId, int? roleId, bool? active}) {
    return _AccessDraft(
      companyId: companyId ?? this.companyId,
      roleId: roleId ?? this.roleId,
      active: active ?? this.active,
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({
    required this.user,
    required this.existingAccesses,
    required this.companies,
    required this.roles,
  });

  final User user;
  final List<UserAccessView> existingAccesses;
  final List<Company> companies;
  final List<RoleWithPermissions> roles;

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late bool _active;
  late List<_AccessDraft> _accesses;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _active = widget.user.active;
    _accesses = widget.existingAccesses
        .map(
          (entry) => _AccessDraft(
            companyId: entry.company.id,
            roleId: entry.role.id,
            active: entry.access.active,
          ),
        )
        .toList();
    if (_accesses.isEmpty) {
      _accesses = [
        _AccessDraft(
          companyId: widget.companies.first.id,
          roleId: widget.roles.first.role.id,
          active: true,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final assignments = _accesses
        .map(
          (entry) => UserCompanyRoleAssignment(
            companyId: entry.companyId,
            roleId: entry.roleId,
            active: entry.active,
          ),
        )
        .toList();
    Navigator.of(context).pop(
      _EditUserPayload(
        fullName: _fullNameController.text,
        active: _active,
        assignments: assignments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar usuario (${widget.user.username})'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: widget.user.username,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  enabled: false,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingrese nombre completo.'
                      : null,
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: _active,
                  onChanged: (value) {
                    setState(() {
                      _active = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Usuario activo'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Accesos por empresa',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _accesses.add(
                              _AccessDraft(
                                companyId: widget.companies.first.id,
                                roleId: widget.roles.first.role.id,
                                active: true,
                              ),
                            );
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                ),
                ..._accesses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final draft = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: draft.companyId,
                          decoration: const InputDecoration(
                            labelText: 'Empresa',
                          ),
                          items: widget.companies
                              .map(
                                (company) => DropdownMenuItem<int>(
                                  value: company.id,
                                  child: Text(company.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _accesses[index] = draft.copyWith(
                                companyId: value,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: draft.roleId,
                          decoration: const InputDecoration(labelText: 'Rol'),
                          items: widget.roles
                              .map(
                                (role) => DropdownMenuItem<int>(
                                  value: role.role.id,
                                  child: Text(roleDisplayName(role.role.name)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _accesses[index] = draft.copyWith(roleId: value);
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _accesses.length <= 1
                            ? null
                            : () {
                                setState(() {
                                  _accesses.removeAt(index);
                                });
                              },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.username});

  final String username;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Resetear contrasena (${widget.username})'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Nueva contrasena'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _CreateRolePayload {
  const _CreateRolePayload({
    required this.name,
    required this.description,
    required this.permissionKeys,
  });

  final String name;
  final String? description;
  final Set<String> permissionKeys;
}

class _CreateRoleDialog extends StatefulWidget {
  const _CreateRoleDialog({required this.permissions});

  final List<Permission> permissions;

  @override
  State<_CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<_CreateRoleDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selected = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissions = [...widget.permissions]
      ..sort(
        (a, b) => permissionDisplayName(
          a.key,
        ).compareTo(permissionDisplayName(b.key)),
      );
    return AlertDialog(
      title: const Text('Nuevo rol'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripcion'),
              ),
              const SizedBox(height: 12),
              ...permissions.map((permission) {
                final isForbidden = PermissionKeys.superAdminOnly.contains(
                  permission.key,
                );
                return CheckboxListTile(
                  value: _selected.contains(permission.key),
                  onChanged: isForbidden
                      ? null
                      : (value) {
                          setState(() {
                            if (value == true) {
                              _selected.add(permission.key);
                            } else {
                              _selected.remove(permission.key);
                            }
                          });
                        },
                  title: Text(permissionDisplayName(permission.key)),
                  subtitle: Text(permission.description ?? ''),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _CreateRolePayload(
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                permissionKeys: _selected,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _RolePermissionsDialog extends StatefulWidget {
  const _RolePermissionsDialog({
    required this.role,
    required this.permissions,
    required this.selectedKeys,
  });

  final Role role;
  final List<Permission> permissions;
  final Set<String> selectedKeys;

  @override
  State<_RolePermissionsDialog> createState() => _RolePermissionsDialogState();
}

class _RolePermissionsDialogState extends State<_RolePermissionsDialog> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selectedKeys};
  }

  @override
  Widget build(BuildContext context) {
    final permissions = [...widget.permissions]
      ..sort(
        (a, b) => permissionDisplayName(
          a.key,
        ).compareTo(permissionDisplayName(b.key)),
      );
    final isSuperRole = widget.role.name == RoleNames.superAdmin;
    return AlertDialog(
      title: Text('Permisos: ${roleDisplayName(widget.role.name)}'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            children: permissions.map((permission) {
              final forbidden = PermissionKeys.superAdminOnly.contains(
                permission.key,
              );
              final disabled = isSuperRole || forbidden;
              final value = isSuperRole
                  ? true
                  : _selected.contains(permission.key);
              return CheckboxListTile(
                value: value,
                onChanged: disabled
                    ? null
                    : (checked) {
                        setState(() {
                          if (checked == true) {
                            _selected.add(permission.key);
                          } else {
                            _selected.remove(permission.key);
                          }
                        });
                      },
                title: Text(permissionDisplayName(permission.key)),
                subtitle: Text(permission.description ?? ''),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
