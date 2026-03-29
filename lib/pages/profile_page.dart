import 'package:ding/core/app_colors.dart';
import 'package:ding/widgets/profile_header.dart';
import 'package:ding/widgets/profile_info_row.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logOut(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const ProfileHeader(
                  name: 'Andrii Melnyk',
                  role: 'Waiter',
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: const Column(
                    children: [
                      ProfileInfoRow(
                        icon: Icons.restaurant_outlined,
                        title: 'Restaurant',
                        value: 'Urban Grill',
                      ),
                      SizedBox(height: 16),
                      ProfileInfoRow(
                        icon: Icons.access_time_outlined,
                        title: 'Shift',
                        value: '10:00 - 18:00',
                      ),
                      SizedBox(height: 16),
                      ProfileInfoRow(
                        icon: Icons.work_outline,
                        title: 'Work status',
                        value: 'On shift',
                      ),
                      SizedBox(height: 16),
                      ProfileInfoRow(
                        icon: Icons.table_restaurant_outlined,
                        title: 'Assigned tables',
                        value: '3',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Edit profile'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logOut(context),
                    child: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
