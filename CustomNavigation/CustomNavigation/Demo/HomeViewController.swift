import UIKit

final class HomeViewController: BaseViewController {

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNavigationBar(
            owner: self,
            title: "Trang chủ",
            type: .standard,
            titleStyle: .largeLeading,
            isPush: true,
            hasBackground: true
        )
        customNavigationBar?.listRightButtons = [
            UIImage(systemName: "bell") as Any
        ]
        pinNavigationBarToTop()

        setupContent()
    }

    private func setupContent() {
        view.addSubview(contentStack)

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Demo custom navigation bar theo pattern hybrid UIKit."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel

        let pushButton = makeButton(title: "Push màn chi tiết", color: .systemBlue)
        pushButton.addTarget(self, action: #selector(openDetail), for: .touchUpInside)

        let modalButton = makeButton(title: "Present floating sheet", color: .systemOrange)
        modalButton.addTarget(self, action: #selector(openModalSheet), for: .touchUpInside)

        let modalStackedButton = makeButton(title: "Present stacked card", color: .systemTeal)
        modalStackedButton.addTarget(self, action: #selector(openModalStacked), for: .touchUpInside)

        let modalFullScreenButton = makeButton(title: "Present fullscreen modal", color: .systemIndigo)
        modalFullScreenButton.addTarget(self, action: #selector(openModalFullScreen), for: .touchUpInside)

        let searchButton = makeButton(title: "Push màn tìm kiếm", color: .systemGreen)
        searchButton.addTarget(self, action: #selector(openSearch), for: .touchUpInside)

        contentStack.addArrangedSubview(descriptionLabel)
        contentStack.addArrangedSubview(pushButton)
        contentStack.addArrangedSubview(modalButton)
        contentStack.addArrangedSubview(modalStackedButton)
        contentStack.addArrangedSubview(modalFullScreenButton)
        contentStack.addArrangedSubview(searchButton)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: LayoutHelper.navigationContentTopPadding(for: self, titleStyle: .largeLeading) + 24
            ),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func makeButton(title: String, color: UIColor) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = color
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        let button = UIButton(configuration: config)
        return button
    }

    @objc private func openDetail() {
        navigationController?.pushViewController(DetailViewController(), animated: true)
    }

    @objc private func openModalSheet() {
        presentSheet(ModalViewController(mode: .floatingSheet))
    }

    @objc private func openModalStacked() {
        presentStacked(ModalViewController(mode: .stackedCard))
    }

    @objc private func openModalFullScreen() {
        presentFullScreen(ModalViewController(mode: .fullscreen))
    }

    @objc private func openSearch() {
        navigationController?.pushViewController(SearchViewController(), animated: true)
    }
}

extension HomeViewController: NavigationBarDelegate {
    func navigationBar(_ bar: CustomNavigationBar, firstRightAction sender: Any) {
        let alert = UIAlertController(title: "Thông báo", message: "Nút chuông được nhấn", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
