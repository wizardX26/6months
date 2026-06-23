# GlassUIKit — Gesture Engine Demo

Reference implementation of [`uikit-custom-gesture-engine-guide.md`](../architecture/uikit-custom-gesture-engine-guide.md) for a **pure UIKit** project.

## Bootstrap (Phase 0)

```
main.swift → UIApplicationMain(..., Application, AppDelegate)
SceneDelegate → UIWindow + GlassTabBarController + AppWindowController
```

## Module layout

| Folder | Maps to guide |
|--------|----------------|
| `GestureEngine/Foundation/` | Phase 1 — UIView flags, GestureHost, utilities |
| `GestureEngine/Recognizers/` | Phase 2–4 — leaf + core recognizers |
| `GestureEngine/Navigation/` | Phase 5 — full-width swipe back |
| `GestureEngine/Window/` | Phase 5 optional — keyboard pan |
| `GestureEngine/UI/` | Phase 6–7 — ContextGesture host, declarative gesture attach |
| `TabBar/` | Glass tab bar + search shell |
| `Screens/` | Phase 7–8 — demo + verify checklist |

## Demo screens

1. **Swipe back** — pan ngang toàn màn hình (`InteractiveTransitionGestureRecognizerDirections.right`)
2. **Horizontal scroll** — `disablesInteractiveTransitionGestureRecognizer = true`
3. **Context menu** — `ContextControllerSourceView` + long-press
4. **Keyboard** — `AppWindowController` + `WindowPanRecognizer`
5. **Component gesture** — `GestureAttachableView.updateGestures`

## Build

Open `GlassUIKit.xcodeproj` in Xcode and run on simulator.

## License

This project is licensed under the **GNU General Public License v2.0 or later**
(GPL-2.0-or-later). See [`NOTICE.md`](NOTICE.md) for upstream attribution.

- Full license text: [`LICENSE`](LICENSE)

## Notes

- Uses Swift associated objects instead of ObjC `RuntimeUtils` (guide §5.1 option B).
- `KeyboardManager` private API is **not** ported; keyboard height via `keyboardWillChangeFrame` (guide §22.8).
- Interactive pop uses `UIPercentDrivenInteractiveTransition` instead of a custom navigation transition coordinator.
