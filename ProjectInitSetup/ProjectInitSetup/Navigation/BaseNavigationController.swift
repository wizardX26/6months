import RxSwift
import UIKit

class BaseNavigationController: UINavigationController, ContainerLayoutParticipant, UINavigationControllerDelegate {
    private var presentationDisposeBag = DisposeBag()
    private var currentPresentationData: PresentationData?

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    func bindPresentationData(_ observable: Observable<PresentationData>) {
        presentationDisposeBag = DisposeBag()
        observable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.updateTheme(data)
            })
            .disposed(by: presentationDisposeBag)
    }

    func updateTheme(_ data: PresentationData) {
        currentPresentationData = data
        view.backgroundColor = data.theme.backgroundColor
        setNeedsLayoutUpdate()
    }

    func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        propagateLayout(layout, transition: transition)
    }

    func setNeedsLayoutUpdate() {
        if let layout = (view.window as? AppWindow)?.containerLayout {
            containerLayoutUpdated(layout, transition: .immediate)
        }
    }

    private func propagateLayout(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        for controller in viewControllers {
            (controller as? ContainerLayoutParticipant)?.containerLayoutUpdated(layout, transition: transition)
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let layout = (view.window as? AppWindow)?.containerLayout {
            (viewController as? ContainerLayoutParticipant)?.containerLayoutUpdated(layout, transition: .animated(duration: 0.25))
        }
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
