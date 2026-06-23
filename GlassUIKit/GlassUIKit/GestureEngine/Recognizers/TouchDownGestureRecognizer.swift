//
//  TouchDownGestureRecognizer.swift
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

final class TouchDownGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    var touchDown: (() -> Void)?
    var waitForTouchUp: (() -> Bool)?

    private var touchLocation: CGPoint?
    private var isWaitingForTouchUp = false

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delegate = self
    }

    override func reset() {
        touchLocation = nil
        isWaitingForTouchUp = false
        super.reset()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if let waitForTouchUp = waitForTouchUp, waitForTouchUp() {
            isWaitingForTouchUp = true
            if let touch = touches.first {
                touchLocation = touch.location(in: view)
            }
        } else if let touchDown {
            touchDown()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let touchLocation else { return }
        let location = touch.location(in: view)
        let distance = CGPoint(x: location.x - touchLocation.x, y: location.y - touchLocation.y)
        if distance.x * distance.x + distance.y * distance.y > 4.0 {
            state = .cancelled
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        if let touchDown, isWaitingForTouchUp {
            isWaitingForTouchUp = false
            touchDown()
        }
    }
}
