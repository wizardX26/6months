//
//  DisplayLinkAnimator.swift
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

final class DisplayLinkAnimator {
    private var displayLink: CADisplayLink?
    private let duration: Double
    private let fromValue: CGFloat
    private let toValue: CGFloat
    private let startTime: CFTimeInterval
    private let update: (CGFloat) -> Void
    private let completion: () -> Void
    private var completed = false

    init(duration: Double, from fromValue: CGFloat, to toValue: CGFloat, update: @escaping (CGFloat) -> Void, completion: @escaping () -> Void) {
        self.duration = duration
        self.fromValue = fromValue
        self.toValue = toValue
        self.update = update
        self.completion = completion
        self.startTime = CACurrentMediaTime()

        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        self.displayLink = link
    }

    deinit {
        invalidate()
    }

    func invalidate() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick() {
        guard !completed else { return }
        let t = min(1.0, max(0.0, (CACurrentMediaTime() - startTime) / duration))
        update(fromValue * (1 - CGFloat(t)) + toValue * CGFloat(t))
        if t >= 1.0 - Double.ulpOfOne {
            completed = true
            invalidate()
            completion()
        }
    }
}
