import 'package:flutter/material.dart';

class FerroColors {
  // Brand Identity
  static const Color black = Color(0xFF050505);
  static const Color amber = Color(0xFFF59E0B);
  static const Color card = Color(0xFF121212);
  static const Color border = Color(0xFF27272A);

  // User Roles
  static const Color driver = Color(0xFFF59E0B);
  static const Color customer = Color(0xFF2563EB);
  static const Color supplier = Color(0xFF9333EA);
  static const Color admin = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color textPrimary = Color(0xFFE5E5E5);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Role based color getter
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'driver': return driver;
      case 'customer': return customer;
      case 'supplier': return supplier;
      case 'admin': return admin;
      default: return customer;
    }
  }
}
