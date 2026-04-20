import 'package:ding/data/models/table_model.dart';

class TablesState {
  const TablesState({
    this.tables = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<TableModel> tables;
  final bool isLoading;
  final String? errorMessage;

  TablesState copyWith({
    List<TableModel>? tables,
    bool? isLoading,
    String? errorMessage,
  }) =>
      TablesState(
        tables: tables ?? this.tables,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}
