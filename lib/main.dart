import 'package:ding/cubits/connectivity_cubit.dart';
import 'package:ding/cubits/mqtt_cubit.dart';
import 'package:ding/cubits/tables_cubit.dart';
import 'package:ding/cubits/user_cubit.dart';
import 'package:ding/data/repositories/firebase_user_repository.dart';
import 'package:ding/data/repositories/firestore_table_repository.dart';
import 'package:ding/data/repositories/table_repository.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/data/services/session_storage_service.dart';
import 'package:ding/firebase_options.dart';
import 'package:ding/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  final sessionStorage = SessionStorageService();
  final prefs = await SharedPreferences.getInstance();

  final connectivityCubit = ConnectivityCubit();
  await connectivityCubit.initialize();

  final userRepository = FirebaseUserRepository(
    sessionStorage: sessionStorage,
  );
  final tableRepository = FirestoreTableRepository(prefs);
  final mqttCubit = MqttCubit();
  final userCubit = UserCubit(userRepository);
  final tablesCubit = TablesCubit(
    tableRepository: tableRepository,
    mqttCubit: mqttCubit,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: connectivityCubit),
        BlocProvider.value(value: mqttCubit),
        BlocProvider.value(value: userCubit),
        BlocProvider.value(value: tablesCubit),
        // UserRepository kept for SplashPage auto-login (lab exception)
        Provider<UserRepository>.value(value: userRepository),
        Provider<TableRepository>.value(value: tableRepository),
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
