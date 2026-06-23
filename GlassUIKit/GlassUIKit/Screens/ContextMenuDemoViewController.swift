//
//  ContextMenuDemoViewController.swift
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

final class ContextMenuDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Context Menu"

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])

        for index in 1 ... 3 {
            let card = makeCard(title: "Card \(index)")
            stack.addArrangedSubview(card)
            card.heightAnchor.constraint(equalToConstant: 72).isActive = true
        }
    }

    private func makeCard(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12

        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        let source = ContextControllerSourceView(frame: .zero)
        source.translatesAutoresizingMaskIntoConstraints = false
        source.activated = { [weak self] _, point in
            self?.showMenu(at: point, in: container, title: title)
        }
        container.addSubview(source)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            source.topAnchor.constraint(equalTo: container.topAnchor),
            source.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            source.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            source.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func showMenu(at point: CGPoint, in view: UIView, title: String) {
        let alert = UIAlertController(title: "Context", message: "\(title) @ \(Int(point.x)), \(Int(point.y))", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(origin: point, size: .zero)
        }
        present(alert, animated: true)
    }
}
