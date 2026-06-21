import UIKit

enum LayoutTransition: Equatable {
    case immediate
    case animated(duration: TimeInterval)

    var isAnimated: Bool {
        if case .animated = self { return true }
        return false
    }

    var duration: TimeInterval {
        if case let .animated(duration) = self { return duration }
        return 0
    }
}
