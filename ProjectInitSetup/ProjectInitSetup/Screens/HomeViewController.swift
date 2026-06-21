import RxSwift
import UIKit

final class HomeViewController: BaseViewController {
    private let session: SessionContext
    private let label = UILabel()
    private let stackView = UIStackView()

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
        setupUI()
        bindPresentationData()
        loadFeed()
    }

    override func layoutContent(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        super.layoutContent(layout, transition: transition)
        stackView.frame = contentFrame(for: layout).insetBy(dx: 16, dy: 16)
    }

    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        view.addSubview(stackView)

        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
    }

    private func bindPresentationData() {
        session.shared.presentationData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.view.backgroundColor = data.theme.backgroundColor
                self?.label.textColor = data.theme.primaryTextColor
                (self?.navigationBarView as? CustomNavigationBar)?.setTitle(data.strings.homeTitle)
            })
            .disposed(by: disposeBag)
    }

    private func loadFeed() {
        session.api.fetchFeed()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.render(items)
            })
            .disposed(by: disposeBag)
    }

    private func render(_ items: [String]) {
        stackView.arrangedSubviews.dropFirst().forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for item in items {
            let itemLabel = UILabel()
            itemLabel.text = item
            itemLabel.numberOfLines = 0
            itemLabel.font = .preferredFont(forTextStyle: .body)
            stackView.addArrangedSubview(itemLabel)
        }
    }
}
