import RxSwift
import UIKit

protocol PersistenceService: AnyObject {
    func presentationSettings() -> Observable<PresentationSettings>
    func loadAuthState() -> Single<AuthState>
}

enum AuthState: Equatable {
    case guest
    case authenticated(userId: String)
}

final class PersistenceServiceImpl: PersistenceService {
    func presentationSettings() -> Observable<PresentationSettings> {
        let isDark = UITraitCollection.current.userInterfaceStyle == .dark
        return .just(PresentationSettings(isDarkMode: isDark))
    }

    func loadAuthState() -> Single<AuthState> {
        .just(.authenticated(userId: "demo-user"))
    }
}
