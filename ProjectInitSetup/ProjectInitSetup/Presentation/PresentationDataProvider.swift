import RxSwift

final class PresentationDataProvider {
    private let subject = BehaviorSubject<PresentationData>(value: .default)

    var observable: Observable<PresentationData> {
        subject.asObservable().distinctUntilChanged()
    }

    var current: PresentationData {
        (try? subject.value()) ?? .default
    }

    func load(from persistence: PersistenceService) -> Disposable {
        persistence.presentationSettings()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] settings in
                self?.subject.onNext(PresentationData(settings: settings))
            })
    }

    func update(_ data: PresentationData) {
        subject.onNext(data)
    }
}
