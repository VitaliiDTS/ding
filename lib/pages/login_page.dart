import 'package:ding/core/app_text_styles.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/domain/validators.dart';
import 'package:ding/pages/home_page.dart';
import 'package:ding/pages/register_page.dart';
import 'package:ding/providers/connectivity_provider.dart';
import 'package:ding/widgets/app_password_field.dart';
import 'package:ding/widgets/app_text_field.dart';
import 'package:ding/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final UserRepository userRepository;

  const LoginPage({required this.userRepository, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Block login when there is no internet — Firebase cannot authenticate.
    final connectivity = context.read<ConnectivityProvider>();
    if (!connectivity.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection. '
            'Login requires an active network.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await widget.userRepository.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user == null) {
        _showError('Invalid email or password.');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => HomePage(userRepository: widget.userRepository),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.message ?? 'Login failed. Please try again.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Login failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RegisterPage(userRepository: widget.userRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final formWidth = screenWidth > 500 ? 420.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Login', style: AppTextStyles.appBarTitle),
      ),
      body: Column(
        children: [
          // Offline warning banner
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, _) {
              if (connectivity.isOnline) return const SizedBox.shrink();
              return const _OfflineBanner(
                message: 'No internet. Login is unavailable offline.',
              );
            },
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: formWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.restaurant_menu, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Ding',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pageTitle,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Staff login for restaurant service system',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.secondary,
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        AppPasswordField(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          controller: _passwordController,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          PrimaryButton(text: 'Sign In', onPressed: _submit),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _openRegister,
                          child: const Text(
                            "Don't have an account? Register",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final String message;

  const _OfflineBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.wifi_off, size: 18, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
