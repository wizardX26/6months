//
//  DirectionalPanGestureRecognizer.swift
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

final class DirectionalPanGestureRecognizer: UIPanGestureRecognizer {
    enum Direction {
        case horizontal
        case vertical
    }

    var shouldBegin: ((CGPoint) -> Bool)?
    var direction: Direction = .vertical

    private var validatedGesture = false
    private var firstLocation = CGPoint()

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        maximumNumberOfTouches = 1
    }

    override func reset() {
        super.reset()
        validatedGesture = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        let point = touches.first!.location(in: view)
        if let shouldBegin, !shouldBegin(point) {
            state = .failed
            return
        }
        firstLocation = point
        if let target = view?.hitTest(firstLocation, with: event), target == view {
            validatedGesture = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let location = touches.first!.location(in: view)
        let translation = CGPoint(x: location.x - firstLocation.x, y: location.y - firstLocation.y)
        let absTranslationX = abs(translation.x)
        let absTranslationY = abs(translation.y)

        if !validatedGesture {
            switch direction {
            case .horizontal:
                if absTranslationY > 4.0 && absTranslationY > absTranslationX * 2.0 {
                    state = .failed
                } else if absTranslationX > 2.0 && absTranslationY * 2.0 < absTranslationX {
                    validatedGesture = true
                }
            case .vertical:
                if absTranslationX > 4.0 && absTranslationX > absTranslationY * 2.0 {
                    state = .failed
                } else if absTranslationY > 2.0 && absTranslationX * 2.0 < absTranslationY {
                    validatedGesture = true
                }
            }
        }

        if validatedGesture {
            super.touchesMoved(touches, with: event)
        }
    }
}
