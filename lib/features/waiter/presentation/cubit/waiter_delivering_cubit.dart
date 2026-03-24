import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/serve_item_entity.dart';
import '../../domain/usecases/get_areas_usecase.dart';
import '../../domain/usecases/get_order_items_by_status_usecase.dart';
import '../../domain/usecases/update_order_items_status_usecase.dart';

abstract class WaiterDeliveringState {}

class WaiterDeliveringInitial extends WaiterDeliveringState {}

class WaiterDeliveringLoading extends WaiterDeliveringState {}

class WaiterDeliveringLoaded extends WaiterDeliveringState {
  final List<AreaEntity> areas;
  final List<ServeItemEntity> items;
  final String selectedAreaId;
  final Set<String> selectedItemIds;
  final bool isSubmitting;

  WaiterDeliveringLoaded({
    required this.areas,
    required this.items,
    required this.selectedAreaId,
    required this.selectedItemIds,
    required this.isSubmitting,
  });

  List<ServeItemEntity> get filteredItems {
    if (selectedAreaId.isEmpty) return items;
    return items.where((item) => item.areaId == selectedAreaId).toList();
  }

  Map<String, List<ServeItemEntity>> get groupedByTable {
    final grouped = <String, List<ServeItemEntity>>{};
    for (final item in filteredItems) {
      grouped.putIfAbsent(item.tableId, () => <ServeItemEntity>[]).add(item);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final aTable = a.value.first.tableNumber;
        final bTable = b.value.first.tableNumber;
        return aTable.compareTo(bTable);
      });

    return {for (final entry in sortedEntries) entry.key: entry.value};
  }

  int get totalDeliveringItems => filteredItems.length;

  int get selectedCount => selectedItemIds.length;

  Set<String> get filteredItemIds =>
      filteredItems.map((item) => item.id).toSet();

  int get selectedInFilterCount =>
      filteredItemIds.intersection(selectedItemIds).length;

  bool get isAllFilteredSelected =>
      filteredItems.isNotEmpty && selectedInFilterCount == filteredItems.length;

  bool get canMarkServed => selectedItemIds.isNotEmpty && !isSubmitting;

  WaiterDeliveringLoaded copyWith({
    List<AreaEntity>? areas,
    List<ServeItemEntity>? items,
    String? selectedAreaId,
    Set<String>? selectedItemIds,
    bool? isSubmitting,
  }) {
    return WaiterDeliveringLoaded(
      areas: areas ?? this.areas,
      items: items ?? this.items,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class WaiterDeliveringError extends WaiterDeliveringState {
  final String message;

  WaiterDeliveringError(this.message);
}

class WaiterDeliveringCubit extends Cubit<WaiterDeliveringState> {
  final GetAreasUseCase _getAreasUseCase;
  final GetOrderItemsByStatusUseCase _getOrderItemsByStatusUseCase;
  final UpdateOrderItemsStatusUseCase _updateOrderItemsStatusUseCase;

  static const int _deliveringStatusCode = 4;
  static const int _servedStatusCode = 5;

  WaiterDeliveringCubit({
    required GetAreasUseCase getAreasUseCase,
    required GetOrderItemsByStatusUseCase getOrderItemsByStatusUseCase,
    required UpdateOrderItemsStatusUseCase updateOrderItemsStatusUseCase,
  }) : _getAreasUseCase = getAreasUseCase,
       _getOrderItemsByStatusUseCase = getOrderItemsByStatusUseCase,
       _updateOrderItemsStatusUseCase = updateOrderItemsStatusUseCase,
       super(WaiterDeliveringInitial());

  Future<void> load({bool keepSelectedArea = false}) async {
    final previousState = state;
    final previousSelectedArea =
        keepSelectedArea && previousState is WaiterDeliveringLoaded
        ? previousState.selectedAreaId
        : '';
    final previousSelectedItems =
        keepSelectedArea && previousState is WaiterDeliveringLoaded
        ? previousState.selectedItemIds
        : <String>{};

    emit(WaiterDeliveringLoading());
    try {
      final results = await Future.wait([
        _getAreasUseCase(),
        _getOrderItemsByStatusUseCase(_deliveringStatusCode),
      ]);

      final areas = (results[0] as List).cast<AreaEntity>().toList();
      final items = (results[1] as List).cast<ServeItemEntity>().toList();
      final latestIds = items.map((item) => item.id).toSet();
      final selectedItems = keepSelectedArea
          ? previousSelectedItems.where(latestIds.contains).toSet()
          : latestIds;

      final hasSelectedArea = areas.any((a) => a.id == previousSelectedArea);

      emit(
        WaiterDeliveringLoaded(
          areas: areas,
          items: items,
          selectedAreaId: hasSelectedArea ? previousSelectedArea : '',
          selectedItemIds: selectedItems,
          isSubmitting: false,
        ),
      );
    } on ServerFailure catch (e) {
      emit(WaiterDeliveringError(e.message));
    } catch (e) {
      emit(WaiterDeliveringError(e.toString()));
    }
  }

  Future<void> refresh() => load(keepSelectedArea: true);

  void selectArea(String areaId) {
    final current = state;
    if (current is! WaiterDeliveringLoaded) return;
    emit(current.copyWith(selectedAreaId: areaId));
  }

  void toggleItemSelection(String itemId) {
    final current = state;
    if (current is! WaiterDeliveringLoaded || current.isSubmitting) return;

    final selectedIds = current.selectedItemIds.toSet();
    if (!selectedIds.add(itemId)) {
      selectedIds.remove(itemId);
    }

    emit(current.copyWith(selectedItemIds: selectedIds));
  }

  void toggleSelectAllForFilteredItems(bool selected) {
    final current = state;
    if (current is! WaiterDeliveringLoaded || current.isSubmitting) return;

    final filteredIds = current.filteredItemIds;
    if (filteredIds.isEmpty) return;

    final selectedIds = current.selectedItemIds.toSet();
    if (selected) {
      selectedIds.addAll(filteredIds);
    } else {
      selectedIds.removeAll(filteredIds);
    }

    emit(current.copyWith(selectedItemIds: selectedIds));
  }

  void clearSelection() {
    final current = state;
    if (current is! WaiterDeliveringLoaded || current.selectedItemIds.isEmpty) {
      return;
    }

    emit(current.copyWith(selectedItemIds: <String>{}));
  }

  Future<void> markSelectedAsServed({required String accountId}) async {
    final current = state;
    if (current is! WaiterDeliveringLoaded || !current.canMarkServed) {
      return;
    }

    emit(current.copyWith(isSubmitting: true));

    try {
      final selectedItems = current.items
          .where((item) => current.selectedItemIds.contains(item.id))
          .toList();

      final groupedByChef = <String?, List<String>>{};
      for (final item in selectedItems) {
        groupedByChef
            .putIfAbsent(item.chefAccountId, () => <String>[])
            .add(item.id);
      }

      for (final entry in groupedByChef.entries) {
        await _updateOrderItemsStatusUseCase(
          orderItemIds: entry.value,
          newStatus: _servedStatusCode,
          accountId: accountId,
          changeSource: 'manual',
          assigneeId: entry.key,
        );
      }

      final latestItems = await _getOrderItemsByStatusUseCase(
        _deliveringStatusCode,
      );

      emit(
        current.copyWith(
          items: latestItems,
          selectedItemIds: <String>{},
          isSubmitting: false,
        ),
      );
    } on ServerFailure {
      emit(current.copyWith(isSubmitting: false));
      rethrow;
    } catch (_) {
      emit(current.copyWith(isSubmitting: false));
      rethrow;
    }
  }
}
