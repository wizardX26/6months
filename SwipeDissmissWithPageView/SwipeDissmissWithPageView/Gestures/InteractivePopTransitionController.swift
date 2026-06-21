//
//  InteractivePopTransitionController.swift
//  SwipeDissmissWithPageView
//

import UIKit

/// Drives navigation pop with UIPercentDrivenInteractiveTransition so the previous
/// view controller is visible during the drag (instead of a black gap from transform).
final class InteractivePopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let width = container.bounds.width

        container.insertSubview(toView, belowSubview: fromView)
        toView.frame = container.bounds.offsetBy(dx: -width * 0.25, dy: 0)
        fromView.frame = container.bounds

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut
        ) {
            fromView.frame = container.bounds.offsetBy(dx: width, dy: 0)
            toView.frame = container.bounds
        } completion: { _ in
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                fromView.frame = container.bounds
            }
            transitionContext.completeTransition(!cancelled)
        }
    }
}

final class InteractivePopTransitionController: NSObject {

    private weak var navigationController: UINavigationController?
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private weak var previousNavigationDelegate: UINavigationControllerDelegate?

    private(set) var isInteractivePopActive = false

    func attach(to navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func beginInteractivePop() {
        guard
            let navigationController,
            interactionController == nil,
            navigationController.viewControllers.count > 1
        else { return }

        isInteractivePopActive = true
        interactionController = UIPercentDrivenInteractiveTransition()
        previousNavigationDelegate = navigationController.delegate
        navigationController.delegate = self
        navigationController.popViewController(animated: true)
    }

    func update(progress: CGFloat) {
        interactionController?.update(max(0, min(1, progress)))
    }

    func end(shouldComplete: Bool) {
        guard let interactionController else {
            cleanup()
            return
        }

        if shouldComplete {
            interactionController.finish()
        } else {
            interactionController.cancel()
        }

        DispatchQueue.main.async { [weak self] in
            self?.cleanup()
        }
    }

    func cancelInteractivePop() {
        guard isInteractivePopActive else { return }
        interactionController?.cancel()
        DispatchQueue.main.async { [weak self] in
            self?.cleanup()
        }
    }

    private func cleanup() {
        isInteractivePopActive = false
        interactionController = nil

        guard let navigationController else { return }
        if navigationController.delegate === self {
            navigationController.delegate = previousNavigationDelegate
        }
        previousNavigationDelegate = nil
    }
}

extension InteractivePopTransitionController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard operation == .pop, isInteractivePopActive else { return nil }
        return InteractivePopAnimator()
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}
