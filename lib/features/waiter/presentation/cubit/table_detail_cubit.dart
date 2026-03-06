import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/table_detail_entity.dart';
import '../../domain/usecases/get_table_detail_usecase.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class TableDetailState {}

class TableDetailInitial extends TableDetailState {}

class TableDetailLoading extends TableDetailState {}

class TableDetailLoaded extends TableDetailState {
  final TableDetailEntity table;
  TableDetailLoaded(this.table);
}

class TableDetailError extends TableDetailState {
  final String message;
  TableDetailError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class TableDetailCubit extends Cubit<TableDetailState> {
  final GetTableDetailUseCase _getTableDetailUseCase;
  String? _lastTableId;

  TableDetailCubit({required GetTableDetailUseCase getTableDetailUseCase})
      : _getTableDetailUseCase = getTableDetailUseCase,
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
}
