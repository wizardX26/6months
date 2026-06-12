//
//  TouchWindow.swift
//  Gesture&Touch
//
//  Created by eco mobile on 12/6/26.
//

import UIKit

class TouchWindow: UIWindow {

    private let touchOverlayView = TouchOverlayView()
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupOverlay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sendEvent(_ event: UIEvent) {
        if let touches = event.allTouches {
            touchOverlayView.handle(touches: touches)
        }
        
        super.sendEvent(event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bringSubviewToFront(self.touchOverlayView)
    }
    
    private func setupOverlay() {
        self.touchOverlayView.translatesAutoresizingMaskIntoConstraints = false
        
        self.touchOverlayView.isUserInteractionEnabled = false
        self.touchOverlayView.backgroundColor = .clear
        
        addSubview(self.touchOverlayView)
        
        NSLayoutConstraint.activate([
            self.touchOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.touchOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.touchOverlayView.topAnchor.constraint(equalTo: topAnchor),
            self.touchOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
