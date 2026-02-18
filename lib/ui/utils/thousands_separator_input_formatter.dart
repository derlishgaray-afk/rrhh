import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _onlyDigits(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final normalizedDigits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final formatted = _formatWithThousands(normalizedDigits);
    final selectionIndex = _selectionOffsetForDigitsCount(
      text: formatted,
      digitCount: _digitsBeforeSelection(newValue),
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
      composing: TextRange.empty,
    );
  }

  String _onlyDigits(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  int _digitsBeforeSelection(TextEditingValue value) {
    final offset = value.selection.baseOffset;
    if (offset <= 0) {
      return 0;
    }
    final safeOffset = offset.clamp(0, value.text.length);
    return _onlyDigits(value.text.substring(0, safeOffset)).length;
  }

  int _selectionOffsetForDigitsCount({
    required String text,
    required int digitCount,
  }) {
    if (digitCount <= 0) {
      return 0;
    }

    var seenDigits = 0;
    for (var index = 0; index < text.length; index++) {
      final codeUnit = text.codeUnitAt(index);
      if (codeUnit >= 48 && codeUnit <= 57) {
        seenDigits += 1;
      }
      if (seenDigits >= digitCount) {
        return index + 1;
      }
    }
    return text.length;
  }

  String _formatWithThousands(String digits) {
    if (digits.length <= 3) {
      return digits;
    }

    final buffer = StringBuffer();
    final leadingGroupLength = digits.length % 3;
    var index = 0;

    if (leadingGroupLength > 0) {
      buffer.write(digits.substring(0, leadingGroupLength));
      index = leadingGroupLength;
      if (index < digits.length) {
        buffer.write('.');
      }
    }

    while (index < digits.length) {
      final next = index + 3;
      buffer.write(digits.substring(index, next));
      index = next;
      if (index < digits.length) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}
