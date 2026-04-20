import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit() : super(true);

  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<void> initialize() async {
    final results = await Connectivity().checkConnectivity();
    emit(_hasConnection(results));
    _sub = Connectivity().onConnectivityChanged.listen(
      (results) => emit(_hasConnection(results)),
    );
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
