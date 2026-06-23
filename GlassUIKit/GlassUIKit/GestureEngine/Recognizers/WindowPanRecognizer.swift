//
//  WindowPanRecognizer.swift
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

final class WindowPanRecognizer: UIGestureRecognizer {
    var began: ((CGPoint) -> Void)?
    var moved: ((CGPoint) -> Void)?
    var ended: ((CGPoint, CGPoint?) -> Void)?

    private var previousPoints: [(CGPoint, Double)] = []
    private var previousVelocity: CGFloat = 0.0

    override func reset() {
        super.reset()
        previousPoints.removeAll()
    }

    func cancel() {
        state = .cancelled
    }

    private func addPoint(_ point: CGPoint) {
        previousPoints.append((point, CACurrentMediaTime()))
        if previousPoints.count > 6 {
            previousPoints.removeFirst()
        }
    }

    private func estimateVerticalVelocity() -> CGFloat {
        let timestamp = CACurrentMediaTime()
        var sum: CGFloat = 0.0
        var count = 0
        if previousPoints.count > 1 {
            for i in 1 ..< previousPoints.count {
                if previousPoints[i].1 >= timestamp - 0.1 {
                    sum += (previousPoints[i].0.y - previousPoints[i - 1].0.y) / CGFloat(previousPoints[i].1 - previousPoints[i - 1].1)
                    count += 1
                }
            }
        }
        return count != 0 ? sum / CGFloat(count * 5) : 0.0
    }

    func velocity(in view: UIView?) -> CGPoint {
        let point = CGPoint(x: 0.0, y: previousVelocity)
        return self.view?.convert(point, to: view) ?? .zero
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: view)
            addPoint(location)
            began?(location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: view)
            addPoint(location)
            moved?(location)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
        if let touch = touches.first {
            let location = touch.location(in: view)
            addPoint(location)
            previousVelocity = estimateVerticalVelocity()
            ended?(location, CGPoint(x: 0.0, y: estimateVerticalVelocity()))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
        if let touch = touches.first {
            ended?(touch.location(in: view), nil)
        }
    }
}
