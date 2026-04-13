import 'package:ding/data/models/table_model.dart';
import 'package:ding/data/models/table_notification.dart';

abstract class TableRepository {
  Future<List<TableModel>> fetchMyTables();

  Future<void> acceptTable(
    TableNotification notification,
    String assignedTo,
  );

  Future<void> closeTable(String tableId);
}
