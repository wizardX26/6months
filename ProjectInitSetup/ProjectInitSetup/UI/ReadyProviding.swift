import RxSwift
import UIKit

protocol ReadyProviding: AnyObject {
    var isReady: Observable<Bool> { get }
    func markReady()
}

class ReadyStateHolder {
    private let subject = BehaviorSubject<Bool>(value: false)

    var isReady: Observable<Bool> {
        subject
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .startWith(false)
    }

    func markReady() {
        subject.onNext(true)
    }
}
