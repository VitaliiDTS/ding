import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/pages/home_page.dart';
import 'package:ding/pages/login_page.dart';
import 'package:ding/providers/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shown briefly on app start while the auth state is resolved.
///
/// Decision logic:
///   Online  → check FirebaseAuth.currentUser (via repository)
///             → user found  : go to HomePage
///             → no user     : go to LoginPage
///   Offline → check saved local session (via repository)
///             → session found : go to HomePage with [offlineSession] = true
///             → no session    : go to LoginPage (login unavailable)
class SplashPage extends StatefulWidget {
  final UserRepository userRepository;

  const SplashPage({required this.userRepository, super.key});

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
    // Short delay so the splash logo is visible for at least one frame.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final connectivity = context.read<ConnectivityProvider>();
    final user = await widget.userRepository.getCurrentUser();
    if (!mounted) return;

    if (user != null) {
      // Either online (Firebase user exists) or offline with saved session.
      final offlineSession = !connectivity.isOnline;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => HomePage(
            userRepository: widget.userRepository,
            offlineSession: offlineSession,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => LoginPage(userRepository: widget.userRepository),
        ),
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
