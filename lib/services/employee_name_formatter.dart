import '../data/database/app_database.dart';

String composeEmployeeFullName({
  required String firstNames,
  required String lastNames,
}) {
  final normalizedFirstNames = _normalizeNamePart(firstNames);
  final normalizedLastNames = _normalizeNamePart(lastNames);
  if (normalizedFirstNames.isEmpty) {
    return normalizedLastNames;
  }
  if (normalizedLastNames.isEmpty) {
    return normalizedFirstNames;
  }
  return '$normalizedFirstNames $normalizedLastNames';
}

String composeEmployeeNameLastFirst({
  required String firstNames,
  required String lastNames,
}) {
  final normalizedFirstNames = _normalizeNamePart(firstNames);
  final normalizedLastNames = _normalizeNamePart(lastNames);
  if (normalizedLastNames.isEmpty) {
    return normalizedFirstNames;
  }
  if (normalizedFirstNames.isEmpty) {
    return normalizedLastNames;
  }
  return '$normalizedLastNames $normalizedFirstNames';
}

String employeeDisplayName(Employee employee) {
  final fullFromParts = composeEmployeeFullName(
    firstNames: employee.firstNames,
    lastNames: employee.lastNames,
  );
  if (fullFromParts.trim().isNotEmpty) {
    return fullFromParts;
  }
  return employee.fullName.trim();
}

String employeeDisplayNameLastFirst(Employee employee) {
  final lastFirst = composeEmployeeNameLastFirst(
    firstNames: employee.firstNames,
    lastNames: employee.lastNames,
  );
  if (lastFirst.trim().isNotEmpty) {
    return lastFirst;
  }
  return employee.fullName.trim();
}

String _normalizeNamePart(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
