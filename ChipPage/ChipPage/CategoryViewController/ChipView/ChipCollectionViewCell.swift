//
//  ChipCollectionViewCell.swift
//  ChipPage
//
//  Created by wizard.os25 on 1/6/26.
//

import UIKit

class ChipCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var chipTitle: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.chipTitle.textColor = .black
    }
    
    func cellConfig(title: String, isSelected: Bool) {
        self.chipTitle.text = title
        self.chipTitle.textColor = isSelected ? .systemBlue : .black
    }
}
