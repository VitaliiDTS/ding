import 'package:ding/core/app_colors.dart';
import 'package:ding/data/models/user_model.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/domain/validators.dart';
import 'package:ding/pages/login_page.dart';
import 'package:ding/widgets/app_password_field.dart';
import 'package:ding/widgets/app_text_field.dart';
import 'package:ding/widgets/primary_button.dart';
import 'package:ding/widgets/profile_header.dart';
import 'package:ding/widgets/profile_info_row.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final UserRepository userRepository;

  const ProfilePage({required this.userRepository, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();

  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await widget.userRepository.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _isLoading = false;
      if (user != null) {
        _nameController.text = user.name;
      }
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing && _user != null) {
        _nameController.text = _user!.name;
        _oldPasswordController.clear();
        _passwordController.clear();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // If the user wants to change the password, re-authenticate first.
    if (_passwordController.text.isNotEmpty) {
      final email = _user!.email;
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _oldPasswordController.text,
      );
      try {
        await FirebaseAuth.instance.currentUser
            ?.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        _showError(e.message ?? 'Current password is incorrect.');
        return;
      }
    }

    final updated = _user!.copyWith(
      name: _nameController.text.trim(),
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text
          : null,
    );

    try {
      await widget.userRepository.updateUser(updated);
      if (!mounted) return;
      setState(() {
        _user = updated;
        _isEditing = false;
        _isSaving = false;
        _passwordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError(e.message ?? 'Failed to update profile.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError('Failed to update profile: $e');
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.userRepository.deleteUser();
      if (!mounted) return;
      _navigateToLogin();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(e.message ?? 'Failed to delete account.');
    }
  }

  Future<void> _logOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await widget.userRepository.logout();
    if (!mounted) return;
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(userRepository: widget.userRepository),
      ),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('User not found'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProfileHeader(name: _user!.name, role: 'Waiter'),
                const SizedBox(height: 32),
                if (_isEditing) _buildEditForm() else _buildInfoCard(),
                const SizedBox(height: 24),
                if (_isEditing)
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(
                          text: 'Save changes',
                          onPressed: _saveChanges,
                        )
                else
                  PrimaryButton(
                    text: 'Edit profile',
                    onPressed: _toggleEdit,
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _logOut,
                    child: const Text('Log out'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _deleteAccount,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
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

  Widget _buildInfoCard() {
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
            value: _user!.name,
          ),
          const SizedBox(height: 16),
          ProfileInfoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: _user!.email,
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
          controller: _nameController,
          validator: Validators.validateName,
        ),
        const SizedBox(height: 16),
        AppPasswordField(
          labelText: 'Current Password',
          hintText: 'Required only when changing password',
          prefixIcon: Icons.lock_outline,
          controller: _oldPasswordController,
          validator: (value) {
            if (_passwordController.text.isEmpty) return null;
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
          controller: _passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            return Validators.validatePassword(value);
          },
        ),
      ],
    );
  }
}
