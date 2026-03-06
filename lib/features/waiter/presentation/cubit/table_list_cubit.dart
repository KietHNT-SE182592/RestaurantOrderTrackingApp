import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/usecases/get_areas_usecase.dart';
import '../../domain/usecases/get_tables_usecase.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class TableListState {}

class TableListInitial extends TableListState {}

class TableListLoading extends TableListState {}

class TableListLoaded extends TableListState {
  final List<AreaEntity> areas;
  final List<TableEntity> tables;
  final String selectedAreaId; // '' = Tất cả

  TableListLoaded({
    required this.areas,
    required this.tables,
    required this.selectedAreaId,
  });

  List<TableEntity> get filteredTables {
    if (selectedAreaId.isEmpty) return tables;
    String? selectedName;
    for (final a in areas) {
      if (a.id == selectedAreaId) {
        selectedName = a.name;
        break;
      }
    }
    if (selectedName == null) return tables;
    return tables.where((t) => t.areaName == selectedName).toList();
  }

  TableListLoaded copyWith({
    List<AreaEntity>? areas,
    List<TableEntity>? tables,
    String? selectedAreaId,
  }) {
    return TableListLoaded(
      areas: areas ?? this.areas,
      tables: tables ?? this.tables,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
    );
  }
}

class TableListError extends TableListState {
  final String message;
  TableListError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class TableListCubit extends Cubit<TableListState> {
  final GetAreasUseCase _getAreasUseCase;
  final GetTablesUseCase _getTablesUseCase;

  TableListCubit({
    required GetAreasUseCase getAreasUseCase,
    required GetTablesUseCase getTablesUseCase,
  })  : _getAreasUseCase = getAreasUseCase,
        _getTablesUseCase = getTablesUseCase,
        super(TableListInitial());

  /// Tải danh sách khu vực và bàn cùng lúc.
  Future<void> loadTablesAndAreas() async {
    emit(TableListLoading());
    try {
      final results = await Future.wait([
        _getAreasUseCase(),
        _getTablesUseCase(pageSize: 100),
      ]);
      emit(TableListLoaded(
        areas: (results[0] as List).cast<AreaEntity>().toList(),
        tables: (results[1] as List).cast<TableEntity>().toList(),
        selectedAreaId: '',
      ));
    } on ServerFailure catch (e) {
      emit(TableListError(e.message));
    } catch (e) {
      emit(TableListError(e.toString()));
    }
  }

  /// Đổi khu vực được chọn.
  void selectArea(String areaId) {
    final current = state;
    if (current is TableListLoaded) {
      emit(current.copyWith(selectedAreaId: areaId));
    }
  }

  /// Pull-to-refresh.
  Future<void> refresh() => loadTablesAndAreas();
}
