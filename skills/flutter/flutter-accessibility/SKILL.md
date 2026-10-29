---
name: flutter-accessibility
description: "Flutter accessibility (a11y) guidelines based on Flutter's own accessibility docs and WCAG 2.1 AA: no TextOverflow.ellipsis, mandatory widget-test guideline validation, minimum touch target sizes, Semantics/MergeSemantics/ExcludeSemantics/Tooltip usage, Semantics(identifier:) vs Key, large-font/dynamic-type support, color contrast and the inactive-UI exemption, state in value and action in onTapHint, live-region and Cubit-driven announcements, tap-target padding gotchas, keyboard focus, and semantics assertions in tests. Invoke when building or reviewing any UI widget, or writing a widget test."
---

# Flutter Accessibility (a11y) Skill

Grounded in [Flutter's accessibility docs](https://docs.flutter.dev/ui/accessibility) and WCAG 2.1 Level AA.

## 1. Core Principles

Flutter bridges to platform assistive technologies (TalkBack on Android, VoiceOver on iOS/macOS, NVDA/JAWS on Windows). Relevant standards: **WCAG 2** (web/digital content), **EN 301 549** (EU ICT accessibility), **VPAT** (accessibility requirements translation).

## 2. Two Rules Worth Making Mandatory

### No `TextOverflow.ellipsis`

Text truncation with ellipsis breaks screen readers and large font scaling. Use responsive layouts (scroll containers, multi-line wrapping) instead of truncating.

### Every widget test validates accessibility guidelines

```dart
await tester.expectMeetsAccessibilityGuidelines();
```

This runs Flutter's 4 standard guidelines: `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`.

## 3. Minimum Touch Target Sizes

| Platform | Minimum | Guideline |
|---|---|---|
| Android | 48×48dp | `androidTapTargetGuideline` |
| iOS/iPadOS | 44×44dp | `iOSTapTargetGuideline` |

```dart
ConstrainedBox(
  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  child: IconButton(icon: const Icon(Icons.payment), onPressed: onTap, tooltip: l10n.payButtonTooltip),
)
```

Material components enforce this automatically; custom interactive widgets need explicit `ConstrainedBox`/`Padding`.

## 4. Semantics

### `Semantics`

```dart
Semantics(
  label: l10n.cardLabel(name),
  hint: l10n.cardHint,
  button: true,
  child: InkWell(onTap: onTap, child: Card(...)),
)
```

### `MergeSemantics`

Group a composite widget into one screen-reader focus node:

```dart
MergeSemantics(child: Row(children: [Icon(...), Text(name), Text(status)]))
```

### `ExcludeSemantics`

Hide purely decorative elements from screen readers:

```dart
ExcludeSemantics(child: Icon(Icons.arrow_forward_ios))
```

### `Tooltip`

Icon-only interactive elements (icon buttons, FABs) must provide `tooltip` or an explicit `Semantics.label`. One of them, not both with the same text:

- **Don't repeat the label in the tooltip.** iOS appends the tooltip to the accessibility label, so `Semantics(label: 'Increase')` around `IconButton(tooltip: 'Increase')` reads "Increase, Increase, button". If you need both, keep the tooltip visual-only: `Tooltip(message: ..., excludeFromSemantics: true)` and no `tooltip:` on the `IconButton`.
- **Never put a `Tooltip` inside `MergeSemantics`.** `Tooltip` is built on `OverlayPortal`, which tags its child's semantics node with a `traversalParentIdentifier`. Inside a merge that node is merged away and never reaches the platform, and the iOS accessibility bridge then drops the tree of the **whole screen**: XCUITest/Appium only sees empty `XCUIElementTypeOther` containers. Android/TalkBack keeps working, so it's easy to miss. `IconButton(tooltip:)` creates a `Tooltip` too. Wrap the other way around:

  ```dart
  Tooltip(
    message: label,
    excludeFromSemantics: true,
    child: MergeSemantics(
      child: Semantics(label: label, child: IconButton(onPressed: onPressed, icon: icon)),
    ),
  )
  ```

### `Semantics.identifier` (Flutter 3.19+): not the same as a `Key`

A plain `Key('foo')` is invisible to the platform accessibility tree (Android `resource-id`/iOS accessibility identifier): it never reaches TalkBack/VoiceOver, and it's also what most Flutter E2E test frameworks' element selectors read instead of `Key`.

```dart
Semantics(identifier: 'addItemCta', child: AppButton(key: const Key('addItemCta'), ...))
```

Keep the `Key` too: widget tests still use it via `find.byKey`; `identifier` is additive.

**Merged semantics note:** adjacent `Text` widgets under a shared `Semantics` ancestor (e.g. a card's name + description) get announced as one combined multi-line node, not two separate ones: worth knowing when writing `label`/`hint` on a wrapping `Semantics`, since it composes with the merged children text rather than replacing it. The same merging affects E2E selectors that try to match just one of the merged text nodes.

**Empty-string label gotcha:** `Semantics(label: '')` (explicit empty string, not omitted/`null`) still composes with descendant text the same way: it does not blank out a non-empty child label. The failure mode only shows up when *both* the explicit label and every merged child are empty: the node ends up with no label at all and fails `labeledTapTargetGuideline`. This is easy to miss when a wrapping component defaults its `label` param to `''` and silently relies on a child `Text`/`heading` to supply the real label through merge, it works until that child text is ever legitimately blank.

## 5. Large Fonts / Dynamic Type

- Never hardcode container heights for text wrappers (`height: 40`): let them expand.
- Allow multi-line wrapping (`maxLines: null` or default wrapping) instead of restricting lines.
- Wrap pages/cards in `SingleChildScrollView`/`ListView` so they tolerate expanded font sizes.

## 6. Color Contrast

- Minimum 4.5:1 for normal text (WCAG 2.1 AA).
- Use paired `ColorScheme` roles: `primary` on `surface`/`onPrimary`, `onPrimaryContainer` on `primaryContainer`, etc.
- Avoid low-opacity foregrounds on chips/badges: use the matching `onContainer` role for full contrast.
- **Inactive UI is exempt** (WCAG 1.4.3). When a low-contrast color deliberately communicates "disabled/unavailable", mark the node `Semantics(enabled: false)` instead of darkening the color; `textContrastGuideline` skips disabled nodes. Fix the semantics, not the color.
- If a design system component itself fails contrast, fix it in the design system package, not with an app-side color override.

## 7. Name, Role, Value (SC 4.1.2)

- **Pass explicit labels.** If a component exposes `label`/`semanticsLabel`, pass it. Relying on a child `Text` to supply the label through merge breaks the day that text is empty (see the empty-string gotcha in §4).
- **State in `value`, action in `onTapHint`.** TalkBack doesn't announce the `checked` flag when unchecked, so "not selected" is never read:
  ```dart
  Semantics(
    label: name,
    value: selected ? l10n.selected : l10n.notSelected,
    onTapHint: selected ? l10n.remove : l10n.add,
    enabled: onTap != null,
    onTap: onTap,
    excludeSemantics: true,
    child: ...,
  )
  ```
  Mark non-actionable items `enabled: false` instead of leaving a dead button.
- **Never interpolate nullable values into labels.** `'$label $price'` with a null value is announced as "null". Build the string conditionally.
- **One stop per action.** Exclude images that repeat adjacent text. In grids, wrap each card in `Semantics(container: true, explicitChildNodes: true)` so the reader finishes one card before moving to the next.
- **Forms:** `Semantics(isRequired: true)` on required fields and `validationResult` (`SemanticsValidationResult.valid/invalid`) alongside `errorText`.
- **Headings:** `Semantics(header: true, headingLevel: n)` on structural titles; one level 1 per page, no skipped levels.
- **Identifiers are for automation only**; screen readers don't read them. Accessibility fixes must not rename existing identifiers.

## 8. Status Messages (SC 4.1.3)

- Regions that change without focus moving (loading, errors, totals): `Semantics(liveRegion: true)`.
- Values a Cubit changes in place (quantity counters, step indicators): announce from a `BlocListener`/`BlocConsumer` gated with `listenWhen` on that value only, so unrelated state changes stay silent:
  ```dart
  BlocListener<ItemCubit, ItemState>(
    listenWhen: (previous, current) => previous.quantity != current.quantity,
    listener: (context, state) => SemanticsService.sendAnnouncement(View.of(context), '${state.quantity}', TextDirection.ltr),
  )
  ```

## 9. Tap Target Gotchas

- Padding **inside** the tappable counts toward the target (with `HitTestBehavior.opaque` on a `GestureDetector`); padding **outside** only adds space. Moving padding outward silently shrinks the target with no visual change.
- Padding inside a fixed-size parent (app bars, fixed-height rows) squeezes the button.
- `IconButton` guarantees 48x48 by default; custom `padding`, `constraints`, `visualDensity` or `MaterialTapTargetSize.shrinkWrap` can drop it.
- A grown target can overlap its neighbour; the guideline doesn't catch that, so verify on device.

## 10. Keyboard and Focus (web and desktop)

- Group related controls with `FocusTraversalGroup`; use `OrderedTraversalPolicy` + `FocusTraversalOrder` only when reading order is wrong.
- Create `FocusNode`s in `State`, dispose them, give them a `debugLabel`; never allocate one per build or share one between widgets.
- Custom tappables need a visible focus state (`Focus(onFocusChange: ...)`).
- Respect `MediaQuery.disableAnimationsOf(context)` in custom `AnimationController` animations.

## 11. Testing Beyond the Guidelines

- Guidelines only prove a label exists. Assert **what** is announced, per state:
  ```dart
  expect(tester.getSemantics(find.byType(X)), isSemantics(label: 'Name', value: l10n.selected, isEnabled: true, hasTapAction: true, onTapHint: l10n.remove));
  ```
- Assert announcements with `tester.takeAnnouncements()`, including the negative case (an unrelated state change produces none).
- When a widget combines an `OverlayPortal` (`Tooltip`, menus) with `MergeSemantics`, assert that no merged-away node keeps the traversal link. It's the only widget-test signal for the iOS empty-tree bug from §4:
  ```dart
  expect(find.semantics.byPredicate((node) => node.isMergedIntoParent && node.traversalParentIdentifier != null), findsNothing);
  ```
- Test at `TextScaler.linear(2)` (not the deprecated `textScaleFactor`) and expect `tester.takeException()` to be null.
- **Blank mock data causes false failures.** A factory or mock defaulting a display name to `''` makes `labeledTapTargetGuideline` fail even though production data is never blank. Use realistic text before reaching for an opt-out.
- **Opt-outs** of the guideline check must carry the ticket of the tech debt next to them. "Missing labels" is never a valid long-term reason.
- Platform views (maps, web views) throw `MissingPluginException` during guideline checks; swap them for a test builder or a fake platform, never a test-only parameter on the production page.

## 12. Pre-Submission Checklist

- [ ] All widget tests run `expectMeetsAccessibilityGuidelines()`.
- [ ] No `TextOverflow.ellipsis` anywhere in the diff.
- [ ] Icon buttons/FABs have `tooltip` or `Semantics(label:)`, not both with the same text, and no `Tooltip` nested inside `MergeSemantics`.
- [ ] Decorative icons excluded from the semantics tree.
- [ ] Selectable items expose state in `value` and action in `onTapHint`; no `null` in any label.
- [ ] Headings marked; dynamic regions are live regions.
- [ ] Padding changes keep tappables at 48x48 without overlapping neighbours.
- [ ] Layout tested at maximum system font scale.
- [ ] Navigation tested with TalkBack (Android) or VoiceOver (iOS), and keyboard on web.
