import RxSwift

protocol APIService: AnyObject {
    func fetchFeed() -> Observable<[String]>
}

final class APIServiceImpl: APIService {
    func fetchFeed() -> Observable<[String]> {
        .just(["Welcome to Home", "Telegram-inspired architecture"])
    }
}
