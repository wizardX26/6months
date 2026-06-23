//
//  ComponentGestureDemoViewController.swift
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

final class ComponentGestureDemoViewController: UIViewController {
    private let hostView = ComponentHostView()
    private let attachable = GestureAttachableView()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Component Gesture"

        hostView.translatesAutoresizingMaskIntoConstraints = false
        attachable.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        attachable.layer.cornerRadius = 12
        attachable.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.text = "Tap the blue area"
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        hostView.addSubview(attachable)
        view.addSubview(hostView)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            hostView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            hostView.widthAnchor.constraint(equalToConstant: 240),
            hostView.heightAnchor.constraint(equalToConstant: 120),
            attachable.topAnchor.constraint(equalTo: hostView.topAnchor),
            attachable.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            attachable.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            attachable.bottomAnchor.constraint(equalTo: hostView.bottomAnchor),
            statusLabel.topAnchor.constraint(equalTo: hostView.bottomAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        attachable.updateGestures([
            .tap(id: 1) { [weak self] in
                self?.statusLabel.text = "Declarative tap fired (GestureAttachableView.updateGestures)"
            }
        ])
    }
}
