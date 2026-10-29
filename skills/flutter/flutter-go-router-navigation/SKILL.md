---
name: flutter-go-router-navigation
description: "go_router-only navigation pattern for Flutter apps using Bloc/Cubit: auth redirects via refreshListenable, RBAC guards, ShellRoute for bottom-nav shells, navigating from Cubits via bloc_presentation (never raw Navigator), route-level Cubit provisioning, named routes, and modal/dialog routes built on CustomTransitionPage. Invoke when declaring routes, adding RBAC guards, navigating from a Cubit, or deciding whether a screen should be a ShellBranch vs a flat route."
---

# go_router + Bloc/Cubit Navigation Pattern

## Overview

Use `go_router` exclusively: no legacy `Navigator.push`/`showDialog`/`showModalBottomSheet` anywhere, including for modals and dialogs. `context.push()`/`context.pop()`/`context.go()` are the only navigation mechanism. This avoids a whole class of bugs where a widget created via raw `Navigator` doesn't share the same Provider ancestry as one created via `GoRoute`, producing `ProviderNotFoundException` or navigation state that doesn't match what go_router thinks is current.

- **One `GoRouter` instance**, created at the app root, injected via DI.
- **Route-level Cubit provisioning**: Cubits a route needs are provided in that `GoRoute`'s `builder`/`pageBuilder`, not instantiated inside a Page's `build()`.
- **Auth redirects** via `refreshListenable` + a `ChangeNotifier` that mirrors the app's auth Bloc state.
- **RBAC guards**: the `redirect` callback checks the current role against a route→roles map.
- **Navigation from Cubits** uses `bloc_presentation` one-shot events: Cubits never hold a `BuildContext`.
- **ShellRoute** (or `StatefulShellRoute`) only for screens that are genuinely persistent tabs with their own preserved navigation stack: not for every screen reachable from a tab.

## 1. File Layout (suggested)

```
lib/core/router/
├── app_router.dart          # GoRouter instance, all routes, redirect guard
├── app_router_notifier.dart # AuthRedirectNotifier (ChangeNotifier)
├── app_routes.dart          # AppRouteName / AppRoutePath: centralized names
├── modal_page.dart          # buildDialogPage / buildBottomSheetPage helpers
└── routes/                  # optional per-feature route files if app_router.dart grows too large
```

## 2. Auth Redirect via refreshListenable

```dart
enum AuthStatus { initial, authenticated, unauthenticated }

class AuthRedirectNotifier extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  void update(AuthStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }
}

// Wiring: forward the app's global auth Bloc stream into the notifier.
getIt<AppAuthBloc>().stream.listen((state) {
  state.when(
    initial: () => notifier.update(AuthStatus.initial),
    loading: () => notifier.update(AuthStatus.initial),
    authenticated: (_) => notifier.update(AuthStatus.authenticated),
    unauthenticated: () => notifier.update(AuthStatus.unauthenticated),
    error: (_) => notifier.update(AuthStatus.unauthenticated),
  );
});
```

## 3. GoRouter Instance with RBAC Guard

```dart
late final GoRouter router = GoRouter(
  initialLocation: AppRoutePath.splash,
  navigatorKey: rootNavigatorKey,
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final isLoggedIn = authNotifier.status == AuthStatus.authenticated;
    final location = state.matchedLocation;

    if (location == AppRoutePath.splash || location == AppRoutePath.login) {
      if (isLoggedIn && location == AppRoutePath.login) return AppRoutePath.home;
      return null;
    }
    if (!isLoggedIn) return AppRoutePath.login;

    final requiredRoles = routeRoles[location];
    if (requiredRoles != null && !requiredRoles.contains(currentUserRole)) {
      return AppRoutePath.unauthorized;
    }
    return null;
  },
  routes: [...],
);

/// Maps route paths to allowed roles. Absent from the map = any authenticated user.
const routeRoles = <String, Set<UserRole>>{
  AppRoutePath.adminArea: {UserRole.admin},
};
```

**Redirect rules:** return `null` to not redirect, a path to redirect. Use `matchedLocation` (not `path`) for exact comparisons: it includes the full path with sub-routes.

## 4. ShellRoute / StatefulShellRoute

Only the app's actual persistent bottom-nav (or top-nav) destinations should be a `StatefulShellBranch`: every other screen (modals, dialogs, detail pages, anything reached via push) is a flat `GoRoute` with `parentNavigatorKey: rootNavigatorKey`, rendered as a sibling page over the shell. Don't promote a screen to a shell branch just because it happens to be reachable from a tab.

```dart
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

ShellRoute(
  navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shell'),
  builder: (_, __, child) => AppShell(child: child),
  routes: [
    GoRoute(path: AppRoutePath.home, name: AppRouteName.home, builder: (_, __) => const HomePage()),
    // ...other tab destinations
  ],
),

GoRoute(
  path: AppRoutePath.detail,
  name: AppRouteName.detail,
  parentNavigatorKey: rootNavigatorKey,
  builder: (_, state) => DetailPage(id: state.pathParameters['id']!),
),
```

`context.push('/route')` from inside a shell branch stacks imperatively within that branch's own navigator: `NavigationBar.selectedIndex` does **not** change. Use `context.go()`, not an imperative pop chain, to return to a shell tab afterward (as long as nothing in the app mixes in raw `Navigator` calls, mixing the two is what makes `context.go()` unreliable).

## 5. Modal & Dialog Routes

go_router has no native "dialog" or "bottom sheet" route type. Build one with `CustomTransitionPage`: the same mechanism `DialogRoute`/`ModalBottomSheetRoute` use internally:

```dart
// modal_page.dart
Page<T> buildDialogPage<T>({required LocalKey key, required WidgetBuilder builder}) =>
    CustomTransitionPage<T>(
      key: key,
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      child: Builder(builder: builder),
    );

Page<T> buildBottomSheetPage<T>({required LocalKey key, required WidgetBuilder builder}) =>
    CustomTransitionPage<T>(
      key: key,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
        // Align (not Column): Column gives infinite height to a main-axis child by
        // default, which breaks any descendant that needs a finite height to compute
        // fractions (e.g. DraggableScrollableSheet).
        child: Align(alignment: Alignment.bottomCenter, child: Builder(builder: builder)),
      ),
      child: const SizedBox.shrink(),
    );

GoRoute(
  path: AppRoutePath.confirmDialog,
  name: AppRouteName.confirmDialog,
  parentNavigatorKey: rootNavigatorKey,
  pageBuilder: (context, state) => buildDialogPage<bool>(
    key: state.pageKey,
    builder: (context) => ConfirmDialog(onConfirm: () => context.pop(true)),
  ),
),
```

Nested pushes (a modal opening another modal) need no special handling: it's just two sequential `context.push()` calls on the root navigator; the inner `pop()` only resolves its own `Future`.

## 6. Navigation from Widgets

```dart
context.pushNamed(AppRouteName.detail, pathParameters: {'id': '42'});
context.goNamed(AppRouteName.home);
context.pop();
context.pop<bool>(true);
context.pushReplacementNamed(AppRouteName.login);
```

## 7. Navigation from Cubits: bloc_presentation, never raw context

Cubits have no `BuildContext`. Emit a one-shot presentation event and let the widget layer navigate:

```dart
sealed class MyCubitEvent implements BlocPresentationEvent {}
class NavigateToDetail extends MyCubitEvent { const NavigateToDetail(this.id); final String id; }

class MyCubit extends Cubit<MyState> with BlocPresentationMixin<MyState, MyCubitEvent> {
  void onConfirm(String id) => emitPresentation(NavigateToDetail(id));
}

BlocPresentationListener<MyCubit, MyCubitEvent>(
  listener: (context, event) => switch (event) {
    NavigateToDetail(:final id) => context.pushNamed(AppRouteName.detail, pathParameters: {'id': id}),
  },
  child: MyView(),
)
```

## 8. Passing Arguments

Prefer `extra:` over path/query params for complex or type-safe data; use path params for IDs, query params for optional filters.

- **No data, no callback:** pass nothing.
- **Data only, no callback:** pass the value directly via `extra:`, no wrapper class needed.
- **Multiple fields and/or callbacks that fire *during* the flow** (not reducible to a final pop value): a small plain (non-freezed) args class co-located with the screen, e.g. `DetailArgs { item, onAction }`.
- **A callback that only ever fires once, right before pop:** eliminate it: return a typed value from the pushed route instead: `final result = await context.push<ConfigResult>(AppRouteName.config, extra: item); if (result != null) { ... }`.

## 9. Route-Level Cubit Provisioning (mandatory)

Every Cubit/Bloc a route needs is provided at the `GoRoute` `builder`/`pageBuilder` level, never instantiated inside a Page's `build()`:

```dart
GoRoute(
  path: AppRoutePath.home,
  name: AppRouteName.home,
  builder: (context, state) => MultiBlocProvider(
    providers: [
      BlocProvider<HomeCubit>(create: (_) => getIt<HomeCubit>()),
    ],
    child: const HomePage(),
  ),
),
```

Creating a Cubit inline in a Page's `build()` recreates it on every rebuild (losing state), breaks the "Pages are dumb presentation widgets" principle, and forces widget tests to provide the Cubit manually instead of exercising the real DI path.

**Sibling routes needing the same Cubit:** route-level provisioning only reaches *descendants* of that route. When a non-nested sibling route (e.g. a review screen reached by `push` rather than nested under the originating route) also needs the same Cubit instance, promote it to an app-root singleton (registered alongside the global auth Bloc) instead of trying to share a route-scoped provider:

```dart
// app root
MultiBlocProvider(
  providers: [
    BlocProvider<AppAuthBloc>(create: (_) => getIt<AppAuthBloc>()),
    BlocProvider<SharedFeatureCubit>(create: (_) => getIt<SharedFeatureCubit>()),
  ],
  child: MaterialApp.router(...),
)
```

Only promote the specific Cubit a sibling route actually needs: Cubits that stay scoped to a single shell branch should stay provisioned at that branch's `MultiBlocProvider`, not the app root. Turning a Cubit into a singleton means it now persists across visits, any method that "starts a new flow" (e.g. resetting a cart) must explicitly clear state left over from the previous visit, since nothing else will.

**Context-capture pitfall:** never capture the `context` received in a `build(BuildContext context)` for use in a later callback if that same `build()` also creates the `Provider`/`BlocProvider` the callback needs to read: that `context` is an *ancestor* of what `build()` returns, not a descendant, so `context.read<T>()` inside the callback throws `ProviderNotFoundException` at the moment it fires (not at analyze time). Fix: wrap the child in a `Builder` to get a descendant context, or apply route-level provisioning per above.

## 10. Named Routes (recommended standard)

Hard-coded path strings at call sites (`context.push('/detail')`) are fragile: a typo isn't a compile error, and renaming a path requires a manual grep. Centralize both names and paths:

```dart
abstract class AppRouteName {
  static const home = 'home';
  static const detail = 'detail';
}

abstract class AppRoutePath {
  static const home = '/home';
  static const detail = '/detail/:id';
}
```

- Only the file declaring `GoRoute(path:, name:)` (and the `redirect` callback, which only sees raw paths) references `AppRoutePath` directly.
- Everywhere else navigates by name: `context.pushNamed(AppRouteName.x, ...)`, never `context.push('/x')`.
- Every `GoRoute` needs `name:` filled in: without it, `pushNamed`/`goNamed` throws at runtime, not analyze time.
- **Test harnesses:** any local `GoRouter` in a widget test that registers a route also targeted by `pushNamed` in production code needs `name:` on that test route too, or the widget under test throws `GoException` trying to resolve a name the local router doesn't have. Purely local test-bootstrap routes that production code never targets by name don't need one.

## 11. Testing

```dart
testWidgets('redirects to login when unauthenticated', (tester) async {
  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) =>
        notifier.status != AuthStatus.authenticated && state.matchedLocation != '/login' ? '/login' : null,
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const Text('Login')),
      GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  expect(find.text('Login'), findsOneWidget);
});
```

A screen that navigates via `context.push`/`pushNamed` needs a real `GoRouter` in its widget-test harness: a bare `MaterialApp` without a router throws. This applies to every screen that *triggers* a push (opening a modal, etc.), not just the pushed screen's own tests, reuse the app's real `pageBuilder` in the harness rather than re-implementing it.

## Quick Reference

| Task | Code |
|---|---|
| Push named route | `context.pushNamed(AppRouteName.x, pathParameters: {...})` |
| Go named route | `context.goNamed(AppRouteName.x)` |
| Pop / pop with result | `context.pop()` / `context.pop<T>(value)` |
| Navigate from Cubit | `emitPresentation(Event())` → `BlocPresentationListener` → `context.pushNamed()` |
| Auth guard | `redirect:` + `refreshListenable` on `GoRouter` |
| RBAC guard | Check a route→roles map inside `redirect` |
| Modal/dialog route | `pageBuilder` returning `buildDialogPage`/`buildBottomSheetPage` |
| Sibling routes sharing state | Promote the Cubit to an app-root singleton |
