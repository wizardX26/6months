//
//  InteractiveTransitionGestureRecognizer.swift
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

private enum HorizontalGestures {
    case none
    case some
    case strict
}

private func hasHorizontalGestures(_ view: UIView, point: CGPoint?) -> HorizontalGestures {
    if let disablesInteractiveTransitionGestureRecognizerNow = view.disablesInteractiveTransitionGestureRecognizerNow, disablesInteractiveTransitionGestureRecognizerNow() {
        return .strict
    }

    if view.disablesInteractiveTransitionGestureRecognizer {
        return .some
    }

    if let point, let test = view.interactiveTransitionGestureRecognizerTest, test(point) {
        return .some
    }

    if let superview = view.superview {
        return hasHorizontalGestures(superview, point: point != nil ? view.convert(point!, to: superview) : nil)
    }
    return .none
}

struct InteractiveTransitionGestureRecognizerDirections: OptionSet {
    var rawValue: Int

    static let leftCenter = InteractiveTransitionGestureRecognizerDirections(rawValue: 1 << 0)
    static let rightCenter = InteractiveTransitionGestureRecognizerDirections(rawValue: 1 << 1)
    static let leftEdge = InteractiveTransitionGestureRecognizerDirections(rawValue: 1 << 2)
    static let rightEdge = InteractiveTransitionGestureRecognizerDirections(rawValue: 1 << 3)
    static let down = InteractiveTransitionGestureRecognizerDirections(rawValue: 1 << 4)

    static let left: InteractiveTransitionGestureRecognizerDirections = [.leftEdge, .leftCenter]
    static let right: InteractiveTransitionGestureRecognizerDirections = [.rightEdge, .rightCenter]
}

enum InteractiveTransitionGestureRecognizerEdgeWidth {
    case constant(CGFloat)
    case widthMultiplier(factor: CGFloat, min: CGFloat, max: CGFloat)
}

final class InteractiveTransitionGestureRecognizer: UIPanGestureRecognizer {
    private let edgeWidth: InteractiveTransitionGestureRecognizerEdgeWidth
    private let allowedDirections: (CGPoint) -> InteractiveTransitionGestureRecognizerDirections

    private var validatedGesture = false
    private var firstLocation = CGPoint()
    private var currentAllowedDirections: InteractiveTransitionGestureRecognizerDirections = []

    init(target: Any?, action: Selector?, allowedDirections: @escaping (CGPoint) -> InteractiveTransitionGestureRecognizerDirections, edgeWidth: InteractiveTransitionGestureRecognizerEdgeWidth = .constant(16.0)) {
        self.allowedDirections = allowedDirections
        self.edgeWidth = edgeWidth
        super.init(target: target, action: action)
        maximumNumberOfTouches = 1
        delaysTouchesBegan = false
    }

    override func reset() {
        super.reset()
        validatedGesture = false
        currentAllowedDirections = []
    }

    func cancel() {
        state = .cancelled
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let touch = touches.first!
        let point = touch.location(in: view)

        var allowedDirections = allowedDirections(point)
        if allowedDirections.isEmpty {
            state = .failed
            return
        }

        super.touchesBegan(touches, with: event)
        firstLocation = point

        if let target = view?.hitTest(firstLocation, with: event) {
            let horizontalGestures = hasHorizontalGestures(target, point: view?.convert(firstLocation, to: target))
            switch horizontalGestures {
            case .some, .strict:
                if allowedDirections.contains(.down) {
                    break
                } else {
                    if case .strict = horizontalGestures {
                        allowedDirections = []
                    } else if allowedDirections.contains(.leftEdge) || allowedDirections.contains(.rightEdge) {
                        allowedDirections.remove(.leftCenter)
                        allowedDirections.remove(.rightCenter)
                    }
                }
            case .none:
                break
            }
        }

        if allowedDirections.isEmpty {
            state = .failed
        } else {
            currentAllowedDirections = allowedDirections
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let location = touches.first!.location(in: view)
        let translation = CGPoint(x: location.x - firstLocation.x, y: location.y - firstLocation.y)
        let absTranslationX = abs(translation.x)
        let absTranslationY = abs(translation.y)
        let size = view?.bounds.size ?? .zero

        var fireBegan = false

        if currentAllowedDirections.contains(.down) {
            if !validatedGesture {
                let totalMovement = sqrt(absTranslationX * absTranslationX + absTranslationY * absTranslationY)
                if totalMovement > 10.0 {
                    if absTranslationY >= absTranslationX {
                        validatedGesture = true
                    } else {
                        state = .failed
                    }
                } else if absTranslationX > 2.0 && absTranslationX > absTranslationY * 2.0 {
                    state = .failed
                } else if absTranslationY > 2.0 && absTranslationX * 2.0 < absTranslationY {
                    validatedGesture = true
                }
            }
        } else {
            let edgeWidth: CGFloat
            switch self.edgeWidth {
            case let .constant(value):
                edgeWidth = value
            case let .widthMultiplier(factor, minValue, maxValue):
                edgeWidth = max(minValue, min(size.width * factor, maxValue))
            }

            if !validatedGesture {
                if firstLocation.x < edgeWidth && !currentAllowedDirections.contains(.rightEdge) {
                    state = .failed
                    return
                }
                if firstLocation.x > size.width - edgeWidth && !currentAllowedDirections.contains(.leftEdge) {
                    state = .failed
                    return
                }

                if currentAllowedDirections.contains(.rightEdge) && firstLocation.x < edgeWidth {
                    validatedGesture = true
                } else if currentAllowedDirections.contains(.leftEdge) && firstLocation.x > size.width - edgeWidth {
                    validatedGesture = true
                } else if !currentAllowedDirections.contains(.leftCenter) && translation.x < 0.0 {
                    state = .failed
                } else if !currentAllowedDirections.contains(.rightCenter) && translation.x > 0.0 {
                    state = .failed
                } else {
                    let totalMovement = sqrt(absTranslationX * absTranslationX + absTranslationY * absTranslationY)
                    if totalMovement > 10.0 {
                        if absTranslationX >= absTranslationY {
                            validatedGesture = true
                            fireBegan = true
                        } else {
                            state = .failed
                        }
                    } else if absTranslationY > 2.0 && absTranslationY > absTranslationX * 2.0 {
                        state = .failed
                    } else if absTranslationX > 2.0 && absTranslationY * 2.0 < absTranslationX {
                        validatedGesture = true
                        fireBegan = true
                    }
                }
            }
        }

        if validatedGesture {
            super.touchesMoved(touches, with: event)
            if fireBegan, state == .possible {
                state = .began
            }
        }
    }
}
