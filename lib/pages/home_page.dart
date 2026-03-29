import 'package:ding/core/app_colors.dart';
import 'package:ding/core/app_text_styles.dart';
import 'package:ding/data/models/user_model.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/pages/profile_page.dart';
import 'package:ding/widgets/stat_card.dart';
import 'package:ding/widgets/table_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserRepository userRepository;

  const HomePage({required this.userRepository, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await widget.userRepository.getCurrentUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ProfilePage(userRepository: widget.userRepository),
      ),
    ).then((_) => _loadUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        actions: [
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  _currentUser!.name,
                  style: AppTextStyles.secondary,
                ),
              ),
            ),
          IconButton(
            onPressed: _openProfile,
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
