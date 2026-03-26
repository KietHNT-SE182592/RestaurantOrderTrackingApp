import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../waiter/domain/entities/serve_item_entity.dart';
import '../../../waiter/domain/usecases/get_order_items_by_account_usecase.dart';
import '../../../waiter/domain/usecases/update_order_items_status_usecase.dart';

class ChefDishGroup {
  final String key;
  final String productName;
  final List<ServeItemEntity> items;

  const ChefDishGroup({
    required this.key,
    required this.productName,
    required this.items,
  });

  int get quantity => items.length;

  List<String> get orderItemIds => items.map((item) => item.id).toList();

  ServeItemEntity? get oldestItem {
    if (items.isEmpty) return null;
    final sorted = [...items]
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });
    return sorted.first;
  }
}

abstract class ChefCookingBoardState {}

class ChefCookingBoardInitial extends ChefCookingBoardState {}

class ChefCookingBoardLoading extends ChefCookingBoardState {}

class ChefCookingBoardLoaded extends ChefCookingBoardState {
  final List<ServeItemEntity> items;
  final Set<String> finishingIds;

  ChefCookingBoardLoaded({required this.items, required this.finishingIds});

  List<ChefDishGroup> get groups {
    final map = <String, List<ServeItemEntity>>{};
    for (final item in items) {
      final key = '${item.productId}|${item.productName}';
      map.putIfAbsent(key, () => <ServeItemEntity>[]).add(item);
    }

    final result = map.entries
        .map(
          (entry) => ChefDishGroup(
            key: entry.key,
            productName: entry.value.first.productName,
            items: entry.value,
          ),
        )
        .toList();

    result.sort((a, b) {
      final aTime =
          a.oldestItem?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          b.oldestItem?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });

    return result;
  }

  bool isGroupProcessing(ChefDishGroup group) =>
      group.orderItemIds.any(finishingIds.contains);

  ChefCookingBoardLoaded copyWith({
    List<ServeItemEntity>? items,
    Set<String>? finishingIds,
  }) {
    return ChefCookingBoardLoaded(
      items: items ?? this.items,
      finishingIds: finishingIds ?? this.finishingIds,
    );
  }
}

class ChefCookingBoardError extends ChefCookingBoardState {
  final String message;

  ChefCookingBoardError(this.message);
}

class ChefCookingBoardCubit extends Cubit<ChefCookingBoardState> {
  final GetOrderItemsByAccountUseCase _getOrderItemsByAccountUseCase;
  final UpdateOrderItemsStatusUseCase _updateOrderItemsStatusUseCase;

  static const int _cookingStatus = 2;
  static const int _readyStatus = 3;

  ChefCookingBoardCubit({
    required GetOrderItemsByAccountUseCase getOrderItemsByAccountUseCase,
    required UpdateOrderItemsStatusUseCase updateOrderItemsStatusUseCase,
  }) : _getOrderItemsByAccountUseCase = getOrderItemsByAccountUseCase,
       _updateOrderItemsStatusUseCase = updateOrderItemsStatusUseCase,
       super(ChefCookingBoardInitial());

  Future<void> load() async {
    emit(ChefCookingBoardLoading());
    try {
      final items = await _getOrderItemsByAccountUseCase();
      final cookingOnly = items
          .where((item) => item.status.apiCode == _cookingStatus)
          .toList();
      emit(
        ChefCookingBoardLoaded(items: cookingOnly, finishingIds: <String>{}),
      );
    } on ServerFailure catch (e) {
      emit(ChefCookingBoardError(e.message));
    } catch (e) {
      emit(ChefCookingBoardError(e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> finishOneItem(ChefDishGroup group) async {
    final current = state;
    if (current is! ChefCookingBoardLoaded) return;

    final target = group.oldestItem;
    if (target == null || target.id.isEmpty) return;
    if (current.finishingIds.contains(target.id)) return;

    emit(
      current.copyWith(
        finishingIds: <String>{...current.finishingIds, target.id},
      ),
    );

    try {
      await _updateOrderItemsStatusUseCase(
        orderItemIds: [target.id],
        newStatus: _readyStatus,
        accountId: null,
        changeSource: '',
        assigneeId: null,
      );
      await load();
    } on ServerFailure {
      _clearFinishing([target.id]);
      rethrow;
    } catch (_) {
      _clearFinishing([target.id]);
      rethrow;
    }
  }

  Future<void> finishAllItems(ChefDishGroup group) async {
    final current = state;
    if (current is! ChefCookingBoardLoaded) return;

    final ids = group.orderItemIds.where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty || ids.any(current.finishingIds.contains)) return;

    emit(
      current.copyWith(finishingIds: <String>{...current.finishingIds, ...ids}),
    );

    try {
      await _updateOrderItemsStatusUseCase(
        orderItemIds: ids.toList(),
        newStatus: _readyStatus,
        accountId: null,
        changeSource: '',
        assigneeId: null,
      );
      await load();
    } on ServerFailure {
      _clearFinishing(ids);
      rethrow;
    } catch (_) {
      _clearFinishing(ids);
      rethrow;
    }
  }

  void _clearFinishing(Iterable<String> ids) {
    final current = state;
    if (current is! ChefCookingBoardLoaded) return;
    final next = Set<String>.from(current.finishingIds)..removeAll(ids);
    emit(current.copyWith(finishingIds: next));
  }
}
