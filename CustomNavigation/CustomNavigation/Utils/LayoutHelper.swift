import UIKit

@MainActor
enum NavigationBarLayoutContext {
    case standard
    case compact
}

@MainActor
enum LayoutHelper {

    static var hasNotch: Bool { safeAreaTop > 20 }

    static var safeAreaTop: CGFloat {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        else { return 20 }
        return window.safeAreaInsets.top
    }

    static func safeAreaTop(for view: UIView) -> CGFloat {
        view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : safeAreaTop
    }

    static func navigationBarLayoutContext(for viewController: UIViewController) -> NavigationBarLayoutContext {
        viewController.requiresCompactNavigationBar ? .compact : .standard
    }

    static func navigationContentHeight(titleStyle: TitleStyle, context: NavigationBarLayoutContext) -> CGFloat {
        NavigationBarMetrics.contentHeight(titleStyle: titleStyle, context: context)
    }

    static func navigationContentHeight(titleStyle: TitleStyle) -> CGFloat {
        navigationContentHeight(titleStyle: titleStyle, context: .standard)
    }

    static func navigationBarHeight(
        titleStyle: TitleStyle = .inline,
        for viewController: UIViewController
    ) -> CGFloat {
        let context = navigationBarLayoutContext(for: viewController)
        return NavigationBarMetrics.barHeight(
            titleStyle: titleStyle,
            context: context,
            safeAreaTop: safeAreaTop(for: viewController.view)
        )
    }

    static func navigationBarHeight(titleStyle: TitleStyle = .inline) -> CGFloat {
        NavigationBarMetrics.barHeight(
            titleStyle: titleStyle,
            context: .standard,
            safeAreaTop: safeAreaTop
        )
    }

    static var navigationBarHeight: CGFloat { navigationBarHeight(titleStyle: .inline) }

    static func navigationContentTopPadding(
        for viewController: UIViewController,
        titleStyle: TitleStyle = .inline
    ) -> CGFloat {
        navigationBarHeight(titleStyle: titleStyle, for: viewController)
    }

    static func navigationContentTopPadding(for view: UIView, titleStyle: TitleStyle = .inline) -> CGFloat {
        NavigationBarMetrics.barHeight(
            titleStyle: titleStyle,
            context: .standard,
            safeAreaTop: safeAreaTop(for: view)
        )
    }
}

extension UIViewController {
    var requiresCompactNavigationBar: Bool {
        guard let presentationStyle = presentedModalPresentationStyle else { return false }
        switch presentationStyle {
        case .pageSheet, .formSheet, .custom: return true
        default: return false
        }
    }

    private var presentedModalPresentationStyle: UIModalPresentationStyle? {
        if let navigationController, navigationController.presentingViewController != nil {
            return navigationController.modalPresentationStyle
        }
        if presentingViewController != nil { return modalPresentationStyle }
        return nil
    }
}
