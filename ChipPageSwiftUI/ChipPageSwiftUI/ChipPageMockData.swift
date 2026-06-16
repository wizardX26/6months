import SwiftUI

enum ChipPageMockData {
    static let pages: [ChipPage] = [
        ChipPage(
            id: "overview",
            title: "Overview",
            systemImageName: "rectangle.grid.1x2",
            cards: [
                ChipPageCard(id: "overview-state", title: "SwiftUI State", subtitle: "Page index is the source of truth.", systemImageName: "swift", accentColor: .orange),
                ChipPageCard(id: "overview-bridge", title: "Bridge Layer", subtitle: "UIKit logic stays in UIKitRepresentation.", systemImageName: "arrow.left.arrow.right", accentColor: .blue),
                ChipPageCard(id: "overview-events", title: "Event Intent", subtitle: "UIKit sends taps back as IDs.", systemImageName: "hand.tap", accentColor: .green),
                ChipPageCard(id: "overview-boundary", title: "Clear Boundary", subtitle: "Feature views do not touch delegates.", systemImageName: "square.dashed", accentColor: .purple)
            ]
        ),
        ChipPage(
            id: "layout",
            title: "Layout",
            systemImageName: "square.grid.2x2",
            cards: [
                ChipPageCard(id: "layout-grid", title: "Two Columns", subtitle: "Each page uses the same grid layout.", systemImageName: "square.grid.2x2", accentColor: .cyan),
                ChipPageCard(id: "layout-scroll", title: "Vertical Scroll", subtitle: "Cards scroll inside the active page.", systemImageName: "arrow.up.and.down", accentColor: .indigo),
                ChipPageCard(id: "layout-frame", title: "Outer Frame", subtitle: "SwiftUI owns page sizing.", systemImageName: "rectangle.inset.filled", accentColor: .mint),
                ChipPageCard(id: "layout-spacing", title: "Stable Spacing", subtitle: "Grid gaps stay consistent across pages.", systemImageName: "align.horizontal.left", accentColor: .pink)
            ]
        ),
        ChipPage(
            id: "diffing",
            title: "Diffing",
            systemImageName: "arrow.triangle.2.circlepath",
            cards: [
                ChipPageCard(id: "diffing-id", title: "Stable IDs", subtitle: "Chip and page identity share the same IDs.", systemImageName: "number", accentColor: .teal),
                ChipPageCard(id: "diffing-snapshot", title: "Snapshots", subtitle: "The chip row updates through diffable data.", systemImageName: "camera.filters", accentColor: .blue),
                ChipPageCard(id: "diffing-reconfigure", title: "Reconfigure", subtitle: "Changed chip content updates without reloads.", systemImageName: "slider.horizontal.3", accentColor: .orange),
                ChipPageCard(id: "diffing-guard", title: "Guard Updates", subtitle: "No snapshot is applied when input is unchanged.", systemImageName: "checkmark.shield", accentColor: .green)
            ]
        ),
        ChipPage(
            id: "selection",
            title: "Selection",
            systemImageName: "checkmark.circle",
            cards: [
                ChipPageCard(id: "selection-tap", title: "Tap Chip", subtitle: "Selecting a chip changes the page index.", systemImageName: "hand.point.up.left", accentColor: .red),
                ChipPageCard(id: "selection-swipe", title: "Swipe Page", subtitle: "Swiping updates the selected chip.", systemImageName: "arrow.left.and.right", accentColor: .blue),
                ChipPageCard(id: "selection-scroll", title: "Keep Visible", subtitle: "The chip row centers the selected item.", systemImageName: "scope", accentColor: .purple),
                ChipPageCard(id: "selection-single", title: "One Source", subtitle: "The page index prevents selection drift.", systemImageName: "1.circle", accentColor: .mint)
            ]
        ),
        ChipPage(
            id: "reuse",
            title: "Reuse",
            systemImageName: "tray.2",
            cards: [
                ChipPageCard(id: "reuse-reset", title: "Reset Cell", subtitle: "Reusable cells clear stale state.", systemImageName: "eraser", accentColor: .gray),
                ChipPageCard(id: "reuse-symbol", title: "Symbols", subtitle: "SF Symbols are applied during configuration.", systemImageName: "sparkles", accentColor: .yellow),
                ChipPageCard(id: "reuse-access", title: "Accessibility", subtitle: "Selected state is reflected to VoiceOver.", systemImageName: "accessibility", accentColor: .blue),
                ChipPageCard(id: "reuse-memory", title: "Memory", subtitle: "Callbacks avoid retaining old UIKit objects.", systemImageName: "memorychip", accentColor: .green)
            ]
        ),
        ChipPage(
            id: "scaling",
            title: "Scaling",
            systemImageName: "chart.line.uptrend.xyaxis",
            cards: [
                ChipPageCard(id: "scaling-files", title: "Bridge Files", subtitle: "UIKit files stay grouped together.", systemImageName: "folder", accentColor: .brown),
                ChipPageCard(id: "scaling-api", title: "Small API", subtitle: "Add inputs only when screens need them.", systemImageName: "rectangle.3.group", accentColor: .indigo),
                ChipPageCard(id: "scaling-tests", title: "Testable Logic", subtitle: "Pure mapping can be tested separately.", systemImageName: "testtube.2", accentColor: .green),
                ChipPageCard(id: "scaling-future", title: "Future Work", subtitle: "Paging, snapping, and prefetching can be added later.", systemImageName: "plus.forwardslash.minus", accentColor: .pink)
            ]
        )
    ]
}
