import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../security/password_hasher.dart';
import 'authorization_service.dart';
import 'company_service.dart';

class AuthService {
  AuthService(
    this._authorizationService,
    this._securityDao,
    this._companyService,
  );

  final AuthorizationService _authorizationService;
  final SecurityDao _securityDao;
  final CompanyService _companyService;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.isEmpty) {
      throw ArgumentError('Usuario y contrasena son obligatorios.');
    }

    final user = await _securityDao.getUserByUsername(normalizedUsername);
    if (user == null || !user.active) {
      throw StateError('Usuario o contrasena incorrectos.');
    }

    final validPassword = PasswordHasher.verify(
      username: user.username,
      password: password,
      expectedHash: user.passwordHash,
    );
    if (!validPassword) {
      throw StateError('Usuario o contrasena incorrectos.');
    }

    await _authorizationService.setCurrentUser(user.id);
    await _securityDao.updateUser(
      user.copyWith(lastLoginAt: Value(DateTime.now())),
    );

    final accessibleCompanies = await _authorizationService
        .listAccessibleCompanies();
    if (accessibleCompanies.isNotEmpty) {
      final activeCompanyId = await _companyService.getActiveCompanyId();
      final canUseCurrent =
          activeCompanyId != null &&
          accessibleCompanies.any((company) => company.id == activeCompanyId);
      if (!canUseCurrent) {
        await _companyService.setActiveCompany(accessibleCompanies.first.id);
      }
    }
  }

  Future<void> logout() async {
    await _authorizationService.clearCurrentUser();
  }

  Future<bool> isSessionActive() async {
    final currentUser = await _authorizationService.getCurrentUser();
    return currentUser != null;
  }

  Future<User?> currentUser() {
    return _authorizationService.getCurrentUser();
  }
}
