import UIKit

protocol NavigationBarProtocol: UIView {
    func updatePresentationData(_ data: NavigationBarPresentationData)
    func layoutNavigationBar(width: CGFloat, insets: UIEdgeInsets, transition: LayoutTransition)
}

final class CustomNavigationBar: UIView, NavigationBarProtocol {
    private let titleLabel = UILabel()
    private var presentationData: NavigationBarPresentationData

    init(presentationData: NavigationBarPresentationData) {
        self.presentationData = presentationData
        super.init(frame: .zero)
        setup()
        applyTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updatePresentationData(_ data: NavigationBarPresentationData) {
        presentationData = data
        applyTheme()
    }

    func layoutNavigationBar(width: CGFloat, insets: UIEdgeInsets, transition: LayoutTransition) {
        let height: CGFloat = 44 + insets.top
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        titleLabel.frame = CGRect(x: 16, y: insets.top, width: width - 32, height: 44)
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    private func setup() {
        addSubview(titleLabel)
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .left
    }

    private func applyTheme() {
        backgroundColor = presentationData.theme.backgroundColor
        titleLabel.textColor = presentationData.theme.titleColor
    }
}

extension CustomNavigationBar {
    static func preferredHeight(topInset: CGFloat) -> CGFloat {
        44 + topInset
    }
}
