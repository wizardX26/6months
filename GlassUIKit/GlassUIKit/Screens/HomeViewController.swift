//
//  HomeViewController.swift
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

final class DemoCell: UITableViewCell {
    static let reuseId = "DemoCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

final class HomeViewController: UITableViewController {
    private enum Demo: Int, CaseIterable {
        case swipeBack
        case horizontalScroll
        case contextMenu
        case keyboard
        case componentGesture

        var title: String {
            switch self {
            case .swipeBack: return "Swipe back (toàn màn hình)"
            case .horizontalScroll: return "Horizontal scroll + opt-out flag"
            case .contextMenu: return "ContextGesture (long-press)"
            case .keyboard: return "Keyboard dismiss pan"
            case .componentGesture: return "Declarative .gesture(.tap)"
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
        title = "Gesture Engine"
        tableView.register(DemoCell.self, forCellReuseIdentifier: DemoCell.reuseId)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Demo.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DemoCell.reuseId, for: indexPath)
        cell.textLabel?.text = Demo(rawValue: indexPath.row)?.title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let demo = Demo(rawValue: indexPath.row) else { return }
        let vc: UIViewController
        switch demo {
        case .swipeBack:
            vc = PushDemoViewController()
        case .horizontalScroll:
            vc = HorizontalScrollDemoViewController()
        case .contextMenu:
            vc = ContextMenuDemoViewController()
        case .keyboard:
            vc = KeyboardDemoViewController()
        case .componentGesture:
            vc = ComponentGestureDemoViewController()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
