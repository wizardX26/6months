import UIKit

/// Nguồn sự thật duy nhất cho kích thước navigation bar.
/// Các giá trị hiện tại đã được gộp thành default — không cộng padding rời rạc ở runtime.
@MainActor
enum NavigationBarMetrics {

    enum Toolbar {
        static let height: CGFloat = 44
        static let verticalBias: CGFloat = 4
        static var centerOffsetFromBottom: CGFloat { height / 2 + verticalBias }
    }

    enum Compact {
        static let additionalHeight: CGFloat = 8
        static let verticalBias: CGFloat = 2
        static var barHeight: CGFloat { Toolbar.height + additionalHeight }
        static var centerOffsetFromBottom: CGFloat { Toolbar.centerOffsetFromBottom - verticalBias }
    }

    enum LargeTitle {
        static let rowHeight: CGFloat = 36
        static let bottomInset: CGFloat = 8
        static let toolbarGap: CGFloat = 8
        static var extraContentHeight: CGFloat { rowHeight + toolbarGap }
    }

    enum ContentSpacing {
        static let horizontal: CGFloat = 8
        static let titleLeading: CGFloat = 16
    }

    static func contentHeight(titleStyle: TitleStyle, context: NavigationBarLayoutContext) -> CGFloat {
        let toolbarBand = context == .compact ? Compact.barHeight : Toolbar.height
        switch titleStyle {
        case .inline, .largeLeading:
            return toolbarBand
        case .large:
            return toolbarBand + LargeTitle.extraContentHeight
        }
    }

    static func barHeight(
        titleStyle: TitleStyle,
        context: NavigationBarLayoutContext,
        safeAreaTop: CGFloat
    ) -> CGFloat {
        let content = contentHeight(titleStyle: titleStyle, context: context)
        switch context {
        case .standard:
            return safeAreaTop + content
        case .compact:
            return content
        }
    }

    static func toolbarCenterOffsetFromBottom(
        titleStyle: TitleStyle,
        context: NavigationBarLayoutContext
    ) -> CGFloat {
        let base = context == .compact ? Compact.centerOffsetFromBottom : Toolbar.centerOffsetFromBottom
        switch titleStyle {
        case .inline, .largeLeading:
            return base
        case .large:
            return LargeTitle.extraContentHeight + base
        }
    }
}
