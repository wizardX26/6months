//
//  PageContentViewController.swift
//  SwipeDissmissWithPageView
//

import UIKit

final class PageContentViewController: UIViewController {

    let pageIndex: Int
    let titleText: String
    let accentColor: UIColor
    let showsScrollableContent: Bool

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(
        pageIndex: Int,
        titleText: String,
        accentColor: UIColor,
        showsScrollableContent: Bool = false
    ) {
        self.pageIndex = pageIndex
        self.titleText = titleText
        self.accentColor = accentColor
        self.showsScrollableContent = showsScrollableContent
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = accentColor.withAlphaComponent(0.15)

        if showsScrollableContent {
            setupTableView()
        } else {
            setupPlaceholder()
        }
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.delaysContentTouches = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupPlaceholder() {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = accentColor.withAlphaComponent(0.35)
        card.layer.cornerRadius = 16

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = titleText
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0

        let hint = UILabel()
        hint.translatesAutoresizingMaskIntoConstraints = false
        hint.text = pageIndex == 0
            ? "Swipe right to pop when on this page."
            : "Swipe left or right to change pages."
        hint.font = .systemFont(ofSize: 15, weight: .medium)
        hint.textColor = .secondaryLabel
        hint.textAlignment = .center
        hint.numberOfLines = 0

        view.addSubview(card)
        card.addSubview(label)
        card.addSubview(hint)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            hint.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12),
            hint.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            hint.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            hint.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
        ])
    }
}

extension PageContentViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        24
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Item \(indexPath.row + 1)"
        cell.detailTextLabel?.text = "Scroll vertically; swipe right at page 0 to pop."
        cell.backgroundColor = accentColor.withAlphaComponent(0.12)
        return cell
    }
}
