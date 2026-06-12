//
//  LayerTouchOverlayView.swift
//  Gesture&Touch
//
//  Created by eco mobile on 12/6/26.
//


import UIKit

final class LayerTouchOverlayView: UIView {

    private var layersByTouchID: [ObjectIdentifier: CAShapeLayer] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func handle(touches: Set<UITouch>) {
        for touch in touches {
            let id = ObjectIdentifier(touch)
            let point = touch.location(in: self)

            switch touch.phase {
            case .began:
                createCircle(for: id, at: point)

            case .moved, .stationary:
                moveCircle(for: id, to: point)

            case .ended, .cancelled:
                removeCircle(for: id, at: point)

            @unknown default:
                break
            }
        }
    }

    private func setup() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    private func createCircle(for id: ObjectIdentifier, at point: CGPoint) {
        let radius: CGFloat = 28
        let rect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: rect).cgPath
        circleLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.45).cgColor
        circleLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.9).cgColor
        circleLayer.lineWidth = 2

        layer.addSublayer(circleLayer)
        layersByTouchID[id] = circleLayer
    }

    private func moveCircle(for id: ObjectIdentifier, to point: CGPoint) {
        guard let circleLayer = layersByTouchID[id] else {
            createCircle(for: id, at: point)
            return
        }

        let radius: CGFloat = 28
        let rect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circleLayer.path = UIBezierPath(ovalIn: rect).cgPath
        CATransaction.commit()
    }

    private func removeCircle(for id: ObjectIdentifier, at point: CGPoint) {
        guard let circleLayer = layersByTouchID[id] else { return }

        layersByTouchID.removeValue(forKey: id)

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = circleLayer.opacity
        fade.toValue = 0
        fade.duration = 0.18
        fade.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 1.35
        scale.duration = 0.18
        scale.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let group = CAAnimationGroup()
        group.animations = [fade, scale]
        group.duration = 0.18
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)

        circleLayer.opacity = 0
        circleLayer.add(group, forKey: "touchEnd")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            circleLayer.removeFromSuperlayer()
        }
    }
}