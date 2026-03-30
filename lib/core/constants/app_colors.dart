import 'package:flutter/material.dart';

class AppColors {
  // ── Monochrome Aesthetic (Pitch Black & Charcoal) ──
  static const Color primary = Color(0xFF111111);       // Pitch Black
  static const Color accent = Color(0xFF111111);        // Pitch Black
  static const Color secondary = Color(0xFF424242);     // Charcoal Grey
  static const Color background = Color(0xFFF7F7F7);    // Off-White Background
  static const Color surface = Color(0xFFFFFFFF);       // Pure White (Floating base)
  static const Color cardBackground = Color(0xFFFFFFFF);// Pure White
  static const Color textPrimary = Color(0xFF111111);   // Sharp Dark Text
  static const Color textSecondary = Color(0xFF757575); // Medium Grey hierarchy
  static const Color textSecondaryAccent = Color(0xFFBDBDBD); // Light Gray Accent
  static const Color error = Color(0xFFE53935);         // Crimson Red Status (Essential for Destructive actions)
  static const Color primaryAccent = Color(0xFF2C2C2C); // Dark Grey (Hover/Accent)

  // ── Floating Shadows & Strokes ──
  static const Color border = Color(0xFFEEEEEE);        // Very Soft Border
  static const Color shimmer = Color(0xFFF0F0F0);       // Shimmer fill
  static const Color navBar = Color(0xFFFFFFFF);        // White NavBar
  static const Color inputFill = Color(0xFFF5F5F5);     // Input field bg
  static const Color sheetBackground = Color(0xFFFFFFFF); // Bottom sheet bg
  
  // Enhanced floating shadow (e.g. 10% black) to complement the off-white bg
  static const Color cardShadow = Color(0x14000000);    // 8% Black Shadow
}
