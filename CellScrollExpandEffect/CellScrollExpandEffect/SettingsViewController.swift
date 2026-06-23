import UIKit
import SwiftUI

final class SettingsViewController: UIViewController {
    private let sections = SettingsData.sections
    private var revealedIndexPaths = Set<IndexPath>()

    private lazy var collectionView: UICollectionView = {
        let layout = makeLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.systemGroupedBackground
        collectionView.alwaysBounceVertical = true
        collectionView.isPrefetchingEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            SettingsCollectionCell.self,
            forCellWithReuseIdentifier: SettingsCollectionCell.reuseIdentifier
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cài đặt"
        view.backgroundColor = .systemBlue
        setupNavigationBar()
        setupCollectionView()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "SwiftUI",
            style: .plain,
            target: self,
            action: #selector(openSwiftUISettings)
        )
    }

    @objc private func openSwiftUISettings() {
        let hostingController = UIHostingController(rootView: SettingsScreen())
        hostingController.title = "Cài đặt (SwiftUI)"
        hostingController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSwiftUISettings)
        )

        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    @objc private func dismissSwiftUISettings() {
        dismiss(animated: true)
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.makeSettingsSection()
        }
        layout.register(
            SectionBackgroundView.self,
            forDecorationViewOfKind: SectionBackgroundKind.elementKind
        )
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }

    private func makeSettingsSection() -> NSCollectionLayoutSection {
        let height = SettingsCollectionCell.layoutHeight
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: height
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 0

        let background = NSCollectionLayoutDecorationItem.background(
            elementKind: SectionBackgroundKind.elementKind
        )
        background.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.decorationItems = [background]

        return section
    }
}

extension SettingsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsCollectionCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsCollectionCell else {
            return UICollectionViewCell()
        }
        let section = indexPath.section
        let itemCount = sections[section].count
        let position = SectionCellPosition.inSection(
            itemIndex: indexPath.item,
            itemCount: itemCount
        )
        cell.configure(with: sections[section][indexPath.item], position: position)
        return cell
    }
}

extension SettingsViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? SettingsCollectionCell else { return }

        guard !revealedIndexPaths.contains(indexPath) else {
            cell.showFullyVisible()
            return
        }
        revealedIndexPaths.insert(indexPath)

        let visibleRow = collectionView.indexPathsForVisibleItems
            .sorted()
            .firstIndex(of: indexPath) ?? 0
        let delay = min(TimeInterval(visibleRow) * 0.04, 0.3)

        cell.prepareForRevealAnimation()
        cell.performRevealAnimation(delay: delay)
    }
}
