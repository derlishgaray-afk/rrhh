import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as xl;

xl.Excel decodeExcelBytesSafe(List<int> bytes) {
  final payload = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  try {
    return xl.Excel.decodeBytes(payload);
  } catch (error) {
    if (!_needsLegacyStyleRepair(error)) {
      rethrow;
    }

    final repaired = _repairLegacyCustomNumFmtIds(payload);
    return xl.Excel.decodeBytes(repaired);
  }
}

bool _needsLegacyStyleRepair(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains('custom numfmtid starts at 164');
}

Uint8List _repairLegacyCustomNumFmtIds(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes, verify: false);
  ArchiveFile? stylesFile;
  for (final file in archive.files) {
    if (file.isFile && file.name == 'xl/styles.xml') {
      stylesFile = file;
      break;
    }
  }

  if (stylesFile == null) {
    return bytes;
  }

  final rawContent = stylesFile.content;
  if (rawContent is! List<int>) {
    return bytes;
  }

  final originalStylesXml = utf8.decode(rawContent, allowMalformed: true);
  final repairedStylesXml = _repairStylesXml(originalStylesXml);
  if (repairedStylesXml == originalStylesXml) {
    return bytes;
  }

  final repairedArchive = Archive();
  for (final file in archive.files) {
    final content = file.name == 'xl/styles.xml'
        ? Uint8List.fromList(utf8.encode(repairedStylesXml))
        : file.content;
    final repairedFile = ArchiveFile(file.name, file.size, content)
      ..mode = file.mode
      ..ownerId = file.ownerId
      ..groupId = file.groupId
      ..lastModTime = file.lastModTime
      ..isFile = file.isFile
      ..isSymbolicLink = file.isSymbolicLink
      ..nameOfLinkedFile = file.nameOfLinkedFile
      ..crc32 = file.crc32
      ..comment = file.comment
      ..compress = file.compress;
    repairedArchive.addFile(repairedFile);
  }

  final encoded = ZipEncoder().encode(repairedArchive);
  if (encoded == null) {
    return bytes;
  }
  return Uint8List.fromList(encoded);
}

String _repairStylesXml(String xml) {
  final customNumFmtRegExp = RegExp(r'<numFmt\b[^>]*numFmtId="(\d+)"');
  final matches = customNumFmtRegExp.allMatches(xml).toList();
  if (matches.isEmpty) {
    return xml;
  }

  var maxCustomId = 163;
  final remap = <int, int>{};
  for (final match in matches) {
    final id = int.tryParse(match.group(1) ?? '');
    if (id == null) {
      continue;
    }
    if (id > maxCustomId) {
      maxCustomId = id;
    }
  }

  for (final match in matches) {
    final id = int.tryParse(match.group(1) ?? '');
    if (id == null || id >= 164 || remap.containsKey(id)) {
      continue;
    }
    maxCustomId += 1;
    remap[id] = maxCustomId;
  }

  if (remap.isEmpty) {
    return xml;
  }

  var repaired = xml;
  for (final entry in remap.entries) {
    repaired = repaired.replaceAll(
      'numFmtId="${entry.key}"',
      'numFmtId="${entry.value}"',
    );
  }
  return repaired;
}
