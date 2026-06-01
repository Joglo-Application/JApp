import 'package:intl/intl.dart';

/// Utility for formatting currency values consistently across the app.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Formats a [double] value as Indonesian Rupiah string.
  ///
  /// Example: `formatRupiah(15000)` → `'Rp 15.000'`
  static String format(double amount) => _formatter.format(amount);

  /// Formats with a custom symbol (useful when symbol comes from Settings).
  static String formatWithSymbol(double amount, String symbol) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$symbol ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
