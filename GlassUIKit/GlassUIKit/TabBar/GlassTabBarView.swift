//
//  GlassTabBarView.swift
//  GlassUIKit
//
//  Copyright (C) 2026 wizardOs contributors
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

/// Custom glass tab bar: 3 items + trailing search, drag pill, scroll collapse (glass tab bar reference layout).
final class GlassTabBarView: UIView {
    static let barHeight: CGFloat = 48
    static let searchTrailingSpacing: CGFloat = 8
    static let outerCornerRadius: CGFloat = 28
    static let scrollCollapseDistance: CGFloat = 80

    weak var delegate: GlassTabBarDelegate?

    private(set) var items: [GlassTabBarItem] = []
    private(set) var selectedIndex: Int = 0
    private(set) var searchState: GlassTabBarSearchState = .inactive
    private(set) var keyboardHeight: CGFloat = 0
    private(set) var scrollCollapseProgress: CGFloat = 0

    private var selectionGestureState: (startX: CGFloat, currentX: CGFloat, itemWidth: CGFloat, itemId: String)?

    private let glassContainer: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        view.layer.cornerRadius = GlassTabBarView.outerCornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let tabsContainer = UIView()
    private let lensView = GlassSelectionLensView()
    private let searchBarView = TabSearchBarView()
    private var itemViews: [TabItemView] = []
    private var selectionPanRecognizer: UIPanGestureRecognizer?

    private var tabsClusterLeadingOffset: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(glassContainer)
        glassContainer.contentView.addSubview(tabsContainer)
        tabsContainer.addSubview(lensView)
        addSubview(searchBarView)

        searchBarView.delegate = self

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSelectionPan(_:)))
        pan.delegate = self
        tabsContainer.addGestureRecognizer(pan)
        selectionPanRecognizer = pan
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(items: [GlassTabBarItem], selectedIndex: Int) {
        self.items = items
        self.selectedIndex = min(max(0, selectedIndex), max(0, items.count - 1))

        itemViews.forEach { $0.removeFromSuperview() }
        itemViews = items.map { item in
            let view = TabItemView(item: item)
            view.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            tabsContainer.addSubview(view)
            return view
        }
        tabsContainer.bringSubviewToFront(lensView)

        setNeedsLayout()
        layoutIfNeeded()
    }

    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard index >= 0, index < items.count else { return }
        selectedIndex = index
        layoutTabs(animated: animated)
    }

    func setSearchState(_ state: GlassTabBarSearchState, animated: Bool) {
        searchState = state
        let active = state == .active
        searchBarView.setActive(active, animated: animated)
        lensView.setCollapsed(active, animated: animated)
        setNeedsLayout()
        layoutIfNeeded()
    }

    func setKeyboardHeight(_ height: CGFloat) {
        keyboardHeight = height
        setNeedsLayout()
        layoutIfNeeded()
    }

    func reportScrollOffset(_ offset: CGFloat) {
        let progress = min(1, max(0, offset / Self.scrollCollapseDistance))
        guard abs(progress - scrollCollapseProgress) > 0.001 else { return }
        scrollCollapseProgress = progress
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutAll(animated: false)
    }

    private func layoutAll(animated: Bool) {
        let safeBottom = safeAreaInsets.bottom
        let bottomY = bounds.height - safeBottom - Self.barHeight - 8

        if searchState == .active {
            layoutSearchActive(bottomY: bottomY, animated: animated)
        } else {
            layoutNormal(bottomY: bottomY, animated: animated)
        }
    }

    private func layoutNormal(bottomY: CGFloat, animated: Bool) {
        let searchWidth = Self.barHeight
        let searchX = bounds.width - searchWidth - 16
        searchBarView.frame = CGRect(x: searchX, y: bottomY, width: searchWidth, height: Self.barHeight)
        searchBarView.setCloseButtonVisible(false)

        let glassRight = searchX - Self.searchTrailingSpacing
        let glassLeft: CGFloat = 16
        let glassWidth = glassRight - glassLeft
        glassContainer.frame = CGRect(x: glassLeft, y: bottomY, width: glassWidth, height: Self.barHeight)
        tabsContainer.frame = glassContainer.bounds

        layoutTabs(animated: animated)
    }

    private func layoutSearchActive(bottomY: CGFloat, animated: Bool) {
        let fullWidth = bounds.width - 32
        var searchY = bottomY

        if keyboardHeight > 0 {
            searchY = bounds.height - keyboardHeight - Self.barHeight - 8
            searchBarView.setCloseButtonVisible(true)
        } else {
            searchBarView.setCloseButtonVisible(false)
        }

        searchBarView.frame = CGRect(x: 16, y: searchY, width: fullWidth, height: Self.barHeight)

        let collapsedSize: CGFloat = 48
        let tabsWidth = tabsContainer.bounds.width > 0 ? itemViews.reduce(0) { $0 + $1.bounds.width } : collapsedSize * 3
        let glassLeft: CGFloat = 16
        glassContainer.frame = CGRect(
            x: glassLeft - tabsWidth + collapsedSize,
            y: bottomY,
            width: collapsedSize,
            height: collapsedSize
        )
        tabsContainer.frame = glassContainer.bounds
        layoutTabs(animated: animated)
    }

    private func layoutTabs(animated: Bool) {
        guard !itemViews.isEmpty else { return }

        let containerWidth = tabsContainer.bounds.width
        let itemCount = CGFloat(itemViews.count)
        let itemWidth = containerWidth / itemCount
        let itemHeight = tabsContainer.bounds.height

        for (index, itemView) in itemViews.enumerated() {
            let isSelected = index == selectedIndex
            let isDragging = selectionGestureState?.itemId == items[index].id
            let scale: CGFloat = (selectionGestureState != nil && (isSelected || isDragging)) ? 1.15 : 1.0

            itemView.frame = CGRect(
                x: CGFloat(index) * itemWidth,
                y: 0,
                width: itemWidth,
                height: itemHeight
            )
            itemView.setSelected(isSelected, scale: scale, animated: animated)
        }

        let lensX: CGFloat
        let lensWidth: CGFloat

        if let state = selectionGestureState {
            lensX = state.currentX
            lensWidth = state.itemWidth
        } else {
            lensX = CGFloat(selectedIndex) * itemWidth
            lensWidth = itemWidth
        }

        let collapseOffset = scrollCollapseProgress * max(0, containerWidth - 48)
        tabsClusterLeadingOffset = -collapseOffset
        tabsContainer.transform = CGAffineTransform(translationX: tabsClusterLeadingOffset, y: 0)

        lensView.update(originX: lensX, width: lensWidth, height: itemHeight - 8, animated: animated)
    }

    private func itemIndex(at location: CGPoint) -> Int? {
        let point = tabsContainer.convert(location, from: self)
        guard tabsContainer.bounds.contains(point) else { return nil }
        let itemWidth = tabsContainer.bounds.width / CGFloat(itemViews.count)
        let index = Int(point.x / itemWidth)
        guard index >= 0, index < itemViews.count else { return nil }
        return index
    }

    @objc private func itemTapped(_ sender: TabItemView) {
        guard searchState == .inactive,
              let index = itemViews.firstIndex(where: { $0 === sender }) else { return }
        setSelectedIndex(index, animated: true)
        delegate?.glassTabBar(self, didSelectItemAt: index)
    }

    @objc private func handleSelectionPan(_ recognizer: UIPanGestureRecognizer) {
        guard searchState == .inactive else { return }

        let itemWidth = tabsContainer.bounds.width / CGFloat(max(1, itemViews.count))

        switch recognizer.state {
        case .began:
            guard let index = itemIndex(at: recognizer.location(in: self)) else { return }
            let startX = CGFloat(index) * itemWidth
            selectionGestureState = (startX, startX, itemWidth, items[index].id)
            lensView.setLifted(true, animated: true)
            layoutTabs(animated: false)

        case .changed:
            guard var state = selectionGestureState else { return }
            state.currentX = state.startX + recognizer.translation(in: tabsContainer).x
            if let index = itemIndex(at: recognizer.location(in: self)) {
                state.itemId = items[index].id
            }
            selectionGestureState = state
            layoutTabs(animated: false)

        case .ended, .cancelled:
            guard let state = selectionGestureState else { return }
            selectionGestureState = nil
            lensView.setLifted(false, animated: true)

            if let index = items.firstIndex(where: { $0.id == state.itemId }) {
                setSelectedIndex(index, animated: true)
                delegate?.glassTabBar(self, didSelectItemAt: index)
            } else {
                layoutTabs(animated: true)
            }

        default:
            break
        }
    }
}

// MARK: - TabSearchBarViewDelegate

extension GlassTabBarView: TabSearchBarViewDelegate {
    func searchBarDidTapActivate(_ searchBar: TabSearchBarView) {
        setSearchState(.active, animated: true)
        searchBar.searchField.becomeFirstResponder()
        delegate?.glassTabBarDidActivateSearch(self)
    }

    func searchBarDidTapClose(_ searchBar: TabSearchBarView) {
        searchBar.resignSearch()
        setSearchState(.inactive, animated: true)
        delegate?.glassTabBarDidDeactivateSearch(self)
    }

    func searchBarDidBeginEditing(_ searchBar: TabSearchBarView) {
        if searchState != .active {
            setSearchState(.active, animated: true)
            delegate?.glassTabBarDidActivateSearch(self)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension GlassTabBarView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}

// MARK: - Tab item button

private final class TabItemView: UIControl {
    private let iconView: UIImageView
    private let titleLabel: UILabel

    init(item: GlassTabBarItem) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconView = UIImageView(image: UIImage(systemName: item.systemImage, withConfiguration: config))
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit

        titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        super.init(frame: .zero)
        addSubview(iconView)
        addSubview(titleLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let iconSize: CGFloat = 22
        iconView.frame = CGRect(x: (bounds.width - iconSize) / 2, y: 6, width: iconSize, height: iconSize)
        titleLabel.frame = CGRect(x: 0, y: bounds.height - 16, width: bounds.width, height: 12)
    }

    func setSelected(_ selected: Bool, scale: CGFloat, animated: Bool) {
        let alpha: CGFloat = selected ? 1.0 : 0.55
        let updates = {
            self.iconView.alpha = alpha
            self.titleLabel.alpha = alpha
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }
    }
}
