import SwiftUI
import UIKit

struct ChipCollectionView: UIViewRepresentable {
    let items: [ChipCollectionItem]
    let selection: ChipCollectionItem.ID?
    var showsScrollIndicator = false
    var onSelect: (ChipCollectionItem.ID) -> Void

    func makeCoordinator() -> ChipCollectionViewCoordinator {
        ChipCollectionViewCoordinator(onSelect: onSelect)
    }

    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = context.coordinator.makeCollectionView()
        collectionView.showsHorizontalScrollIndicator = showsScrollIndicator
        return collectionView
    }

    func updateUIView(_ collectionView: UICollectionView, context: Context) {
        context.coordinator.onSelect = onSelect
        collectionView.showsHorizontalScrollIndicator = showsScrollIndicator
        context.coordinator.update(
            collectionView,
            items: items,
            selection: selection
        )
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UICollectionView,
        context: Context
    ) -> CGSize? {
        CGSize(width: proposal.width ?? uiView.contentSize.width, height: 56)
    }
}
