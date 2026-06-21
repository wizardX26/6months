import UIKit

enum LayoutMetrics: Equatable {
    case compact
    case regular

    init(traitCollection: UITraitCollection) {
        self = traitCollection.horizontalSizeClass == .regular ? .regular : .compact
    }
}

struct LayoutInsetOptions: OptionSet {
    let rawValue: Int

    static let statusBar = LayoutInsetOptions(rawValue: 1 << 0)
    static let keyboard = LayoutInsetOptions(rawValue: 1 << 1)
}
