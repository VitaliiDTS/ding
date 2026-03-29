import 'package:ding/core/app_colors.dart';
import 'package:ding/core/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.role,
    super.key,
  });

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.avatarBackground,
          child: Icon(
            Icons.person,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: AppTextStyles.title),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
