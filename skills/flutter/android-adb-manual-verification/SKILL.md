---
name: android-adb-manual-verification
description: "Manual on-device verification of an Android/Flutter app via ADB, without a human physically tapping the screen: screenshot/scale/tap loop, coordinate-scaling math, adb shell input text limitations and character-by-character workaround, a keyevent reference table, and a checklist for telling a real regression apart from bad test data/stale session/coordinate-math mistakes. Invoke when a task calls for a manual on-device verification pass beyond automated tests."
---

# Android ADB Manual Verification Skill

## Overview

Some bug classes only manifest at runtime on a real device/emulator and are invisible to static analysis, unit/widget tests, and even scripted E2E flows: DI wiring order bugs, provider-scoping bugs from a widget tree assembled differently than a test harness assumes, environment-gating bugs, visual/layout breakage only visible at real screen dimensions, and state-leakage bugs from long-lived singletons that only show up navigating the app in realistic order.

**This is not a substitute for automated tests**: run those first, they're cheaper and catch more mundane regressions. Manual verification is the last-mile check for the class of bug that only appears when the full app, real DI, and real widget tree run together.

## 1. Prerequisites

```bash
adb devices                                              # confirm target device/emulator is listed and "device" (not "offline")
adb -s <device-id> shell getprop sys.boot_completed       # "1" once fully booted
```

- The app must be built/installed in a mode that talks to a real or mock backend: confirm the backend is reachable (`curl <health-endpoint>`) **before** starting; a down backend produces misleading error screens that look like app bugs.
- Write screenshots to a scratch directory, never directly into the repo.

## 2. The Core Loop

Every interaction is the same four-step loop. **Never tap blind**: screenshot before *and* after any tap you're not certain of, especially after navigation, a dialog, or a keyboard toggle (the on-screen keyboard shifts every coordinate below it).

1. **Screenshot** to a scratch PNG, incrementing a counter (`verify01.png`, `verify02.png`, ...): never overwrite, so you can scroll back through the sequence if something diverges:
   ```bash
   adb -s <device-id> exec-out screencap -p > "$SCRATCHPAD/verifyNN.png"
   ```
2. **Read** the screenshot (a multimodal image read includes an annotation like `[Image: original 1080x2424, displayed at 891x2000. Multiply coordinates by 1.21 to map to original image.]`). **This annotation is authoritative and can change per screenshot**: don't reuse a multiplier computed from a previous one. Compute fresh each time: `factor = original_width / displayed_width` (should agree with the height-based ratio; if it doesn't, re-screenshot).
3. **Compute the real tap coordinate**: read the target's position off the *displayed* image, then `real_x = round(displayed_x * factor)`, `real_y = round(displayed_y * factor)`. Tap in real device-pixel space: `adb shell input tap` operates on the original dimensions, not the preview.
4. **Act, then re-screenshot** to confirm the action landed as intended:
   ```bash
   adb -s <device-id> shell input tap <real_x> <real_y>
   adb -s <device-id> exec-out screencap -p > "$SCRATCHPAD/verifyNN.png"
   ```
   If the result doesn't match expectation, don't guess and retap: re-read, recompute from scratch. Tapping repeatedly without re-observing compounds mistakes (a missed tap can land on the wrong element, silently changing which flow you're now in).

### Common failure mode: tapping "through" a modal

A tap at the coordinate an element *would* occupy if a bottom sheet/dialog weren't open lands **inside the modal instead**: it does not pass through. Check the current screenshot for an open modal before computing coordinates for anything expected to be underneath it; close it first if so.

## 3. Text Entry

`adb shell input text "..."` has real limitations:

- **ASCII-only**: can't type accented characters. Use accent-free test data where the field allows it.
- **A bare space argument fails** (`IllegalArgumentException: Argument expected after "text"`). For a literal space mid-string, send it as its own keyevent: `adb shell input keyevent KEYCODE_SPACE`.
- **Unreliable for some punctuation/special-character sequences** sent as one long string: characters can drop or reorder. For anything that must be exact (PINs, formatted values with separators), type character-by-character with a small delay:
  ```bash
  for ch in 0 4 : A B : C D : E F; do
    adb -s <device-id> shell input text "$ch"
    sleep 0.05
  done
  ```
- **Wrong-field entry recovery**: if focus lagged behind a screen transition and text landed in the wrong field, don't fight it: tap the wrong field, clear it, tap the correct field, retype:
  ```bash
  adb -s <device-id> shell input keyevent KEYCODE_DEL          # backspace
  adb -s <device-id> shell input keyevent KEYCODE_FORWARD_DEL  # forward-delete
  ```
  Re-screenshot to confirm the field is actually empty before retyping: don't assume the delete count was right.

## 4. Keyevent Reference

| Keyevent | Effect |
|---|---|
| `66` / `KEYCODE_ENTER` | Enter/"Done" on the soft keyboard |
| `4` / `KEYCODE_BACK` | Hardware back: for apps using a declarative router, confirm it correctly pops routes the same way an in-app back affordance does |
| `67` / `KEYCODE_DEL` | Backspace |
| `112` / `KEYCODE_FORWARD_DEL` | Forward-delete |
| `62` / `KEYCODE_SPACE` | Literal space (use instead of a bare space in `input text`) |

## 5. Real Regression vs. Noise

Before treating something as a regression in the code under verification, rule out the mundane explanations, roughly in order of likelihood:

1. **Bad test data, not a code bug**: sanity-check the input you fed the app is actually valid for that field before assuming the app is broken.
2. **Pre-existing bug, unrelated to the change under verification**: read the source of the misbehaving widget and check whether the current branch's diff touched that code path at all. If not, file it as a separate issue rather than scope-creeping a fix into the branch being verified.
3. **Environment/session staleness, not a code bug**: an auth error after a long testing session can be normal token expiry rather than a regression, especially if the token-refresh path wasn't touched. Re-authenticate and continue rather than chasing it.
4. **Your own coordinate math**: if a tap visibly "does nothing" or hits the wrong element, re-check the scaling factor and arithmetic (§2) before concluding the UI is broken. This is the most common cause of an apparently-failed manual step.

Only after ruling out 1–4 should something be treated as a genuine regression.
