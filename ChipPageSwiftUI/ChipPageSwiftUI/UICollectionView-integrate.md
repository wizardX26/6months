# UICollectionView Integration Plan

## Goal

Integrate `UICollectionView` into the SwiftUI app through `ChipPageSwiftUI/UIKitRepresentation` as the dedicated bridge layer. SwiftUI remains the app composition and state owner; UIKit is used only where `UICollectionView` gives stronger control over layout, reuse, scrolling, selection, and performance.

The bridge should make UIKit behavior available to SwiftUI without leaking UIKit lifecycle details into feature views.

## Architecture Mindset

SwiftUI and UIKit have different models:

- SwiftUI views are value descriptions that can be recreated often.
- UIKit views are reference objects with explicit lifecycle, delegates, reuse, and mutation.
- SwiftUI expects declarative state flow.
- UIKit expects imperative updates at the right time.

The bridge layer exists to absorb that mismatch.

`UIKitRepresentation` should own:

- `UIViewRepresentable` wrappers.
- `Coordinator` objects.
- `UICollectionViewDelegate` and related delegate methods.
- Diffable data source setup and snapshot application.
- Cell and supplementary-view registration.
- Layout construction and invalidation.
- UIKit-only measurement, scrolling, focus, and gesture logic.

SwiftUI feature views should own:

- Source-of-truth state.
- Data models passed into the collection view.
- User intent handlers.
- View composition around the UIKit component.
- App-level navigation, presentation, and environment state.

The main rule: SwiftUI describes what should be shown; UIKitRepresentation decides how `UICollectionView` realizes it.

## Proposed Bridge Shape

Start with a small, explicit wrapper rather than a generic bridge that tries to support every collection-view feature.

```swift
struct ChipCollectionView<Item: Identifiable>: UIViewRepresentable {
    let items: [Item]
    let selection: Item.ID?
    let onSelect: (Item.ID) -> Void

    func makeUIView(context: Context) -> UICollectionView {
        context.coordinator.makeCollectionView()
    }

    func updateUIView(_ collectionView: UICollectionView, context: Context) {
        context.coordinator.update(
            collectionView,
            items: items,
            selection: selection
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }
}
```

The real implementation can use a concrete item model first. Add generics only when there is more than one actual collection-view use case.

Recommended files under `UIKitRepresentation` when implementation begins:

- `ChipCollectionView.swift`: SwiftUI-facing `UIViewRepresentable`.
- `ChipCollectionViewCoordinator.swift`: delegate, data source, and callback bridge.
- `ChipCollectionViewLayout.swift`: compositional layout or flow layout construction.

Keep public SwiftUI-facing inputs small. Add new inputs only when a feature view needs them.

## State And Data Flow

Use one-way data flow by default:

1. SwiftUI owns source-of-truth state.
2. SwiftUI passes render input into `ChipCollectionView`.
3. `updateUIView` forwards the latest input to the coordinator.
4. The coordinator applies UIKit updates.
5. UIKit events call closures back into SwiftUI.
6. SwiftUI updates state, which triggers another render pass.

Avoid these patterns:

- Storing source-of-truth business state only inside the coordinator.
- Mutating SwiftUI bindings from inside cell configuration.
- Calling SwiftUI callbacks during every `updateUIView` pass.
- Rebuilding the collection view in `updateUIView`.
- Applying snapshots when the item identity and content have not changed.

For selection, use SwiftUI as the source of truth:

- UIKit delegate reports user selection through `onSelect`.
- SwiftUI updates `selection`.
- `updateUIView` applies the selected visual state if needed.

This prevents UIKit and SwiftUI from disagreeing about what is selected.

## UIKit vs SwiftUI Conflict Checklist

### Lifecycle

`makeUIView` should create UIKit objects once. `updateUIView` should mutate the existing collection view to match current SwiftUI input.

Do not assume `updateUIView` means "new screen" or "new component." It can be called frequently for unrelated SwiftUI changes.

Coordinator lifecycle is tied to the representable instance, but it can outlive individual SwiftUI view value recreations. Store only bridge state there, not feature state.

### Identity And Diffing

SwiftUI identity and collection-view identity must agree.

Each item needs a stable identifier. Do not use array indexes as identifiers unless the list is truly static and never reorders, inserts, deletes, or filters.

If using `UICollectionViewDiffableDataSource`, item identifiers must be hashable, stable, and represent logical identity. Visual content changes should update cells without pretending the item is a different object.

### Layout Ownership

UIKit owns collection-view layout. SwiftUI owns the outer frame and surrounding composition.

Decide layout inputs explicitly:

- item size policy
- section spacing
- content inset
- scroll direction
- estimated vs fixed sizing
- safe-area behavior

Avoid mixing SwiftUI layout assumptions with UIKit auto layout assumptions. If cells host SwiftUI content, define clear sizing behavior and test dynamic type.

### Updates And Reload Timing

Prefer diffable snapshots or targeted updates over `reloadData`.

Apply snapshots on the main actor. Avoid applying a new snapshot during an active batch update or while another snapshot is still animating.

Use animated updates only when they improve user understanding. Disable animation for large data changes, initial load, or state restoration.

### Cell Reuse

Cells must be fully configured every time. Reused cells should not keep stale selection, loading, gesture, image, task, or accessibility state.

If a cell starts async work, cancellation must be tied to reuse. If the app later loads remote images, add cancellation in `prepareForReuse`.

### SwiftUI Content Inside Cells

If cells host SwiftUI views through `UIHostingConfiguration` or a hosting controller, keep the hosted view stateless or driven by explicit item input.

Avoid giving each cell its own independent SwiftUI source of truth unless that state is intentionally local to the cell.

Watch for:

- unstable identity causing hosted SwiftUI views to reset
- expensive hosted view creation during fast scrolling
- environment values not matching the parent SwiftUI hierarchy
- dynamic type or layout changes not invalidating collection layout

### Delegates And Callbacks

UIKit delegates should translate UIKit events into SwiftUI intentions.

Good callback examples:

- `onSelect(id)`
- `onAppearItem(id)`
- `onReachEnd()`
- `onScroll(offset)`

Avoid callbacks that expose raw UIKit objects to feature views unless there is no cleaner alternative.

### Gestures And Scrolling

`UICollectionView` has its own scroll and gesture system. Conflicts can appear when it sits inside SwiftUI scroll views, pagers, sheets, navigation stacks, or custom gestures.

Avoid placing a vertical `UICollectionView` inside a vertical SwiftUI `ScrollView` unless there is a specific coordination plan.

For nested scrolling, decide which view owns:

- pan gestures
- bounce behavior
- keyboard dismissal
- scroll indicators
- scroll-to-item commands
- refresh behavior

### Main Actor And Threading

UIKit work must happen on the main actor.

Keep model transformation and expensive diff preparation outside the hot UIKit path when possible, but apply final collection-view mutations on the main actor.

Do not call UIKit from background tasks.

### Memory Management

Coordinators, data sources, cells, and closures can easily create retain cycles.

Use weak references when a closure stored by UIKit captures a coordinator or view controller-like object. Do not let cells own long-lived closures that strongly capture feature state objects.

The bridge should not retain old snapshots, large model arrays, image data, or hosted controllers longer than needed.

### Environment And Appearance

SwiftUI environment changes may need explicit UIKit updates:

- color scheme
- dynamic type
- layout direction
- locale
- accessibility settings
- enabled/disabled state

Treat these as bridge inputs when they affect collection-view layout or cells.

### Navigation And Presentation

UIKit cells should not present screens directly. They should report user intent to SwiftUI, and SwiftUI should perform navigation or presentation.

This keeps navigation consistent with SwiftUI app structure and avoids UIKit presentation state hidden inside reusable cells.

### Accessibility

The bridge owns UIKit accessibility configuration for collection cells and supplementary views.

Each cell should define:

- accessibility label
- accessibility value when selected or stateful
- accessibility traits
- focus order if custom layout needs it

Selection and scrolling should remain understandable with VoiceOver.

## Scaling Rules

Use these rules when the project becomes larger:

- Keep `UIKitRepresentation` as the only place that imports UIKit for bridge code.
- Keep feature views free from `UICollectionView`, delegate, and data-source details.
- Add bridge inputs deliberately; do not pass a large configuration object until repeated use cases prove it is needed.
- Keep coordinator state minimal and derived from SwiftUI input where possible.
- Treat item identity as an API contract.
- Separate layout construction from data-source logic when layout becomes complex.
- Add explicit commands for imperative behavior, such as scroll-to-item, instead of reaching into the collection view from feature views.
- Document any UIKit behavior that SwiftUI callers must understand.

Do not generalize too early. A focused bridge for one chip/page collection view is easier to make correct than a broad wrapper that imitates all of `UICollectionView`.

## Implementation Phases

### Phase 1: Minimal Bridge

Create a concrete collection-view wrapper for the first screen.

Include:

- static or simple dynamic item rendering
- stable item identity
- basic selection callback
- compositional or flow layout
- preview usage from `ContentView`

Use this phase to confirm lifecycle, sizing, and selection behavior.

### Phase 2: Diffable Updates

Add `UICollectionViewDiffableDataSource` when item updates become dynamic.

Include:

- section and item identifiers
- snapshot application guard
- initial-load non-animated snapshot
- optional animated updates for small changes

Measure whether snapshot updates are happening more often than necessary.

### Phase 3: Rich Interaction

Add only the interactions the product needs:

- scroll-to-item command
- visible-item reporting
- paging or snapping
- context menus
- drag and drop
- prefetching

Each interaction should remain expressed as SwiftUI input or callback intent.

### Phase 4: Hardening

Add tests and diagnostics once the bridge is shared by multiple screens.

Cover:

- snapshot identity behavior
- selection synchronization
- reuse correctness
- dynamic type layout
- memory cycle checks during repeated navigation
- large data set scrolling performance

## Testing Strategy

Use manual validation first while the app is small:

- collection view appears inside SwiftUI without layout warnings
- items render and reuse correctly
- selection updates exactly once per tap
- SwiftUI state and UIKit selected state stay synchronized
- scrolling remains smooth with a larger local data set
- rotation and iPad sizes do not break layout
- dynamic type does not clip content

When test targets are added, prefer focused tests around pure bridge logic:

- item identity mapping
- snapshot construction
- layout configuration decisions
- callback translation

UI tests should cover user-visible behavior:

- selecting an item
- scrolling to reveal more items
- preserving selection after data updates
- returning to the screen without stale UIKit state

## Assumptions

- The app is SwiftUI-first.
- `UICollectionView` is introduced for behavior that is better handled by UIKit than current SwiftUI collection APIs.
- `ChipPageSwiftUI/UIKitRepresentation` is the permanent bridge boundary.
- Initial implementation should be concrete and narrow, then generalized only after a second real use case appears.
- The Xcode project uses a filesystem-synchronized root group, so files added under `ChipPageSwiftUI/` should be visible to the target without manual project-file edits.
