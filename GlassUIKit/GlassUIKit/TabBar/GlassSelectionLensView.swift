//
//  GlassSelectionLensView.swift
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

/// Glass pill selection indicator (UIKit blur liquid-lens pill (no Display dependency)).
final class GlassSelectionLensView: UIView {
    private let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        view.layer.cornerRadius = 22
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let tintOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        view.isUserInteractionEnabled = false
        return view
    }()

    private let borderLayer: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        return layer
    }()

    private(set) var isLifted = false
    private(set) var isCollapsed = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        addSubview(blurView)
        blurView.contentView.addSubview(tintOverlay)
        layer.addSublayer(borderLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        tintOverlay.frame = blurView.bounds
        borderLayer.frame = bounds
        blurView.layer.cornerRadius = bounds.height / 2
        borderLayer.cornerRadius = bounds.height / 2
        tintOverlay.layer.cornerRadius = bounds.height / 2
    }

    func update(
        originX: CGFloat,
        width: CGFloat,
        height: CGFloat,
        inset: CGFloat = 4,
        animated: Bool
    ) {
        let targetFrame = CGRect(
            x: originX - inset,
            y: (bounds.height - height) / 2,
            width: width + inset * 2,
            height: height
        )

        let apply = {
            self.frame = CGRect(
                x: targetFrame.origin.x,
                y: self.frame.origin.y,
                width: targetFrame.width,
                height: self.superview?.bounds.height ?? targetFrame.height
            )
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0) {
                apply()
            }
        } else {
            apply()
        }
    }

    func setLifted(_ lifted: Bool, animated: Bool) {
        guard isLifted != lifted else { return }
        isLifted = lifted
        let scale: CGFloat = lifted ? 1.12 : 1.0
        let animations = { self.transform = CGAffineTransform(scaleX: scale, y: scale) }
        if animated {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }

    func setCollapsed(_ collapsed: Bool, animated: Bool) {
        guard isCollapsed != collapsed else { return }
        isCollapsed = collapsed
        let alpha: CGFloat = collapsed ? 0 : 1
        let animations = { self.alpha = alpha }
        if animated {
            UIView.animate(withDuration: 0.25, animations: animations)
        } else {
            animations()
        }
    }
}
