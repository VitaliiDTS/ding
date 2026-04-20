import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class TableModel {
  const TableModel({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.requestText,
    required this.assignedTo,
  });

  factory TableModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return TableModel(
      id: doc.id,
      tableNumber: data['tableNumber'] as int,
      status: data['status'] as String,
      requestText: data['requestText'] as String,
      assignedTo: data['assignedToName'] as String? ?? '',
    );
  }

  factory TableModel.fromJson(Map<String, dynamic> json) => TableModel(
        id: json['id'] as String,
        tableNumber: json['tableNumber'] as int,
        status: json['status'] as String,
        requestText: json['requestText'] as String,
        assignedTo: json['assignedTo'] as String,
      );

  final String id;
  final int tableNumber;
  final String status;
  final String requestText;
  final String assignedTo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tableNumber': tableNumber,
        'status': status,
        'requestText': requestText,
        'assignedTo': assignedTo,
      };

  static List<TableModel> listFromJson(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list
        .map((e) => TableModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<TableModel> tables) =>
      jsonEncode(tables.map((t) => t.toJson()).toList());
}
