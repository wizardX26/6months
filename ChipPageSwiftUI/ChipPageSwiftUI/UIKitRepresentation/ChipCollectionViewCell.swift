import UIKit

final class ChipCollectionViewCell: UICollectionViewCell {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textStack = UIStackView()
    private let contentStack = UIStackView()
    private var accessibilityText = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.image = nil
        iconView.isHidden = true
        titleLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel.isHidden = true
        accessibilityText = ""
        isAccessibilityElement = true
        accessibilityLabel = nil
        accessibilityValue = nil
        accessibilityTraits = [.button]
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateAppearance()
    }

    func configure(with item: ChipCollectionItem, isSelected: Bool) {
        titleLabel.text = item.title

        if let subtitle = item.subtitle, !subtitle.isEmpty {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
            accessibilityText = "\(item.title), \(subtitle)"
        } else {
            subtitleLabel.text = nil
            subtitleLabel.isHidden = true
            accessibilityText = item.title
        }

        if let systemImageName = item.systemImageName {
            iconView.image = UIImage(systemName: systemImageName)
            iconView.isHidden = false
        } else {
            iconView.image = nil
            iconView.isHidden = true
        }

        self.isSelected = isSelected
        updateAppearance()
    }

    private func configureHierarchy() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .subheadline),
            scale: .medium
        )

        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 1
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        subtitleLabel.font = .preferredFont(forTextStyle: .caption2)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.numberOfLines = 1
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 1
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 7
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(textStack)

        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }

    private func configureStyle() {
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 1
        contentView.clipsToBounds = true
        isAccessibilityElement = true
        updateAppearance()
    }

    private func updateAppearance() {
        let selectedBackground = tintColor ?? .systemBlue
        let normalBackground = UIColor.secondarySystemGroupedBackground
        let highlightedBackground = normalBackground.withAlphaComponent(0.75)

        if isSelected {
            contentView.backgroundColor = selectedBackground
            contentView.layer.borderColor = selectedBackground.cgColor
            titleLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
            iconView.tintColor = .white
        } else {
            contentView.backgroundColor = isHighlighted ? highlightedBackground : normalBackground
            contentView.layer.borderColor = UIColor.separator.cgColor
            titleLabel.textColor = .label
            subtitleLabel.textColor = .secondaryLabel
            iconView.tintColor = .secondaryLabel
        }

        contentView.transform = isHighlighted
            ? CGAffineTransform(scaleX: 0.98, y: 0.98)
            : .identity

        accessibilityLabel = accessibilityText
        accessibilityValue = isSelected ? "Selected" : nil

        var traits: UIAccessibilityTraits = [.button]
        if isSelected {
            traits.insert(.selected)
        }
        accessibilityTraits = traits
    }
}
