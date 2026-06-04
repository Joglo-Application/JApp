/// Global constants for the Resto POS application.
///
/// Centralising box names and route names here ensures there are no
/// hard-coded strings scattered across the codebase.
class AppConstants {
  AppConstants._();

  // ─── Hive box names ─────────────────────────────────────────────────────────
  static const String categoryBox = 'categories';
  static const String productBox = 'products';
  static const String transactionBox = 'transactions';
  static const String settingsBox = 'settings';

  // ─── Route names ────────────────────────────────────────────────────────────
  static const String routeDashboard = '/';
  static const String routeProducts = '/products';
  static const String routeProductForm = '/products/form';
  static const String routeCategories = '/categories';
  static const String routeCategoryForm = '/categories/form';
  static const String routeCart = '/cart';
  static const String routeTransactions = '/transactions';
  static const String routeTransactionDetail = '/transactions/detail';
  static const String routeSettings = '/settings';

  // ─── Settings keys ──────────────────────────────────────────────────────────
  static const String settingStoreName = 'store_name';
  static const String settingCurrencySymbol = 'currency_symbol';
  static const String settingTaxRate = 'tax_rate';
}
