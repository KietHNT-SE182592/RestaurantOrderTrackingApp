# Routing & Role-Based Navigation Plan

## 1. Tổng quan hệ thống

**5 Roles:** Admin | Manager | Chef | Waiter | Cashier  
**Router:** GoRouter với `StatefulShellRoute.indexedStack` (giữ state mỗi tab)  
**Auth redirect:** `GoRouter.redirect` + `refreshListenable` tự động điều hướng khi auth state đổi  
**JWT Decode:** Không cần package ngoài — base64url decode thuần Dart

---

## 2. Luồng Auth hoàn chỉnh

```
Cold Start
  └─ main() calls authCubit.checkAuthStatus()
       ├─ Lấy accessToken từ SharedPrefs
       ├─ JwtDecoder.isExpired(token)?
       │    ├─ Expired  → emit AuthInitial → redirect '/login'
       │    └─ Valid    → decode payload → emit AuthSuccess(user)
       │                    └─ redirect theo role (xem bảng §4)
       └─ Không có token → emit AuthInitial → redirect '/login'

Login Flow
  └─ LoginPage → AuthCubit.login(user, pass)
       ├─ API trả về { succeeded: true, data: { accessToken, ... } }
       ├─ UserModel.fromJson(data) → lưu session
       └─ emit AuthSuccess(user)
             └─ GoRouter.redirect tự động → roleHome(user.role)

Logout Flow
  └─ AuthCubit.logout()
       ├─ xóa session
       └─ emit AuthInitial → GoRouter.redirect → '/login'
```

---

## 3. JWT Payload format

```json
{
  "sub":         "019c9e1d-...",        ← id
  "unique_name": "admin",               ← userName
  "fullName":    "Nguyễn Văn A",        ← fullName (MỚI)
  "role":        "Admin",               ← role
  "jti":         "e6046cc2-...",
  "exp":         1772259476,            ← dùng để check hết hạn
  "iss":         "RestaurantOrderTracking",
  "aud":         "RestaurantOrderTrackingClient"
}
```

**JwtDecoder** (`core/utils/jwt_decoder.dart`):
- `decode(token)` → `Map<String, dynamic>` payload
- `extractRole(token)` → `String?`
- `isExpired(token)` → `bool`

---

## 4. Role → Route Mapping

| Role      | Initial Route          | Bottom Nav Tabs                              |
|-----------|------------------------|----------------------------------------------|
| `Admin`   | `/admin/dashboard`     | Dashboard · Nhân viên · Menu · Báo cáo       |
| `Manager` | `/manager/dashboard`   | Dashboard · Bàn ăn · Kho · Báo cáo           |
| `Chef`    | `/kitchen/display`     | *(toàn màn hình, không có bottom nav)*        |
| `Waiter`  | `/waiter/pos`          | Gọi món (POS) · Sơ đồ bàn                    |
| `Cashier` | `/cashier/orders`      | Đơn hàng                                     |

---

## 5. Bảng màn hình theo Role

| Màn hình                       | Admin | Manager | Chef | Waiter | Cashier |
|--------------------------------|:-----:|:-------:|:----:|:------:|:-------:|
| Dashboard (KPI tổng quan)      |  ✅   |   ✅    |      |        |         |
| Kitchen Display (KDS)          |       |         |  ✅  |        |         |
| POS – Gọi món                  |       |         |      |   ✅   |         |
| Sơ đồ bàn                      |       |   ✅    |      |   ✅   |         |
| Quản lý Menu                   |  ✅   |   ✅    |      |        |         |
| Quản lý Kho                    |       |   ✅    |      |        |         |
| Quản lý Nhân viên              |  ✅   |         |      |        |         |
| Báo cáo & Thống kê             |  ✅   |   ✅    |      |        |         |
| Hàng chờ thanh toán            |       |         |      |        |   ✅    |
| Thanh toán (Checkout)          |       |         |      |        |   ✅    |
| Thông báo *(shared)*           |  ✅   |   ✅    |  ✅  |   ✅   |   ✅    |
| Hồ sơ / Cài đặt *(shared)*     |  ✅   |   ✅    |  ✅  |   ✅   |   ✅    |

---

## 6. Cấu trúc thư mục sau refactor

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_colors.dart
│   │   └── app_routes.dart            ← THÊM MỚI — hằng số route paths
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── dio_client.dart
│   ├── utils/
│   │   └── jwt_decoder.dart           ← THÊM MỚI — decode JWT thuần Dart
│   └── shared_features/
│       ├── notifications/
│       │   └── presentation/pages/notifications_page.dart
│       └── profile/
│           └── presentation/pages/profile_page.dart
│
├── di/
│   └── injection.dart
│
├── features/
│   ├── auth/                          ← Đã có ✅ (cập nhật nhỏ)
│   │
│   ├── admin/
│   │   └── presentation/pages/
│   │       ├── admin_shell_page.dart  ← StatefulNavigationShell + BottomNav
│   │       ├── admin_dashboard_page.dart
│   │       ├── admin_staff_page.dart
│   │       ├── admin_menu_page.dart
│   │       └── admin_reports_page.dart
│   │
│   ├── manager/
│   │   └── presentation/pages/
│   │       ├── manager_shell_page.dart
│   │       ├── manager_dashboard_page.dart
│   │       ├── manager_tables_page.dart
│   │       ├── manager_inventory_page.dart
│   │       └── manager_reports_page.dart
│   │
│   ├── kitchen/
│   │   └── presentation/pages/
│   │       ├── kitchen_shell_page.dart
│   │       └── kitchen_display_page.dart
│   │
│   ├── waiter/
│   │   └── presentation/pages/
│   │       ├── waiter_shell_page.dart
│   │       ├── waiter_pos_page.dart
│   │       └── waiter_tables_page.dart
│   │
│   └── cashier/
│       └── presentation/pages/
│           ├── cashier_shell_page.dart
│           ├── cashier_orders_page.dart
│           └── cashier_checkout_page.dart
│
├── routes/
│   └── app_router.dart                ← REWRITE — StatefulShellRoute + redirect
│
└── main.dart                          ← cập nhật — gọi checkAuthStatus()
```

---

## 7. GoRouter Architecture

```
GoRouter
  │  refreshListenable: GoRouterRefreshStream(authCubit.stream)
  │  redirect: kiểm tra AuthState → trả về route phù hợp
  │
  ├── GoRoute('/login')
  │
  ├── StatefulShellRoute.indexedStack    [Admin — 4 tabs]
  │   ├── Branch: GoRoute('/admin/dashboard')
  │   ├── Branch: GoRoute('/admin/staff')
  │   ├── Branch: GoRoute('/admin/menu')
  │   └── Branch: GoRoute('/admin/reports')
  │
  ├── StatefulShellRoute.indexedStack    [Manager — 4 tabs]
  │   ├── Branch: GoRoute('/manager/dashboard')
  │   ├── Branch: GoRoute('/manager/tables')
  │   ├── Branch: GoRoute('/manager/inventory')
  │   └── Branch: GoRoute('/manager/reports')
  │
  ├── ShellRoute                         [Kitchen — full screen]
  │   └── GoRoute('/kitchen/display')
  │
  ├── StatefulShellRoute.indexedStack    [Waiter — 2 tabs]
  │   ├── Branch: GoRoute('/waiter/pos')
  │   └── Branch: GoRoute('/waiter/tables')
  │
  └── StatefulShellRoute.indexedStack    [Cashier — 1 tab]
      └── Branch: GoRoute('/cashier/orders')
```

---

## 8. Redirect Logic

```dart
redirect: (context, routerState) {
  final authState = authCubit.state;
  final loc = routerState.matchedLocation;
  final isLoggingIn = loc == AppRoutes.login;

  // Chưa đăng nhập → về login
  if (authState is AuthInitial && !isLoggingIn) return AppRoutes.login;

  // Đã đăng nhập, đang ở login → tự động vào trang tương ứng role
  if (authState is AuthSuccess && isLoggingIn) {
    return AppRoutes.roleHome(authState.user.role);
  }

  return null; // không redirect
}
```

---

## 9. Các thay đổi code cần thiết

| File | Thay đổi |
|------|----------|
| `core/utils/jwt_decoder.dart` | Tạo mới |
| `core/constants/app_routes.dart` | Tạo mới |
| `auth/domain/entities/user_entity.dart` | Thêm field `fullName` |
| `auth/data/models/user_model.dart` | Thêm field `fullName` |
| `auth/data/datasources/auth_local_datasource.dart` | Thêm `getAccessToken()` |
| `auth/domain/repositories/auth_repository.dart` | Thêm `getAccessToken()` |
| `auth/data/repositories/auth_repository_impl.dart` | Implement `getAccessToken()` |
| `auth/domain/usecases/check_auth_status_usecase.dart` | Tạo mới |
| `auth/presentation/cubit/auth_cubit.dart` | Thêm `checkAuthStatus()` |
| `di/injection.dart` | Đổi AuthCubit sang singleton, đăng ký usecase mới |
| `routes/app_router.dart` | Viết lại toàn bộ |
| `main.dart` | Gọi `checkAuthStatus()` trước `runApp` |

---

## 10. Checklist triển khai

- [x] PLAN.md đã tạo
- [ ] `JwtDecoder` + `AppRoutes`
- [ ] Update `UserEntity` + `UserModel` (thêm fullName)
- [ ] Update `AuthLocalDataSource` + `AuthRepository` (thêm getAccessToken)
- [ ] `CheckAuthStatusUseCase`
- [ ] Update `AuthCubit` (thêm checkAuthStatus)
- [ ] Skeleton pages — Admin (5 files)
- [ ] Skeleton pages — Manager (5 files)
- [ ] Skeleton pages — Kitchen · Waiter · Cashier (7 files)
- [ ] Shared pages — Notifications · Profile (2 files)
- [ ] `AppRouter` rewrite
- [ ] DI + main.dart update
