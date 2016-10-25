//
//  ExpandableCell.swift
//  Yelp
//
//  Created by Akifumi Shinagawa on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class ExpandableCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var toggleIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func toggleIcon(toggleUp: Bool) {
        
//        let rotateAngle:Float!
//        if(toggleUp) {
//            rotateAngle = 0.0
//        }
//        else {
//            rotateAngle = 180.0
//        }

    }

}
