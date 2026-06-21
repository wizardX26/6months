import RxSwift
import UIKit

protocol TabPagerContainerDelegate: AnyObject {
    func pager(_ pager: TabPagerContainer, didUpdateProgress progress: CGFloat, from: Int, to: Int)
    func pager(_ pager: TabPagerContainer, didCommitTo index: Int)
    func pagerShouldBeginPaging(_ pager: TabPagerContainer) -> Bool
}

/// Horizontal paging between tab root view controllers (Instagram-style content swipe).
/// Gesture lives on this container — not on AppWindow.
final class TabPagerContainer: UIView, ReadyProviding {
    weak var delegate: TabPagerContainerDelegate?

    private var viewControllers: [UIViewController] = []
    private weak var parentController: UIViewController?
    private var panRecognizer: UIPanGestureRecognizer!
    private(set) var currentIndex: Int = 0
    private var isAnimating = false
    private var isHorizontalPanLocked = false
    private var interactiveFromIndex: Int = 0
    private var interactiveToIndex: Int = 0

    private let readyState = ReadyStateHolder()
    var isReady: Observable<Bool> { readyState.isReady }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func markReady() {
        readyState.markReady()
    }

    func setViewControllers(_ controllers: [UIViewController], parent: UIViewController, selectedIndex: Int) {
        viewControllers.forEach { vc in
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }

        viewControllers = controllers
        parentController = parent
        currentIndex = min(max(selectedIndex, 0), max(controllers.count - 1, 0))

        for (index, controller) in controllers.enumerated() {
            parent.addChild(controller)
            addSubview(controller.view)
            controller.view.frame = pageFrame(for: index, progress: 0, from: currentIndex, to: currentIndex)
            controller.didMove(toParent: parent)
        }

        layoutPages(progress: 0, from: currentIndex, to: currentIndex)
        markReady()
    }

    func scrollToIndex(_ index: Int, animated: Bool, completion: (() -> Void)? = nil) {
        guard index >= 0, index < viewControllers.count else {
            completion?()
            return
        }
        guard index != currentIndex else {
            completion?()
            return
        }
        guard !isAnimating else { return }

        let from = currentIndex
        let to = index

        if animated {
            isAnimating = true
            layoutPages(progress: 0, from: from, to: to)
            UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseOut, animations: {
                self.layoutPages(progress: 1, from: from, to: to)
            }, completion: { _ in
                self.currentIndex = to
                self.layoutPages(progress: 0, from: to, to: to)
                self.isAnimating = false
                completion?()
            })
        } else {
            currentIndex = to
            layoutPages(progress: 0, from: to, to: to)
            completion?()
        }
    }

    func updateInteractiveTransition(progress: CGFloat, from: Int, to: Int) {
        guard !isAnimating, from >= 0, to >= 0, from < viewControllers.count, to < viewControllers.count else { return }
        interactiveFromIndex = from
        interactiveToIndex = to
        layoutPages(progress: progress, from: from, to: to)
    }

    func commitInteractiveTransition(to index: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard index >= 0, index < viewControllers.count else {
            completion?()
            return
        }

        let from = interactiveFromIndex
        let to = interactiveToIndex

        if index == currentIndex {
            layoutPages(progress: 0, from: currentIndex, to: currentIndex)
            completion?()
            return
        }

        let endProgress: CGFloat = index == to ? 1 : 0

        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut, animations: {
                self.layoutPages(progress: endProgress, from: from, to: to)
            }, completion: { _ in
                self.currentIndex = index
                self.layoutPages(progress: 0, from: index, to: index)
                self.isAnimating = false
                completion?()
            })
        } else {
            currentIndex = index
            layoutPages(progress: 0, from: index, to: index)
            completion?()
        }
    }

    func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        frame = CGRect(
            x: 0,
            y: 0,
            width: layout.size.width,
            height: layout.size.height - layout.intrinsicInsets.bottom
        )
        layoutPages(progress: 0, from: currentIndex, to: currentIndex)

        let childLayout = layout.withIntrinsicBottomInset(0)
        visibleViewControllers().forEach { vc in
            (vc as? ContainerLayoutParticipant)?.containerLayoutUpdated(childLayout, transition: transition)
        }
    }

    func visibleViewControllers() -> [UIViewController] {
        guard !viewControllers.isEmpty else { return [] }
        var indices = Set<Int>([currentIndex])
        if currentIndex > 0 { indices.insert(currentIndex - 1) }
        if currentIndex < viewControllers.count - 1 { indices.insert(currentIndex + 1) }
        return indices.sorted().compactMap { idx in
            guard idx >= 0, idx < viewControllers.count else { return nil }
            return viewControllers[idx]
        }
    }

    func selectedViewController() -> UIViewController? {
        guard currentIndex >= 0, currentIndex < viewControllers.count else { return nil }
        return viewControllers[currentIndex]
    }

    /// Finger moves left → next tab; finger moves right → previous tab.
    private func dragDirection(forTranslationX translationX: CGFloat) -> Int {
        if translationX < 0 { return 1 }
        if translationX > 0 { return -1 }
        return 0
    }

    private func adjacentIndices(direction: Int) -> (Int, Int) {
        if direction > 0, currentIndex < viewControllers.count - 1 {
            return (currentIndex, currentIndex + 1)
        } else if direction < 0, currentIndex > 0 {
            return (currentIndex, currentIndex - 1)
        }
        return (currentIndex, currentIndex)
    }

    private func isTouchInsideTabContent(_ touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return false }
        if touchedView === self { return true }
        for controller in viewControllers {
            guard let root = controller.view else { continue }
            if touchedView.isDescendant(of: root) {
                return true
            }
        }
        return false
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !isAnimating, viewControllers.count > 1 else { return }
        guard delegate?.pagerShouldBeginPaging(self) ?? true else { return }

        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        let width = max(bounds.width, 1)

        switch gesture.state {
        case .began:
            isHorizontalPanLocked = false
            interactiveFromIndex = currentIndex
            interactiveToIndex = currentIndex
        case .changed:
            if !isHorizontalPanLocked {
                let absX = abs(translation.x)
                let absY = abs(translation.y)
                if absX > 8 || absY > 8 {
                    if absX <= absY * 1.2 {
                        gesture.state = .cancelled
                        return
                    }
                    isHorizontalPanLocked = true
                } else {
                    return
                }
            }

            let progress = min(max(abs(translation.x) / width, 0), 1)
            let direction = dragDirection(forTranslationX: translation.x)
            let (from, to) = adjacentIndices(direction: direction)
            interactiveFromIndex = from
            interactiveToIndex = to
            layoutPages(progress: progress, from: from, to: to)
            if from != to {
                delegate?.pager(self, didUpdateProgress: progress, from: from, to: to)
            }
        case .ended:
            guard isHorizontalPanLocked else { return }
            finishPan(translation: translation, velocity: velocity, width: width)
        case .cancelled:
            guard isHorizontalPanLocked else { return }
            finishPan(translation: translation, velocity: velocity, width: width, cancelled: true)
        default:
            break
        }
    }

    private func finishPan(translation: CGPoint, velocity: CGPoint, width: CGFloat, cancelled: Bool = false) {
        let progress = min(max(abs(translation.x) / width, 0), 1)
        let direction = dragDirection(forTranslationX: translation.x)
        let (from, to) = adjacentIndices(direction: direction)
        interactiveFromIndex = from
        interactiveToIndex = to

        let target: Int
        if cancelled && progress < 0.15 {
            target = currentIndex
        } else {
            target = TabSwitchPolicy.resolveTargetIndex(
                currentIndex: currentIndex,
                pageCount: viewControllers.count,
                progress: progress,
                velocity: velocity,
                direction: direction
            )
        }

        commitInteractiveTransition(to: target, animated: true) { [weak self] in
            guard let self else { return }
            self.delegate?.pager(self, didCommitTo: target)
        }
    }

    private func layoutPages(progress: CGFloat, from: Int, to: Int) {
        for (index, controller) in viewControllers.enumerated() {
            controller.view.frame = pageFrame(for: index, progress: progress, from: from, to: to)
        }
    }

    private func pageFrame(for index: Int, progress: CGFloat, from: Int, to: Int) -> CGRect {
        let width = bounds.width
        let height = bounds.height
        var x = CGFloat(index - currentIndex) * width

        if from != to {
            if index == from {
                x = -progress * width * CGFloat(to - from)
            } else if index == to {
                x = width * CGFloat(to - from) * (1 - progress)
            } else {
                x = CGFloat(index - currentIndex) * width
            }
        }

        return CGRect(x: x, y: 0, width: width, height: height)
    }
}

extension TabPagerContainer: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panRecognizer else { return true }
        return delegate?.pagerShouldBeginPaging(self) ?? true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === panRecognizer else { return true }
        guard delegate?.pagerShouldBeginPaging(self) ?? true else { return false }
        guard isTouchInsideTabContent(touch) else { return false }

        if let touchedView = touch.view, touchedView is UIControl {
            return false
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        false
    }
}
