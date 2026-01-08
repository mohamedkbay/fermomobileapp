import 'package:flutter/material.dart';

enum UserRole { customer, driver, supplier, workshopOwner }
enum DriverType { towTruck, mobileWorkshop, regularService }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final DriverType? driverType;
  final String? carBrand;
  final String? carModel;
  final String? carYear;
  final String? location;
  final String? personalCode;
  final String? workshopName;
  final String? specialization;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.driverType,
    this.carBrand,
    this.carModel,
    this.carYear,
    this.location,
    this.personalCode,
    this.workshopName,
    this.specialization,
  });
}

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    // Mock login logic for demo purposes
    await Future.delayed(const Duration(seconds: 1));
    
    UserRole role = UserRole.customer;
    String name = 'Ahmed Ali';
    DriverType? driverType;

    // Logic to detect role from demo emails
    if (email.contains('driver')) {
      role = UserRole.driver;
      name = email.contains('tow') ? 'Sami (Tow Truck)' : 'Khalid (Delivery)';
      driverType = email.contains('tow') ? DriverType.towTruck : DriverType.regularService;
    } else if (email.contains('supplier')) {
      role = UserRole.supplier;
      name = 'Best Parts Store';
    } else if (email.contains('workshop')) {
      role = UserRole.workshopOwner;
      name = 'ورشة الأمل';
    }

    _user = User(
      id: '1',
      name: name,
      email: email,
      phone: '+966 50 123 4567',
      role: role,
      driverType: driverType,
      carBrand: role == UserRole.customer ? 'Toyota' : null,
      carModel: role == UserRole.customer ? 'Camry' : null,
      carYear: role == UserRole.customer ? '2024' : null,
      location: 'Riyadh, Saudi Arabia',
      personalCode: 'FR-9921',
      workshopName: role == UserRole.workshopOwner ? 'ورشة الأمل المتكاملة' : null,
      specialization: role == UserRole.workshopOwner ? 'ميكانيكا وكهرباء' : null,
    );
    notifyListeners();
  }

  Future<void> signup(String name, String email, String password, String phone, UserRole role, {
    DriverType? driverType,
    String? workshopName,
    String? specialization,
    String? location,
  }) async {
    // Mock signup
    await Future.delayed(const Duration(seconds: 1));
    _user = User(
      id: '1',
      name: name,
      email: email,
      phone: phone,
      role: role,
      driverType: driverType,
      workshopName: workshopName,
      specialization: specialization,
      location: location,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    // Mock reset password
    await Future.delayed(const Duration(seconds: 1));
  }
}
