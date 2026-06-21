import RxSwift
import UIKit

final class ApplicationCoordinator {
    let shared: SharedAppContext
    let session: SessionContext?
    let rootController: RootNavigationController
    let isReady: Observable<Bool>

    init(shared: SharedAppContext, session: SessionContext?) {
        self.shared = shared
        self.session = session

        let rootController = RootNavigationController(presentationData: shared.presentationData)
        let navigation = NavigationCoordinatorImpl(rootController: rootController)
        if let session = session as? SessionContextImpl {
            session.bind(navigation: navigation)
        }
        rootController.configure(session: session)

        self.rootController = rootController
        isReady = rootController.isReadyStream
    }
}
