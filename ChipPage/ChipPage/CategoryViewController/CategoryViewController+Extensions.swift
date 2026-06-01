//
//  CategoryViewController+extensions.swift
//  ChipPage
//
//  Created by wizard.os25 on 1/6/26.
//

import UIKit

extension CategoryViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.pages.firstIndex(of: viewController),
              index > 0
        else { return nil }
        return self.pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.pages.firstIndex(of: viewController),
              index < self.pages.count - 1
        else { return nil }
        return self.pages[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentViewController = pageViewController.viewControllers?.first,
              let index = self.pages.firstIndex(of: currentViewController)
        else { return }
                
        let oldIndex = currentIndex
        currentIndex = index
        updateChipSelection(from: oldIndex, to: currentIndex)
    }
    
}

extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.chipData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChipCollectionViewCell", for: indexPath) as! ChipCollectionViewCell
        
        let isSelected = indexPath.item == self.currentIndex
        cell.cellConfig(title: self.chipData[indexPath.item], isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != currentIndex else { return }
        
        let direction: UIPageViewController.NavigationDirection =
        indexPath.item > currentIndex ? .forward : .reverse
                
        pageViewController.setViewControllers(
            [pages[indexPath.item]],
            direction: direction,
            animated: true,
            completion: nil
        )
        let oldIndex = currentIndex
        currentIndex = indexPath.item
        updateChipSelection(from: oldIndex, to: currentIndex)
    }
}

extension CategoryViewController {
    private func updateChipSelection(
        from oldIndex: Int,
        to newIndex: Int
    ) {
        let oldPath = IndexPath(item: oldIndex, section: 0)
        let newPath = IndexPath(item: newIndex, section: 0)

        chipCollectionView.reloadItems(
            at: [oldPath, newPath]
        )

        chipCollectionView.scrollToItem(
            at: newPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
}
