import UIKit

// MARK: - SceneDelegate
// -----------------------------------------------------------------------
// Tương đương với AppDelegate trong sách Objective-C.
//
// Trong Obj-C (sách), tác giả dùng macro compile-time:
//   #define WINDOW_CLASS TOUCHOverlayWindow   (khi USES_TOUCHkit = 1)
//   #define WINDOW_CLASS UIWindow             (khi deploy lên App Store)
//
// Trong Swift, ta dùng build flag tương tự:
//   Product → Scheme → Edit Scheme → Run → Arguments → Swift Flags
//   Thêm: -D USES_TOUCH_OVERLAY
//
// Điểm thay đổi DUY NHẤT trong cả project là 1 dòng ở đây:
//   window = TouchOverlayWindow(windowScene: scene)  // thay vì UIWindow
// -----------------------------------------------------------------------

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // ⭐ Thuộc tính window của UIWindowSceneDelegate
    // UIKit đọc property này để biết window nào là key window.
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // ── Bước 1: Tạo window ───────────────────────────────────────────
        // ĐÂY LÀ ĐIỂM DUY NHẤT khác biệt so với app bình thường.
        // Đổi UIWindow → TouchOverlayWindow là tất cả những gì cần làm.
        //
        // Với build flag (giống sách):
        //#if USES_TOUCH_OVERLAY
        window = TouchOverlayWindow(windowScene: windowScene)
        //#else
        //window = UIWindow(windowScene: windowScene)
        //#endif

        // ── Bước 2: Gán rootViewController như bình thường ──────────────
        let rootVC = DemoViewController()
        let nav = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = nav

        // ── Bước 3: makeKeyAndVisible — BẮT BUỘC trước khi attach overlay
        window?.makeKeyAndVisible()

        // ── Bước 4: Gắn overlay lên key window ──────────────────────────
        // (Chỉ làm khi dùng TouchOverlayWindow)
        #if USES_TOUCH_OVERLAY
        TouchFeedbackView.shared.attachToKeyWindow()
        #endif
    }
}

// MARK: - UIWindow.Level — ứng dụng thực tế
//
// windowLevel quyết định z-order khi có nhiều UIWindow.
// Ứng dụng phổ biến:
//
//   UIWindow.Level.normal      = 0      // App UI bình thường
//   UIWindow.Level.statusBar   = 1000   // Status bar
//   UIWindow.Level.alert       = 2000   // UIAlertController
//
// Ví dụ: Toast notification window nằm trên app nhưng dưới alert
//   let toastWindow = UIWindow(windowScene: scene)
//   toastWindow.windowLevel = UIWindow.Level.alert - 1
//
// Ví dụ: Luôn hiển thị trên tất cả (debug overlay)
//   debugWindow.windowLevel = UIWindow.Level.alert + 100
