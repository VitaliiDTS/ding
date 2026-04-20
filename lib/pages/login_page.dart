import 'package:ding/core/app_text_styles.dart';
import 'package:ding/cubits/connectivity_cubit.dart';
import 'package:ding/cubits/user_cubit.dart';
import 'package:ding/cubits/user_state.dart';
import 'package:ding/domain/validators.dart';
import 'package:ding/pages/home_page.dart';
import 'package:ding/pages/register_page.dart';
import 'package:ding/widgets/app_password_field.dart';
import 'package:ding/widgets/app_text_field.dart';
import 'package:ding/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    if (!_formKey.currentState!.validate()) return;
    final isOnline = context.read<ConnectivityCubit>().state;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection. Login requires an active network.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    context.read<UserCubit>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formWidth =
        MediaQuery.sizeOf(context).width > 500 ? 420.0 : double.infinity;

    return BlocListener<UserCubit, UserState>(
      listenWhen: (p, c) => !c.isLoading && p.isLoading,
      listener: (context, state) {
        if (state.isAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(builder: (_) => const HomePage()),
          );
          return;
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('Login', style: AppTextStyles.appBarTitle),
        ),
        body: Column(
          children: [
            BlocBuilder<ConnectivityCubit, bool>(
              builder: (context, isOnline) {
                if (isOnline) return const SizedBox.shrink();
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
                          BlocBuilder<UserCubit, UserState>(
                            builder: (context, state) => state.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : PrimaryButton(
                                    text: 'Sign In',
                                    onPressed: _submit,
                                  ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const RegisterPage(),
                              ),
                            ),
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
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.message});

  final String message;

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
