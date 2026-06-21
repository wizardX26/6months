//
//  InteractivePopGestureRecognizer.swift
//  SwipeDissmissWithPageView
//

import UIKit

/// Raw touch recognizer with direction lock. Does not subclass UIPanGestureRecognizer
/// so UIKit cannot transition to `.began` before horizontal-right intent is confirmed.
final class InteractivePopGestureRecognizer: UIGestureRecognizer {

    var canBegin: () -> Bool = { true }
    var onActiveUpdate: ((CGPoint, CGPoint) -> Void)?

    private(set) var currentTranslation: CGPoint = .zero
    private(set) var currentVelocity: CGPoint = .zero

    private let directionThreshold: CGFloat = 4
    private let earlyDirectionThreshold: CGFloat = 4
    private var beginPosition: CGPoint = .zero
    private var lastPosition: CGPoint = .zero
    private var lastTimestamp: TimeInterval = 0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view else {
            state = .failed
            return
        }
        beginPosition = touch.location(in: view)
        lastPosition = beginPosition
        lastTimestamp = touch.timestamp
        currentTranslation = .zero
        currentVelocity = .zero
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let view else { return }

        let point = touch.location(in: view)
        let dx = point.x - beginPosition.x
        let dy = point.y - beginPosition.y

        if state == .possible {
            // Fail fast on clear wrong direction so page scroll pan is not blocked by require(toFail:).
            if abs(dy) > earlyDirectionThreshold, abs(dy) > abs(dx) {
                state = .failed
                return
            }
            if dx < -earlyDirectionThreshold, abs(dx) > abs(dy) {
                state = .failed
                return
            }

            if abs(dx) < directionThreshold, abs(dy) < directionThreshold {
                return
            }
            if abs(dy) > abs(dx) {
                state = .failed
                return
            }
            if dx < 0 {
                state = .failed
                return
            }
            if dx > 0, canBegin() {
                updateMotion(to: point, timestamp: touch.timestamp)
                state = .began
            } else {
                state = .failed
            }
            return
        }

        guard state == .began else { return }
        updateMotion(to: point, timestamp: touch.timestamp)
        onActiveUpdate?(currentTranslation, currentVelocity)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        if state == .began {
            state = .ended
        } else {
            state = .failed
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
    }

    override func reset() {
        super.reset()
        beginPosition = .zero
        lastPosition = .zero
        lastTimestamp = 0
        currentTranslation = .zero
        currentVelocity = .zero
    }

    private func updateMotion(to point: CGPoint, timestamp: TimeInterval) {
        currentTranslation = CGPoint(
            x: point.x - beginPosition.x,
            y: point.y - beginPosition.y
        )

        let dt = timestamp - lastTimestamp
        if dt > 0 {
            currentVelocity = CGPoint(
                x: (point.x - lastPosition.x) / CGFloat(dt),
                y: (point.y - lastPosition.y) / CGFloat(dt)
            )
        }

        lastPosition = point
        lastTimestamp = timestamp
    }
}
