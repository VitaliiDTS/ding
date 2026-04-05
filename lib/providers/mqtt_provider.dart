import 'package:ding/data/models/table_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttState { disconnected, connecting, connected, error }

/// Connects to a public MQTT broker over plain TCP and listens for
/// incoming table requests on [topic].
///
/// Publish JSON to that topic to trigger a live update:
///   {"table": 3, "type": "Waiter call"}
class MqttProvider extends ChangeNotifier {
  static const _broker = 'broker.hivemq.com';
  static const _port = 1883;
  static const topic = 'restaurant/table/requests';
  static const _maxNotifications = 20;

  MqttServerClient? _client;
  MqttState _state = MqttState.disconnected;
  String? _errorMessage;
  final List<TableNotification> _notifications = [];

  MqttState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _state == MqttState.connected;
  List<TableNotification> get notifications =>
      List.unmodifiable(_notifications);

  Future<void> connect() async {
    if (_state == MqttState.connecting || _state == MqttState.connected) {
      return;
    }

    // Always start clean.
    try {
      _client?.disconnect();
    } catch (_) {}
    _client = null;

    _state = MqttState.connecting;
    _errorMessage = null;
    notifyListeners();

    final clientId = 'ding_${DateTime.now().millisecondsSinceEpoch}';
    final client = MqttServerClient.withPort(_broker, clientId, _port);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 10000; // 10 s
    client.onDisconnected = _onDisconnected;
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();

    _client = client;

    try {
      await client.connect();
    } catch (e) {
      _state = MqttState.error;
      _errorMessage = e.toString();
      try {
        client.disconnect();
      } catch (_) {}
      _client = null;
      notifyListeners();
      return;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      _state = MqttState.connected;
      notifyListeners();
      _subscribe();
    } else {
      _state = MqttState.error;
      _errorMessage =
          'Refused by broker (${client.connectionStatus?.returnCode})';
      notifyListeners();
    }
  }

  void _subscribe() {
    _client!.subscribe(topic, MqttQos.atMostOnce);
    _client!.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage>> events) {
        for (final event in events) {
          final msg = event.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            msg.payload.message,
          );
          final notification = TableNotification.tryParse(payload);
          if (notification != null) {
            // Remove existing entry for the same table (if any) to avoid
            // duplicates — the updated request bubbles to the top instead.
            _notifications.removeWhere(
              (n) => n.tableNumber == notification.tableNumber,
            );
            _notifications.insert(0, notification);
            if (_notifications.length > _maxNotifications) {
              _notifications.removeLast();
            }
            notifyListeners();
          }
        }
      },
    );
  }

  void _onDisconnected() {
    if (_state == MqttState.connected) {
      _state = MqttState.disconnected;
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void disconnect() {
    try {
      _client?.disconnect();
    } catch (_) {}
    _client = null;
    _state = MqttState.disconnected;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
