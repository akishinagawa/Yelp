//
//  DetailsViewController.swift
//  Yelp
//
//  Created by Akifumi Shinagawa on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking

class DetailsViewController: UIViewController {

    var business: Business!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var isOpen: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingCount: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var aboutRestaurant: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = business.name!
        
        image.setImageWith(business.imageURL!, placeholderImage: nil)
        category.text = business.categories
        address.text = business.address
        ratingCount.text = "\(business.reviewCount!)"
        ratingImage.setImageWith(business.ratingImageURL!, placeholderImage: nil)
        distance.text = business.distance
        phoneNumber.text = business.phoneNumber
        if business.isClosed! {
            isOpen.text = "Closed"
            isOpen.textColor = UIColor.red
        }
        else {
            isOpen.text = "Open"
            isOpen.textColor = UIColor.green
        }
        aboutRestaurant.text = business.aboutRestaurant
    }

    @IBAction func onBackButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
