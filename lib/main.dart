import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'widgets/ferro_logo.dart';
import 'screens/customer_dashboard.dart';
import 'screens/driver_dashboard.dart';
import 'screens/supplier_dashboard.dart';
import 'screens/requests_page.dart';
import 'screens/profile_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/ferro_colors.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);

    return MaterialApp(
        title: 'FERRO',
        useInheritedMediaQuery: true,
        locale: lp.locale,
        builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: FerroColors.amber,
        scaffoldBackgroundColor: FerroColors.black,
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: FerroColors.black,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context);
    return ap.isAuthenticated ? const MainScreen() : const LoginScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final ap = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const FerroLogo(size: 28),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: FerroColors.amber),
            onPressed: () => lp.toggleLanguage(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: FerroColors.danger),
            onPressed: () => ap.logout(),
          ),
        ],
      ),
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: lp.translate('dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.list), label: lp.translate('requests')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: lp.translate('profile')),
        ],
      ),
    );
  }

  Widget _buildPage() {
    final ap = Provider.of<AuthProvider>(context);
    final role = ap.user?.role ?? UserRole.customer;

    switch (_currentIndex) {
      case 0:
        if (role == UserRole.driver) return const DriverDashboard();
        if (role == UserRole.supplier) return const SupplierDashboard();
        return const CustomerDashboard();
      case 1:
        return const RequestsPage();
      case 2:
        return const ProfilePage();
      default:
        return const CustomerDashboard();
    }
  }
}

class LoginScreenStub extends StatelessWidget {
  const LoginScreenStub({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final lp = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lp.translate('appName'),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => ap.login('test@example.com', 'password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(lp.translate('login')),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: Text(lp.translate('signUp'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
