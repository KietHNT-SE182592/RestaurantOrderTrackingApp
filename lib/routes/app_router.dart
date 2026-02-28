import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
// Các page dummy khác (AdminDashboardPage, PosPage, KdsPage) để nguyên như cũ

class AppRouter {
  static GoRouter createRouter(String? savedRole) {
    // Quyết định trang đầu tiên khi mở App
    String initialLocation = '/login';
    if (savedRole != null) {
      if (savedRole == 'Admin') initialLocation = '/admin';
      else if (savedRole == 'Staff') initialLocation = '/pos';
      else if (savedRole == 'Chef') initialLocation = '/kds';
    }

    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(), // Trỏ tới file thực tế vừa tạo
        ),
        // ... giữ nguyên các GoRoute khác (/admin, /pos, /kds) ...
      ],
    );
  }
}