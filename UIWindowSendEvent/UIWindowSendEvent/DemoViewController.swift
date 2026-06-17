//
//  DemoViewController.swift
//  UIWindowSendEvent
//
//  Created by eco mobile on 17/6/26.
//


import UIKit

// MARK: - DemoViewController
// -----------------------------------------------------------------------
// Demo tổng hợp các ứng dụng thực tế của UIWindow:
//
//  1. Touch feedback overlay (chính của bài học)
//  2. Multiple UIWindow — Toast notification
//  3. windowLevel — z-order management
//  4. convert(_:to:) — chuyển đổi tọa độ giữa windows
// -----------------------------------------------------------------------

final class DemoViewController: UIViewController {

    // MARK: - UI Components
    private let descriptionLabel = UILabel()
    private let touchAreaView    = UIView()
    private let showToastButton  = UIButton(type: .system)
    private let showAlertButton  = UIButton(type: .system)
    private let coordLabel       = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIWindow Demo"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        // ── Touch area ───────────────────────────────────────────────────
        touchAreaView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        touchAreaView.layer.cornerRadius = 12
        touchAreaView.layer.borderWidth = 1.5
        touchAreaView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        touchAreaView.translatesAutoresizingMaskIntoConstraints = false

        let areaLabel = UILabel()
        areaLabel.text = "Chạm vào đây để xem touch overlay"
        areaLabel.font = .systemFont(ofSize: 15, weight: .medium)
        areaLabel.textColor = .systemBlue
        areaLabel.textAlignment = .center
        areaLabel.translatesAutoresizingMaskIntoConstraints = false
        touchAreaView.addSubview(areaLabel)

        // ── Description ──────────────────────────────────────────────────
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.text = """
        TouchOverlayWindow ghi đè sendEvent: để bắt mọi UITouch.
        Vòng tròn trắng hiện tại vị trí chạm là UIView trong suốt
        (isUserInteractionEnabled = false) — app vẫn hoạt động bình thường.
        """
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── Coordinate label ─────────────────────────────────────────────
        coordLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        coordLabel.textColor = .tertiaryLabel
        coordLabel.textAlignment = .center
        coordLabel.text = "Tọa độ touch: —"
        coordLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── Buttons ──────────────────────────────────────────────────────
        configureButton(showToastButton,
                        title: "Demo: Toast Window (windowLevel)",
                        action: #selector(showToastWindow))

        configureButton(showAlertButton,
                        title: "Demo: Alert trên Toast",
                        action: #selector(showSystemAlert))

        // ── Stack layout ─────────────────────────────────────────────────
        let stack = UIStackView(arrangedSubviews: [
            descriptionLabel,
            touchAreaView,
            coordLabel,
            showToastButton,
            showAlertButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            touchAreaView.heightAnchor.constraint(equalToConstant: 180),
            areaLabel.centerXAnchor.constraint(equalTo: touchAreaView.centerXAnchor),
            areaLabel.centerYAnchor.constraint(equalTo: touchAreaView.centerYAnchor),
        ])

        // ── GestureRecognizer để track tọa độ ───────────────────────────
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        touchAreaView.addGestureRecognizer(pan)
        touchAreaView.isUserInteractionEnabled = true
    }

    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 46).isActive = true
    }

    // MARK: - Touch coordinate tracking
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        // ── convert(_:to:) — ứng dụng thực tế ───────────────────────────
        // locationInView trả về tọa độ trong coordinate system của touchAreaView
        // convert sang window để thấy tọa độ tuyệt đối trên màn hình
        let pointInView   = gesture.location(in: touchAreaView)
        let pointInWindow = gesture.location(in: view.window)

        coordLabel.text = String(
            format: "Trong view: (%.0f, %.0f)  │  Trong window: (%.0f, %.0f)",
            pointInView.x, pointInView.y,
            pointInWindow.x, pointInWindow.y
        )
    }

    // MARK: - Demo 2: Toast Notification Window
    // -----------------------------------------------------------------------
    // Ứng dụng thực tế của UIWindow: Toast / HUD luôn hiển thị trên mọi
    // màn hình của app mà không cần truyền reference qua ViewController.
    //
    // windowLevel = .alert - 1  →  Nằm trên app nhưng dưới UIAlertController
    // -----------------------------------------------------------------------
    @objc private func showToastWindow() {
        guard let windowScene = view.window?.windowScene else { return }

        // Tạo một UIWindow mới — đây là cách làm HUD/Toast chuyên nghiệp
        let toastWindow = UIWindow(windowScene: windowScene)

        // ⭐ windowLevel: nằm trên app (.normal=0) nhưng dưới alert (=2000)
        toastWindow.windowLevel = UIWindow.Level.alert - 1

        // Window trong suốt, chỉ chứa toast view
        toastWindow.backgroundColor = .clear
        toastWindow.isUserInteractionEnabled = false

        // Tạo toast view
        let toastView = makeToastView(message: "✅  Toast từ UIWindow riêng (level \(UIWindow.Level.alert - 1))")
        toastWindow.addSubview(toastView)

        // Căn giữa cuối màn hình
        toastWindow.frame = UIScreen.main.bounds
        toastView.center = CGPoint(x: toastWindow.bounds.midX,
                                   y: toastWindow.bounds.maxY - 120)

        toastWindow.isHidden = false
        toastWindow.makeKeyAndVisible()

        // Auto-dismiss sau 2.5 giây
        // Giữ strong reference trong closure để window không bị deallocate
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            UIView.animate(withDuration: 0.3, animations: {
                toastView.alpha = 0
            }, completion: { _ in
                toastWindow.isHidden = true
                // toastWindow sẽ bị ARC giải phóng sau khi closure kết thúc
                _ = toastWindow
            })
        }
    }

    private func makeToastView(message: String) -> UIView {
        let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        container.layer.cornerRadius = 14
        container.clipsToBounds = true

        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        container.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.contentView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: container.contentView.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: container.contentView.trailingAnchor, constant: -20),
        ])
        container.frame = CGRect(x: 0, y: 0, width: 320, height: 56)
        return container
    }

    // MARK: - Demo 3: windowLevel comparison
    @objc private func showSystemAlert() {
        // UIAlertController dùng windowLevel = .alert (2000)
        // Nên nó sẽ hiển thị TRÊN Toast window (level = 1999)
        let alert = UIAlertController(
            title: "windowLevel Demo",
            message: "Alert này có windowLevel = 2000 (.alert)\nToast có windowLevel = 1999\n\nAlert luôn nằm trên Toast.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIWindow Ứng dụng thực tế — Cheat Sheet
/*
 ┌─────────────────────────────────────────────────────────────────────┐
 │  UIWindow Use Cases                                                  │
 ├────────────────────────┬────────────────────────────────────────────┤
 │  Touch Overlay (sách)  │  Override sendEvent: → vẽ debug touch      │
 │  Toast / HUD           │  UIWindow mới + windowLevel .alert - 1     │
 │  Keyboard Toolbar      │  UIWindow gắn vào inputAccessoryView       │
 │  External Display      │  UIWindow(windowScene: externalScene)      │
 │  Coordinate convert    │  window.convert(_:from/to:)                │
 │  Multi-scene iPad      │  Mỗi UIWindowScene có 1+ UIWindow          │
 └────────────────────────┴────────────────────────────────────────────┘
*/