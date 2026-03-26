import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_detail_entity.dart';
import '../../../orders/domain/usecases/get_order_detail_usecase.dart';
import '../../domain/entities/table_detail_entity.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_table_detail_usecase.dart';
import '../../domain/usecases/update_table_status_usecase.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class TableDetailState {}

class TableDetailInitial extends TableDetailState {}

class TableDetailLoading extends TableDetailState {}

class TableDetailLoaded extends TableDetailState {
  final TableDetailEntity table;
  final bool isCreatingOrder;
  final bool isUpdatingTableStatus;

  TableDetailLoaded(
    this.table, {
    this.isCreatingOrder = false,
    this.isUpdatingTableStatus = false,
  });
}

class TableDetailError extends TableDetailState {
  final String message;
  TableDetailError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class TableDetailCubit extends Cubit<TableDetailState> {
  final GetTableDetailUseCase _getTableDetailUseCase;
  final CreateOrderUseCase _createOrderUseCase;
  final UpdateTableStatusUseCase _updateTableStatusUseCase;
  final GetOrderDetailUseCase _getOrderDetailUseCase;
  String? _lastTableId;

  TableDetailCubit({
    required GetTableDetailUseCase getTableDetailUseCase,
    required CreateOrderUseCase createOrderUseCase,
    required UpdateTableStatusUseCase updateTableStatusUseCase,
    required GetOrderDetailUseCase getOrderDetailUseCase,
  }) : _createOrderUseCase = createOrderUseCase,
       _updateTableStatusUseCase = updateTableStatusUseCase,
       _getOrderDetailUseCase = getOrderDetailUseCase,
       _getTableDetailUseCase = getTableDetailUseCase,
       super(TableDetailInitial());

  Future<TableDetailEntity> _hydrateOrderDetail(TableDetailEntity table) async {
    final orderId = table.activeOrder?.id;
    if (orderId == null || orderId.isEmpty) {
      return table;
    }

    return _hydrateOrderDetailById(table: table, orderId: orderId);
  }

  Future<TableDetailEntity> _hydrateOrderDetailById({
    required TableDetailEntity table,
    required String orderId,
  }) async {
    if (orderId.isEmpty) {
      return table;
    }

    final order = await _getOrderDetailUseCase(orderId);
    return TableDetailEntity(
      id: table.id,
      tableNumber: table.tableNumber,
      areaName: table.areaName,
      status: table.status,
      qrCode: table.qrCode,
      capacity: table.capacity,
      activeOrder: _toTableOrderSummary(order),
    );
  }

  TableOrderSummaryEntity _toTableOrderSummary(OrderDetailEntity order) {
    return TableOrderSummaryEntity(
      id: order.id,
      orderType: order.orderType,
      status: order.status,
      totalAmount: order.totalAmount,
      orderItems: order.orderItems
          .map(
            (item) => TableOrderItemSummaryEntity(
              id: item.id,
              orderId: item.orderId,
              productId: item.productId,
              productName: item.productName,
              price: item.productPrice,
              quantity: 1,
              chefAccountId: item.chefAccountId,
              chefName: item.chefName,
              waiterAccountId: item.waiterAccountId,
              waiterName: item.waiterName,
              orderChannel: item.orderChannel,
              note: item.note,
              status: item.status,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
            ),
          )
          .toList(),
    );
  }

  Future<void> loadTableDetail(String tableId) async {
    _lastTableId = tableId;
    emit(TableDetailLoading());
    try {
      final table = await _getTableDetailUseCase(tableId);
      final detail = await _hydrateOrderDetail(table);
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
      final createdOrderId = await _createOrderUseCase(
        tableId: currentTable.id,
        accountId: accountId,
        orderType: 0,
      );

      final refreshedTable = await _getTableDetailUseCase(currentTable.id);
      final fallbackOrderId = refreshedTable.activeOrder?.id ?? createdOrderId;
      final hydratedTable = fallbackOrderId.isEmpty
          ? refreshedTable
          : await _hydrateOrderDetailById(
              table: refreshedTable,
              orderId: fallbackOrderId,
            );

      emit(TableDetailLoaded(hydratedTable));
      return hydratedTable.activeOrder?.id;
    } on ServerFailure {
      emit(TableDetailLoaded(currentTable));
      rethrow;
    } catch (_) {
      emit(TableDetailLoaded(currentTable));
      rethrow;
    }
  }

  Future<void> mergeCurrentTable() async {
    final currentState = state;
    if (currentState is! TableDetailLoaded) return;

    final currentTable = currentState.table;
    if (!currentTable.isAvailable || currentTable.hasActiveOrder) {
      return;
    }

    emit(TableDetailLoaded(currentTable, isUpdatingTableStatus: true));

    try {
      await _updateTableStatusUseCase(tableId: currentTable.id, status: 2);
      final refreshedTable = await _getTableDetailUseCase(currentTable.id);
      final hydratedTable = await _hydrateOrderDetail(refreshedTable);
      emit(TableDetailLoaded(hydratedTable));
    } on ServerFailure {
      emit(TableDetailLoaded(currentTable));
      rethrow;
    } catch (_) {
      emit(TableDetailLoaded(currentTable));
      rethrow;
    }
  }

  Future<void> unmergeCurrentTable() async {
    final currentState = state;
    if (currentState is! TableDetailLoaded) return;

    final currentTable = currentState.table;
    if (!currentTable.isMergedWithoutOrder) {
      return;
    }

    emit(TableDetailLoaded(currentTable, isUpdatingTableStatus: true));

    try {
      await _updateTableStatusUseCase(tableId: currentTable.id, status: 0);
      final refreshedTable = await _getTableDetailUseCase(currentTable.id);
      final hydratedTable = await _hydrateOrderDetail(refreshedTable);
      emit(TableDetailLoaded(hydratedTable));
    } on ServerFailure {
      emit(TableDetailLoaded(currentTable));
      rethrow;
    } catch (_) {
      emit(TableDetailLoaded(currentTable));
      rethrow;
    }
  }
}
