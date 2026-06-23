import UIKit

open class PushDownCollectionViewCell: UICollectionViewCell {
    public let scale: CGFloat = 0.95

    public var viewToPushDown: UIView {
        return self
    }

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.viewToPushDown.transform = self.isHighlighted ?
                CGAffineTransform(scaleX: self.scale, y: self.scale) : .identity
            }
        }
    }
}

open class PushDownAnimationButton: UIButton {
    public let scale: CGFloat = 0.95

    public weak var viewToPushDown: UIView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        setTitle("", for: .normal)
        adjustsImageWhenHighlighted = false
    }

    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.viewToPushDown?.transform = self.isHighlighted ?
                CGAffineTransform(scaleX: self.scale, y: self.scale) : .identity
            }
        }
    }
}
