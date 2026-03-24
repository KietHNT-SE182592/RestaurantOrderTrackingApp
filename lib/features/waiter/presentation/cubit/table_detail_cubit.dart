import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/table_detail_entity.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_table_detail_usecase.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class TableDetailState {}

class TableDetailInitial extends TableDetailState {}

class TableDetailLoading extends TableDetailState {}

class TableDetailLoaded extends TableDetailState {
  final TableDetailEntity table;
  final bool isCreatingOrder;

  TableDetailLoaded(this.table, {this.isCreatingOrder = false});
}

class TableDetailError extends TableDetailState {
  final String message;
  TableDetailError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class TableDetailCubit extends Cubit<TableDetailState> {
  final GetTableDetailUseCase _getTableDetailUseCase;
  final CreateOrderUseCase _createOrderUseCase;
  String? _lastTableId;

  TableDetailCubit({
    required GetTableDetailUseCase getTableDetailUseCase,
    required CreateOrderUseCase createOrderUseCase,
  }) : _createOrderUseCase = createOrderUseCase,
       _getTableDetailUseCase = getTableDetailUseCase,
       super(TableDetailInitial());

  Future<void> loadTableDetail(String tableId) async {
    _lastTableId = tableId;
    emit(TableDetailLoading());
    try {
      final detail = await _getTableDetailUseCase(tableId);
      emit(TableDetailLoaded(detail));
    } on ServerFailure catch (e) {
      emit(TableDetailError(e.message));
    } catch (e) {
      emit(TableDetailError(e.toString()));
    }
  }

  Future<void> retry() async {
    if (_lastTableId != null) {
      await loadTableDetail(_lastTableId!);
    }
  }

  Future<String?> createOrderForCurrentTable({
    required String accountId,
  }) async {
    final currentState = state;
    if (currentState is! TableDetailLoaded) return null;

    final currentTable = currentState.table;
    if (!currentTable.isAvailable || currentTable.hasActiveOrder) {
      return currentTable.activeOrder?.id;
    }

    emit(TableDetailLoaded(currentTable, isCreatingOrder: true));
    try {
      await _createOrderUseCase(
        tableId: currentTable.id,
        accountId: accountId,
        orderType: 0,
      );

      final refreshedTable = await _getTableDetailUseCase(currentTable.id);
      emit(TableDetailLoaded(refreshedTable));
      return refreshedTable.activeOrder?.id;
    } on ServerFailure {
      emit(TableDetailLoaded(currentTable));
      rethrow;
    } catch (_) {
      emit(TableDetailLoaded(currentTable));
      rethrow;
    }
  }
}
