import 'package:ding/data/models/table_notification.dart';

enum MqttStatus { disconnected, connecting, connected, error }

class MqttState {
  const MqttState({
    this.status = MqttStatus.disconnected,
    this.notifications = const [],
    this.errorMessage,
  });

  final MqttStatus status;
  final List<TableNotification> notifications;
  final String? errorMessage;

  bool get isConnected => status == MqttStatus.connected;

  MqttState copyWith({
    MqttStatus? status,
    List<TableNotification>? notifications,
    String? errorMessage,
  }) =>
      MqttState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
