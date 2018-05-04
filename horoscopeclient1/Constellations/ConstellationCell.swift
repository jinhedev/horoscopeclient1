//
//  ConstellationCell.swift
//  horoscopeclient
//
//  Created by rightmeow on 1/30/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import UIKit

class ConstellationCell: BaseCollectionViewCell {

    var constellation: Constellation? {
        didSet {
            updateCell()
        }
    }
    let screenWidth = UIScreen.main.bounds.width
    static let cell_id = String(describing: ConstellationCell.self)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: SFImageView!
    @IBOutlet weak var titleLabel: UILabel!

    private func updateCell() {
        guard let unwrappedConstellation = self.constellation else { return }
        self.titleLabel.text = unwrappedConstellation.name
        self.imageView.image = UIImage(named: unwrappedConstellation.image_name)
    }

    private func setupCell() {
        self.backgroundColor = Color.clear
        self.containerView.backgroundColor = Color.white
//        self.imageView.backgroundColor = Color.clear
        self.layer.cornerRadius = 8
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

}
