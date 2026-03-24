import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/create_order_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/create_order_items_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';

class OrderCartItem {
  final String cartItemId;
  final ProductEntity product;
  final String note;

  const OrderCartItem({
    required this.cartItemId,
    required this.product,
    required this.note,
  });

  OrderCartItem copyWith({
    String? cartItemId,
    ProductEntity? product,
    String? note,
  }) {
    return OrderCartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      product: product ?? this.product,
      note: note ?? this.note,
    );
  }
}

class OrderMenuState {
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<CategoryEntity> categories;
  final String? selectedCategoryName;
  final List<ProductEntity> products;
  final bool hasNextPage;
  final int currentPage;
  final int pageSize;
  final Map<String, OrderCartItem> cartItems;
  final bool isSubmitting;
  final String? submitMessage;

  const OrderMenuState({
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.categories,
    required this.selectedCategoryName,
    required this.products,
    required this.hasNextPage,
    required this.currentPage,
    required this.pageSize,
    required this.cartItems,
    required this.isSubmitting,
    required this.submitMessage,
  });

  factory OrderMenuState.initial() {
    return const OrderMenuState(
      isLoadingInitial: true,
      isLoadingMore: false,
      errorMessage: null,
      categories: [],
      selectedCategoryName: null,
      products: [],
      hasNextPage: true,
      currentPage: 0,
      pageSize: 10,
      cartItems: {},
      isSubmitting: false,
      submitMessage: null,
    );
  }

  OrderMenuState copyWith({
    bool? isLoadingInitial,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    List<CategoryEntity>? categories,
    String? selectedCategoryName,
    bool keepSelectedCategory = false,
    List<ProductEntity>? products,
    bool? hasNextPage,
    int? currentPage,
    int? pageSize,
    Map<String, OrderCartItem>? cartItems,
    bool? isSubmitting,
    String? submitMessage,
    bool clearSubmitMessage = false,
  }) {
    return OrderMenuState(
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      categories: categories ?? this.categories,
      selectedCategoryName: keepSelectedCategory
          ? this.selectedCategoryName
          : selectedCategoryName,
      products: products ?? this.products,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      cartItems: cartItems ?? this.cartItems,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitMessage: clearSubmitMessage
          ? null
          : (submitMessage ?? this.submitMessage),
    );
  }

  int get cartItemsCount => cartItems.length;
}

class OrderMenuCubit extends Cubit<OrderMenuState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductsUseCase _getProductsUseCase;
  final CreateOrderItemsUseCase _createOrderItemsUseCase;

  OrderMenuCubit({
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetProductsUseCase getProductsUseCase,
    required CreateOrderItemsUseCase createOrderItemsUseCase,
  }) : _getCategoriesUseCase = getCategoriesUseCase,
       _getProductsUseCase = getProductsUseCase,
       _createOrderItemsUseCase = createOrderItemsUseCase,
       super(OrderMenuState.initial());

  String _newCartItemId(String productId, int seed) {
    final now = DateTime.now().microsecondsSinceEpoch;
    return '${productId}_${now}_$seed';
  }

  Future<void> initialize() async {
    emit(OrderMenuState.initial());
    try {
      final categories = await _getCategoriesUseCase();
      final firstPage = await _getProductsUseCase(pageIndex: 1, pageSize: 10);

      emit(
        state.copyWith(
          isLoadingInitial: false,
          clearError: true,
          categories: categories,
          selectedCategoryName: null,
          products: firstPage.products.where((item) => item.isActive).toList(),
          hasNextPage: firstPage.hasNextPage,
          currentPage: firstPage.pageNumber,
          pageSize: firstPage.pageSize,
        ),
      );
    } on ServerFailure catch (e) {
      emit(state.copyWith(isLoadingInitial: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingInitial: false,
          errorMessage: 'Không thể tải danh sách món ăn.',
        ),
      );
    }
  }

  Future<void> loadMoreProducts() async {
    if (state.isLoadingMore || state.isLoadingInitial || !state.hasNextPage) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final nextPage = state.currentPage + 1;
      final pageData = await _getProductsUseCase(
        pageIndex: nextPage,
        pageSize: state.pageSize,
      );

      final existingIds = state.products.map((item) => item.id).toSet();
      final appended = pageData.products
          .where((item) => item.isActive)
          .where((item) => !existingIds.contains(item.id))
          .toList();

      emit(
        state.copyWith(
          isLoadingMore: false,
          products: [...state.products, ...appended],
          hasNextPage: pageData.hasNextPage,
          currentPage: pageData.pageNumber,
        ),
      );
    } on ServerFailure catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Không thể tải thêm món ăn.',
        ),
      );
    }
  }

  void selectCategory(String? categoryName) {
    emit(
      state.copyWith(
        selectedCategoryName: categoryName,
        keepSelectedCategory: false,
      ),
    );
  }

  void addToCart(ProductEntity product) {
    final next = Map<String, OrderCartItem>.from(state.cartItems);
    final cartItemId = _newCartItemId(product.id, next.length);
    next[cartItemId] = OrderCartItem(
      cartItemId: cartItemId,
      product: product,
      note: '',
    );
    emit(state.copyWith(cartItems: next, clearSubmitMessage: true));
  }

  void upsertCartItem({
    required ProductEntity product,
    required int quantity,
    required List<String> notes,
  }) {
    final normalizedQty = quantity < 1 ? 1 : quantity;
    final normalizedNotes = List<String>.generate(
      normalizedQty,
      (index) => index < notes.length ? notes[index].trim() : '',
    );
    final next = Map<String, OrderCartItem>.from(state.cartItems);
    next.removeWhere((_, item) => item.product.id == product.id);

    for (var i = 0; i < normalizedQty; i++) {
      final cartItemId = _newCartItemId(product.id, i);
      next[cartItemId] = OrderCartItem(
        cartItemId: cartItemId,
        product: product,
        note: normalizedNotes[i],
      );
    }

    emit(state.copyWith(cartItems: next, clearSubmitMessage: true));
  }

  void updateQuantity(String cartItemId, int quantity) {
    final current = state.cartItems[cartItemId];
    if (current == null) return;
    if (quantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }
    if (quantity == 1) {
      return;
    }

    final next = Map<String, OrderCartItem>.from(state.cartItems);
    for (var i = 0; i < quantity - 1; i++) {
      final newId = _newCartItemId(current.product.id, i);
      next[newId] = OrderCartItem(
        cartItemId: newId,
        product: current.product,
        note: current.note,
      );
    }
    emit(state.copyWith(cartItems: next, clearSubmitMessage: true));
  }

  void updateNote(String cartItemId, String note) {
    final current = state.cartItems[cartItemId];
    if (current == null) return;
    final next = Map<String, OrderCartItem>.from(state.cartItems);
    next[cartItemId] = current.copyWith(note: note);
    emit(state.copyWith(cartItems: next, clearSubmitMessage: true));
  }

  void removeFromCart(String cartItemId) {
    if (!state.cartItems.containsKey(cartItemId)) return;
    final next = Map<String, OrderCartItem>.from(state.cartItems);
    next.remove(cartItemId);
    emit(state.copyWith(cartItems: next, clearSubmitMessage: true));
  }

  List<OrderCartItem> get cartList => state.cartItems.values.toList();

  String noteOf(String productId) {
    final matched = state.cartItems.values.where(
      (item) => item.product.id == productId,
    );
    if (matched.isEmpty) return '';
    return matched.last.note;
  }

  List<String> notesOf(String productId) {
    return state.cartItems.values
        .where((item) => item.product.id == productId)
        .map((item) => item.note)
        .toList();
  }

  int quantityOf(String productId) {
    return state.cartItems.values
        .where((item) => item.product.id == productId)
        .length;
  }

  Future<String> submitOrderItems({
    required String orderId,
    required String createdBy,
    String orderChannel = 'WaiterApp',
  }) async {
    if (state.cartItems.isEmpty) {
      throw ServerFailure('Giỏ hàng đang trống.');
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final items = state.cartItems.values
          .map(
            (item) => CreateOrderItemEntity(
              productId: item.product.id,
              note: item.note.trim(),
              quantity: 1,
            ),
          )
          .toList();

      final message = await _createOrderItemsUseCase(
        orderId: orderId,
        orderChannel: orderChannel,
        createdBy: createdBy,
        items: items,
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          cartItems: {},
          submitMessage: message,
        ),
      );
      return message;
    } on ServerFailure catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
      rethrow;
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Không thể gửi gọi món. Vui lòng thử lại.',
        ),
      );
      rethrow;
    }
  }
}
