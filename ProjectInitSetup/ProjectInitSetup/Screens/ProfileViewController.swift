import RxSwift
import UIKit

final class ProfileViewController: BaseViewController {
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
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        view.addSubview(label)

        session.shared.presentationData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.view.backgroundColor = data.theme.backgroundColor
                self.label.textColor = data.theme.primaryTextColor
                self.label.text = "User: \(self.session.userId)"
                (self.navigationBarView as? CustomNavigationBar)?.setTitle(data.strings.profileTitle)
            })
            .disposed(by: disposeBag)
    }

    override func layoutContent(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        super.layoutContent(layout, transition: transition)
        label.frame = contentFrame(for: layout).insetBy(dx: 24, dy: 24)
    }
}
