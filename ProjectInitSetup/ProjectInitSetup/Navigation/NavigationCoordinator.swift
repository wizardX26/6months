import UIKit

enum ModalPresentationStyle {
    case sheet
    case fullScreen
    case overCurrentContext
}

protocol NavigationCoordinator: AnyObject {
    var rootController: UINavigationController { get }

    func push(_ viewController: UIViewController, animated: Bool)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
    func present(_ viewController: UIViewController, style: ModalPresentationStyle)
    func dismiss(animated: Bool)
}

final class NavigationCoordinatorImpl: NavigationCoordinator {
    let rootController: UINavigationController

    init(rootController: UINavigationController) {
        self.rootController = rootController
    }

    func push(_ viewController: UIViewController, animated: Bool) {
        rootController.pushViewController(viewController, animated: animated)
    }

    func pop(animated: Bool) {
        rootController.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool) {
        rootController.popToRootViewController(animated: animated)
    }

    func present(_ viewController: UIViewController, style: ModalPresentationStyle) {
        switch style {
        case .sheet:
            viewController.modalPresentationStyle = .pageSheet
        case .fullScreen:
            viewController.modalPresentationStyle = .fullScreen
        case .overCurrentContext:
            viewController.modalPresentationStyle = .overCurrentContext
        }
        rootController.present(viewController, animated: true)
    }

    func dismiss(animated: Bool) {
        rootController.dismiss(animated: animated)
    }
}
