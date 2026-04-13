import 'package:ding/data/repositories/firebase_user_repository.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/data/services/session_storage_service.dart';
import 'package:ding/firebase_options.dart';
import 'package:ding/pages/splash_page.dart';
import 'package:ding/providers/connectivity_provider.dart';
import 'package:ding/providers/mqtt_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialisation.
  // If firebase_options.dart has not been generated yet (see the TODO inside
  // that file), this will throw and the app falls back to local-only mode.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase not configured — registration and online login are unavailable.
    // Offline session access still works.
    debugPrint('Firebase init skipped: $e');
  }

  final sessionStorage = SessionStorageService();

  // Resolve connectivity BEFORE runApp so SplashPage has the correct state
  // on the very first frame.
  final connectivityProvider = ConnectivityProvider();
  await connectivityProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: connectivityProvider),
        ChangeNotifierProvider<MqttProvider>(
          create: (_) => MqttProvider(),
        ),
        Provider<SessionStorageService>.value(value: sessionStorage),
        Provider<UserRepository>(
          create: (_) => FirebaseUserRepository(
            sessionStorage: sessionStorage,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<UserRepository>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ding',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SplashPage(userRepository: repository),
    );
  }
}
