import 'package:flutter/services.dart';

/// Memformat input angka uang dengan pemisah ribuan `.` saat mengetik.
/// Contoh: mengetik `100000` menjadi `100.000`.
///
/// Nilai mentahnya dibaca dengan membuang titik, mis.
/// `text.replaceAll('.', '')`.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final formatted = _group(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _group(String digits) {
    // Buang nol di depan (mis. "007" → "7"), tetap izinkan "0".
    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final buf = StringBuffer();
    for (var i = 0; i < normalized.length; i++) {
      if (i > 0 && (normalized.length - i) % 3 == 0) buf.write('.');
      buf.write(normalized[i]);
    }
    return buf.toString();
  }
}
