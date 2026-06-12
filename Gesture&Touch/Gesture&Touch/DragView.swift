//
//  DragView.swift
//  Gesture&Touch
//
//  Created by eco mobile on 12/6/26.
//

import UIKit

final class DragView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }

    private func setupGesture() {
        isUserInteractionEnabled = true

        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )

        addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview else { return }

        switch gesture.state {
        case .began:
            superview.bringSubviewToFront(self)

        case .changed:
            let translation = gesture.translation(in: superview)

            var currentTransform = self.transform
            currentTransform.tx = translation.x
            currentTransform.ty = translation.y
            self.transform = currentTransform

        case .ended, .cancelled, .failed:
            let newCenter = CGPoint(
                x: center.x + transform.tx,
                y: center.y + transform.ty
            )

            center = newCenter

            var resetTransform = self.transform
            resetTransform.tx = 0
            resetTransform.ty = 0
            self.transform = resetTransform

        default:
            break
        }
    }
}
