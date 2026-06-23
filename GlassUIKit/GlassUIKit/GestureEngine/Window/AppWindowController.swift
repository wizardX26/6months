//
//  AppWindowController.swift
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

/// Keyboard tracking + interactive dismiss pan (guide §22; no private keyboard window API).
final class AppWindowController {
    let window: UIWindow
    private var keyboardHeight: CGFloat = 0
    private var keyboardPanBeginLocation: CGPoint?
    private var windowPanRecognizer: WindowPanRecognizer?
    private let keyboardGestureDelegate = WindowKeyboardGestureRecognizerDelegate()

    var onKeyboardHeightChanged: ((CGFloat) -> Void)?

    init(window: UIWindow) {
        self.window = window
        setupKeyboardObservers()
        setupWindowPanRecognizer()
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let converted = window.convert(frame, from: nil)
        let height = max(0, window.bounds.maxY - converted.minY)
        keyboardHeight = height
        onKeyboardHeightChanged?(height)
    }

    private func setupWindowPanRecognizer() {
        guard let rootView = window.rootViewController?.view else { return }
        let recognizer = WindowPanRecognizer(target: self, action: #selector(handleWindowPan(_:)))
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        recognizer.delegate = keyboardGestureDelegate
        recognizer.began = { [weak self] point in self?.panBegan(at: point) }
        recognizer.moved = { [weak self] point in self?.panMoved(to: point) }
        recognizer.ended = { [weak self] point, velocity in self?.panEnded(at: point, velocity: velocity) }
        rootView.addGestureRecognizer(recognizer)
        windowPanRecognizer = recognizer
    }

    func attachToRootViewIfNeeded() {
        guard windowPanRecognizer?.view == nil, let rootView = window.rootViewController?.view else { return }
        if let recognizer = windowPanRecognizer {
            rootView.addGestureRecognizer(recognizer)
        }
    }

    private func panBegan(at location: CGPoint) {
        guard keyboardHeight > 0, let rootView = window.rootViewController?.view else { return }
        guard location.y < rootView.bounds.height - keyboardHeight else { return }
        if let hit = rootView.hitTest(location, with: nil),
           doesViewTreeDisableInteractiveTransitionGestureRecognizer(hit, keyboardOnly: true) {
            return
        }
        if rootView.findFirstResponder() != nil {
            keyboardPanBeginLocation = location
        }
    }

    private func panMoved(to location: CGPoint) {
        guard keyboardPanBeginLocation != nil else { return }
        // Demo: dismiss when dragged down past threshold
    }

    private func panEnded(at location: CGPoint, velocity: CGPoint?) {
        guard keyboardPanBeginLocation != nil else { return }
        keyboardPanBeginLocation = nil
        let dismiss = (velocity?.y ?? 0) > 100
        if dismiss {
            window.endEditing(true)
        }
    }

    @objc private func handleWindowPan(_ recognizer: WindowPanRecognizer) {
        switch recognizer.state {
        case .began:
            panBegan(at: recognizer.location(in: recognizer.view))
        case .changed:
            panMoved(to: recognizer.location(in: recognizer.view))
        case .ended:
            panEnded(at: recognizer.location(in: recognizer.view), velocity: recognizer.velocity(in: recognizer.view))
        case .cancelled:
            panEnded(at: recognizer.location(in: recognizer.view), velocity: nil)
        default:
            break
        }
    }

    func simulateKeyboardDismiss() {
        window.endEditing(true)
    }
}

final class WindowKeyboardGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = gestureRecognizer.view {
            let location = touch.location(in: gestureRecognizer.view)
            if location.y > view.bounds.height - 44.0 {
                return false
            }
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
