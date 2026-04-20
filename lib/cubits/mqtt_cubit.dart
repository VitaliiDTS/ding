import 'package:ding/cubits/mqtt_state.dart';
import 'package:ding/data/models/table_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttCubit extends Cubit<MqttState> {
  MqttCubit() : super(const MqttState());

  static const _broker = 'broker.hivemq.com';
  static const _port = 1883;
  static const topic = 'restaurant/table/requests';
  static const _maxNotifications = 20;

  MqttServerClient? _client;

  Future<void> connect() async {
    if (state.status == MqttStatus.connecting || state.isConnected) return;
    try {
      _client?.disconnect();
    } catch (_) {}
    _client = null;
    emit(state.copyWith(status: MqttStatus.connecting));

    final clientId = 'ding_${DateTime.now().millisecondsSinceEpoch}';
    final client = MqttServerClient.withPort(_broker, clientId, _port);
    client
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..connectTimeoutPeriod = 10000
      ..onDisconnected = _onDisconnected
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean();
    _client = client;

    try {
      await client.connect();
    } catch (e) {
      try {
        client.disconnect();
      } catch (_) {}
      _client = null;
      emit(state.copyWith(status: MqttStatus.error, errorMessage: '$e'));
      return;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      emit(state.copyWith(status: MqttStatus.connected));
      _subscribe();
    } else {
      emit(
        state.copyWith(
          status: MqttStatus.error,
          errorMessage:
              'Refused (${client.connectionStatus?.returnCode})',
        ),
      );
    }
  }

  void _subscribe() {
    _client!.subscribe(topic, MqttQos.atMostOnce);
    _client!.updates?.listen((events) {
      for (final event in events) {
        final msg = event.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          msg.payload.message,
        );
        final n = TableNotification.tryParse(payload);
        if (n == null) continue;
        final updated = [...state.notifications]
          ..removeWhere((x) => x.tableNumber == n.tableNumber);
        updated.insert(0, n);
        if (updated.length > _maxNotifications) updated.removeLast();
        emit(state.copyWith(notifications: updated));
      }
    });
  }

  void _onDisconnected() {
    if (state.isConnected) {
      emit(state.copyWith(status: MqttStatus.disconnected));
    }
  }

  void removeNotification(TableNotification n) {
    emit(
      state.copyWith(
        notifications: state.notifications
            .where(
              (x) =>
                  x.tableNumber != n.tableNumber ||
                  x.receivedAt != n.receivedAt,
            )
            .toList(),
      ),
    );
  }

  void clearNotifications() {
    emit(state.copyWith(notifications: []));
  }

  void disconnect() {
    try {
      _client?.disconnect();
    } catch (_) {}
    _client = null;
    emit(state.copyWith(status: MqttStatus.disconnected));
  }

  @override
  Future<void> close() {
    disconnect();
    return super.close();
  }
}
