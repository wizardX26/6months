import UIKit

final class ChipCollectionViewCoordinator: NSObject {
    var onSelect: (ChipCollectionItem.ID) -> Void

    private var dataSource: UICollectionViewDiffableDataSource<Int, ChipCollectionItem.ID>?
    private var currentItemsByID: [ChipCollectionItem.ID: ChipCollectionItem] = [:]
    private var currentItemIDs: [ChipCollectionItem.ID] = []
    private var currentSelection: ChipCollectionItem.ID?
    private var hasAppliedInitialSnapshot = false

    init(onSelect: @escaping (ChipCollectionItem.ID) -> Void) {
        self.onSelect = onSelect
    }

    func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: ChipCollectionViewLayout.makeLayout()
        )

        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.allowsMultipleSelection = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self

        configureDataSource(for: collectionView)
        return collectionView
    }

    func update(
        _ collectionView: UICollectionView,
        items: [ChipCollectionItem],
        selection: ChipCollectionItem.ID?
    ) {
        guard let dataSource else {
            return
        }

        let uniqueItems = uniquedItems(from: items)
        let newItemIDs = uniqueItems.map(\.id)
        let newItemsByID = Dictionary(uniqueKeysWithValues: uniqueItems.map { ($0.id, $0) })
        let changedIDs = newItemIDs.filter { itemID in
            guard let previousItem = currentItemsByID[itemID] else {
                return false
            }
            return previousItem != newItemsByID[itemID]
        }
        let identityChanged = newItemIDs != currentItemIDs
        let needsSnapshot = !hasAppliedInitialSnapshot || identityChanged || !changedIDs.isEmpty

        currentSelection = selection
        currentItemsByID = newItemsByID
        currentItemIDs = newItemIDs

        guard needsSnapshot else {
            syncSelection(selection, in: collectionView)
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, ChipCollectionItem.ID>()
        snapshot.appendSections([0])
        snapshot.appendItems(newItemIDs, toSection: 0)

        if !changedIDs.isEmpty {
            snapshot.reconfigureItems(changedIDs)
        }

        let shouldAnimate = hasAppliedInitialSnapshot && identityChanged && collectionView.window != nil
        hasAppliedInitialSnapshot = true

        dataSource.apply(snapshot, animatingDifferences: shouldAnimate) { [weak self, weak collectionView] in
            guard let self, let collectionView else {
                return
            }
            self.syncSelection(selection, in: collectionView)
        }
    }

    private func configureDataSource(for collectionView: UICollectionView) {
        let registration = UICollectionView.CellRegistration<ChipCollectionViewCell, ChipCollectionItem.ID> {
            [weak self] cell, _, itemID in
            guard let self, let item = self.currentItemsByID[itemID] else {
                return
            }

            cell.configure(with: item, isSelected: itemID == self.currentSelection)
        }

        dataSource = UICollectionViewDiffableDataSource<Int, ChipCollectionItem.ID>(
            collectionView: collectionView
        ) { collectionView, indexPath, itemID in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: itemID
            )
        }
    }

    private func syncSelection(
        _ selection: ChipCollectionItem.ID?,
        in collectionView: UICollectionView
    ) {
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            guard dataSource?.itemIdentifier(for: indexPath) != selection else {
                continue
            }

            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.cellForItem(at: indexPath)?.isSelected = false
        }

        guard let selection, let selectedIndexPath = dataSource?.indexPath(for: selection) else {
            return
        }

        collectionView.selectItem(
            at: selectedIndexPath,
            animated: false,
            scrollPosition: .centeredHorizontally
        )
        collectionView.cellForItem(at: selectedIndexPath)?.isSelected = true
    }

    private func uniquedItems(from items: [ChipCollectionItem]) -> [ChipCollectionItem] {
        var seenIDs = Set<ChipCollectionItem.ID>()

        return items.filter { item in
            let isUnique = seenIDs.insert(item.id).inserted
            assert(isUnique, "ChipCollectionView item IDs must be unique.")
            return isUnique
        }
    }
}

extension ChipCollectionViewCoordinator: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemID = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }

        onSelect(itemID)
    }
}
