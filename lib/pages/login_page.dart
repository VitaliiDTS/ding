import 'package:ding/core/app_text_styles.dart';
import 'package:ding/pages/home_page.dart';
import 'package:ding/pages/register_page.dart';
import 'package:ding/widgets/app_password_field.dart';
import 'package:ding/widgets/app_text_field.dart';
import 'package:ding/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _emailController.clear();
      _passwordController.clear();
      _formKey.currentState!.reset();
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const RegisterPage(),
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
      body: Center(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppPasswordField(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
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
    );
  }
}
