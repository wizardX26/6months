//
//  TouchOverlayWindow.swift
//  UIWindowSendEvent
//
//  Created by eco mobile on 17/6/26.
//


import UIKit

// MARK: - TouchOverlayWindow
// -----------------------------------------------------------------------
// Tương đương với TOUCHOverlayWindow trong sách (Objective-C)
//
// NGUYÊN LÝ HOẠT ĐỘNG:
//   UIApplication nhận raw event từ OS rồi gọi window.sendEvent(_:)
//   Ta override phương thức này để "chen vào giữa" và:
//     1. Lấy danh sách tất cả các UITouch trong event
//     2. Phân loại theo UITouchPhase (began / moved / ended / cancelled)
//     3. Forward sang TouchFeedbackView để vẽ vòng tròn
//     4. Gọi super.sendEvent để mọi thứ vẫn hoạt động bình thường
//
// UIWindow hierarchy:
//   UIApplication
//     └── TouchOverlayWindow  ← subclass này
//           ├── rootViewController.view  (app UI bình thường)
//           └── TouchFeedbackView        (overlay trong suốt, vẽ vòng tròn)
// -----------------------------------------------------------------------

final class TouchOverlayWindow: UIWindow {

    // MARK: - Override sendEvent — đây là toàn bộ logic
    override func sendEvent(_ event: UIEvent) {

        // ── Bước 1: Lấy tất cả touches trong event này ──────────────────
        guard let touches = event.allTouches else {
            super.sendEvent(event)
            return
        }

        // ── Bước 2: Phân loại theo phase ────────────────────────────────
        // Dùng Set thay vì NSMutableSet — idiomatic Swift
        var began      = Set<UITouch>()
        var moved      = Set<UITouch>()
        
        ///missing important `UITouch's phase` here
        
        var ended      = Set<UITouch>()
        var cancelled  = Set<UITouch>()

        for touch in touches {
            switch touch.phase {
            case .began:       began.insert(touch)
            case .moved:       moved.insert(touch)
            case .ended:       ended.insert(touch)
            case .cancelled:   cancelled.insert(touch)
            default:           break   // .stationary, .regionEntered, v.v.
            }
        }

        // ── Bước 3: Forward sang overlay để vẽ vòng tròn ────────────────
        // TouchFeedbackView.shared là singleton UIView nằm trên cùng
        let overlay = TouchFeedbackView.shared

        if !began.isEmpty     { overlay.touchesBegan(began, with: event)     }
        if !moved.isEmpty     { overlay.touchesMoved(moved, with: event)     }
        if !ended.isEmpty     { overlay.touchesEnded(ended, with: event)     }
        if !cancelled.isEmpty { overlay.touchesCancelled(cancelled, with: event) }

        // ── Bước 4: LUÔN gọi super để event vẫn đi vào responder chain ──
        // Nếu bỏ dòng này, app sẽ không nhận được touch nào cả!
        super.sendEvent(event)
    }
}
