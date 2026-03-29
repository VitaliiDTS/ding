import 'package:ding/core/app_colors.dart';
import 'package:ding/core/app_text_styles.dart';
import 'package:ding/widgets/primary_button.dart';
import 'package:ding/widgets/status_chip.dart';
import 'package:flutter/material.dart';

class TableCard extends StatelessWidget {
  const TableCard({
    required this.tableNumber,
    required this.statusText,
    required this.statusColor,
    required this.statusTextColor,
    required this.requestText,
    required this.buttonText,
    required this.onPressed,
    super.key,
    this.assignedTo,
  });

  final int tableNumber;
  final String statusText;
  final Color statusColor;
  final Color statusTextColor;
  final String requestText;
  final String buttonText;
  final VoidCallback onPressed;
  final String? assignedTo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Table $tableNumber',
                style: AppTextStyles.cardTitle,
              ),
              const Spacer(),
              StatusChip(
                text: statusText,
                backgroundColor: statusColor,
                textColor: statusTextColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(requestText, style: AppTextStyles.requestText),
          if (assignedTo != null) ...[
            const SizedBox(height: 10),
            Text(
              'Assigned to: $assignedTo',
              style: AppTextStyles.secondary,
            ),
          ],
          const SizedBox(height: 18),
          PrimaryButton(text: buttonText, onPressed: onPressed),
        ],
      ),
    );
  }
}
