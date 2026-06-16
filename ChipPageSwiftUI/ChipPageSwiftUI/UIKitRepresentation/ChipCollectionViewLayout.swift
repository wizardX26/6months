import UIKit

enum ChipCollectionViewLayout {
    static func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 112, height: 44)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        layout.sectionInsetReference = .fromContentInset
        return layout
    }
}
