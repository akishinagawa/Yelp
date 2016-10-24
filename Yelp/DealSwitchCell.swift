//
//  DealSwitchCell.swift
//  Yelp
//
//  Created by Akifumi Shinagawa on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol DealSwitchCellDelegate {
    @objc optional func dealSwitchCell(dealSwitchCell: DealSwitchCell, didChangeValue value: Bool)
}

class DealSwitchCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    weak var delegate: DealSwitchCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        onSwitch.addTarget(self, action: #selector(DealSwitchCell.switchValueChanged), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func switchValueChanged() {
        delegate?.dealSwitchCell?(dealSwitchCell: self, didChangeValue: onSwitch.isOn)
        
    }

}
