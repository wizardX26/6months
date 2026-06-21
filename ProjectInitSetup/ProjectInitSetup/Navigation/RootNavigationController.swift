import RxSwift
import UIKit

final class RootNavigationController: BaseNavigationController {
    private(set) var tabBarControllerRef: TabBarController?
    private let readyState = ReadyStateHolder()
    private let bootstrapDisposeBag = DisposeBag()

    var isReadyStream: Observable<Bool> { readyState.isReady }

    init(presentationData: Observable<PresentationData>) {
        super.init(navigationBarClass: nil, toolbarClass: nil)
        bindPresentationData(presentationData)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(session: SessionContext?) {
        guard let session else {
            readyState.markReady()
            return
        }

        let tabBar = TabBarController(session: session)
        let controllers = [
            session.shared.makeHomeViewController(session: session),
            session.shared.makeExploreViewController(session: session),
            session.shared.makeProfileViewController(session: session)
        ]
        tabBar.setViewControllers(controllers, selectedIndex: 0)
        tabBarControllerRef = tabBar
        setViewControllers([tabBar], animated: false)

        Self.buildReadyStream(tabBar: tabBar)
            .subscribe(onNext: { [weak self] _ in
                self?.readyState.markReady()
            })
            .disposed(by: bootstrapDisposeBag)
    }

    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
    }

    private static func buildReadyStream(tabBar: TabBarController) -> Observable<Bool> {
        Observable.combineLatest(
            tabBar.isReady,
            tabBar.pager.isReady,
            tabBar.selectedViewControllerReady
        )
        .map { $0 && $1 && $2 }
        .filter { $0 }
        .take(1)
    }
}
