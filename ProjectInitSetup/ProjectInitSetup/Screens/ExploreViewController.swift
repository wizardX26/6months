import RxSwift
import UIKit

final class ExploreViewController: BaseViewController {
    private let session: SessionContext
    private let label = UILabel()

    init(session: SessionContext) {
        self.session = session
        super.init(
            navigationBarPresentationData: NavigationBarPresentationData(
                presentationData: PresentationData.default
            )
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Swipe horizontally to switch tabs (Instagram-style)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        view.addSubview(label)

        session.shared.presentationData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.view.backgroundColor = data.theme.backgroundColor
                self?.label.textColor = data.theme.secondaryTextColor
                (self?.navigationBarView as? CustomNavigationBar)?.setTitle(data.strings.exploreTitle)
            })
            .disposed(by: disposeBag)
    }

    override func layoutContent(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        super.layoutContent(layout, transition: transition)
        label.frame = contentFrame(for: layout).insetBy(dx: 24, dy: 24)
    }
}
