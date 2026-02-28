# Code Organization Guide

> **Mục đích:** File này là nguồn sự thật duy nhất về cách tổ chức code trong project.
> AI agent hoặc developer mới **PHẢI đọc file này** trước khi implement bất kỳ feature nào.

---

## 1. Tech Stack

| Thứ | Package | Ghi chú |
|-----|---------|---------|
| State Management | `flutter_bloc` — Cubit | Ưu tiên Cubit, dùng BLoC khi có nhiều Event phức tạp |
| Routing | `go_router` | StatefulShellRoute cho multi-tab, redirect guard tự động |
| DI | `get_it` | Không dùng `injectable_generator` — wiring thủ công trong `di/injection.dart` |
| Network | `dio` | Interceptor tự gắn Bearer token, singleton qua GetIt |
| Local Storage | `shared_preferences` | Token, role |
| Auth decode | Thuần Dart (base64url) | Không cần package `jwt_decoder` ngoài |

---

## 2. Kiến trúc: Clean Architecture + Feature-first

```
Dependency Rule: Presentation → Domain ← Data
                               (Domain không phụ thuộc bất kỳ ai)
```

### Layer trách nhiệm

| Layer | Chứa gì | KHÔNG được import |
|-------|---------|------------------|
| **Domain** | entities, repository interfaces, usecases | `dio`, `shared_preferences`, bất kỳ package infrastructure |
| **Data** | models, datasources, repository implementations | `flutter`, `flutter_bloc` |
| **Presentation** | pages, widgets, cubit/bloc | Data layer trực tiếp — chỉ qua UseCase |

---

## 3. Cấu trúc thư mục hoàn chỉnh

```
lib/
├── core/                              # Tiện ích TOÀN CỤC, không thuộc feature nào
│   ├── constants/
│   │   ├── api_constants.dart         # Base URL, endpoint paths
│   │   ├── app_colors.dart            # Toàn bộ color palette (light + dark)
│   │   └── app_routes.dart            # Tất cả route path strings + roleHome()
│   ├── errors/
│   │   ├── exceptions.dart            # ServerException, CacheException (Data throws)
│   │   └── failures.dart              # ServerFailure, CacheFailure (Domain exposes)
│   ├── network/
│   │   └── dio_client.dart            # Dio singleton + Bearer token interceptor
│   ├── utils/
│   │   └── jwt_decoder.dart           # decode(), extractRole(), isExpired(), extractUserClaims()
│   └── shared_features/               # Widget/page dùng CHUNG nhiều role
│       ├── widgets/
│       │   ├── app_text_field.dart    # ✅ Input field chuẩn — dùng cho mọi form
│       │   ├── form_field_label.dart  # ✅ Label trên input — dùng cho mọi form
│       │   ├── dot_pattern_background.dart  # ✅ Nền chấm bi — Login, Splash...
│       │   └── placeholder_body.dart  # Skeleton placeholder — XÓA sau khi implement UI thật
│       ├── notifications/
│       │   └── presentation/pages/notifications_page.dart
│       └── profile/
│           └── presentation/pages/profile_page.dart  # Hiển thị user info + logout
│
├── di/
│   └── injection.dart                 # GetIt wiring: External→DS→Repo→UseCase→Cubit
│
├── features/                          # MỖI feature = 1 thư mục, có đủ 3 layer
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/user_entity.dart
│   │   │   ├── repositories/auth_repository.dart   # abstract interface
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       ├── check_auth_status_usecase.dart  # decode JWT cold start
│   │   │       └── get_saved_role_usecase.dart
│   │   ├── data/
│   │   │   ├── models/user_model.dart               # extends UserEntity + fromJson
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart      # Dio API calls
│   │   │   │   └── auth_local_datasource.dart       # SharedPreferences
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── cubit/auth_cubit.dart                # singleton — dùng chung với AppRouter
│   │       └── pages/login_page.dart
│   │
│   ├── admin/presentation/pages/      # 5 files: shell + 4 tab pages
│   ├── manager/presentation/pages/   # 5 files: shell + 4 tab pages
│   ├── kitchen/presentation/pages/   # 2 files: shell + display
│   ├── waiter/presentation/pages/    # 3 files: shell + pos + tables
│   └── cashier/presentation/pages/   # 3 files: shell + orders + checkout
│
├── routes/
│   └── app_router.dart                # GoRouter với redirect guard + refreshListenable
│
└── main.dart                          # initDependencies() → checkAuthStatus() → runApp()
```

---

## 4. Quy tắc tạo Feature mới

Khi tạo feature `[feature_name]` (VD: `menu`, `order`, `table`), luôn tạo đúng thứ tự:

```
1. domain/entities/[name]_entity.dart
2. domain/repositories/[name]_repository.dart      ← abstract interface
3. domain/usecases/[action]_usecase.dart            ← 1 class = 1 hành động
4. data/models/[name]_model.dart                   ← extends entity + fromJson
5. data/datasources/[name]_remote_datasource.dart
6. data/datasources/[name]_local_datasource.dart   ← nếu cần cache
7. data/repositories/[name]_repository_impl.dart
8. di/injection.dart                               ← wire vào GetIt
9. presentation/cubit/[name]_cubit.dart            ← gọi UseCases, KHÔNG gọi repo
10. presentation/pages/[name]_page.dart
11. routes/app_router.dart                         ← thêm GoRoute mới
```

---

## 5. Routing — Role & Route Map

### Role → Home Route

| Role | Home Route | Shell Type |
|------|-----------|-----------|
| `Admin` | `/admin/dashboard` | StatefulShellRoute — 4 tabs |
| `Manager` | `/manager/dashboard` | StatefulShellRoute — 4 tabs |
| `Chef` | `/kitchen/display` | ShellRoute — full screen |
| `Waiter` | `/waiter/pos` | StatefulShellRoute — 2 tabs |
| `Cashier` | `/cashier/orders` | StatefulShellRoute — 1 tab |

### Route Paths (từ `AppRoutes`)

```
/login
/admin/dashboard    /admin/staff         /admin/menu         /admin/reports
/manager/dashboard  /manager/tables      /manager/inventory  /manager/reports
/kitchen/display
/waiter/pos         /waiter/tables
/cashier/orders     /cashier/checkout/:orderId
/notifications      /profile             ← shared, mọi role đều vào được
```

### Redirect Guard (trong `app_router.dart`)

```
AuthInitial → /login
AuthSuccess + đang ở /login → roleHome(role)
AuthSuccess + sai role prefix → roleHome(role)
AuthSuccess + shared route → cho qua (null)
```

---

## 6. Auth Flow

### Cold Start
```
main() → initDependencies() → authCubit.checkAuthStatus()
  └─ CheckAuthStatusUseCase → getAccessToken() → JwtDecoder.isExpired()?
       ├─ Hết hạn / không có → emit AuthInitial → router → /login
       └─ Còn hạn → JwtDecoder.extractUserClaims() → emit AuthSuccess → router → roleHome
```

### Login
```
LoginPage → authCubit.login(user, pass)
  └─ LoginUseCase → RemoteDS.login() → UserModel.fromJson(data['data'])
       └─ LocalDS.saveSession(token, role) → emit AuthSuccess
            └─ refreshListenable → GoRouter.redirect → roleHome(role)
```

### Logout
```
ProfilePage → authCubit.logout()
  └─ LogoutUseCase → LocalDS.clearSession() → emit AuthInitial
       └─ refreshListenable → GoRouter.redirect → /login
```

---

## 7. JWT Payload Format

Backend trả về JWT với payload:

```json
{
  "sub":         "019c9e1d-...",     → UserEntity.id
  "unique_name": "admin",            → UserEntity.userName
  "fullName":    "Nguyễn Văn A",    → UserEntity.fullName
  "role":        "Admin",            → UserEntity.role (Admin|Manager|Chef|Waiter|Cashier)
  "exp":         1772259476          → JwtDecoder.isExpired() dùng cái này
}
```

Backend response login:
```json
{
  "succeeded": true,
  "data": {
    "id":           "...",
    "userName":     "...",
    "fullName":     "...",
    "role":         "Admin",
    "accessToken":  "eyJ...",
    "refreshToken": "eyJ..."
  }
}
```

---

## 8. DI Registration Pattern

```dart
// Thứ tự BẮT BUỘC trong injection.dart:
// 1. External (SharedPreferences, Dio)
// 2. DataSources
// 3. Repository — đăng ký dưới INTERFACE, không phải concrete
sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));
// 4. UseCases — lazySingleton
// 5. Cubit/BLoC — lazySingleton nếu dùng với AppRouter, factory nếu độc lập
```

**AuthCubit phải là `registerLazySingleton`** (không phải Factory) vì AppRouter
dùng `refreshListenable` trỏ trực tiếp vào cùng 1 instance.

---

## 9. Shared Widgets — Khi nào dùng gì

| Widget | File | Dùng khi |
|--------|------|---------|
| `AppTextField` | `core/shared_features/widgets/app_text_field.dart` | Mọi input field trong form |
| `FormFieldLabel` | `core/shared_features/widgets/form_field_label.dart` | Label phía trên input |
| `DotPatternBackground` | `core/shared_features/widgets/dot_pattern_background.dart` | Nền trang Login, Splash |
| `PlaceholderBody` | `core/shared_features/widgets/placeholder_body.dart` | **TẠM THỜI** — xóa khi implement UI thật |

---

## 10. Naming Conventions

| Thứ | Convention | Ví dụ |
|-----|-----------|-------|
| Files | `snake_case.dart` | `auth_repository_impl.dart` |
| Classes | `PascalCase` | `AuthRepositoryImpl` |
| Variables/Methods | `camelCase` | `accessToken`, `loginUseCase` |
| Private class trong file | `_PascalCase` | `_SocialButton` |
| Route paths | `kebab-case` | `/cashier/checkout/:orderId` |
| Feature folders | `snake_case` | `features/kitchen/` |

---

## 11. Lỗi thường gặp & Cách tránh

| Lỗi | Nguyên nhân | Cách tránh |
|-----|------------|-----------|
| Cubit gọi repo trực tiếp | Bỏ qua UseCase | Luôn đi qua UseCase |
| Presentation import Data | Import sai layer | Chỉ import từ `domain/` |
| Interface đặt trong `data/` | Hiểu sai Clean Arch | Interface → `domain/repositories/`, Impl → `data/repositories/` |
| `context.go()` thủ công sau login | Code cũ | Để GoRouter.redirect tự xử lý |
| AuthCubit registerFactory | Instance khác với AppRouter | Phải `registerLazySingleton` |

---

## 12. AppColors Reference

```dart
// Primary palette (Orange brand)
AppColors.primary            // #F97316 — màu chủ đạo, button, border focus
AppColors.primaryForeground  // #FFFFFF — text trên nền primary
AppColors.secondary          // #FACC15 — accent vàng
AppColors.accent             // #EA580C — orange đậm hơn

// Semantic
AppColors.destructive        // #EF4444 — lỗi, xóa

// Light theme
AppColors.backgroundLight    // #FFF7ED
AppColors.foregroundLight    // #1C1917
AppColors.cardLight          // #FFFFFF
AppColors.muted              // #F3F4F6 — input background
AppColors.mutedForeground    // #6B7280 — placeholder, label
AppColors.border             // #E5E7EB

// Dark theme
AppColors.backgroundDark     // #0C0A09
AppColors.foregroundDark     // #FFF7ED
AppColors.cardDark           // #1C1917
AppColors.mutedDark          // #292524
AppColors.mutedForegroundDark // #A8A29E
```
