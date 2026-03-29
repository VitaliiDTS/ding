import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1F6F8B);
  static const Color primaryLight = Color(0xFFE8F1F5);
  static const Color avatarBackground = Color(0xFFE3F2FD);
  static const Color shadow = Color(0x14000000);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // Table status colors
  static const Color statusNewBackground = Color(0xFFFFF3CD);
  static const Color statusNewText = Color(0xFF856404);
  static const Color statusBillBackground = Color(0xFFF3E8FF);
  static const Color statusBillText = Color(0xFF6B21A8);
  static const Color statusAssignedBackground = Color(0xFFE0F2FE);
  static const Color statusAssignedText = Color(0xFF075985);
}
