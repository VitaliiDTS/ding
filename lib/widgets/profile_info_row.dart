import 'package:ding/core/app_colors.dart';
import 'package:ding/core/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: AppTextStyles.infoLabel),
        ),
        Text(value, style: AppTextStyles.infoValue),
      ],
    );
  }
}
