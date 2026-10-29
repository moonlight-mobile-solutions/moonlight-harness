---
name: flutter-responsive-design-system
description: "Responsive/adaptive layout system for Flutter (breakpoint enum, BuildContext extension, layout-swap widget, spacing/sizing tokens) plus Material Design 3 theming rules (ColorScheme-only colors, ThemeData-only customization, textTheme-only typography) and general adaptive-design best practices from Flutter's own docs. Invoke when building a page that must work across phone/tablet/desktop, or customizing an M3 theme."
---

# Flutter Responsive Design System Skill

## 1. Responsive System

### Breakpoints (adapt the widths to the project)

| Name | Typical min width | Typical use |
|---|---|---|
| `mobile` | 0px | Phones, default stack layout |
| `tablet` | ~600–640px | Wider forms, split-pane |
| `desktop` | ~1024px | Web, side-by-side layouts |

### Suggested File Structure

```
lib/core/common/responsiveness/
├── breakpoint.dart               # Breakpoint enum
├── responsive_extension.dart     # BuildContext extension
├── app_responsive_layout.dart    # Layout swap widget
├── app_responsive_tokens.dart    # Responsive spacing/sizing
└── app_grid.dart                 # Grid column helpers
```

### BuildContext Extension

```dart
enum Breakpoint { mobile, tablet, desktop }

extension ResponsiveContext on BuildContext {
  Breakpoint get breakpoint {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= 1024) return Breakpoint.desktop;
    if (width >= 640) return Breakpoint.tablet;
    return Breakpoint.mobile;
  }

  bool get isMobile => breakpoint == Breakpoint.mobile;
  bool get isTablet => breakpoint == Breakpoint.tablet;
  bool get isDesktop => breakpoint == Breakpoint.desktop;

  T responsive<T>({required T mobile, T? tablet, required T desktop}) => switch (breakpoint) {
        Breakpoint.mobile => mobile,
        Breakpoint.tablet => tablet ?? mobile,
        Breakpoint.desktop => desktop,
      };
}
```

### Layout-Swap Widget

```dart
class AppResponsiveLayout extends StatelessWidget {
  const AppResponsiveLayout({required this.mobile, this.tablet, required this.desktop, super.key});
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) => context.responsive<Widget>(mobile: mobile, tablet: tablet, desktop: desktop);
}
```

### Spacing/Sizing Tokens

```dart
abstract class AppResponsiveTokens {
  static double pagePadding(BuildContext context) => context.responsive(mobile: 16.0, tablet: 24.0, desktop: 40.0);
  static double cardPadding(BuildContext context) => context.responsive(mobile: 12.0, tablet: 16.0, desktop: 20.0);
  static double maxContentWidth(BuildContext context) =>
      context.responsive(mobile: double.infinity, tablet: 720.0, desktop: 1200.0);
}
```

## 2. Material Design 3 Theming

- **`useMaterial3: true` mandatory**: never `false`.
- **`ColorScheme` only**: never hardcoded hex or `Colors.*` constants in widgets: `Theme.of(context).colorScheme.primary`, not `Color(0xFF...)`.
- **Theme, not inline**: customize widgets via `ThemeData`'s `XxxThemeData` properties (`cardTheme`, `inputDecorationTheme`, `filledButtonTheme`, ...), never via inline widget-level style overrides when a theme property exists.
- **`textTheme` only**: `Theme.of(context).textTheme.headlineMedium`, never a raw `TextStyle(fontSize:, fontWeight:)`.
- **No `Theme.of(context).copyWith()`** in widget trees: that partially re-creates a theme per widget instance, expensive and defeats global theming.

### M3 Widget → ThemeData Property Map

| Widget | Property | Widget | Property |
|---|---|---|---|
| `ElevatedButton` | `elevatedButtonTheme` | `Card` | `cardTheme` |
| `TextButton` | `textButtonTheme` | `Chip`/`FilterChip` | `chipTheme` |
| `OutlinedButton` | `outlinedButtonTheme` | `Dialog` | `dialogTheme` |
| `FilledButton` | `filledButtonTheme` | `BottomSheet` | `bottomSheetTheme` |
| `FloatingActionButton` | `floatingActionButtonTheme` | `NavigationBar` | `navigationBarTheme` |
| `TextField`/`TextFormField` | `inputDecorationTheme` | `AppBar` | `appBarTheme` |

## 3. Adaptive Design Best Practices

> Source: [Flutter Adaptive & Responsive Design](https://docs.flutter.dev/ui/adaptive-responsive)

- **Responsive** = layout adjusts to fit available space (columns, wrapping). **Adaptive** = the right *component* for the space (`NavigationBar` vs `NavigationRail`). Aim for both.
- **`LayoutBuilder`/`MediaQuery.sizeOf`, never `OrientationBuilder`** for layout decisions: orientation doesn't reflect actual available space (multi-window, foldables).
- **Never branch on device type** (`if (isTablet)`): branch on `MediaQuery.sizeOf(context).width`, since window size isn't tied to physical screen size (multi-window, ChromeOS, foldables).
- **Constrain content width on large screens**: `ConstrainedBox(constraints: BoxConstraints(maxWidth: ...))` around forms/content rather than stretching full width. Rough guidance: ~480px for forms, ~720px for content, ~1200px as an overall max.
- **`SafeArea`** around `Scaffold` bodies for notches/status bars: nested `SafeArea`s compose correctly without duplicated padding.
- **`.adaptive()` constructors** (`Switch.adaptive()`, `CircularProgressIndicator.adaptive()`, `RefreshIndicator.adaptive()`, `Checkbox.adaptive()`) for platform-native appearance.
- **Small, `const` widgets**: improves rebuild performance and lets parts be swapped independently per breakpoint.
- **Touch-first, then add mouse/keyboard layers** (hover, right-click, shortcuts, tab navigation) on top of a solid touch UI.
- **`PageStorageKey`** to preserve scroll position across widget destroy/recreate (e.g. orientation change): `ListView(key: PageStorageKey('my_list'), ...)`.
- **Don't lock orientation**: an accessibility concern, breaks large-format Android tiers, and letterboxes on foldables. If truly unavoidable, use the `Display` API rather than `MediaQuery` for physical dimensions.

## 4. Token-Based Component System (optional pattern)

A 3-tier token architecture works well for larger design systems:
1. **Primitive tokens**: base spacing/radius/elevation/touch-target values.
2. **Semantic tokens**: contextual roles (`touchTargetMin = 48.0` for WCAG AA, `buttonHeight`, `inputHeight`).
3. **Component tokens**: pre-styled reusable widgets (a button, card, chip, empty/error state) consuming the semantic tokens via a `ThemeExtension`.

```dart
final tokens = context.tokens; // a ThemeExtension<AppDesignTokens> accessor
Padding(padding: EdgeInsets.all(tokens.spacingMd), child: AppButton(label: 'Save', onPressed: onSave));
```
