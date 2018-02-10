//
//  ConstellationDetailsCell.swift
//  horoscopeclient
//
//  Created by rightmeow on 2/4/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import UIKit

class ConstellationDetailsCell: BaseTableViewCell {

    var constellation: Constellation? {
        didSet {
            updateCell()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    static let cell_id = String(describing: ConstellationDetailsCell.self)
    static let nibName = String(describing: ConstellationDetailsCell.self)

    private func updateCell() {
        
    }

    private func setupCell() {
        self.titleLabel.text = "今日概述"
        self.subtitleLabel.text = "有些思考的小漩涡，可能让你忽然的放空，生活中许多的细节让你感触良多，五味杂陈，常常有时候就慢动作定格，想法在某处冻结停留，陷入一阵自我对话的沉思之中，这个时候你不喜欢被打扰或询问，也不想让某些想法曝光，个性变得有些隐晦。"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
