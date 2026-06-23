import UIKit

final class SettingsCollectionCell: SinkDownCollectionViewCell {
    static let reuseIdentifier = "SettingsCollectionCell"

    static var layoutHeight: NSCollectionLayoutDimension {
        .estimated(64)
    }

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: SettingsItem, position: SectionCellPosition) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        iconImageView.image = UIImage(systemName: item.systemImageName)
        applySectionCorners(position: position)
    }

    private func applySectionCorners(position: SectionCellPosition) {
        if position.appliesCornerRadius {
            contentView.layer.cornerRadius = SectionCellPosition.sectionCornerRadius
            contentView.layer.maskedCorners = position.maskedCorners
        } else {
            contentView.layer.cornerRadius = 0
            contentView.layer.maskedCorners = []
        }
        contentView.clipsToBounds = true
    }

    private func setupViews() {
        contentView.backgroundColor = UIColor.tertiarySystemFill

        contentView.addSubview(iconImageView)
        contentView.addSubview(textStackView)
        contentView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),

            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func prepareForRevealAnimation() {
        layoutIfNeeded()
        let width = contentView.bounds.width
        contentView.alpha = 0
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: -width / 2, y: 0)
        transform = transform.scaledBy(x: 0.0001, y: 1)
        contentView.transform = transform
    }

    func performRevealAnimation(delay: TimeInterval) {
        UIView.animate(
            withDuration: 0.45,
            delay: delay,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.3,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.contentView.alpha = 1
                self.contentView.transform = .identity
            }
        )
    }

    func showFullyVisible() {
        contentView.layer.removeAllAnimations()
        contentView.alpha = 1
        contentView.transform = .identity
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        applySectionCorners(position: .middle)
        showFullyVisible()
    }
}
