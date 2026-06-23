//
//  TabSearchBarView.swift
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

protocol TabSearchBarViewDelegate: AnyObject {
    func searchBarDidTapActivate(_ searchBar: TabSearchBarView)
    func searchBarDidTapClose(_ searchBar: TabSearchBarView)
    func searchBarDidBeginEditing(_ searchBar: TabSearchBarView)
}

/// Trailing search control that expands full-width when active (expandable trailing search layout).
final class TabSearchBarView: UIView {
    weak var delegate: TabSearchBarViewDelegate?

    private(set) var isActive = false

    private let glassBackground: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let searchIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        let view = UIImageView(image: image)
        view.tintColor = .secondaryLabel
        view.contentMode = .scaleAspectFit
        return view
    }()

    let searchField: UITextField = {
        let field = UITextField()
        field.placeholder = "Search"
        field.font = .systemFont(ofSize: 17)
        field.returnKeyType = .search
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing
        field.alpha = 0
        return field
    }()

    private let activateButton = UIButton(type: .system)
    private let closeButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryLabel
        button.isHidden = true
        button.accessibilityLabel = "Close search"
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(glassBackground)
        glassBackground.contentView.addSubview(searchIcon)
        glassBackground.contentView.addSubview(searchField)
        glassBackground.contentView.addSubview(closeButton)

        activateButton.addTarget(self, action: #selector(activateTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        searchField.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        addSubview(activateButton)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        glassBackground.frame = bounds
        activateButton.frame = bounds

        let iconSize: CGFloat = 22
        let padding: CGFloat = 14
        if isActive {
            closeButton.frame = CGRect(
                x: bounds.width - padding - 32,
                y: (bounds.height - 32) / 2,
                width: 32,
                height: 32
            )
            searchIcon.frame = CGRect(x: padding, y: (bounds.height - iconSize) / 2, width: iconSize, height: iconSize)
            searchField.frame = CGRect(
                x: padding + iconSize + 8,
                y: 0,
                width: closeButton.frame.minX - padding - iconSize - 8,
                height: bounds.height
            )
        } else {
            searchIcon.frame = CGRect(
                x: (bounds.width - iconSize) / 2,
                y: (bounds.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            searchField.frame = .zero
            closeButton.frame = .zero
        }
    }

    func setActive(_ active: Bool, animated: Bool) {
        guard isActive != active else { return }
        isActive = active

        let updates = {
            self.searchField.alpha = active ? 1 : 0
            self.closeButton.isHidden = !active || self.closeButton.isHidden
            self.activateButton.isHidden = active
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: updates)
        } else {
            updates()
        }
    }

    func setCloseButtonVisible(_ visible: Bool) {
        closeButton.isHidden = !visible
    }

    func resignSearch() {
        searchField.resignFirstResponder()
        searchField.text = nil
    }

    @objc private func activateTapped() {
        delegate?.searchBarDidTapActivate(self)
    }

    @objc private func closeTapped() {
        delegate?.searchBarDidTapClose(self)
    }

    @objc private func editingBegan() {
        delegate?.searchBarDidBeginEditing(self)
    }
}
