import RxSwift
import UIKit

protocol SharedAppContext: AnyObject {
    var window: AppWindow? { get set }
    var presentationData: Observable<PresentationData> { get }
    var appBindings: AppBindings { get }
    var persistence: PersistenceService { get }
    var guestNavigation: NavigationCoordinator { get }

    func makeHomeViewController(session: SessionContext) -> UIViewController
    func makeExploreViewController(session: SessionContext) -> UIViewController
    func makeProfileViewController(session: SessionContext) -> UIViewController
}

protocol SessionContext: AnyObject {
    var shared: SharedAppContext { get }
    var userId: String { get }
    var api: APIService { get }
    var navigation: NavigationCoordinator { get }
}
