//
//  DragImageView.swift
//  Gesture&Touch
//
//  Created by eco mobile on 12/6/26.
//


import UIKit

final class DragImageView: UIImageView, UIGestureRecognizerDelegate {

    private var tx: CGFloat = 0.0
    private var ty: CGFloat = 0.0
    private var scale: CGFloat = 1.0
    private var theta: CGFloat = 0.0

    // Dùng khi khởi tạo bằng code: DragView(image: ...)
    override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }

    // Dùng khi khởi tạo bằng code: DragView(frame: ...)
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    // Dùng khi tạo từ Storyboard / XIB
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.isUserInteractionEnabled = true
        self.transform = .identity

        self.tx = 0.0
        self.ty = 0.0
        self.scale = 1.0
        self.theta = 0.0

        let rotation = UIRotationGestureRecognizer(
            target: self,
            action: #selector(handleRotation(_:))
        )

        let pinch = UIPinchGestureRecognizer(
            target: self,
            action: #selector(handlePinch(_:))
        )

        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )

        self.gestureRecognizers = [rotation, pinch, pan]

        self.gestureRecognizers?.forEach { recognizer in
            recognizer.delegate = self
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.bringSubviewToFront(self)

        tx = self.transform.tx
        ty = self.transform.ty
        scale = self.scaleX
        theta = self.rotation
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if touch.tapCount == 3 {
            self.transform = .identity
            tx = 0.0
            ty = 0.0
            scale = 1.0
            theta = 0.0
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }

    private func updateTransform(withOffset translation: CGPoint) {
        self.transform = CGAffineTransform(
            translationX: translation.x + tx,
            y: translation.y + ty
        )

        self.transform = self.transform.rotated(by: theta)

        if self.currentScale > 0.5 {
            self.transform = self.transform.scaledBy(
                x: scale,
                y: scale
            )
        } else {
            self.transform = self.transform.scaledBy(
                x: 0.5,
                y: 0.5
            )
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = self.superview else { return }

        let translation = gesture.translation(in: superview)
        self.updateTransform(withOffset: translation)
    }

    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        theta = gesture.rotation
        self.updateTransform(withOffset: .zero)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        scale = gesture.scale
        self.updateTransform(withOffset: .zero)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}



private extension UIView {

    var scaleX: CGFloat {
        let a = self.transform.a
        let c = self.transform.c
        return sqrt(a * a + c * c)
    }

    var rotation: CGFloat {
        atan2(self.transform.b, self.transform.a)
    }

    var currentScale: CGFloat {
        let a = self.transform.a
        let c = self.transform.c
        return sqrt(a * a + c * c)
    }
}
