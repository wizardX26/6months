//
//  InteractivePopPipeline.swift
//  SwipeDissmissWithPageView
//

import UIKit

/// Coordinates interactive pop gesture: delegate negotiation, gating, and progress mapping.
final class InteractivePopPipeline: NSObject {

    enum PopState {
        case began
        case changed(translation: CGFloat, progress: CGFloat)
        case ended(translation: CGFloat, velocity: CGFloat, shouldComplete: Bool)
        case cancelled
    }

    var currentPageIndex: () -> Int = { 0 }
    var canPop: () -> Bool = { true }
    weak var pageView: UIView?
    weak var pageScrollPan: UIGestureRecognizer? {
        didSet { wirePageScrollPan() }
    }
    var onPop: (PopState) -> Void = { _ in }

    private(set) var recognizer: InteractivePopGestureRecognizer

    init(on view: UIView) {
        let recognizer = InteractivePopGestureRecognizer()
        self.recognizer = recognizer
        super.init()

        recognizer.addTarget(self, action: #selector(handleStateChange(_:)))
        recognizer.delegate = self
        recognizer.canBegin = { [weak self] in
            guard let self else { return false }
            return self.currentPageIndex() == 0 && self.canPop()
        }
        recognizer.onActiveUpdate = { [weak self] translation, velocity in
            self?.handleActiveUpdate(translation: translation, velocity: velocity)
        }
        recognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizer)
    }

    private func wirePageScrollPan() {
        guard let pageScrollPan else { return }
        pageScrollPan.require(toFail: recognizer)
    }

    @objc private func handleStateChange(_ gesture: InteractivePopGestureRecognizer) {
        guard let view = gesture.view else { return }

        switch gesture.state {
        case .began:
            onPop(.began)
            let translation = max(0, gesture.currentTranslation.x)
            let progress = min(1, translation / view.bounds.width)
            onPop(.changed(translation: translation, progress: progress))
        case .ended:
            let translation = max(0, gesture.currentTranslation.x)
            let progress = min(1, translation / view.bounds.width)
            let velocity = gesture.currentVelocity.x
            let shouldComplete = velocity > 800 || progress > 0.35
            onPop(.ended(translation: translation, velocity: velocity, shouldComplete: shouldComplete))
        case .cancelled, .failed:
            onPop(.cancelled)
        default:
            break
        }
    }

    private func handleActiveUpdate(translation: CGPoint, velocity: CGPoint) {
        guard let view = recognizer.view else { return }
        let clampedTranslation = max(0, translation.x)
        let progress = min(1, clampedTranslation / view.bounds.width)
        onPop(.changed(translation: clampedTranslation, progress: progress))
        _ = velocity
    }
}

extension InteractivePopPipeline: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard currentPageIndex() == 0, canPop() else { return false }
        guard let recognizer = gestureRecognizer as? InteractivePopGestureRecognizer else { return false }

        let translation = recognizer.currentTranslation
        let velocity = recognizer.currentVelocity

        if abs(translation.y) > abs(translation.x) {
            return false
        }
        if abs(velocity.y) > abs(velocity.x) * 1.5, abs(velocity.x) > 0 {
            return false
        }
        if translation.x < 0 || velocity.x < 0 {
            return false
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if currentPageIndex() == 0,
           let pageScrollPan,
           otherGestureRecognizer === pageScrollPan {
            return true
        }

        if currentPageIndex() != 0,
           otherGestureRecognizer is UIPanGestureRecognizer,
           let pageView,
           otherGestureRecognizer.view?.isDescendant(of: pageView) == true {
            return true
        }

        return false
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
}
