//
//  BaseCollectionViewCell.swift
//  newsclient
//
//  Created by rightmeow on 1/25/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {

    private func setupCell() {
        self.backgroundColor = Color.clear
        self.contentView.backgroundColor = Color.clear
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
