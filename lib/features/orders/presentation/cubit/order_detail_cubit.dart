import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_detail_entity.dart';
import '../../domain/usecases/get_order_detail_usecase.dart';

abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final OrderDetailEntity order;

  OrderDetailLoaded(this.order);
}

class OrderDetailError extends OrderDetailState {
  final String message;

  OrderDetailError(this.message);
}

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final GetOrderDetailUseCase _getOrderDetailUseCase;
  String? _lastOrderId;

  OrderDetailCubit({required GetOrderDetailUseCase getOrderDetailUseCase})
    : _getOrderDetailUseCase = getOrderDetailUseCase,
      super(OrderDetailInitial());

  Future<void> loadOrderDetail(String orderId) async {
    _lastOrderId = orderId;
    emit(OrderDetailLoading());
    try {
      final order = await _getOrderDetailUseCase(orderId);
      emit(OrderDetailLoaded(order));
    } on ServerFailure catch (e) {
      emit(OrderDetailError(e.message));
    } catch (e) {
      emit(OrderDetailError(e.toString()));
    }
  }

  Future<void> retry() async {
    if (_lastOrderId != null) {
      await loadOrderDetail(_lastOrderId!);
    }
  }
}
