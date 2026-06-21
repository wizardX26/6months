import RxSwift
import UIKit

final class BootstrapCoordinator {
    private let window: AppWindow
    private var sharedContext: SharedAppContextImpl?

    init(window: AppWindow) {
        self.window = window
    }

    func start() -> Observable<UIViewController> {
        buildSharedContext()
            .flatMap { [weak self] shared -> Observable<(SharedAppContextImpl, SessionContext?)> in
                guard let self else { return .empty() }
                return self.buildSessionContext(shared: shared).map { (shared, $0) }
            }
            .map { shared, session in
                ApplicationCoordinator(shared: shared, session: session)
            }
            .flatMap { coordinator in
                coordinator.isReady
                    .filter { $0 }
                    .take(1)
                    .map { _ in coordinator.rootController as UIViewController }
            }
    }

    private func buildSharedContext() -> Observable<SharedAppContextImpl> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }

            let presentationProvider = PresentationDataProvider()
            let persistence = PersistenceServiceImpl()
            let appBindings = AppBindingsImpl()
            let placeholderNav = UINavigationController()
            let guestNavigation = NavigationCoordinatorImpl(rootController: placeholderNav)

            let shared = SharedAppContextImpl(
                presentationProvider: presentationProvider,
                appBindings: appBindings,
                persistence: persistence,
                guestNavigation: guestNavigation
            )
            shared.window = self.window
            self.sharedContext = shared

            let disposable = shared.startPresentationDataLoading()
            observer.onNext(shared)
            observer.onCompleted()

            return Disposables.create {
                disposable.dispose()
            }
        }
    }

    private func buildSessionContext(shared: SharedAppContextImpl) -> Observable<SessionContext?> {
        shared.persistence.loadAuthState()
            .asObservable()
            .map { authState -> SessionContext? in
                switch authState {
                case .guest:
                    return nil
                case let .authenticated(userId):
                    let placeholderNav = UINavigationController()
                    let placeholderNavigation = NavigationCoordinatorImpl(rootController: placeholderNav)
                    return SessionContextImpl(
                        shared: shared,
                        userId: userId,
                        api: APIServiceImpl(),
                        navigation: placeholderNavigation
                    )
                }
            }
    }
}
