//
//  PopTransitionAnimator.swift
//  GlassUIKit
//
//  Copyright (C) 2026 wizardOs contributors
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

final class PopTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isInteractive: Bool

    init(isInteractive: Bool) {
        self.isInteractive = isInteractive
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let width = container.bounds.width
        toView.frame = container.bounds.offsetBy(dx: -width * 0.3, dy: 0)
        container.insertSubview(toView, belowSubview: fromView)
        fromView.frame = container.bounds

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut]) {
            fromView.frame = container.bounds.offsetBy(dx: width, dy: 0)
            toView.frame = container.bounds
        } completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled)
        }
    }
}

final class PopInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false

    func attach(to recognizer: UIPanGestureRecognizer, in view: UIView, navigationController: UINavigationController) {
        let translation = recognizer.translation(in: view).x
        let progress = max(0, min(1, translation / view.bounds.width))

        switch recognizer.state {
        case .began:
            interactionInProgress = true
            navigationController.popViewController(animated: true)
        case .changed:
            update(progress)
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: view).x
            if progress > 0.2 || velocity > 500 {
                finish()
            } else {
                cancel()
            }
            interactionInProgress = false
        default:
            break
        }
    }
}
