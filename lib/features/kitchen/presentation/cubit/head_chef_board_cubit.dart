import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../chef/domain/entities/chef_member_entity.dart';
import '../../../chef/domain/usecases/get_available_chefs_usecase.dart';
import '../../../waiter/domain/entities/serve_item_entity.dart';
import '../../../waiter/domain/usecases/get_order_items_by_status_usecase.dart';
import '../../../waiter/domain/usecases/update_order_items_status_usecase.dart';

abstract class HeadChefBoardState {}

class HeadChefBoardInitial extends HeadChefBoardState {}

class HeadChefBoardLoading extends HeadChefBoardState {}

class HeadChefBoardLoaded extends HeadChefBoardState {
  final List<ServeItemEntity> pendingItems;
  final List<ServeItemEntity> confirmedItems;
  final List<ServeItemEntity> cookingItems;
  final List<ServeItemEntity> readyItems;
  final List<ChefMemberEntity> availableChefs;
  final Map<String, String> selectedAssigneesByOrderItem;
  final Set<String> processingItemIds;

  HeadChefBoardLoaded({
    required this.pendingItems,
    required this.confirmedItems,
    required this.cookingItems,
    required this.readyItems,
    required this.availableChefs,
    required this.selectedAssigneesByOrderItem,
    required this.processingItemIds,
  });

  HeadChefBoardLoaded copyWith({
    List<ServeItemEntity>? pendingItems,
    List<ServeItemEntity>? confirmedItems,
    List<ServeItemEntity>? cookingItems,
    List<ServeItemEntity>? readyItems,
    List<ChefMemberEntity>? availableChefs,
    Map<String, String>? selectedAssigneesByOrderItem,
    Set<String>? processingItemIds,
  }) {
    return HeadChefBoardLoaded(
      pendingItems: pendingItems ?? this.pendingItems,
      confirmedItems: confirmedItems ?? this.confirmedItems,
      cookingItems: cookingItems ?? this.cookingItems,
      readyItems: readyItems ?? this.readyItems,
      availableChefs: availableChefs ?? this.availableChefs,
      selectedAssigneesByOrderItem:
          selectedAssigneesByOrderItem ?? this.selectedAssigneesByOrderItem,
      processingItemIds: processingItemIds ?? this.processingItemIds,
    );
  }
}

class HeadChefBoardError extends HeadChefBoardState {
  final String message;

  HeadChefBoardError(this.message);
}

class HeadChefBoardCubit extends Cubit<HeadChefBoardState> {
  final GetOrderItemsByStatusUseCase _getOrderItemsByStatusUseCase;
  final UpdateOrderItemsStatusUseCase _updateOrderItemsStatusUseCase;
  final GetAvailableChefsUseCase _getAvailableChefsUseCase;

  static const int _pendingStatus = 0;
  static const int _confirmedStatus = 1;
  static const int _cookingStatus = 2;
  static const int _readyStatus = 3;

  HeadChefBoardCubit({
    required GetOrderItemsByStatusUseCase getOrderItemsByStatusUseCase,
    required UpdateOrderItemsStatusUseCase updateOrderItemsStatusUseCase,
    required GetAvailableChefsUseCase getAvailableChefsUseCase,
  }) : _getOrderItemsByStatusUseCase = getOrderItemsByStatusUseCase,
       _updateOrderItemsStatusUseCase = updateOrderItemsStatusUseCase,
       _getAvailableChefsUseCase = getAvailableChefsUseCase,
       super(HeadChefBoardInitial());

  Future<void> load({bool keepSelections = false}) async {
    final previousState = state;
    final previousSelection =
        keepSelections && previousState is HeadChefBoardLoaded
        ? previousState.selectedAssigneesByOrderItem
        : <String, String>{};

    emit(HeadChefBoardLoading());
    try {
      final results = await Future.wait([
        _getOrderItemsByStatusUseCase(_pendingStatus),
        _getOrderItemsByStatusUseCase(_confirmedStatus),
        _getOrderItemsByStatusUseCase(_cookingStatus),
        _getOrderItemsByStatusUseCase(_readyStatus),
        _getAvailableChefsUseCase(),
      ]);

      final pendingItems = (results[0] as List).cast<ServeItemEntity>();
      final confirmedItems = (results[1] as List).cast<ServeItemEntity>();
      final cookingItems = (results[2] as List).cast<ServeItemEntity>();
      final readyItems = (results[3] as List).cast<ServeItemEntity>();
      final availableChefs = (results[4] as List).cast<ChefMemberEntity>();

      final availableChefIds = availableChefs
          .map((chef) => chef.accountId)
          .toSet();
      final confirmedIds = confirmedItems.map((item) => item.id).toSet();
      final nextSelection = <String, String>{};
      for (final entry in previousSelection.entries) {
        if (confirmedIds.contains(entry.key) &&
            availableChefIds.contains(entry.value)) {
          nextSelection[entry.key] = entry.value;
        }
      }

      emit(
        HeadChefBoardLoaded(
          pendingItems: pendingItems,
          confirmedItems: confirmedItems,
          cookingItems: cookingItems,
          readyItems: readyItems,
          availableChefs: availableChefs,
          selectedAssigneesByOrderItem: nextSelection,
          processingItemIds: <String>{},
        ),
      );
    } on ServerFailure catch (e) {
      emit(HeadChefBoardError(e.message));
    } catch (e) {
      emit(HeadChefBoardError(e.toString()));
    }
  }

  Future<void> refresh() => load(keepSelections: true);

  void selectAssignee({
    required String orderItemId,
    required String assigneeId,
  }) {
    final current = state;
    if (current is! HeadChefBoardLoaded ||
        current.processingItemIds.contains(orderItemId)) {
      return;
    }

    final next = Map<String, String>.from(current.selectedAssigneesByOrderItem)
      ..[orderItemId] = assigneeId;
    emit(current.copyWith(selectedAssigneesByOrderItem: next));
  }

  Future<void> confirmOrderItem(String orderItemId) async {
    final current = state;
    if (current is! HeadChefBoardLoaded) return;

    if (current.processingItemIds.contains(orderItemId)) return;

    emit(
      current.copyWith(
        processingItemIds: <String>{...current.processingItemIds, orderItemId},
      ),
    );

    try {
      await _updateOrderItemsStatusUseCase(
        orderItemIds: [orderItemId],
        newStatus: _confirmedStatus,
        accountId: null,
        changeSource: '',
        assigneeId: null,
      );
      await load(keepSelections: true);
    } on ServerFailure {
      _clearProcessingState(orderItemId);
      rethrow;
    } catch (_) {
      _clearProcessingState(orderItemId);
      rethrow;
    }
  }

  Future<void> assignOrderItem(String orderItemId) async {
    final current = state;
    if (current is! HeadChefBoardLoaded) return;

    final assigneeId = current.selectedAssigneesByOrderItem[orderItemId];
    if (assigneeId == null || assigneeId.isEmpty) {
      throw StateError('Vui lòng chọn đầu bếp trước khi phân công.');
    }

    if (current.processingItemIds.contains(orderItemId)) return;

    emit(
      current.copyWith(
        processingItemIds: <String>{...current.processingItemIds, orderItemId},
      ),
    );

    try {
      await _updateOrderItemsStatusUseCase(
        orderItemIds: [orderItemId],
        newStatus: _cookingStatus,
        accountId: null,
        changeSource: '',
        assigneeId: assigneeId,
      );
      await load(keepSelections: true);
    } on ServerFailure {
      _clearProcessingState(orderItemId);
      rethrow;
    } catch (_) {
      _clearProcessingState(orderItemId);
      rethrow;
    }
  }

  void _clearProcessingState(String orderItemId) {
    final current = state;
    if (current is! HeadChefBoardLoaded) return;
    final nextProcessing = Set<String>.from(current.processingItemIds)
      ..remove(orderItemId);
    emit(current.copyWith(processingItemIds: nextProcessing));
  }
}
