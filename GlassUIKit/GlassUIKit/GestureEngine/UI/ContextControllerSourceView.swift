//
//  ContextControllerSourceView.swift
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

final class ContextControllerSourceView: UIView {
    private(set) var contextGesture: ContextGesture?

    var isGestureEnabled = true {
        didSet { contextGesture?.isEnabled = isGestureEnabled }
    }

    var beginDelay: Double = 0.12 {
        didSet { contextGesture?.beginDelay = beginDelay }
    }

    var animateScale = true
    var activated: ((ContextGesture, CGPoint) -> Void)?
    var shouldBegin: ((CGPoint) -> Bool)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        isExclusiveTouch = true

        let gesture = ContextGesture(target: self, action: nil)
        contextGesture = gesture
        addGestureRecognizer(gesture)
        gesture.beginDelay = beginDelay
        gesture.isEnabled = isGestureEnabled

        gesture.shouldBegin = { [weak self] point in
            guard let self, !self.bounds.width.isZero else { return false }
            return self.shouldBegin?(point) ?? true
        }

        gesture.activationProgress = { [weak self] progress, update in
            guard let self, self.animateScale else { return }
            let scale = 1.0 - progress * 0.04
            self.layer.transform = CATransform3DMakeScale(scale, scale, 1.0)
            if case .ended = update {
                self.layer.transform = CATransform3DIdentity
            }
        }

        gesture.activated = { [weak self] contextGesture, point in
            self?.activated?(contextGesture, point)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
