import 'package:ding/core/app_text_styles.dart';
import 'package:ding/cubits/connectivity_cubit.dart';
import 'package:ding/cubits/user_cubit.dart';
import 'package:ding/cubits/user_state.dart';
import 'package:ding/data/models/user_model.dart';
import 'package:ding/domain/validators.dart';
import 'package:ding/pages/home_page.dart';
import 'package:ding/widgets/app_password_field.dart';
import 'package:ding/widgets/app_text_field.dart';
import 'package:ding/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final isOnline = context.read<ConnectivityCubit>().state;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection. '
            'Registration requires an active network.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    context.read<UserCubit>().register(
          UserModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
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
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (_) => const HomePage()),
            (route) => false,
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
          title: const Text('Register', style: AppTextStyles.appBarTitle),
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
                    const Icon(Icons.person_add_alt_1, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Register as restaurant staff',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.secondary,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),
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
                      hintText: 'Create a password',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      labelText: 'Confirm Password',
                      hintText: 'Repeat your password',
                      prefixIcon: Icons.lock_outline,
                      controller: _confirmPasswordController,
                      validator: (value) =>
                          Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) => state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              text: 'Register',
                              onPressed: _submit,
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
