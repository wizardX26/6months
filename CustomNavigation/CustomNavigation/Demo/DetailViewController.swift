import UIKit

final class DetailViewController: BaseViewController {

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let shareImage = UIImage(systemName: "square.and.arrow.up")
        setupNavigationBar(
            owner: self,
            title: "Chi tiết",
            type: .backButton,
            titleStyle: .large,
            isPush: true,
            hasBackground: true
        )
        customNavigationBar?.listRightButtons = ["Sửa", shareImage as Any]
        pinNavigationBarToTop()

        infoLabel.text = "Vuốt từ cạnh trái để quay lại.\nNút phải: Sửa / Chia sẻ."
        view.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: LayoutHelper.navigationContentTopPadding(for: self, titleStyle: .large) + 40
            ),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}

extension DetailViewController: NavigationBarDelegate {
    func navigationBar(_ bar: CustomNavigationBar, leftAction sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func navigationBar(_ bar: CustomNavigationBar, firstRightAction sender: Any) {
        showAlert(title: "Sửa", message: "Nút Sửa được nhấn")
    }

    func navigationBar(_ bar: CustomNavigationBar, secondRightAction sender: Any) {
        showAlert(title: "Chia sẻ", message: "Nút Chia sẻ được nhấn")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
