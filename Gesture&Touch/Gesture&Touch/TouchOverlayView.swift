//
//  TouchOverlayView.swift
//  Gesture&Touch
//
//  Created by eco mobile on 12/6/26.
//

import UIKit

class TouchOverlayView: UIView {
    
    private struct TouchCircle {
        var center: CGPoint
        var radius: CGFloat
        var alpha: CGFloat
    }
    
    private var circles: [ObjectIdentifier: TouchCircle] = [:]
    
    func handle(touches: Set<UITouch>) {
        for touch in touches {
            let id = ObjectIdentifier(touch)
            let point = touch.location(in: self)
            
            switch touch.phase {
            case .began:
                self.circles[id] = TouchCircle(center: point,
                                               radius: 28,
                                               alpha: 0.55)
            case .moved, .stationary:
                if var circle = self.circles[id] {
                    circle.center = point
                    circle.alpha = 0.55
                    self.circles[id] = circle
                } else {
                    self.circles[id] = TouchCircle(center: point,
                                                   radius: 28,
                                                   alpha: 0.55
                    )
                }
            case .ended, .cancelled:
                self.fadeOutCircle(for: id, at: point)
            @unknown default: break
            }
        }
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        for circle in self.circles.values {
            let rect = CGRect(x: circle.center.x - circle.radius,
                              y: circle.center.y - circle.radius,
                              width: circle.radius * 2,
                              height: circle.radius * 2)
            context.setFillColor(UIColor.systemBlue.withAlphaComponent(circle.alpha).cgColor)
            
            context.fillEllipse(in: rect)
        }
    }
    
    private func fadeOutCircle(for id: ObjectIdentifier, at point: CGPoint) {
        guard var circle = self.circles[id] else {
            self.circles[id] = TouchCircle(center: point,
                                           radius: 28,
                                           alpha: 0.55)
            return
            
        }
        
        circle.center = point
        self.circles[id] = circle
        
        UIView.animate(withDuration: 0.18,
                       delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            self.circles[id]?.alpha = 0
            self.circles[id]?.radius = 42
            self.setNeedsDisplay()
        } completion: { _ in
            self.circles.removeValue(forKey: id)
            self.setNeedsDisplay()
        }
    }

    
}
