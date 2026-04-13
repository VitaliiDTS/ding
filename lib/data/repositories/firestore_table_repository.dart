import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ding/data/models/table_model.dart';
import 'package:ding/data/models/table_notification.dart';
import 'package:ding/data/repositories/table_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreTableRepository implements TableRepository {
  FirestoreTableRepository(this._prefs);

  static const _collection = 'tables';
  static const _cacheKey = 'cached_tables';

  final SharedPreferences _prefs;

  String get _userEmail =>
      FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  Future<List<TableModel>> fetchMyTables() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('assignedTo', isEqualTo: _userEmail)
          .get();
      final tables = snapshot.docs
          .map(TableModel.fromFirestore)
          .toList();
      await _prefs.setString(
        _cacheKey,
        TableModel.listToJson(tables),
      );
      return tables;
    } catch (_) {
      return _loadFromCache();
    }
  }

  @override
  Future<void> acceptTable(
    TableNotification notification,
    String assignedTo,
  ) async {
    await FirebaseFirestore.instance.collection(_collection).add({
      'tableNumber': notification.tableNumber,
      'status': notification.requestType,
      'requestText': notification.requestType,
      'assignedTo': _userEmail,
      'assignedToName': assignedTo,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> closeTable(String tableId) async {
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(tableId)
        .delete();
  }

  List<TableModel> _loadFromCache() {
    final cached = _prefs.getString(_cacheKey);
    if (cached == null) return [];
    return TableModel.listFromJson(cached);
  }
}
