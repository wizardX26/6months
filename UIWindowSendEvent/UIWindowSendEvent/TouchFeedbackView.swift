//
//  TouchFeedbackView.swift
//  UIWindowSendEvent
//
//  Created by eco mobile on 17/6/26.
//


import UIKit

// MARK: - TouchFeedbackView
// -----------------------------------------------------------------------
// Tương đương với TOUCHkitView trong sách (Objective-C)
//
// ĐÂY LÀ SINGLETON UIView trong suốt, nằm trên CÙNG của window.
//
// Các thuộc tính UIView quan trọng được dùng ở đây:
//   • backgroundColor = .clear         → trong suốt, không che UI bên dưới
//   • isUserInteractionEnabled = false  → touch đi xuyên qua view này
//   • isMultipleTouchEnabled = true     → hỗ trợ multi-finger
//   • setNeedsDisplay()                 → trigger drawRect: vẽ lại
//
// Tại sao là Singleton?
//   Vì chỉ cần 1 overlay duy nhất cho toàn app, và
//   TouchOverlayWindow cần truy cập nó từ sendEvent: mà không
//   cần giữ strong reference phức tạp.
// -----------------------------------------------------------------------

final class TouchFeedbackView: UIView {

    // MARK: - Singleton
    static let shared = TouchFeedbackView()

    // MARK: - State: tập hợp touches đang được hiển thị
    private var activeTouches = Set<UITouch>()

    // MARK: - Cấu hình màu sắc
    /// Màu vòng tròn chính (override nếu muốn)
    var touchColor: UIColor = UIColor.white.withAlphaComponent(0.75)

    /// Màu bóng đổ phía sau vòng tròn (tạo hiệu ứng chiều sâu)
    var shadowColor: UIColor = UIColor.darkGray.withAlphaComponent(0.5)

    // MARK: - Init
    private init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("Use TouchFeedbackView.shared") }

    private func setupView() {
        // Trong suốt hoàn toàn — không che bất cứ thứ gì bên dưới
        backgroundColor = .clear

        // ⭐ Quan trọng: false để touch "đi xuyên qua" view này
        // Nếu để true, overlay sẽ hấp thụ mọi touch và app không nhận được gì
        isUserInteractionEnabled = false

        // Cho phép vẽ nhiều vòng tròn cùng lúc (multi-finger)
        isMultipleTouchEnabled = true
    }

    // MARK: - Gắn overlay vào window (gọi 1 lần khi app start)
    /// Gắn view này lên top của key window.
    /// Phải gọi sau khi window đã makeKeyAndVisible().
    func attachToKeyWindow() {
        guard superview == nil,
              let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }

        frame = keyWindow.bounds
        keyWindow.addSubview(self)
    }

    // MARK: - Nhận events từ TouchOverlayWindow

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeTouches.formUnion(touches)
        setNeedsDisplay()   // Yêu cầu vẽ lại
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // activeTouches đã chứa các touch này rồi (cùng object),
        // chỉ cần setNeedsDisplay để vẽ lại tại vị trí mới
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeTouches.subtract(touches)
        setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeTouches.subtract(touches)
        setNeedsDisplay()
    }

    // MARK: - Vẽ vòng tròn tại từng touch point
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Xóa canvas — quan trọng vì view vẫn còn trên screen
        ctx.clear(bounds)
        UIColor.clear.setFill()
        ctx.fill(bounds)

        let radius: CGFloat = 25   // Dựa trên 44pt touch target chuẩn của Apple

        for touch in activeTouches {
            let center = touch.location(in: self)

            // ── Vẽ bóng đổ (lớp dưới, to hơn 1pt) ─────────────────────
            shadowColor.setFill()
            let shadowRect = CGRect(
                x: center.x - radius - 1,
                y: center.y - radius - 1,
                width: (radius + 1) * 2,
                height: (radius + 1) * 2
            )
            ctx.fillEllipse(in: shadowRect)

            // ── Vẽ vòng tròn chính ───────────────────────────────────
            touchColor.setFill()
            let touchRect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            ctx.fillEllipse(in: touchRect)
        }
    }
}