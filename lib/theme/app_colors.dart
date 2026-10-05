import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Deep Sage / Forest Teal
  static const Color primary = Color(0xFF2F6F62);
  static const Color primaryDark = Color(0xFF1E4B42);
  static const Color primaryLight = Color(0xFF539486);
  static const Color primaryContainer = Color(0xFFE3F0EC);
  static const Color onPrimaryContainer = Color(0xFF13362E);

  // Background & Surface
  static const Color background = Color(0xFFFAF7F2); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4EFEA);
  static const Color surfaceSubtle = Color(0xFFF8F5F0);

  // Accent & Alerts - Soft Terracotta / Coral
  static const Color accent = Color(0xFFE06D53);
  static const Color accentLight = Color(0xFFFBEBE6);
  static const Color accentDark = Color(0xFFB84B32);

  // Neutral Text & Icons
  static const Color textPrimary = Color(0xFF1C1B1A); // Deep off-black
  static const Color textSecondary = Color(0xFF5F5B57); // Warm muted slate
  static const Color textTertiary = Color(0xFF948F8A); // Soft grey
  static const Color divider = Color(0xFFE8E2D9);

  // Status Colors (Calm, Natural Tones)
  static const Color statusTaken = Color(0xFF2E7D32); // Muted Leaf Green
  static const Color statusTakenBg = Color(0xFFE8F5E9);
  
  static const Color statusUpcoming = Color(0xFFD97706); // Warm Amber
  static const Color statusUpcomingBg = Color(0xFFFEF3C7);
  
  static const Color statusMissed = Color(0xFFD9534F); // Soft Terracotta Red
  static const Color statusMissedBg = Color(0xFFFEE2E2);
  
  static const Color statusSkipped = Color(0xFF64748B); // Muted Slate Blue
  static const Color statusSkippedBg = Color(0xFFF1F5F9);

  // Refill Status
  static const Color refillSufficient = Color(0xFF2F6F62);
  static const Color refillSufficientBg = Color(0xFFE3F0EC);

  static const Color refillLow = Color(0xFFD97706);
  static const Color refillLowBg = Color(0xFFFEF3C7);

  static const Color refillOut = Color(0xFFD9534F);
  static const Color refillOutBg = Color(0xFFFEE2E2);

  // Card & Container Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> heroShadow = [
    BoxShadow(
      color: Color(0x182F6F62),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];
}
