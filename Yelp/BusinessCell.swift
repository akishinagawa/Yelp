//
//  BusinessCell.swift
//  Yelp
//
//  Created by Akifumi Shinagawa on 10/21/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking


class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var openCloseLabel: UILabel!
    @IBOutlet weak var aboutRestaurant: UILabel!
    

    var business: Business! {
        didSet {
            self.nameLabel.text = business.name
            
            thumbImageView.setImageWith(business.imageURL!, placeholderImage: nil)
            categoryLabel.text = business.categories
            addressLabel.text = business.address
            reviewsCountLabel.text = "\(business.reviewCount!)"
            ratingImageView.setImageWith(business.ratingImageURL!, placeholderImage: nil)
            distanceLabel.text = business.distance
            phoneLabel.text = business.phoneNumber
            if business.isClosed! {
                openCloseLabel.text = "Closed"
                openCloseLabel.textColor = UIColor.red
            }
            else {
                openCloseLabel.text = "Open"
                openCloseLabel.textColor = UIColor.green
            }
            aboutRestaurant.text = business.aboutRestaurant
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        thumbImageView.layer.cornerRadius = 6
        thumbImageView.clipsToBounds = true
        
//        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
