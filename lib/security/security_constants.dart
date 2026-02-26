class RoleNames {
  RoleNames._();

  static const String superAdmin = 'SUPER_ADMIN';
  static const String adminEmpresa = 'ADMIN_EMPRESA';
  static const String rrhh = 'RRHH';
  static const String supervisor = 'SUPERVISOR';
  static const String lector = 'LECTOR';

  static const List<String> baseRoles = [
    superAdmin,
    adminEmpresa,
    rrhh,
    supervisor,
    lector,
  ];
}

const Map<String, String> roleDisplayNamesEs = {
  RoleNames.superAdmin: 'Super Administrador',
  RoleNames.adminEmpresa: 'Administrador de Empresa',
  RoleNames.rrhh: 'Recursos Humanos',
  RoleNames.supervisor: 'Supervisor',
  RoleNames.lector: 'Lector',
};

String roleDisplayName(String roleName) {
  return roleDisplayNamesEs[roleName] ?? roleName;
}

const Map<String, String> permissionDisplayNamesEs = {
  PermissionKeys.usersRead: 'Usuarios: Ver',
  PermissionKeys.usersCreate: 'Usuarios: Crear',
  PermissionKeys.usersUpdate: 'Usuarios: Editar',
  PermissionKeys.usersDisable: 'Usuarios: Activar/Desactivar',
  PermissionKeys.usersResetPassword: 'Usuarios: Resetear contrasena',
  PermissionKeys.rolesManage: 'Roles: Administrar',
  PermissionKeys.companiesRead: 'Empresas: Ver',
  PermissionKeys.companiesCreate: 'Empresas: Crear',
  PermissionKeys.companiesUpdate: 'Empresas: Editar',
  PermissionKeys.companiesDelete: 'Empresas: Eliminar',
  PermissionKeys.employeesRead: 'Empleados: Ver',
  PermissionKeys.employeesCreate: 'Empleados: Crear',
  PermissionKeys.employeesUpdate: 'Empleados: Editar',
  PermissionKeys.employeesDisable: 'Empleados: Activar/Desactivar',
  PermissionKeys.employeesDelete: 'Empleados: Eliminar',
  PermissionKeys.attendanceRead: 'Asistencia: Ver',
  PermissionKeys.attendanceEdit: 'Asistencia: Editar',
  PermissionKeys.attendanceDelete: 'Asistencia: Eliminar',
  PermissionKeys.attendanceImportClock: 'Asistencia: Importar marcaciones',
  PermissionKeys.payrollRead: 'Liquidacion: Ver',
  PermissionKeys.payrollGenerate: 'Liquidacion: Generar',
  PermissionKeys.payrollLock: 'Liquidacion: Guardar',
  PermissionKeys.payrollUnlock: 'Liquidacion: Desbloquear',
  PermissionKeys.payrollPrint: 'Liquidacion: Imprimir',
  PermissionKeys.payrollExport: 'Liquidacion: Exportar',
  PermissionKeys.reportsRead: 'Informes: Ver',
  PermissionKeys.settingsRead: 'Configuracion: Ver',
  PermissionKeys.settingsUpdate: 'Configuracion: Editar',
};

String permissionDisplayName(String permissionKey) {
  return permissionDisplayNamesEs[permissionKey] ?? permissionKey;
}

class PermissionKeys {
  PermissionKeys._();

  static const String usersRead = 'users.read';
  static const String usersCreate = 'users.create';
  static const String usersUpdate = 'users.update';
  static const String usersDisable = 'users.disable';
  static const String usersResetPassword = 'users.reset_password';
  static const String rolesManage = 'roles.manage';

  static const String companiesRead = 'companies.read';
  static const String companiesCreate = 'companies.create';
  static const String companiesUpdate = 'companies.update';
  static const String companiesDelete = 'companies.delete';

  static const String employeesRead = 'employees.read';
  static const String employeesCreate = 'employees.create';
  static const String employeesUpdate = 'employees.update';
  static const String employeesDisable = 'employees.disable';
  static const String employeesDelete = 'employees.delete';

  static const String attendanceRead = 'attendance.read';
  static const String attendanceEdit = 'attendance.edit';
  static const String attendanceDelete = 'attendance.delete';
  static const String attendanceImportClock = 'attendance.import_clock';

  static const String payrollRead = 'payroll.read';
  static const String payrollGenerate = 'payroll.generate';
  static const String payrollLock = 'payroll.lock';
  static const String payrollUnlock = 'payroll.unlock';
  static const String payrollPrint = 'payroll.print';
  static const String payrollExport = 'payroll.export';
  static const String reportsRead = 'reports.read';

  static const String settingsRead = 'settings.read';
  static const String settingsUpdate = 'settings.update';

  static const List<String> all = [
    usersRead,
    usersCreate,
    usersUpdate,
    usersDisable,
    usersResetPassword,
    rolesManage,
    companiesRead,
    companiesCreate,
    companiesUpdate,
    companiesDelete,
    employeesRead,
    employeesCreate,
    employeesUpdate,
    employeesDisable,
    employeesDelete,
    attendanceRead,
    attendanceEdit,
    attendanceDelete,
    attendanceImportClock,
    payrollRead,
    payrollGenerate,
    payrollLock,
    payrollUnlock,
    payrollPrint,
    payrollExport,
    reportsRead,
    settingsRead,
    settingsUpdate,
  ];

  static const List<String> superAdminOnly = [
    usersRead,
    usersCreate,
    usersUpdate,
    usersDisable,
    usersResetPassword,
    rolesManage,
  ];
}

const Map<String, String> defaultRoleDescriptions = {
  RoleNames.superAdmin: 'Acceso total al sistema holding.',
  RoleNames.adminEmpresa: 'Administracion operativa por empresa.',
  RoleNames.rrhh: 'Gestion integral de RRHH y liquidacion.',
  RoleNames.supervisor: 'Supervision de asistencia y consulta basica.',
  RoleNames.lector: 'Consulta de datos sin edicion.',
};

const Map<String, Set<String>> baseRolePermissionMatrix = {
  RoleNames.superAdmin: {...PermissionKeys.all},
  RoleNames.adminEmpresa: {
    PermissionKeys.companiesRead,
    PermissionKeys.employeesRead,
    PermissionKeys.employeesCreate,
    PermissionKeys.employeesUpdate,
    PermissionKeys.employeesDisable,
    PermissionKeys.employeesDelete,
    PermissionKeys.attendanceRead,
    PermissionKeys.attendanceEdit,
    PermissionKeys.attendanceDelete,
    PermissionKeys.attendanceImportClock,
    PermissionKeys.payrollRead,
    PermissionKeys.payrollGenerate,
    PermissionKeys.payrollLock,
    PermissionKeys.payrollUnlock,
    PermissionKeys.payrollPrint,
    PermissionKeys.payrollExport,
    PermissionKeys.reportsRead,
    PermissionKeys.settingsRead,
  },
  RoleNames.rrhh: {
    PermissionKeys.employeesRead,
    PermissionKeys.employeesCreate,
    PermissionKeys.employeesUpdate,
    PermissionKeys.employeesDisable,
    PermissionKeys.employeesDelete,
    PermissionKeys.attendanceRead,
    PermissionKeys.attendanceEdit,
    PermissionKeys.attendanceDelete,
    PermissionKeys.attendanceImportClock,
    PermissionKeys.payrollRead,
    PermissionKeys.payrollGenerate,
    PermissionKeys.payrollLock,
    PermissionKeys.payrollUnlock,
    PermissionKeys.payrollPrint,
    PermissionKeys.payrollExport,
    PermissionKeys.reportsRead,
    PermissionKeys.settingsRead,
  },
  RoleNames.supervisor: {
    PermissionKeys.employeesRead,
    PermissionKeys.attendanceRead,
    PermissionKeys.attendanceEdit,
    PermissionKeys.reportsRead,
  },
  RoleNames.lector: {
    PermissionKeys.employeesRead,
    PermissionKeys.attendanceRead,
    PermissionKeys.payrollRead,
    PermissionKeys.reportsRead,
  },
};

class SecuritySettingKeys {
  SecuritySettingKeys._();

  static const String currentUserId = 'current_user_id';
}

class SecurityBootstrap {
  SecurityBootstrap._();

  static const String defaultSuperAdminUsername = 'admin';
  static const String defaultSuperAdminPassword = 'admin123';
}
