/// Tập trung tất cả route paths vào một chỗ.
/// Không hard-code string path ở bất kỳ nơi nào khác trong codebase.
abstract class AppRoutes {
  AppRoutes._();

  // ─── Auth ────────────────────────────────────────────────────────────────────
  static const String login = '/login';

  // ─── Admin ───────────────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStaff = '/admin/staff';
  static const String adminMenu = '/admin/menu';
  static const String adminReports = '/admin/reports';

  // ─── Manager ─────────────────────────────────────────────────────────────────
  static const String managerDashboard = '/manager/dashboard';
  static const String managerTables = '/manager/tables';
  static const String managerInventory = '/manager/inventory';
  static const String managerReports = '/manager/reports';

  // ─── Kitchen (Chef) ──────────────────────────────────────────────────────────
  static const String kitchenDisplay = '/kitchen/display';

  // ─── Waiter ──────────────────────────────────────────────────────────────────
  static const String waiterTables = '/waiter/tables';
  static const String waiterServe = '/waiter/serve';
  static const String waiterDelivering = '/waiter/delivering';
  static const String waiterTableDetail = '/waiter/tables/:tableId';
  static const String waiterOrderDetail = '/waiter/orders/:orderId';
  static const String waiterOrderMenu = '/waiter/orders/:orderId/menu';
  static const String waiterOrderItemDetail =
      '/waiter/orders/:orderId/items/:orderItemId';

  /// Build path chi tiết bàn với tableId cụ thể.
  static String waiterTableDetailOf(String tableId) =>
      '/waiter/tables/$tableId';

  static String waiterOrderDetailOf(String orderId) =>
      '/waiter/orders/$orderId';

  static String waiterOrderMenuOf(String orderId) =>
      '/waiter/orders/$orderId/menu';

  static String waiterOrderItemDetailOf(String orderId, String orderItemId) =>
      '/waiter/orders/$orderId/items/$orderItemId';

  static String waiterDeliveringOf() => waiterDelivering;

  // ─── Cashier ─────────────────────────────────────────────────────────────────
  static const String cashierOrders = '/cashier/orders';
  static const String cashierCheckout = '/cashier/checkout/:orderId';

  // ─── Shared (accessible từ mọi role) ─────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // ─── Helper ──────────────────────────────────────────────────────────────────

  /// Trả về route home tương ứng với role sau khi đăng nhập thành công.
  static String roleHome(String role) {
    switch (role) {
      case 'Admin':
        return adminDashboard;
      case 'Manager':
        return managerDashboard;
      case 'Chef':
      case 'HeadChef':
        return kitchenDisplay;
      case 'Waiter':
        return waiterTables;
      case 'Cashier':
        return cashierOrders;
      default:
        return login;
    }
  }

  /// Build path checkout với orderId cụ thể.
  static String cashierCheckoutOf(String orderId) =>
      '/cashier/checkout/$orderId';
}
