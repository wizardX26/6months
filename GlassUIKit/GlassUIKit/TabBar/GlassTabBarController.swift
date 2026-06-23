//
//  GlassTabBarController.swift
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

/// Root container: 3 tab roots + glass tab bar + search overlay (glass tab shell layout).
final class GlassTabBarController: UIViewController {
    private let tabBarView = GlassTabBarView()
    private let contentContainer = UIView()

    private let items: [GlassTabBarItem] = [
        .init(id: "chats", title: "Chats", systemImage: "bubble.left.and.bubble.right"),
        .init(id: "contacts", title: "Contacts", systemImage: "person.2"),
        .init(id: "settings", title: "Settings", systemImage: "gearshape"),
    ]

    private var controllers: [UIViewController] = []
    private var searchController: TabSearchViewController?
    private var selectedIndex = 0
    private var isSearchActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)
        view.addSubview(tabBarView)

        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: GlassTabBarView.barHeight + 24),
        ])

        tabBarView.delegate = self
        tabBarView.configure(items: items, selectedIndex: 0)

        controllers = [
            GestureNavigationController(rootViewController: ChatsTabViewController()),
            GestureNavigationController(rootViewController: ContactsTabViewController()),
            GestureNavigationController(rootViewController: SettingsTabViewController()),
        ]

        for controller in controllers {
            wireScrollReporting(for: controller)
        }

        showController(at: 0, animated: false)
    }

    func updateKeyboardHeight(_ height: CGFloat) {
        tabBarView.setKeyboardHeight(height)
    }

    private func wireScrollReporting(for nav: UIViewController) {
        guard let root = (nav as? UINavigationController)?.viewControllers.first,
              let reporter = root as? TabScrollReporting else { return }
        reporter.scrollCollapseDelegate = self
    }

    private func showController(at index: Int, animated: Bool) {
        guard index >= 0, index < controllers.count else { return }
        let newController = controllers[index]

        children.forEach { child in
            if child !== newController && child !== searchController {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }

        if newController.parent == nil {
            addChild(newController)
            newController.view.frame = contentContainer.bounds
            newController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentContainer.insertSubview(newController.view, at: 0)
            newController.didMove(toParent: self)
        }

        selectedIndex = index
        tabBarView.setSelectedIndex(index, animated: animated)
        updateContentInsets()
    }

    private func showSearchOverlay() {
        guard searchController == nil else { return }
        let search = TabSearchViewController()
        searchController = search
        addChild(search)
        search.view.frame = contentContainer.bounds
        search.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentContainer.addSubview(search.view)
        search.didMove(toParent: self)
        isSearchActive = true
        updateContentInsets()
    }

    private func hideSearchOverlay() {
        guard let search = searchController else { return }
        search.willMove(toParent: nil)
        search.view.removeFromSuperview()
        search.removeFromParent()
        searchController = nil
        isSearchActive = false
        updateContentInsets()
    }

    private func updateContentInsets() {
        let tabBarInset = GlassTabBarView.barHeight + 24 + view.safeAreaInsets.bottom
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarInset, right: 0)

        for controller in controllers {
            controller.additionalSafeAreaInsets = isSearchActive ? .zero : inset
        }
        searchController?.additionalSafeAreaInsets = inset
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateContentInsets()
    }
}

// MARK: - GlassTabBarDelegate

extension GlassTabBarController: GlassTabBarDelegate {
    func glassTabBar(_ tabBar: GlassTabBarView, didSelectItemAt index: Int) {
        guard !isSearchActive else { return }
        showController(at: index, animated: true)
    }

    func glassTabBarDidActivateSearch(_ tabBar: GlassTabBarView) {
        showSearchOverlay()
    }

    func glassTabBarDidDeactivateSearch(_ tabBar: GlassTabBarView) {
        hideSearchOverlay()
    }
}

// MARK: - TabScrollCollapseDelegate

extension GlassTabBarController: TabScrollCollapseDelegate {
    func tabScrollDidUpdate(offset: CGFloat) {
        guard !isSearchActive else { return }
        tabBarView.reportScrollOffset(offset)
    }
}
