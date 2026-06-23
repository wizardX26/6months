//
//  GestureNavigationController.swift
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

/// Custom navigation stack with full-width swipe-back (full-width swipe-back navigation pattern).
/// `allowedDirections = .right` → pan ngang toàn màn hình, không chỉ cạnh trái.
final class GestureNavigationController: UINavigationController, UINavigationControllerDelegate, GestureHost {
    private var panRecognizer: InteractiveTransitionGestureRecognizer?
    private let popAnimator = PopTransitionAnimator(isInteractive: false)
    private let popInteractiveAnimator = PopTransitionAnimator(isInteractive: true)
    private let popInteraction = PopInteractiveTransition()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.isEnabled = false

        let recognizer = InteractiveTransitionGestureRecognizer(
            target: self,
            action: #selector(handlePopPan(_:)),
            allowedDirections: { [weak self] _ in
                guard let self, self.viewControllers.count > 1 else { return [] }
                return .right
            },
            edgeWidth: .constant(16.0)
        )
        if #available(iOS 13.4, *) {
            recognizer.allowedScrollTypesMask = .continuous
        }
        recognizer.delegate = wrappedGestureRecognizerDelegate
        recognizer.delaysTouchesBegan = false
        recognizer.cancelsTouchesInView = true
        view.addGestureRecognizer(recognizer)
        panRecognizer = recognizer
    }

    @objc private func handlePopPan(_ recognizer: UIPanGestureRecognizer) {
        popInteraction.attach(to: recognizer, in: view, navigationController: self)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panRecognizer,
              let pan = gestureRecognizer as? UIPanGestureRecognizer,
              pan.numberOfTouches == 0 else { return true }

        let translation = pan.velocity(in: pan.view)
        if abs(translation.y) > 4.0 && abs(translation.y) > abs(translation.x) * 2.5 {
            return false
        }
        if translation.x < 4.0 {
            return false
        }
        if viewControllers.count <= 1 {
            return false
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is InteractiveTransitionGestureRecognizer {
            return false
        }
        if otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard operation == .pop else { return nil }
        return popInteraction.interactionInProgress ? popInteractiveAnimator : popAnimator
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        popInteraction.interactionInProgress ? popInteraction : nil
    }
}
