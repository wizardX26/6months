import UIKit

final class SearchViewController: BaseViewController {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private var items = ["Apple", "Banana", "Cherry", "Durian", "Elderberry", "Fig", "Grape"]
    private var filteredItems: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        filteredItems = items

        let filterImage = UIImage(systemName: "line.3.horizontal.decrease.circle")
        setupNavigationBar(
            owner: self,
            title: "",
            type: .searchBackButton,
            isPush: true,
            hasBackground: false
        )
        customNavigationBar?.listRightButtons = [filterImage as Any]
        customNavigationBar?.noBackgroundTintColor = .label
        pinNavigationBarToTop()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: LayoutHelper.navigationBarHeight(titleStyle: .inline, for: self)
            ),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SearchViewController: NavigationBarDelegate {
    func navigationBar(_ bar: CustomNavigationBar, leftAction sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func navigationBar(_ bar: CustomNavigationBar, firstRightAction sender: Any) {
        let alert = UIAlertController(title: "Bộ lọc", message: "Nút lọc được nhấn", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func navigationBar(_ bar: CustomNavigationBar, searchEditingChanged keyword: String) {
        if keyword.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { $0.localizedCaseInsensitiveContains(keyword) }
        }
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = filteredItems[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }
}
