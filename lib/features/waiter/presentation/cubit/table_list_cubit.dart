import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/status_enums.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/usecases/get_areas_usecase.dart';
import '../../domain/usecases/get_tables_usecase.dart';

const Object _statusFilterNoChange = Object();

// ─── States ───────────────────────────────────────────────────────────────────

abstract class TableListState {}

class TableListInitial extends TableListState {}

class TableListLoading extends TableListState {}

class TableListLoaded extends TableListState {
  final List<AreaEntity> areas;
  final List<TableEntity> tables;
  final String selectedAreaId; // '' = Tất cả
  final TableStatus? selectedStatus; // null = Tất cả

  TableListLoaded({
    required this.areas,
    required this.tables,
    required this.selectedAreaId,
    required this.selectedStatus,
  });

  List<TableEntity> get filteredTables {
    var currentTables = tables;

    if (selectedAreaId.isNotEmpty) {
      String? selectedName;
      for (final a in areas) {
        if (a.id == selectedAreaId) {
          selectedName = a.name;
          break;
        }
      }
      if (selectedName != null) {
        currentTables = currentTables
            .where((table) => table.areaName == selectedName)
            .toList();
      }
    }

    if (selectedStatus != null) {
      currentTables = currentTables
          .where((table) => table.status == selectedStatus)
          .toList();
    }

    return currentTables;
  }

  TableListLoaded copyWith({
    List<AreaEntity>? areas,
    List<TableEntity>? tables,
    String? selectedAreaId,
    Object? selectedStatus = _statusFilterNoChange,
  }) {
    return TableListLoaded(
      areas: areas ?? this.areas,
      tables: tables ?? this.tables,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      selectedStatus: selectedStatus == _statusFilterNoChange
          ? this.selectedStatus
          : selectedStatus as TableStatus?,
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
  }) : _getAreasUseCase = getAreasUseCase,
       _getTablesUseCase = getTablesUseCase,
       super(TableListInitial());

  /// Tải danh sách khu vực và bàn cùng lúc.
  Future<void> loadTablesAndAreas({bool keepSelectedFilters = false}) async {
    final previousState = state;
    final previousSelectedAreaId =
        keepSelectedFilters && previousState is TableListLoaded
        ? previousState.selectedAreaId
        : '';
    final previousSelectedStatus =
        keepSelectedFilters && previousState is TableListLoaded
        ? previousState.selectedStatus
        : null;

    emit(TableListLoading());
    try {
      final results = await Future.wait([
        _getAreasUseCase(),
        _getTablesUseCase(pageSize: 100),
      ]);
      final loadedAreas = (results[0] as List).cast<AreaEntity>().toList();
      final loadedTables = (results[1] as List).cast<TableEntity>().toList();

      final hasPreviousArea = loadedAreas.any(
        (area) => area.id == previousSelectedAreaId,
      );

      emit(
        TableListLoaded(
          areas: loadedAreas,
          tables: loadedTables,
          selectedAreaId: hasPreviousArea ? previousSelectedAreaId : '',
          selectedStatus: previousSelectedStatus,
        ),
      );
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

  /// Đổi trạng thái bàn được chọn.
  void selectStatus(TableStatus? status) {
    final current = state;
    if (current is TableListLoaded) {
      emit(current.copyWith(selectedStatus: status));
    }
  }

  /// Pull-to-refresh.
  Future<void> refresh() => loadTablesAndAreas(keepSelectedFilters: true);
}
