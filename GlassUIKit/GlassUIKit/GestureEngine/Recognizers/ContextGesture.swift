//
//  ContextGesture.swift
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

enum ContextGestureTransition {
    case begin
    case update
    case ended(CGFloat)
}

private final class ContextTimerTarget: NSObject {
    let handler: () -> Void
    init(_ handler: @escaping () -> Void) { self.handler = handler }
    @objc func fire() { handler() }
}

private func cancelOtherContextGestures(gesture: ContextGesture, view: UIView) {
    if let gestureRecognizers = view.gestureRecognizers {
        for recognizer in gestureRecognizers {
            if let recognizer = recognizer as? ContextGesture, recognizer !== gesture {
                recognizer.cancel()
            } else if let recognizer = recognizer as? UITapGestureRecognizer, recognizer.state == .possible {
                recognizer.state = .failed
            }
        }
    }
    for subview in view.subviews {
        cancelOtherContextGestures(gesture: gesture, view: subview)
    }
}

private final class ContextInternalDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        !(otherGestureRecognizer is UIPanGestureRecognizer)
    }
}

final class ContextGesture: UIGestureRecognizer, UIGestureRecognizerDelegate {
    private let internalDelegate = ContextInternalDelegate()

    var beginDelay: Double = 0.12
    var activateOnTap = false

    var shouldBegin: ((CGPoint) -> Bool)?
    var activationProgress: ((CGFloat, ContextGestureTransition) -> Void)?
    var activated: ((ContextGesture, CGPoint) -> Void)?

    private var currentProgress: CGFloat = 0.0
    private var delayTimer: Timer?
    private var animator: DisplayLinkAnimator?
    private var isValidated = false
    private var wasActivated = false
    private var activationLocation = CGPoint.zero

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delegate = internalDelegate
    }

    override func reset() {
        super.reset()
        currentProgress = 0.0
        delayTimer?.invalidate()
        delayTimer = nil
        isValidated = false
        animator?.invalidate()
        animator = nil
        wasActivated = false
    }

    func cancel() {
        state = .cancelled
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: view)

        if let shouldBegin, !shouldBegin(location) {
            state = .failed
            return
        }

        let windowLocation = touch.location(in: nil)
        if windowLocation.x < 8.0 {
            state = .failed
            return
        }

        activationLocation = location

        if delayTimer == nil {
            let target = ContextTimerTarget { [weak self] in
                guard let self, self.delayTimer != nil else { return }
                self.isValidated = true
                if self.animator == nil {
                    self.animator = DisplayLinkAnimator(duration: 0.2, from: 0.0, to: 1.0, update: { [weak self] value in
                        guard let self, self.isValidated else { return }
                        self.currentProgress = value
                        self.activationProgress?(value, .update)
                    }, completion: { [weak self] in
                        guard let self else { return }
                        if self.state == .possible {
                            self.delayTimer?.invalidate()
                            self.animator?.invalidate()
                            self.activated?(self, self.activationLocation)
                            self.wasActivated = true
                            if let view = self.view, let window = view.window {
                                cancelOtherContextGestures(gesture: self, view: window)
                                cancelParentGestures(view: view, ignore: [self])
                            }
                            self.state = .began
                        }
                    })
                }
                self.activationProgress?(self.currentProgress, .begin)
            }
            let timer = Timer(timeInterval: beginDelay, target: target, selector: #selector(ContextTimerTarget.fire), userInfo: nil, repeats: false)
            delayTimer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let view else { return }
        let location = touch.location(in: view)
        let distance = hypot(location.x - activationLocation.x, location.y - activationLocation.y)
        if distance > 10.0, !wasActivated {
            delayTimer?.invalidate()
            delayTimer = nil
            animator?.invalidate()
            animator = nil
            state = .failed
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        if !wasActivated {
            delayTimer?.invalidate()
            delayTimer = nil
            animator?.invalidate()
            animator = nil
            activationProgress?(currentProgress, .ended(currentProgress))
            state = .failed
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        reset()
        state = .cancelled
    }
}
