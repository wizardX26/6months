import UIKit

// MARK: - Modal presentation styles

/// Các kiểu present modal native UIKit — map sang `UIModalPresentationStyle`.
enum ModalPresentation {
    /// **Full Screen** — modal che kín màn hình, màn present bị remove khỏi window hierarchy
    /// (app chính “xuống background”, behavior classic trước iOS 13).
    case covering

    /// **Floating Sheet** — pageSheet với detent `.medium()` + near-full, card nổi, chỉ dim nền (không scale màn dưới).
    case sheet

    /// **Stacked Card** — custom presentation: màn dưới scale & lùi xuống (như Files › New Folder).
    /// Dùng `UIPresentationController` riêng vì `UISheetPresentationController` (iOS 15+) chỉ dim nền.
    case stacked

    /// **Form Sheet** — khung giữa màn hình (thường dùng iPad).
    case form

    /// **Over Full Screen** — che kín nhưng giữ presenting VC trong hierarchy (modal trong suốt).
    case overCovering

    var uiKitStyle: UIModalPresentationStyle {
        switch self {
        case .covering: return .fullScreen
        case .sheet: return .pageSheet
        case .stacked: return .custom
        case .form: return .formSheet
        case .overCovering: return .overFullScreen
        }
    }

    var usesSheetPresentationController: Bool {
        switch self {
        case .sheet: return true
        case .covering, .stacked, .form, .overCovering: return false
        }
    }
}

extension UIViewController {

    // MARK: - Present shortcuts

    /// Present **full screen** — màn dưới biến mất hoàn toàn (native `.fullScreen`).
    ///
    /// Đây là kiểu “app chính xuống background” khi present modal trong UIKit.
    func presentFullScreen(_ viewController: UIViewController, animated: Bool = true) {
        presentCovering(viewController, animated: animated)
    }

    /// Alias rõ nghĩa: modal **che kín** màn present, transition trượt từ dưới lên (`.coverVertical`).
    func presentCovering(
        _ viewController: UIViewController,
        wrapInNavigation: Bool = true,
        transition: UIModalTransitionStyle = .coverVertical,
        animated: Bool = true
    ) {
        presentModal(
            viewController,
            presentation: .covering,
            wrapInNavigation: wrapInNavigation,
            transition: transition,
            animated: animated
        )
    }

    /// Present dạng **floating sheet** — card nổi (`.medium()` + near-full), nền mờ, màn dưới giữ nguyên kích thước.
    func presentSheet(
        _ viewController: UIViewController,
        wrapInNavigation: Bool = true,
        detents: [UISheetPresentationController.Detent]? = nil,
        grabberVisible: Bool = true,
        animated: Bool = true,
        configureSheet: ((UISheetPresentationController) -> Void)? = nil
    ) {
        presentModal(
            viewController,
            presentation: .sheet,
            wrapInNavigation: wrapInNavigation,
            animated: animated,
            detents: detents,
            grabberVisible: grabberVisible,
            configureSheet: configureSheet
        )
    }

    /// Present dạng **stacked card** — màn dưới scale & lùi xuống phía sau (như Files › New Folder).
    ///
    /// Dùng custom `StackedCardPresentationController` — không dùng `UISheetPresentationController`
    /// vì iOS 15+ với sheet detent chỉ dim nền, không scale màn present.
    func presentStacked(
        _ viewController: UIViewController,
        wrapInNavigation: Bool = true,
        animated: Bool = true
    ) {
        presentModal(
            viewController,
            presentation: .stacked,
            wrapInNavigation: wrapInNavigation,
            animated: animated
        )
    }

    // MARK: - Present core

    /// Present modal linh hoạt — tự bọc `UINavigationController` và ẩn native bar khi cần stack.
    func presentModal(
        _ viewController: UIViewController,
        presentation: ModalPresentation = .sheet,
        wrapInNavigation: Bool = true,
        transition: UIModalTransitionStyle = .coverVertical,
        animated: Bool = true,
        detents: [UISheetPresentationController.Detent]? = nil,
        grabberVisible: Bool = true,
        configureSheet: ((UISheetPresentationController) -> Void)? = nil
    ) {
        let presentedController: UIViewController

        if wrapInNavigation {
            let navigation = UINavigationController(rootViewController: viewController)
            navigation.isNavigationBarHidden = true
            presentedController = navigation
        } else {
            presentedController = viewController
        }

        if presentation == .stacked {
            configureStackedPresentation(for: presentedController, transition: transition)
        } else {
            presentedController.modalPresentationStyle = presentation.uiKitStyle
            presentedController.modalTransitionStyle = transition

            if presentation.usesSheetPresentationController,
               let sheet = presentedController.sheetPresentationController {
                applySheetConfiguration(
                    sheet,
                    for: presentation,
                    detents: detents,
                    grabberVisible: grabberVisible,
                    configureSheet: configureSheet
                )
            }
        }

        present(presentedController, animated: animated)
    }

    private func configureStackedPresentation(
        for presentedController: UIViewController,
        transition: UIModalTransitionStyle
    ) {
        let delegate = StackedCardTransitioningDelegate()
        presentedController.modalPresentationStyle = .custom
        presentedController.modalTransitionStyle = transition
        presentedController.transitioningDelegate = delegate
        presentedController.stackedCardTransitioningDelegate = delegate
    }

    private func applySheetConfiguration(
        _ sheet: UISheetPresentationController,
        for presentation: ModalPresentation,
        detents: [UISheetPresentationController.Detent]?,
        grabberVisible: Bool,
        configureSheet: ((UISheetPresentationController) -> Void)?
    ) {
        switch presentation {
        case .sheet:
            sheet.detents = Self.normalizedFloatingSheetDetents(detents ?? FloatingSheetDetents.default)
            sheet.prefersGrabberVisible = grabberVisible
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            if #available(iOS 18.0, *) {
                sheet.prefersPageSizing = false
            }

        default:
            break
        }

        configureSheet?(sheet)
    }

    /// `.large()` khiến iOS scale màn present — thay bằng near-full để chỉ dim nền (khác stacked).
    private static func normalizedFloatingSheetDetents(
        _ detents: [UISheetPresentationController.Detent]
    ) -> [UISheetPresentationController.Detent] {
        guard #available(iOS 16.0, *) else { return detents }
        return detents.map { detent in
            guard detent.identifier == .large else { return detent }
            return .floatingExpanded()
        }
    }

    /// API cũ — giữ tương thích, map sang `ModalPresentation`.
    func presentModal(
        _ viewController: UIViewController,
        style: UIModalPresentationStyle,
        wrapInNavigation: Bool = true,
        animated: Bool = true,
        detents: [UISheetPresentationController.Detent]? = nil,
        grabberVisible: Bool = true,
        configureSheet: ((UISheetPresentationController) -> Void)? = nil
    ) {
        let presentation: ModalPresentation
        switch style {
        case .fullScreen: presentation = .covering
        case .pageSheet: presentation = .sheet
        case .formSheet: presentation = .form
        case .overFullScreen: presentation = .overCovering
        default: presentation = .sheet
        }
        presentModal(
            viewController,
            presentation: presentation,
            wrapInNavigation: wrapInNavigation,
            animated: animated,
            detents: detents,
            grabberVisible: grabberVisible,
            configureSheet: configureSheet
        )
    }

    // MARK: - Custom push transitions

    func pushFromTop(_ viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .moveIn
        transition.subtype = .fromTop
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(viewController, animated: false)
    }

    func popToBottom() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .reveal
        transition.subtype = .fromBottom
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
}

extension UISheetPresentationController.Detent {

    private static let floatingExpandedIdentifier = UISheetPresentationController.Detent.Identifier(
        "customnavigation.floating-expanded"
    )

    /// Gần full height — tránh hiệu ứng scale màn present của system `.large()` (iOS 16+).
    @available(iOS 16.0, *)
    static func floatingExpanded() -> UISheetPresentationController.Detent {
        .custom(identifier: floatingExpandedIdentifier) { context in
            context.maximumDetentValue - 1
        }
    }
}

private enum FloatingSheetDetents {
    static var `default`: [UISheetPresentationController.Detent] {
        if #available(iOS 16.0, *) {
            return [.medium(), .floatingExpanded()]
        }
        return [.medium(), .large()]
    }
}

extension UIApplication {
    static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
