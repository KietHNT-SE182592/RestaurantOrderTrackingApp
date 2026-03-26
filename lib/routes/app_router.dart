import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/shared_features/notifications/presentation/pages/notifications_page.dart';
import '../core/shared_features/profile/presentation/pages/profile_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/admin_menu_page.dart';
import '../features/admin/presentation/pages/admin_reports_page.dart';
import '../features/admin/presentation/pages/admin_shell_page.dart';
import '../features/admin/presentation/pages/admin_staff_page.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/cashier/presentation/pages/cashier_checkout_page.dart';
import '../features/cashier/presentation/pages/cashier_orders_page.dart';
import '../features/cashier/presentation/pages/cashier_shell_page.dart';
import '../features/kitchen/presentation/pages/kitchen_display_page.dart';
import '../features/kitchen/presentation/pages/kitchen_shell_page.dart';
import '../features/manager/presentation/pages/manager_dashboard_page.dart';
import '../features/manager/presentation/pages/manager_inventory_page.dart';
import '../features/manager/presentation/pages/manager_reports_page.dart';
import '../features/manager/presentation/pages/manager_shell_page.dart';
import '../features/manager/presentation/pages/manager_tables_page.dart';
import '../features/orders/presentation/pages/order_detail_page.dart';
import '../features/orders/presentation/pages/order_menu_page.dart';
import '../features/waiter/domain/entities/table_detail_entity.dart';
import '../features/waiter/presentation/pages/waiter_order_item_detail_page.dart';
import '../features/waiter/presentation/pages/waiter_delivering_page.dart';
import '../features/waiter/presentation/pages/waiter_serve_page.dart';
import '../features/waiter/presentation/pages/waiter_shell_page.dart';
import '../features/waiter/presentation/pages/waiter_table_detail_page.dart';
import '../features/waiter/presentation/pages/waiter_tables_page.dart';

class AppRouter {
  AppRouter._();

  /// Tạo GoRouter hoàn chỉnh.
  ///
  /// [authCubit] phải là **singleton** (từ GetIt) để:
  /// - `refreshListenable` lắng nghe đúng stream
  /// - `redirect` đọc đúng state
  /// - `BlocProvider.value` trong `main.dart` share cùng instance
  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      debugLogDiagnostics: true,
      // Khi authCubit emit state mới → GoRouter chạy lại redirect
      refreshListenable: _GoRouterRefreshStream(authCubit.stream),

      // ─── Guard toàn cục ────────────────────────────────────────────────────
      redirect: (context, state) {
        final authState = authCubit.state;
        final loc = state.matchedLocation;
        final isLoginPage = loc == AppRoutes.login;

        // Chưa đăng nhập (hoặc đang load) → về login
        if (authState is AuthInitial && !isLoginPage) return AppRoutes.login;
        if (authState is AuthLoading && !isLoginPage) return null;

        // Đã đăng nhập, đang ở trang login → redirect theo role
        if (authState is AuthSuccess && isLoginPage) {
          return AppRoutes.roleHome(authState.user.role);
        }

        // Ngăn user truy cập route của role khác
        if (authState is AuthSuccess) {
          return _guardRoleRoute(loc, authState.user.role);
        }

        return null; // Không redirect
      },

      routes: [
        // ─── Auth ─────────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),

        // ─── Shared (push từ bất kỳ đâu) ──────────────────────────────────────
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfilePage(),
        ),

        // ─── Admin — 4 tabs ────────────────────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AdminShellPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminDashboard,
                  builder: (context, state) => const AdminDashboardPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminStaff,
                  builder: (context, state) => const AdminStaffPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminMenu,
                  builder: (context, state) => const AdminMenuPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.adminReports,
                  builder: (context, state) => const AdminReportsPage(),
                ),
              ],
            ),
          ],
        ),

        // ─── Manager — 4 tabs ──────────────────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ManagerShellPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.managerDashboard,
                  builder: (context, state) => const ManagerDashboardPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.managerTables,
                  builder: (context, state) => const ManagerTablesPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.managerInventory,
                  builder: (context, state) => const ManagerInventoryPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.managerReports,
                  builder: (context, state) => const ManagerReportsPage(),
                ),
              ],
            ),
          ],
        ),

        // ─── Kitchen (Chef) — full screen, không có bottom nav ────────────────
        ShellRoute(
          builder: (context, state, child) => KitchenShellPage(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.kitchenDisplay,
              builder: (context, state) => const KitchenDisplayPage(),
            ),
          ],
        ),

        // ─── Waiter — 2 tabs ──────────────────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              WaiterShellPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.waiterTables,
                  builder: (context, state) => const WaiterTablesPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.waiterServe,
                  builder: (context, state) => const WaiterServePage(),
                ),
                GoRoute(
                  path: AppRoutes.waiterDelivering,
                  builder: (context, state) => const WaiterDeliveringPage(),
                ),
              ],
            ),
          ],
        ),

        // ─── Cashier — 1 tab + sub-route checkout ─────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              CashierShellPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.cashierOrders,
                  builder: (context, state) => const CashierOrdersPage(),
                ),
              ],
            ),
          ],
        ),

        // Checkout là sub-route độc lập, push từ CashierOrdersPage
        GoRoute(
          path: AppRoutes.cashierCheckout,
          builder: (context, state) => CashierCheckoutPage(
            orderId: state.pathParameters['orderId'] ?? '',
          ),
        ),

        // Waiter — Chi tiết bàn, push từ WaiterTablesPage
        GoRoute(
          path: AppRoutes.waiterTableDetail,
          builder: (context, state) => WaiterTableDetailPage(
            tableId: state.pathParameters['tableId'] ?? '',
          ),
        ),
        GoRoute(
          path: AppRoutes.waiterOrderDetail,
          builder: (context, state) =>
              OrderDetailPage(orderId: state.pathParameters['orderId'] ?? ''),
        ),
        GoRoute(
          path: AppRoutes.waiterOrderMenu,
          builder: (context, state) =>
              OrderMenuPage(orderId: state.pathParameters['orderId'] ?? ''),
        ),
        GoRoute(
          path: AppRoutes.waiterOrderItemDetail,
          builder: (context, state) => WaiterOrderItemDetailPage(
            item: state.extra as TableOrderItemSummaryEntity?,
          ),
        ),
      ],
    );
  }

  /// Ngăn user truy cập route không thuộc role của mình.
  /// Trả về null nếu hợp lệ, trả về roleHome nếu đi lạc.
  static String? _guardRoleRoute(String location, String role) {
    final home = AppRoutes.roleHome(role);

    // Các route shared (profile, notifications) — ai cũng được vào
    if (location.startsWith(AppRoutes.notifications) ||
        location.startsWith(AppRoutes.profile) ||
        location.startsWith(
          AppRoutes.cashierCheckout.replaceAll('/:orderId', ''),
        )) {
      return null;
    }

    // Kiểm tra prefix của route có khớp với role không
    final allowedPrefixes = _rolePrefixes[role] ?? [];
    final isAllowed = allowedPrefixes.any((p) => location.startsWith(p));

    return isAllowed ? null : home;
  }

  static const Map<String, List<String>> _rolePrefixes = {
    'Admin': ['/admin'],
    'Manager': ['/manager'],
    'Chef': ['/kitchen'],
    'Waiter': ['/waiter'],
    'Cashier': ['/cashier'],
  };
}

// ─── Helper: bridge giữa Cubit stream và GoRouter refreshListenable ──────────

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    // Notify ngay lập tức để router đánh giá redirect lần đầu
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
