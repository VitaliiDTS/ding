import 'dart:convert';

class TableNotification {
  final int tableNumber;
  final String requestType;
  final DateTime receivedAt;

  const TableNotification({
    required this.tableNumber,
    required this.requestType,
    required this.receivedAt,
  });

  /// Parses a JSON string like {"table": 3, "type": "Waiter call"}.
  /// Returns null if the payload is invalid.
  static TableNotification? tryParse(String payload) {
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final table = json['table'];
      final type = json['type'] as String? ?? 'Request';
      if (table == null) return null;
      return TableNotification(
        tableNumber: (table as num).toInt(),
        requestType: type,
        receivedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}
