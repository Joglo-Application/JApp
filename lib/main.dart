import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Core
import 'core/constants/app_constants.dart';

// Features
import 'features/category/data/datasources/category_local_datasource.dart';
import 'features/category/data/models/category_model.dart';
import 'features/category/data/repositories/category_repository_impl.dart';
import 'features/category/presentation/providers/category_provider.dart';

import 'features/product/data/datasources/product_local_datasource.dart';
import 'features/product/data/models/product_model.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/presentation/providers/product_provider.dart';

import 'features/transaction/data/datasources/transaction_local_datasource.dart';
import 'features/transaction/data/models/transaction_model.dart';
import 'features/transaction/data/repositories/transaction_repository_impl.dart';
import 'features/transaction/presentation/providers/transaction_provider.dart';

import 'features/cart/presentation/providers/cart_provider.dart';

// Pages
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/product/presentation/pages/product_list_page.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Hive
  await Hive.initFlutter();

  // 2. Register Hive Adapters (generated via build_runner)
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionItemModelAdapter());

  // 3. Open Hive Boxes
  final categoryBox =
      await Hive.openBox<CategoryModel>(AppConstants.categoryBox);
  final productBox =
      await Hive.openBox<ProductModel>(AppConstants.productBox);
  final transactionBox =
      await Hive.openBox<TransactionModel>(AppConstants.transactionBox);

  // 4. Dependency Injection (Manual Setup)

  // Datasources
  final categoryLocalDs = CategoryLocalDataSource(categoryBox);
  final productLocalDs = ProductLocalDataSource(productBox);
  final transactionLocalDs = TransactionLocalDataSource(transactionBox);

  // Repositories
  final categoryRepo =
      CategoryRepositoryImpl(localDataSource: categoryLocalDs);
  final productRepo =
      ProductRepositoryImpl(localDataSource: productLocalDs);
  final transactionRepo =
      TransactionRepositoryImpl(localDataSource: transactionLocalDs);

  // 5. Run App with MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(repository: categoryRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(repository: productRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(repository: transactionRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
      ],
      child: const RestoPosApp(),
    ),
  );
}

class RestoPosApp extends StatelessWidget {
  const RestoPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resto POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}

/// The main shell of the app with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ProductListPage(),
    CartPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
