import UIKit

final class StackedCardTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        StackedCardPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}

final class StackedCardPresentationController: UIPresentationController {

    private enum Metrics {
        static let minTopPeek: CGFloat = 56
        static let topPeekRatio: CGFloat = 0.10
        static let cornerRadius: CGFloat = 10
        static let presentingScale: CGFloat = 0.94
        static let presentingTranslateY: CGFloat = 12
        static let dismissDragThreshold: CGFloat = 120
        static let dismissVelocityThreshold: CGFloat = 800
        static let dragHandleHeight: CGFloat = 120
    }

    private var presentingTransformBackup: CGAffineTransform = .identity
    private var presentingCornerRadiusBackup: CGFloat = 0
    private var presentingMasksToBoundsBackup = false
    private var isInteractiveDragging = false
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var didApplyPresentedStyle = false
    private var lastPresentedFrame: CGRect = .zero

    private var topPeek: CGFloat {
        guard let containerView else { return Metrics.minTopPeek }
        return max(Metrics.minTopPeek, containerView.bounds.height * Metrics.topPeekRatio)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        let peek = topPeek
        return CGRect(
            x: 0,
            y: peek,
            width: containerView.bounds.width,
            height: containerView.bounds.height - peek
        )
    }

    override func presentationTransitionWillBegin() {
        guard let presentingView = presentingViewController.view else { return }

        presentingTransformBackup = presentingView.transform
        presentingCornerRadiusBackup = presentingView.layer.cornerRadius
        presentingMasksToBoundsBackup = presentingView.layer.masksToBounds

        presentingView.layer.cornerRadius = Metrics.cornerRadius
        presentingView.layer.masksToBounds = true
        applyPresentedStyleIfNeeded()

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.updatePresentingTransform(progress: 0)
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        guard completed else { return }
        installPanGestureIfNeeded()
    }

    override func dismissalTransitionWillBegin() {
        guard let presentingView = presentingViewController.view else { return }

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            presentingView.transform = self.presentingTransformBackup
            presentingView.layer.cornerRadius = self.presentingCornerRadiusBackup
            presentingView.layer.masksToBounds = self.presentingMasksToBoundsBackup
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        guard completed, let panGestureRecognizer else { return }
        panGestureRecognizer.view?.removeGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = nil
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard !isInteractiveDragging else { return }

        let targetFrame = frameOfPresentedViewInContainerView
        guard targetFrame != lastPresentedFrame else { return }
        lastPresentedFrame = targetFrame
        presentedView?.frame = targetFrame
    }

    // MARK: - Interactive dismiss

    private func installPanGestureIfNeeded() {
        guard let presentedView, panGestureRecognizer == nil else { return }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        presentedView.addGestureRecognizer(pan)
        panGestureRecognizer = pan
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView, let containerView else { return }

        let translation = gesture.translation(in: containerView)
        let velocity = gesture.velocity(in: containerView)
        let restingFrame = frameOfPresentedViewInContainerView
        let maxDrag = containerView.bounds.height - restingFrame.origin.y

        switch gesture.state {
        case .began:
            isInteractiveDragging = true

        case .changed:
            let dragY = max(0, translation.y)
            presentedView.frame.origin.y = restingFrame.origin.y + dragY
            updatePresentingTransform(progress: min(1, dragY / maxDrag))

        case .ended, .cancelled:
            let dragY = max(0, translation.y)
            if dragY > Metrics.dismissDragThreshold || velocity.y > Metrics.dismissVelocityThreshold {
                isInteractiveDragging = false
                presentedViewController.dismiss(animated: true)
            } else {
                snapBack(to: restingFrame)
            }

        default:
            break
        }
    }

    private func snapBack(to frame: CGRect) {
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.4
        ) {
            self.presentedView?.frame = frame
            self.updatePresentingTransform(progress: 0)
        } completion: { _ in
            self.isInteractiveDragging = false
            self.lastPresentedFrame = frame
        }
    }

    // MARK: - Styling

    private func applyPresentedStyleIfNeeded() {
        guard !didApplyPresentedStyle, let presentedView else { return }
        didApplyPresentedStyle = true
        presentedView.layer.cornerRadius = Metrics.cornerRadius
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.clipsToBounds = true
        presentedView.layer.shadowColor = UIColor.black.cgColor
        presentedView.layer.shadowOpacity = 0.12
        presentedView.layer.shadowRadius = 16
        presentedView.layer.shadowOffset = CGSize(width: 0, height: -4)
    }

    private func updatePresentingTransform(progress: CGFloat) {
        guard let presentingView = presentingViewController.view else { return }
        let clamped = min(max(progress, 0), 1)
        let scale = Metrics.presentingScale + (1 - Metrics.presentingScale) * clamped
        let translateY = Metrics.presentingTranslateY * (1 - clamped)
        presentingView.transform = CGAffineTransform(translationX: 0, y: translateY).scaledBy(x: scale, y: scale)
    }
}

extension StackedCardPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
              let view = pan.view else { return false }
        let velocity = pan.velocity(in: view)
        let location = pan.location(in: view)
        return velocity.y > abs(velocity.x) && location.y <= Metrics.dragHandleHeight
    }
}

private enum StackedCardAssociatedKeys {
    static var transitioningDelegate: UInt8 = 0
}

extension UIViewController {
    var stackedCardTransitioningDelegate: StackedCardTransitioningDelegate? {
        get {
            objc_getAssociatedObject(self, &StackedCardAssociatedKeys.transitioningDelegate)
                as? StackedCardTransitioningDelegate
        }
        set {
            objc_setAssociatedObject(
                self,
                &StackedCardAssociatedKeys.transitioningDelegate,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
