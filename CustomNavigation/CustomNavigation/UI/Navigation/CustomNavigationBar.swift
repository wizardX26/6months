import UIKit

final class CustomNavigationBar: UIView {

    weak var delegate: NavigationBarDelegate?

    var type: NavigationType = .backButton {
        didSet { updateAppearance() }
    }

    var titleStyle: TitleStyle = .inline {
        didSet {
            guard titleStyle != oldValue else { return }
            updateAppearance()
            updateLayoutForTitleStyle()
        }
    }

    var title: String = "" {
        didSet { applyTitleText() }
    }

    var isPush: Bool = true {
        didSet { updateBackButtonIcon() }
    }

    var hasBackground: Bool = true {
        didSet { updateBackgroundAppearance() }
    }

    var listRightButtons: [Any] = [] {
        didSet { updateRightButtons() }
    }

    var singleButtonComponents: (String?, UIImage?) = (nil, nil) {
        didSet { updateRightButtons() }
    }

    var noBackgroundTintColor: UIColor = .label {
        didSet { updateBackgroundAppearance() }
    }

    var layoutContext: NavigationBarLayoutContext = .standard {
        didSet {
            guard layoutContext != oldValue else { return }
            updateLayoutForTitleStyle()
        }
    }

    private let brandColor = NavigationTheme.brandColor
    private let largeTitleLabel = UILabel()
    private var backButtonCenterYConstraint: NSLayoutConstraint?
    private var largeTitleBottomConstraint: NSLayoutConstraint?
    private var largeTitleCenterYConstraint: NSLayoutConstraint?
    private var didInstallLayoutConstraints = false
    private var layoutCache = NavigationLayoutCache()

    private struct NavigationLayoutCache: Equatable {
        var titleStyle: TitleStyle = .inline
        var layoutContext: NavigationBarLayoutContext = .standard
        var toolbarCenterOffset: CGFloat = 0
        var isLargeTitleBottomActive = false
        var isLargeTitleCenterActive = false
    }

    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var rightButtonsContainer: UIStackView!
    @IBOutlet private weak var rightButton1: UIButton!
    @IBOutlet private weak var rightButton2: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var iconRightButton: UIButton!

    var statusBarStyle: UIStatusBarStyle {
        guard hasBackground else {
            return noBackgroundTintColor.isDark ? .default : .lightContent
        }
        return .lightContent
    }

    var currentContentHeight: CGFloat {
        NavigationBarMetrics.contentHeight(titleStyle: titleStyle, context: layoutContext)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
        installLayoutConstraintsIfNeeded()
        updateAppearance()
        updateLayoutForTitleStyle()
    }

    private func configureViews() {
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        largeTitleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        largeTitleLabel.textAlignment = .left
        largeTitleLabel.numberOfLines = 2
        largeTitleLabel.lineBreakMode = .byTruncatingTail
        largeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(largeTitleLabel)

        backButton.addTarget(self, action: #selector(backTapped(_:)), for: .touchUpInside)
        rightButton1.addTarget(self, action: #selector(firstRightTapped(_:)), for: .touchUpInside)
        rightButton2.addTarget(self, action: #selector(secondRightTapped(_:)), for: .touchUpInside)
        iconRightButton.addTarget(self, action: #selector(firstRightTapped(_:)), for: .touchUpInside)

        searchTextField.borderStyle = .roundedRect
        searchTextField.placeholder = "Tìm kiếm..."
        searchTextField.font = .systemFont(ofSize: 15)
        searchTextField.addTarget(self, action: #selector(searchChanged(_:)), for: .editingChanged)
        searchTextField.addTarget(self, action: #selector(searchDidEnd(_:)), for: .editingDidEnd)

        bottomSeparator.backgroundColor = UIColor.separator.withAlphaComponent(0.3)
    }

    private func installLayoutConstraintsIfNeeded() {
        guard !didInstallLayoutConstraints else { return }
        didInstallLayoutConstraints = true

        let subviews: [UIView?] = [
            backgroundImageView, backButton, titleLabel, searchTextField,
            rightButtonsContainer, iconRightButton, bottomSeparator, largeTitleLabel
        ]
        subviews.compactMap { $0 }.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.deactivate(constraints)

        let toolbarCenterY = backButton.centerYAnchor.constraint(equalTo: bottomAnchor)
        backButtonCenterYConstraint = toolbarCenterY

        let largeTitleBottom = largeTitleLabel.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -NavigationBarMetrics.LargeTitle.bottomInset
        )
        let largeTitleCenterY = largeTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        largeTitleBottomConstraint = largeTitleBottom
        largeTitleCenterYConstraint = largeTitleCenterY

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),

            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: NavigationBarMetrics.ContentSpacing.horizontal),
            toolbarCenterY,
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: NavigationBarMetrics.ContentSpacing.horizontal),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -NavigationBarMetrics.ContentSpacing.horizontal),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            searchTextField.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: NavigationBarMetrics.ContentSpacing.horizontal),
            searchTextField.trailingAnchor.constraint(lessThanOrEqualTo: rightButtonsContainer.leadingAnchor, constant: -8),

            rightButtonsContainer.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            rightButtonsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -NavigationBarMetrics.ContentSpacing.horizontal),
            rightButtonsContainer.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: NavigationBarMetrics.ContentSpacing.horizontal),

            iconRightButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            iconRightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -NavigationBarMetrics.ContentSpacing.horizontal),
            iconRightButton.widthAnchor.constraint(equalToConstant: 44),
            iconRightButton.heightAnchor.constraint(equalToConstant: 44),

            largeTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: NavigationBarMetrics.ContentSpacing.titleLeading),
            largeTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -NavigationBarMetrics.ContentSpacing.titleLeading)
        ])
    }

    private func updateLayoutForTitleStyle() {
        let offset = NavigationBarMetrics.toolbarCenterOffsetFromBottom(
            titleStyle: titleStyle,
            context: layoutContext
        )
        let isLargeTitleBottomActive = titleStyle == .large
        let isLargeTitleCenterActive = titleStyle == .largeLeading

        let newCache = NavigationLayoutCache(
            titleStyle: titleStyle,
            layoutContext: layoutContext,
            toolbarCenterOffset: offset,
            isLargeTitleBottomActive: isLargeTitleBottomActive,
            isLargeTitleCenterActive: isLargeTitleCenterActive
        )
        guard newCache != layoutCache else { return }
        layoutCache = newCache

        if backButtonCenterYConstraint?.constant != -offset {
            backButtonCenterYConstraint?.constant = -offset
        }
        if largeTitleBottomConstraint?.isActive != isLargeTitleBottomActive {
            largeTitleBottomConstraint?.isActive = isLargeTitleBottomActive
        }
        if largeTitleCenterYConstraint?.isActive != isLargeTitleCenterActive {
            largeTitleCenterYConstraint?.isActive = isLargeTitleCenterActive
        }
    }

    private func applyTitleText() {
        let maxLength = 50
        let displayTitle = title.count > maxLength ? String(title.prefix(maxLength)) + "…" : title
        titleLabel.text = displayTitle
        largeTitleLabel.text = displayTitle
    }

    private var showsLargeTitle: Bool {
        (titleStyle == .large || titleStyle == .largeLeading) && type != .searchBackButton
    }

    private var shouldHideBackButton: Bool {
        if titleStyle == .largeLeading { return true }
        switch type {
        case .standard, .onlyRightButton:
            return true
        case .backButton, .backButtonIcon, .searchBackButton:
            return false
        }
    }

    private func updateAppearance() {
        let showsInlineTitle = titleStyle == .inline && type != .searchBackButton
        backButton.isHidden = shouldHideBackButton
        largeTitleLabel.isHidden = !showsLargeTitle

        switch type {
        case .standard:
            searchTextField.isHidden = true
            titleLabel.isHidden = !showsInlineTitle
            rightButtonsContainer.isHidden = listRightButtons.isEmpty
            iconRightButton.isHidden = true
        case .backButton:
            searchTextField.isHidden = true
            titleLabel.isHidden = !showsInlineTitle
            rightButtonsContainer.isHidden = listRightButtons.isEmpty
            iconRightButton.isHidden = true
        case .backButtonIcon:
            searchTextField.isHidden = true
            titleLabel.isHidden = !showsInlineTitle
            rightButtonsContainer.isHidden = true
            iconRightButton.isHidden = false
            updateIconRightButton()
        case .searchBackButton:
            searchTextField.isHidden = false
            titleLabel.isHidden = true
            largeTitleLabel.isHidden = true
            rightButtonsContainer.isHidden = listRightButtons.isEmpty
            iconRightButton.isHidden = true
        case .onlyRightButton:
            searchTextField.isHidden = true
            titleLabel.isHidden = !showsInlineTitle
            rightButtonsContainer.isHidden = listRightButtons.isEmpty
            iconRightButton.isHidden = true
        }

        updateBackButtonIcon()
        updateBackgroundAppearance()
        updateRightButtons()
        applyTitleText()
    }

    private func updateBackButtonIcon() {
        let imageName = isPush ? "chevron.left" : "xmark"
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        backButton.setImage(image, for: .normal)
        backButton.setTitle(nil, for: .normal)
    }

    private func updateBackgroundAppearance() {
        let primaryColor: UIColor = hasBackground ? .white : noBackgroundTintColor

        if hasBackground {
            backgroundImageView.backgroundColor = brandColor
            backgroundImageView.image = nil
            bottomSeparator.isHidden = true
        } else {
            backgroundImageView.backgroundColor = .clear
            backgroundImageView.image = nil
            bottomSeparator.isHidden = false
        }

        titleLabel.textColor = primaryColor
        largeTitleLabel.textColor = primaryColor
        backButton.tintColor = primaryColor
        rightButton1.tintColor = primaryColor
        rightButton2.tintColor = primaryColor
        iconRightButton.tintColor = primaryColor
    }

    private func updateRightButtons() {
        if type == .backButtonIcon {
            updateIconRightButton()
            return
        }

        let buttons = [rightButton1, rightButton2]
        for (index, button) in buttons.enumerated() {
            guard let button else { continue }
            if index < listRightButtons.count {
                button.isHidden = false
                configure(button: button, with: listRightButtons[index])
            } else {
                button.isHidden = true
            }
        }
        rightButtonsContainer.isHidden = listRightButtons.isEmpty && type != .searchBackButton
    }

    private func updateIconRightButton() {
        let (text, image) = singleButtonComponents
        if let image {
            iconRightButton.setImage(image, for: .normal)
            iconRightButton.setTitle(nil, for: .normal)
        } else if let text {
            iconRightButton.setImage(nil, for: .normal)
            iconRightButton.setTitle(text, for: .normal)
            iconRightButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        }
    }

    private func configure(button: UIButton, with item: Any) {
        if let title = item as? String {
            button.setTitle(title, for: .normal)
            button.setImage(nil, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        } else if let image = item as? UIImage {
            button.setImage(image, for: .normal)
            button.setTitle(nil, for: .normal)
        }
    }

    @objc private func backTapped(_ sender: Any) {
        delegate?.navigationBar?(self, leftAction: sender)
    }

    @objc private func firstRightTapped(_ sender: Any) {
        delegate?.navigationBar?(self, firstRightAction: sender)
    }

    @objc private func secondRightTapped(_ sender: Any) {
        delegate?.navigationBar?(self, secondRightAction: sender)
    }

    @objc private func searchChanged(_ sender: UITextField) {
        delegate?.navigationBar?(self, searchEditingChanged: sender.text ?? "")
    }

    @objc private func searchDidEnd(_ sender: UITextField) {
        delegate?.navigationBar?(self, searchEditingDidEnd: sender.text ?? "")
    }
}

extension CustomNavigationBar {
    static func loadFromNib(width: CGFloat, height: CGFloat) -> CustomNavigationBar {
        let nib = UINib(nibName: "CustomNavigationBar", bundle: nil)
        guard let bar = nib.instantiate(withOwner: nil, options: nil).first as? CustomNavigationBar else {
            fatalError("CustomNavigationBar.xib not found or invalid")
        }
        bar.frame = CGRect(x: 0, y: 0, width: width, height: height)
        return bar
    }
}
