//
//  SettingsTabViewController.swift
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

final class SettingsTabViewController: UITableViewController, TabScrollReporting {
    weak var scrollCollapseDelegate: TabScrollCollapseDelegate?

    private enum Row: Int, CaseIterable {
        case notifications, privacy, data, appearance, help

        var title: String {
            switch self {
            case .notifications: return "Notifications"
            case .privacy: return "Privacy"
            case .data: return "Data and Storage"
            case .appearance: return "Appearance"
            case .help: return "Help"
            }
        }

        var icon: String {
            switch self {
            case .notifications: return "bell"
            case .privacy: return "hand.raised"
            case .data: return "externaldrive"
            case .appearance: return "paintbrush"
            case .help: return "questionmark.circle"
            }
        }
    }

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let row = Row(rawValue: indexPath.row) else { return cell }
        var config = cell.defaultContentConfiguration()
        config.text = row.title
        config.image = UIImage(systemName: row.icon)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }
        let detail = UIViewController()
        detail.view.backgroundColor = .systemBackground
        detail.title = row.title
        navigationController?.pushViewController(detail, animated: true)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        scrollCollapseDelegate?.tabScrollDidUpdate(offset: max(0, offset))
    }
}
