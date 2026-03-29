import 'package:ding/data/repositories/local_user_repository.dart';
import 'package:ding/data/services/shared_prefs_service.dart';
import 'package:ding/pages/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MyApp(
      repository: LocalUserRepository(
        storage: SharedPrefsService(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final LocalUserRepository repository;

  const MyApp({required this.repository, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ding',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(userRepository: repository),
    );
  }
}
