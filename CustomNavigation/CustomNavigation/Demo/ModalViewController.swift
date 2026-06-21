import UIKit

final class ModalViewController: BaseViewController {

    enum DemoMode {
        case fullscreen
        case floatingSheet
        case stackedCard
    }

    private let mode: DemoMode

    init(mode: DemoMode = .fullscreen) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    /// Giữ tương thích call site cũ.
    init(isSheetPresentation: Bool) {
        self.mode = isSheetPresentation ? .floatingSheet : .fullscreen
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNavigationBar(
            owner: self,
            title: "Xác nhận",
            type: .backButton,
            isPush: false,
            hasBackground: true
        )
        pinNavigationBarToTop()

        let label = UILabel()
        label.text = descriptionText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: LayoutHelper.navigationContentTopPadding(for: self) + 40
            ),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private var descriptionText: String {
        switch mode {
        case .fullscreen:
            return "Fullscreen modal.\nNhấn X để dismiss."
        case .floatingSheet:
            return "Floating sheet (.medium → near-full).\nChỉ dim nền, màn dưới giữ nguyên.\nNhấn X để dismiss."
        case .stackedCard:
            return "Stacked card (.large only).\nMàn dưới scale & lùi xuống phía sau.\nNhấn X để dismiss."
        }
    }
}

extension ModalViewController: NavigationBarDelegate {
    func navigationBar(_ bar: CustomNavigationBar, leftAction sender: Any) {
        dismiss(animated: true)
    }
}
