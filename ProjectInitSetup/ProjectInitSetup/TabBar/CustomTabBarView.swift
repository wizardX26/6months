import UIKit

enum TabBarContextAction: String {
    case pin = "Pin Tab"
    case markRead = "Mark as Read"
    case hide = "Hide Tab"
}

protocol CustomTabBarViewDelegate: AnyObject {
    func tabBarView(_ tabBar: CustomTabBarView, didSelect index: Int)
    func tabBarView(_ tabBar: CustomTabBarView, didUpdateDragProgress progress: CGFloat, from: Int, to: Int)
    func tabBarView(_ tabBar: CustomTabBarView, didCommitDragTo index: Int)
    func tabBarView(_ tabBar: CustomTabBarView, didPerformContextAction action: TabBarContextAction, forTabAt index: Int)
}

final class CustomTabBarView: UIView {
    weak var delegate: CustomTabBarViewDelegate?

    private var theme: TabBarTheme
    private var items: [String] = []
    private var buttons: [UIButton] = []
    private var selectedIndex: Int = 0
    private var previewFractionalIndex: CGFloat?
    private let stackView = UIStackView()
    private let separator = UIView()
    private let indicatorView = UIView()
    private var panRecognizer: UIPanGestureRecognizer!
    private var dragStartIndex: Int = 0

    private let indicatorHeight: CGFloat = 3

    init(theme: TabBarTheme) {
        self.theme = theme
        super.init(frame: .zero)
        setup()
        applyTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(items: [String], selectedIndex: Int) {
        self.items = items
        self.selectedIndex = selectedIndex
        previewFractionalIndex = nil
        rebuildButtons()
        setNeedsLayout()
    }

    func updateTheme(_ theme: TabBarTheme) {
        self.theme = theme
        applyTheme()
        updateButtonStyles()
    }

    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard index >= 0, index < buttons.count else { return }
        selectedIndex = index
        previewFractionalIndex = nil
        updateButtonStyles()
        updateIndicatorPosition(animated: animated)
    }

    func setDragPreview(fractionalIndex: CGFloat) {
        previewFractionalIndex = fractionalIndex
        updateButtonStylesForPreview(fractionalIndex: fractionalIndex)
        layoutIndicator(forFractionalIndex: fractionalIndex, animated: false)
    }

    func endDragPreview() {
        previewFractionalIndex = nil
    }

    func preferredHeight(bottomInset: CGFloat) -> CGFloat {
        49 + bottomInset
    }

    func layoutTabBar(width: CGFloat, bottomInset: CGFloat, transition: LayoutTransition) {
        let height = preferredHeight(bottomInset: bottomInset)
        frame = CGRect(x: 0, y: superview.map { $0.bounds.height - height } ?? 0, width: width, height: height)
        separator.frame = CGRect(x: 0, y: 0, width: width, height: 0.5)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 49)
        updateIndicatorPosition(animated: transition.isAnimated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if previewFractionalIndex == nil {
            updateIndicatorPosition(animated: false)
        } else if let preview = previewFractionalIndex {
            layoutIndicator(forFractionalIndex: preview, animated: false)
        }
    }

    private func setup() {
        addSubview(separator)
        addSubview(stackView)
        addSubview(indicatorView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panRecognizer)
    }

    private func applyTheme() {
        backgroundColor = theme.backgroundColor
        separator.backgroundColor = theme.separatorColor
        indicatorView.backgroundColor = theme.selectedColor
        indicatorView.layer.cornerRadius = indicatorHeight / 2
    }

    private func rebuildButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0); $0.removeFromSuperview() }

        for (index, title) in items.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            button.showsMenuAsPrimaryAction = false
            button.menu = makeContextMenu(for: index)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        updateButtonStyles()
    }

    private func makeContextMenu(for index: Int) -> UIMenu {
        let title = items.indices.contains(index) ? items[index] : "Tab"
        return UIMenu(title: title, children: [
            UIAction(title: TabBarContextAction.pin.rawValue, image: UIImage(systemName: "pin")) { [weak self] _ in
                guard let self else { return }
                self.delegate?.tabBarView(self, didPerformContextAction: .pin, forTabAt: index)
            },
            UIAction(title: TabBarContextAction.markRead.rawValue, image: UIImage(systemName: "envelope.open")) { [weak self] _ in
                guard let self else { return }
                self.delegate?.tabBarView(self, didPerformContextAction: .markRead, forTabAt: index)
            },
            UIAction(title: TabBarContextAction.hide.rawValue, image: UIImage(systemName: "eye.slash"), attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                self.delegate?.tabBarView(self, didPerformContextAction: .hide, forTabAt: index)
            }
        ])
    }

    private func updateButtonStyles() {
        for (index, button) in buttons.enumerated() {
            let color = index == selectedIndex ? theme.selectedColor : theme.unselectedColor
            button.setTitleColor(color, for: .normal)
            button.titleLabel?.font = index == selectedIndex ? .boldSystemFont(ofSize: 11) : .systemFont(ofSize: 11)
        }
    }

    private func updateButtonStylesForPreview(fractionalIndex: CGFloat) {
        let nearest = Int(round(fractionalIndex))
        for (index, button) in buttons.enumerated() {
            let distance = abs(CGFloat(index) - fractionalIndex)
            let emphasis = max(0, 1 - distance)
            let baseColor = index == nearest ? theme.selectedColor : theme.unselectedColor
            button.setTitleColor(baseColor.withAlphaComponent(0.55 + 0.45 * emphasis), for: .normal)
            button.titleLabel?.font = emphasis > 0.5 ? .boldSystemFont(ofSize: 11) : .systemFont(ofSize: 11)
        }
    }

    private func tabWidth() -> CGFloat {
        guard !buttons.isEmpty else { return bounds.width }
        return bounds.width / CGFloat(buttons.count)
    }

    private func tabCenterX(for index: Int) -> CGFloat {
        let width = tabWidth()
        return width * (CGFloat(index) + 0.5)
    }

    private func layoutIndicator(forFractionalIndex fractionalIndex: CGFloat, animated: Bool) {
        guard !buttons.isEmpty else { return }
        let clamped = min(max(fractionalIndex, 0), CGFloat(buttons.count - 1))
        let lower = Int(floor(clamped))
        let upper = min(lower + 1, buttons.count - 1)
        let t = clamped - CGFloat(lower)
        let centerX = tabCenterX(for: lower) + (tabCenterX(for: upper) - tabCenterX(for: lower)) * t
        let indicatorWidth = max(28, tabWidth() * 0.55)
        let frame = CGRect(
            x: centerX - indicatorWidth / 2,
            y: 49 - indicatorHeight - 4,
            width: indicatorWidth,
            height: indicatorHeight
        )
        if animated {
            UIView.animate(withDuration: 0.2) { self.indicatorView.frame = frame }
        } else {
            indicatorView.frame = frame
        }
    }

    private func updateIndicatorPosition(animated: Bool) {
        layoutIndicator(forFractionalIndex: CGFloat(selectedIndex), animated: animated)
    }

    /// Drag right → next tab; drag left → previous tab (natural scroll direction).
    private func dragDirection(forTranslationX translationX: CGFloat) -> Int {
        if translationX > 0 { return 1 }
        if translationX < 0 { return -1 }
        return 0
    }

    private func adjacentTab(from index: Int, direction: Int) -> Int {
        if direction > 0 { return min(index + 1, buttons.count - 1) }
        if direction < 0 { return max(index - 1, 0) }
        return index
    }

    @objc private func tabTapped(_ sender: UIButton) {
        delegate?.tabBarView(self, didSelect: sender.tag)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard buttons.count > 1 else { return }

        let itemWidth = tabWidth()

        switch gesture.state {
        case .began:
            dragStartIndex = selectedIndex
        case .changed:
            let translation = gesture.translation(in: self)
            let direction = dragDirection(forTranslationX: translation.x)
            let from = dragStartIndex
            let to = adjacentTab(from: from, direction: direction)
            let progress = min(max(abs(translation.x) / itemWidth, 0), 1)
            let previewIndex = CGFloat(from) + CGFloat(to - from) * progress
            setDragPreview(fractionalIndex: previewIndex)
            if from != to {
                delegate?.tabBarView(self, didUpdateDragProgress: progress, from: from, to: to)
            }
        case .ended, .cancelled:
            let translation = gesture.translation(in: self)
            let velocity = gesture.velocity(in: self)
            let direction = dragDirection(forTranslationX: translation.x)
            let progress = min(max(abs(translation.x) / itemWidth, 0), 1)
            let target = TabSwitchPolicy.resolveTargetIndex(
                currentIndex: dragStartIndex,
                pageCount: buttons.count,
                progress: progress,
                velocity: velocity,
                direction: direction
            )
            endDragPreview()
            delegate?.tabBarView(self, didCommitDragTo: target)
        default:
            break
        }
    }
}
