import UIKit

struct ContainerViewLayout: Equatable {
    var size: CGSize
    var safeAreaInsets: UIEdgeInsets
    var statusBarHeight: CGFloat?
    var keyboardHeight: CGFloat?
    var intrinsicInsets: UIEdgeInsets
    var metrics: LayoutMetrics

    init(
        size: CGSize = .zero,
        safeAreaInsets: UIEdgeInsets = .zero,
        statusBarHeight: CGFloat? = nil,
        keyboardHeight: CGFloat? = nil,
        intrinsicInsets: UIEdgeInsets = .zero,
        metrics: LayoutMetrics = .compact
    ) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.statusBarHeight = statusBarHeight
        self.keyboardHeight = keyboardHeight
        self.intrinsicInsets = intrinsicInsets
        self.metrics = metrics
    }

    func insets(options: LayoutInsetOptions) -> UIEdgeInsets {
        var result = intrinsicInsets
        if options.contains(.statusBar), let height = statusBarHeight {
            result.top = max(result.top, height)
        }
        if options.contains(.keyboard), let height = keyboardHeight {
            result.bottom = max(result.bottom, height)
        }
        return result
    }

    func withIntrinsicBottomInset(_ bottom: CGFloat) -> ContainerViewLayout {
        var copy = self
        copy.intrinsicInsets.bottom = bottom
        return copy
    }
}
