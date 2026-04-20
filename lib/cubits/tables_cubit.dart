import 'package:ding/cubits/mqtt_cubit.dart';
import 'package:ding/cubits/tables_state.dart';
import 'package:ding/data/models/table_notification.dart';
import 'package:ding/data/repositories/table_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TablesCubit extends Cubit<TablesState> {
  TablesCubit({
    required TableRepository tableRepository,
    required MqttCubit mqttCubit,
  })  : _repo = tableRepository,
        _mqtt = mqttCubit,
        super(const TablesState());

  final TableRepository _repo;
  final MqttCubit _mqtt;

  Future<void> fetchMyTables() async {
    emit(state.copyWith(isLoading: true));
    final tables = await _repo.fetchMyTables();
    emit(state.copyWith(tables: tables, isLoading: false));
  }

  Future<void> acceptTable(TableNotification n, String assignedTo) async {
    try {
      await _repo.acceptTable(n, assignedTo);
      _mqtt.removeNotification(n);
      await fetchMyTables();
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to accept. Check connection.',
        ),
      );
    }
  }

  Future<void> closeTable(String tableId) async {
    try {
      await _repo.closeTable(tableId);
      await fetchMyTables();
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to close table. Check connection.',
        ),
      );
    }
  }
}
