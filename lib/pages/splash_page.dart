import 'package:ding/cubits/connectivity_cubit.dart';
import 'package:ding/cubits/mqtt_cubit.dart';
import 'package:ding/cubits/tables_cubit.dart';
import 'package:ding/cubits/user_cubit.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/pages/home_page.dart';
import 'package:ding/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shown briefly on app start while the auth state is resolved.
///
/// Decision logic:
///   Online  → check FirebaseAuth.currentUser (via repository)
///             → user found  : go to HomePage
///             → no user     : go to LoginPage
///   Offline → check saved local session (via repository)
///             → session found : go to HomePage
///             → no session    : go to LoginPage (login unavailable)
class SplashPage extends StatefulWidget {
  const SplashPage({required this.userRepository, super.key});

  final UserRepository userRepository;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final user = await widget.userRepository.getCurrentUser();
    if (!mounted) return;

    if (user != null) {
      final isOnline = context.read<ConnectivityCubit>().state;
      context.read<UserCubit>().setUser(user);
      if (isOnline) {
        context.read<TablesCubit>().fetchMyTables();
        context.read<MqttCubit>().connect();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
