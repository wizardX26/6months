//
//  HorizontalScrollDemoViewController.swift
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

final class HorizontalScrollDemoViewController: UIViewController, UIScrollViewDelegate {
    private let scrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Horizontal Scroll"

        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.disablesInteractiveTransitionGestureRecognizer = true
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue]
        var previous: UIView?
        for (index, color) in colors.enumerated() {
            let page = UIView()
            page.backgroundColor = color.withAlphaComponent(0.35)
            page.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(page)

            let label = UILabel()
            label.text = "Page \(index + 1)\nscroll ngang không trigger pop\n(disablesInteractiveTransitionGestureRecognizer = true)"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            page.addSubview(label)

            NSLayoutConstraint.activate([
                page.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                page.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                page.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                page.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
                label.centerXAnchor.constraint(equalTo: page.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: page.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: page.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(lessThanOrEqualTo: page.trailingAnchor, constant: -16)
            ])

            if let previous {
                page.leadingAnchor.constraint(equalTo: previous.trailingAnchor).isActive = true
            } else {
                page.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
            }
            previous = page
        }
        previous?.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
    }
}
