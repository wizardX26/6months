import RxSwift
import UIKit

final class SharedAppContextImpl: SharedAppContext {
    weak var window: AppWindow?

    let presentationData: Observable<PresentationData>
    let appBindings: AppBindings
    let persistence: PersistenceService
    let guestNavigation: NavigationCoordinator

    private let presentationProvider: PresentationDataProvider

    init(
        presentationProvider: PresentationDataProvider,
        appBindings: AppBindings,
        persistence: PersistenceService,
        guestNavigation: NavigationCoordinator
    ) {
        self.presentationProvider = presentationProvider
        self.presentationData = presentationProvider.observable
        self.appBindings = appBindings
        self.persistence = persistence
        self.guestNavigation = guestNavigation
    }

    func makeHomeViewController(session: SessionContext) -> UIViewController {
        HomeViewController(session: session)
    }

    func makeExploreViewController(session: SessionContext) -> UIViewController {
        ExploreViewController(session: session)
    }

    func makeProfileViewController(session: SessionContext) -> UIViewController {
        ProfileViewController(session: session)
    }

    func startPresentationDataLoading() -> Disposable {
        presentationProvider.load(from: persistence)
    }
}

final class SessionContextImpl: SessionContext {
    let shared: SharedAppContext
    let userId: String
    let api: APIService
    private(set) var navigation: NavigationCoordinator

    init(
        shared: SharedAppContext,
        userId: String,
        api: APIService,
        navigation: NavigationCoordinator
    ) {
        self.shared = shared
        self.userId = userId
        self.api = api
        self.navigation = navigation
    }

    func bind(navigation: NavigationCoordinator) {
        self.navigation = navigation
    }
}
