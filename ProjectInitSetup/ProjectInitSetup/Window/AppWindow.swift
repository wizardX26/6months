import UIKit

final class AppWindow: UIWindow {
    private(set) var containerLayout: ContainerViewLayout?
    weak var layoutRoot: ContainerLayoutParticipant?

    private var keyboardHeight: CGFloat?
    private var coveringView: UIView?
    private var coveringController: UIViewController?

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        installObservers()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        installObservers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        installObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setRootViewController(_ controller: UIViewController, animated: Bool) {
        if animated {
            UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) {
                self.rootViewController = controller
                self.layoutRoot = controller as? ContainerLayoutParticipant
                self.commitLayout(transition: .animated(duration: 0.25))
            }
        } else {
            rootViewController = controller
            layoutRoot = controller as? ContainerLayoutParticipant
            commitLayout(transition: .immediate)
        }
    }

    func showCovering(_ controller: UIViewController) {
        coveringController?.willMove(toParent: nil)
        coveringController?.view.removeFromSuperview()
        coveringController?.removeFromParent()

        coveringController = controller
        if let root = rootViewController {
            root.addChild(controller)
            controller.view.frame = root.view.bounds
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            root.view.addSubview(controller.view)
            controller.didMove(toParent: root)
        } else {
            addSubview(controller.view)
            controller.view.frame = bounds
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        coveringView = controller.view
    }

    func hideCovering(animated: Bool) {
        guard let view = coveringView else { return }
        let remove = { [weak self] in
            self?.coveringController?.willMove(toParent: nil)
            view.removeFromSuperview()
            self?.coveringController?.removeFromParent()
            self?.coveringView = nil
            self?.coveringController = nil
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                view.alpha = 0
            }, completion: { _ in remove() })
        } else {
            remove()
        }
    }

    func commitLayout(transition: LayoutTransition = .immediate) {
        let layout = buildContainerLayout()
        guard layout != containerLayout else { return }
        containerLayout = layout
        layoutRoot?.containerLayoutUpdated(layout, transition: transition)
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        commitLayout(transition: .animated(duration: 0.25))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        commitLayout(transition: .immediate)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        commitLayout(transition: .immediate)
    }

    private func installObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let converted = convert(frameEnd, from: nil)
        let overlap = max(0, bounds.maxY - converted.minY)
        keyboardHeight = overlap > 0 ? overlap : nil
        commitLayout(transition: .animated(duration: 0.25))
    }

    private func buildContainerLayout() -> ContainerViewLayout {
        let scene = windowScene
        let statusBarHeight = scene?.statusBarManager?.statusBarFrame.height
        let metrics = LayoutMetrics(traitCollection: traitCollection)

        return ContainerViewLayout(
            size: bounds.size,
            safeAreaInsets: safeAreaInsets,
            statusBarHeight: statusBarHeight,
            keyboardHeight: keyboardHeight,
            intrinsicInsets: .zero,
            metrics: metrics
        )
    }
}
