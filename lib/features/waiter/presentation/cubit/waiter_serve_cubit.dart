import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/serve_item_entity.dart';
import '../../domain/usecases/get_areas_usecase.dart';
import '../../domain/usecases/get_order_items_by_status_usecase.dart';
import '../../domain/usecases/update_order_items_status_usecase.dart';

abstract class WaiterServeState {}

class WaiterServeInitial extends WaiterServeState {}

class WaiterServeLoading extends WaiterServeState {}

class WaiterServeLoaded extends WaiterServeState {
  final List<AreaEntity> areas;
  final List<ServeItemEntity> items;
  final String selectedAreaId;
  final Set<String> selectedItemIds;
  final bool isSubmitting;

  WaiterServeLoaded({
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

  int get totalReadyItems => filteredItems.length;

  int get selectedCount => selectedItemIds.length;

  bool get canDeliverSelected => selectedItemIds.isNotEmpty && !isSubmitting;

  WaiterServeLoaded copyWith({
    List<AreaEntity>? areas,
    List<ServeItemEntity>? items,
    String? selectedAreaId,
    Set<String>? selectedItemIds,
    bool? isSubmitting,
  }) {
    return WaiterServeLoaded(
      areas: areas ?? this.areas,
      items: items ?? this.items,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class WaiterServeError extends WaiterServeState {
  final String message;
  WaiterServeError(this.message);
}

class WaiterServeCubit extends Cubit<WaiterServeState> {
  final GetAreasUseCase _getAreasUseCase;
  final GetOrderItemsByStatusUseCase _getOrderItemsByStatusUseCase;
  final UpdateOrderItemsStatusUseCase _updateOrderItemsStatusUseCase;

  static const int _readyStatusCode = 3;
  static const int _deliveringStatusCode = 4;

  WaiterServeCubit({
    required GetAreasUseCase getAreasUseCase,
    required GetOrderItemsByStatusUseCase getOrderItemsByStatusUseCase,
    required UpdateOrderItemsStatusUseCase updateOrderItemsStatusUseCase,
  }) : _getAreasUseCase = getAreasUseCase,
       _getOrderItemsByStatusUseCase = getOrderItemsByStatusUseCase,
       _updateOrderItemsStatusUseCase = updateOrderItemsStatusUseCase,
       super(WaiterServeInitial());

  Future<void> load({bool keepSelectedArea = false}) async {
    final previousState = state;
    final previousSelectedArea =
        keepSelectedArea && previousState is WaiterServeLoaded
        ? previousState.selectedAreaId
        : '';
    final previousSelectedItems =
        keepSelectedArea && previousState is WaiterServeLoaded
        ? previousState.selectedItemIds
        : <String>{};

    emit(WaiterServeLoading());
    try {
      final results = await Future.wait([
        _getAreasUseCase(),
        _getOrderItemsByStatusUseCase(_readyStatusCode),
      ]);

      final areas = (results[0] as List).cast<AreaEntity>().toList();
      final items = (results[1] as List).cast<ServeItemEntity>().toList();
      final latestIds = items.map((item) => item.id).toSet();
      final selectedItems = previousSelectedItems
          .where(latestIds.contains)
          .toSet();

      final hasSelectedArea = areas.any((a) => a.id == previousSelectedArea);

      emit(
        WaiterServeLoaded(
          areas: areas,
          items: items,
          selectedAreaId: hasSelectedArea ? previousSelectedArea : '',
          selectedItemIds: selectedItems,
          isSubmitting: false,
        ),
      );
    } on ServerFailure catch (e) {
      emit(WaiterServeError(e.message));
    } catch (e) {
      emit(WaiterServeError(e.toString()));
    }
  }

  Future<void> refresh() => load(keepSelectedArea: true);

  void selectArea(String areaId) {
    final current = state;
    if (current is! WaiterServeLoaded) return;
    emit(current.copyWith(selectedAreaId: areaId));
  }

  void toggleItemSelection(String itemId) {
    final current = state;
    if (current is! WaiterServeLoaded || current.isSubmitting) return;

    final selectedIds = current.selectedItemIds.toSet();
    if (!selectedIds.add(itemId)) {
      selectedIds.remove(itemId);
    }

    emit(current.copyWith(selectedItemIds: selectedIds));
  }

  void clearSelection() {
    final current = state;
    if (current is! WaiterServeLoaded || current.selectedItemIds.isEmpty) {
      return;
    }

    emit(current.copyWith(selectedItemIds: <String>{}));
  }

  Future<void> deliverSelectedItems({required String accountId}) async {
    final current = state;
    if (current is! WaiterServeLoaded || !current.canDeliverSelected) {
      return;
    }

    emit(current.copyWith(isSubmitting: true));

    try {
      await _updateOrderItemsStatusUseCase(
        orderItemIds: current.selectedItemIds.toList(),
        newStatus: _deliveringStatusCode,
        accountId: accountId,
        changeSource: 'manual',
        assigneeId: null,
      );

      final latestItems = await _getOrderItemsByStatusUseCase(_readyStatusCode);

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
