const String sundaySurcharge100Marker = '[recargo_domingo_100]';

final RegExp _sundaySurcharge100MarkerRegExp = RegExp(
  r'\[recargo_domingo_100\]',
  caseSensitive: false,
);

bool hasSundaySurcharge100Marker(String? notes) {
  if (notes == null || notes.trim().isEmpty) {
    return false;
  }
  return _sundaySurcharge100MarkerRegExp.hasMatch(notes);
}

String? attendanceUserDetailFromNotes(String? notes) {
  final normalized = (notes ?? '').trim();
  if (normalized.isEmpty) {
    return null;
  }

  final cleaned = normalized
      .replaceAll(_sundaySurcharge100MarkerRegExp, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return cleaned.isEmpty ? null : cleaned;
}

String? composeAttendanceNotes({
  required String? detail,
  required bool sundaySurcharge100Enabled,
}) {
  final cleanedDetail = attendanceUserDetailFromNotes(detail);
  final parts = <String>[];

  if (cleanedDetail != null) {
    parts.add(cleanedDetail);
  }
  if (sundaySurcharge100Enabled) {
    parts.add(sundaySurcharge100Marker);
  }

  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' ');
}
