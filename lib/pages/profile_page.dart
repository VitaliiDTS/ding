import 'package:ding/core/app_colors.dart';
import 'package:ding/cubits/user_cubit.dart';
import 'package:ding/cubits/user_state.dart';
import 'package:ding/data/models/user_model.dart';
import 'package:ding/domain/validators.dart';
import 'package:ding/pages/login_page.dart';
import 'package:ding/widgets/app_password_field.dart';
import 'package:ding/widgets/app_text_field.dart';
import 'package:ding/widgets/primary_button.dart';
import 'package:ding/widgets/profile_header.dart';
import 'package:ding/widgets/profile_info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isEditing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserCubit>().state.user;
    if (user != null) _nameCtrl.text = user.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _oldPassCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit(UserModel user) => setState(() {
        _isEditing = !_isEditing;
        if (!_isEditing) {
          _nameCtrl.text = user.name;
          _oldPassCtrl.clear();
          _passCtrl.clear();
        }
      });

  void _saveChanges(UserModel user) {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    context.read<UserCubit>().updateProfile(
          user.copyWith(
            name: _nameCtrl.text.trim(),
            password:
                _passCtrl.text.isNotEmpty ? _passCtrl.text : null,
          ),
          _oldPassCtrl.text,
        );
  }

  Future<void> _confirm(
    String title,
    String body,
    VoidCallback action,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(title),
          ),
        ],
      ),
    );
    if (ok == true && mounted) action();
  }

  void _navigateToLogin() => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        (r) => false,
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listenWhen: (p, c) =>
          (p.isLoading && !c.isLoading) ||
          (!c.isAuthenticated && p.isAuthenticated) ||
          (p.errorMessage != c.errorMessage && c.errorMessage != null),
      listener: (context, state) {
        if (!state.isAuthenticated) {
          _navigateToLogin();
          return;
        }
        if (state.errorMessage != null) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (!_saving) return;
        setState(() {
          _saving = false;
          _isEditing = false;
          _passCtrl.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: state.user == null
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(state.user!),
      ),
    );
  }

  Widget _buildContent(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProfileHeader(name: user.name, role: 'Waiter'),
                const SizedBox(height: 32),
                if (_isEditing) _buildEditForm() else _buildInfoCard(user),
                const SizedBox(height: 24),
                if (_isEditing)
                  _saving
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(
                          text: 'Save changes',
                          onPressed: () => _saveChanges(user),
                        )
                else
                  PrimaryButton(
                    text: 'Edit profile',
                    onPressed: () => _toggleEdit(user),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _confirm(
                      'Log out',
                      'Are you sure you want to log out?',
                      () => context.read<UserCubit>().logout(),
                    ),
                    child: const Text('Log out'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => _confirm(
                      'Delete',
                      'Are you sure you want to delete your account? '
                          'This action cannot be undone.',
                      () => context.read<UserCubit>().deleteAccount(),
                    ),
                    child: const Text('Delete account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          ProfileInfoRow(
            icon: Icons.person_outline,
            title: 'Full name',
            value: user.name,
          ),
          const SizedBox(height: 16),
          ProfileInfoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user.email,
          ),
          const SizedBox(height: 16),
          const ProfileInfoRow(
            icon: Icons.restaurant_outlined,
            title: 'Restaurant',
            value: 'Urban Grill',
          ),
          const SizedBox(height: 16),
          const ProfileInfoRow(
            icon: Icons.access_time_outlined,
            title: 'Shift',
            value: '10:00 - 18:00',
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        AppTextField(
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icons.person_outline,
          controller: _nameCtrl,
          validator: Validators.validateName,
        ),
        const SizedBox(height: 16),
        AppPasswordField(
          labelText: 'Current Password',
          hintText: 'Required only when changing password',
          prefixIcon: Icons.lock_outline,
          controller: _oldPassCtrl,
          validator: (value) {
            if (_passCtrl.text.isEmpty) return null;
            if (value == null || value.isEmpty) {
              return 'Enter current password to change it';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppPasswordField(
          labelText: 'New Password (optional)',
          hintText: 'Leave empty to keep current',
          prefixIcon: Icons.lock_reset_outlined,
          controller: _passCtrl,
          validator: (v) =>
              (v == null || v.isEmpty) ? null : Validators.validatePassword(v),
        ),
      ],
    );
  }
}
