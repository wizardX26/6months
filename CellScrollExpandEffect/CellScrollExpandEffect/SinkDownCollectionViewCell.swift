import UIKit

/// Base cell cho hiệu ứng nhấn kiểu card chìm nhẹ: scale + translate + giảm shadow.
/// Animation chạy trên `pressAnimatedView` (mặc định là cell) để không đụng reveal trên `contentView`.
open class SinkDownCollectionViewCell: UICollectionViewCell {

    // MARK: - Press tuning

    open var pressScale: CGFloat = 0.96
    open var pressTranslationY: CGFloat = 2
    open var pressDownDuration: TimeInterval = 0.15
    open var releaseDuration: TimeInterval = 0.2

    // MARK: - Shadow (tắt mặc định — row trong section card trắng không cần shadow riêng)

    open var appliesPressShadow: Bool = false {
        didSet { refreshShadowConfiguration() }
    }

    open var restingShadowOpacity: Float = 1
    open var pressedShadowOpacity: Float = 0.5
    open var shadowRadius: CGFloat = 8
    open var shadowOffset: CGSize = CGSize(width: 0, height: 2)
    open var shadowColor: UIColor = UIColor.black.withAlphaComponent(0.08) {
        didSet { refreshShadowConfiguration() }
    }

    /// View nhận transform khi highlight. Subclass có thể trỏ sang container riêng.
    open var pressAnimatedView: UIView {
        return self
    }

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureForPressEffect()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureForPressEffect()
    }

    private func configureForPressEffect() {
        backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
        refreshShadowConfiguration()
    }

    // MARK: - Highlight

    public override var isHighlighted: Bool {
        didSet {
            guard isHighlighted != oldValue else { return }
            if isHighlighted {
                animatePressDown()
            } else {
                animateRelease()
            }
        }
    }

    open func animatePressDown() {
        let view = pressAnimatedView
        UIView.animate(
            withDuration: pressDownDuration,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: { [self] in
                let scale = CGAffineTransform(scaleX: pressScale, y: pressScale)
                let translate = CGAffineTransform(translationX: 0, y: pressTranslationY)
                view.transform = scale.concatenating(translate)
                if appliesPressShadow {
                    view.layer.shadowOpacity = pressedShadowOpacity
                }
            }
        )
    }

    open func animateRelease() {
        let view = pressAnimatedView
        UIView.animate(
            withDuration: releaseDuration,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: { [self] in
                view.transform = .identity
                if appliesPressShadow {
                    view.layer.shadowOpacity = restingShadowOpacity
                }
            }
        )
    }

    open func resetPressEffect() {
        let view = pressAnimatedView
        view.layer.removeAllAnimations()
        view.transform = .identity
        if appliesPressShadow {
            view.layer.shadowOpacity = restingShadowOpacity
        }
    }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPathIfNeeded()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard appliesPressShadow,
              traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        pressAnimatedView.layer.shadowColor = shadowColor
            .resolvedColor(with: traitCollection)
            .cgColor
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        resetPressEffect()
    }

    // MARK: - Shadow helpers

    private func refreshShadowConfiguration() {
        let view = pressAnimatedView
        guard appliesPressShadow else {
            view.layer.shadowOpacity = 0
            return
        }
        view.layer.shadowColor = shadowColor
            .resolvedColor(with: traitCollection)
            .cgColor
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowOpacity = restingShadowOpacity
        updateShadowPathIfNeeded()
    }

    private func updateShadowPathIfNeeded() {
        guard appliesPressShadow else { return }
        let view = pressAnimatedView
        view.layer.shadowPath = UIBezierPath(
            roundedRect: view.bounds,
            cornerRadius: view.layer.cornerRadius
        ).cgPath
    }
}
