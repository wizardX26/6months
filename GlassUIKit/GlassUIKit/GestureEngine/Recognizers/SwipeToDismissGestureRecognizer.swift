//
//  SwipeToDismissGestureRecognizer.swift
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

private func traceScrollView(view: UIView, point: CGPoint) -> UIScrollView? {
    for subview in view.subviews {
        let subviewPoint = view.convert(point, to: subview)
        if subview.frame.contains(point), let result = traceScrollView(view: subview, point: subviewPoint) {
            return result
        }
    }
    if let scrollView = view as? UIScrollView {
        return scrollView
    }
    return nil
}

private final class SwipeToDismissInternalDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        otherGestureRecognizer is UIPanGestureRecognizer
    }
}

final class SwipeToDismissGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    private let internalDelegate = SwipeToDismissInternalDelegate()
    private var beginPosition = CGPoint()

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delegate = internalDelegate
    }

    override func reset() {
        super.reset()
        state = .possible
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view else {
            state = .failed
            return
        }
        let point = touch.location(in: view)
        var found = false
        if let scrollView = traceScrollView(view: view, point: point) {
            let contentOffset = scrollView.contentOffset
            let contentInset = scrollView.contentInset
            if contentOffset.y <= contentInset.top {
                found = true
            }
        }
        if found {
            beginPosition = point
        } else {
            state = .failed
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let view else {
            state = .failed
            return
        }
        let point = touch.location(in: view)
        let translation = CGPoint(x: point.x - beginPosition.x, y: point.y - beginPosition.y)

        if state == .possible {
            if abs(translation.x) > 5.0 {
                state = .failed
                return
            }
            var lockDown = false
            if let scrollView = traceScrollView(view: view, point: point) {
                let contentOffset = scrollView.contentOffset
                let contentInset = scrollView.contentInset
                if contentOffset.y <= contentInset.top {
                    lockDown = true
                }
            }
            if lockDown, translation.y > 2.0 {
                state = .began
            } else {
                state = .failed
            }
        } else {
            state = .changed
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .failed
    }
}
