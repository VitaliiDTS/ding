import 'package:ding/core/app_colors.dart';
import 'package:ding/core/app_text_styles.dart';
import 'package:ding/pages/profile_page.dart';
import 'package:ding/widgets/stat_card.dart';
import 'package:ding/widgets/table_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static void _emptyAction() {}

  static const _newRequests = [
    TableCard(
      tableNumber: 2,
      statusText: 'New',
      statusColor: AppColors.statusNewBackground,
      statusTextColor: AppColors.statusNewText,
      requestText: 'Waiter call',
      buttonText: 'Accept',
      onPressed: _emptyAction,
    ),
    TableCard(
      tableNumber: 5,
      statusText: 'Bill',
      statusColor: AppColors.statusBillBackground,
      statusTextColor: AppColors.statusBillText,
      requestText: 'Bill request',
      buttonText: 'Accept',
      onPressed: _emptyAction,
    ),
  ];

  static const _myTables = [
    TableCard(
      tableNumber: 1,
      statusText: 'Assigned',
      statusColor: AppColors.statusAssignedBackground,
      statusTextColor: AppColors.statusAssignedText,
      requestText: 'Serving table',
      assignedTo: 'Andrii',
      buttonText: 'Close table',
      onPressed: _emptyAction,
    ),
    TableCard(
      tableNumber: 4,
      statusText: 'Bill',
      statusColor: AppColors.statusBillBackground,
      statusTextColor: AppColors.statusBillText,
      requestText: 'Bill request',
      assignedTo: 'Andrii',
      buttonText: 'Close table',
      onPressed: _emptyAction,
    ),
    TableCard(
      tableNumber: 6,
      statusText: 'Assigned',
      statusColor: AppColors.statusAssignedBackground,
      statusTextColor: AppColors.statusAssignedText,
      requestText: 'Waiter call',
      assignedTo: 'Andrii',
      buttonText: 'Close table',
      onPressed: _emptyAction,
    ),
  ];

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        actions: [
          IconButton(
            onPressed: () => _openProfile(context),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Restaurant service dashboard',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage new requests and your assigned tables.',
                  style: AppTextStyles.secondary,
                ),
                const SizedBox(height: 24),
                const StatCard(
                  title: 'Free tables',
                  value: '6',
                  icon: Icons.table_restaurant_outlined,
                ),
                const SizedBox(height: 12),
                const StatCard(
                  title: 'New requests',
                  value: '2',
                  icon: Icons.notifications_active_outlined,
                ),
                const SizedBox(height: 12),
                const StatCard(
                  title: 'My tables',
                  value: '3',
                  icon: Icons.assignment_ind_outlined,
                ),
                const SizedBox(height: 28),
                const Text('New requests', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                ..._newRequests.expand(
                  (Widget card) => [card, const SizedBox(height: 12)],
                ),
                const SizedBox(height: 16),
                const Text('My tables', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                ..._myTables.expand(
                  (Widget card) => [card, const SizedBox(height: 12)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
