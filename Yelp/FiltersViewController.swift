//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Akifumi Shinagawa on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters:[String:AnyObject])
}


enum DistanceItems: String {
    case auto = "Auto"
    case veryClose = "0.3 miles"
    case close = "1 miles"
    case far = "5 miles"
    case varyFar = "20 miles"
}

enum SortItems: String {
    case auto = "Best Match"
    case distance = "Distance"
    case highestRated = "Highest Rated"
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    // static for tableView
    let filterSections = ["Deal", "Distance", "Sort By", "Categories"]
    let distances = ["Auto", "0.3 miles", "1 mile", "5 miles", "20 miles"]
    let sortBy = ["Best Match", "Distance", "Highest Rated"]
    var categories: [[String:String]]!
    
    // For expand feature (will be used later)
    var distanceHeaderOpened:Bool!
    var sortByHeaderOpened:Bool!
    var categoriesHeaderOpened:Bool!
    var defaultCategoriesRows:Int = 3
    
    // current data holdings
    var isDealOn:Bool!
    var distancesStates = [Int:Bool]()
    var selectedDistance:Int!
    var sortByStates = [Int:Bool]()
    var selectedSort:Int!
    var categoriesStates = [Int:Bool]()
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // default values
        isDealOn = false
        distanceHeaderOpened = false
        sortByHeaderOpened = false
        categoriesHeaderOpened = false
        categories = yelpCategories()
        
        selectedDistance = 0
        distancesStates = [1: true, 2: false, 3: false, 4: false]
        selectedSort = 0
        sortByStates = [1: true, 2: false, 3: false]
        
        // tableView settings
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)

        var filters = [String: AnyObject]()

        // deals
        filters["deal"] = isDealOn as AnyObject?
        
        // distance - convert to meters
        var distanceAmount:Double
        switch selectedDistance {
        case 0:
            distanceAmount = 32187.0 // 20.0 miles / Auto
        case 1:
            distanceAmount = 483.0 // 0.3 mile
        case 2:
            distanceAmount = 1609.0 // 1.0 mile
        case 3:
            distanceAmount = 8046.0 // 5.0 miles
        case 4:
            distanceAmount = 32187.0 // 20.0 miles
        default:
            distanceAmount = 32187.0 // 20.0 miles
        }
        filters["distance"] = distanceAmount as AnyObject?
        
        // sort by
        var sortById:Int
        switch selectedSort {
        case 0:
            sortById = 0
        case 1:
            sortById = 1
        case 2:
            sortById = 2
        default:
            sortById = 0
        }
        filters["sortBy"] = sortById as AnyObject?
        
        // categories
        var selectedCategories = [String]()
        for (row, isSelected) in categoriesStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    

    // UITableViewDelegate UITableViewDataSource ----------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filterSections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1:
            if (distanceHeaderOpened == true) {
                return distances.count + 1
            }
            else {
                return 1
            }
            
        case 2:
            if (sortByHeaderOpened == true) {
                return sortBy.count + 1
            }
            else {
                return 1
            }
            
        case 3:
            return categories.count
            
            /* Expand feature
            if categoriesHeaderOpened == true {
                return categories.count
            }
            else {
                return defaultCategoriesRows + 1
            }
            */
            
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print ("indexPath Section = \(indexPath.section)")
//        print ("indexPath Row ID = \(indexPath.row)")
//        print ("---------------------------------------------------------->>>><<<<<<<<<<<")
        
        let cell:UITableViewCell!
        let section = indexPath.section 
        let row = indexPath.row

        switch section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier:"SwitchCell", for: indexPath) as! SwitchCell
            (cell as! SwitchCell).switchLabel.text = "Offering a Deal"
            //(cell as! SwitchCell).onSwitch.isOn = isDealOn ?? false
            (cell as! SwitchCell).onSwitch.setOn(isDealOn ?? false, animated: false)
            (cell as! SwitchCell).delegate = self
            
        case 1:
            if (row == 0) {
                cell = tableView.dequeueReusableCell(withIdentifier:"ExpandableCell", for: indexPath) as! ExpandableCell
                (cell as! ExpandableCell).statusLabel.text = distances[selectedDistance]
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier:"SwitchCell", for: indexPath) as! SwitchCell
                (cell as! SwitchCell).switchLabel.text = distances[row - 1]
                //(cell as! SwitchCell).onSwitch.isOn = distancesStates[row] ?? false
                (cell as! SwitchCell).onSwitch.setOn(distancesStates[row] ?? false, animated: false)
                (cell as! SwitchCell).delegate = self
            }
            
        case 2:
            
            if (row == 0) {
                cell = tableView.dequeueReusableCell(withIdentifier:"ExpandableCell", for: indexPath) as! ExpandableCell
                (cell as! ExpandableCell).statusLabel.text = sortBy[selectedSort]
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier:"SwitchCell", for: indexPath) as! SwitchCell
                (cell as! SwitchCell).switchLabel.text = sortBy[row - 1]
                //(cell as! SwitchCell).onSwitch.isOn = sortByStates[row] ?? false
                (cell as! SwitchCell).onSwitch.setOn(sortByStates[row] ?? false, animated: false)
                (cell as! SwitchCell).delegate = self
            }

            
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier:"SwitchCell", for: indexPath) as! SwitchCell
            (cell as! SwitchCell).switchLabel.text = categories[row]["name"]
            //(cell as! SwitchCell).onSwitch.isOn = categoriesStates[row] ?? false
            (cell as! SwitchCell).onSwitch.setOn(categoriesStates[row] ?? false, animated: false)
            (cell as! SwitchCell).delegate = self
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier:"SwitchCell", for: indexPath) as! SwitchCell
            (cell as! SwitchCell).switchLabel.text = "no data"
            (cell as! SwitchCell).onSwitch.isOn = false
            (cell as! SwitchCell).delegate = self
        }
        
        

        return cell
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!

        switch indexPath.section {
        case 0:
            isDealOn = value
            
        case 1:
            for i in 0 ..< distancesStates.count {
                distancesStates[i] = false
            }
            
            if value == true {
                distancesStates[indexPath.row] = value
                selectedDistance = indexPath.row - 1
            }
            else {
                distancesStates[1] = true
                selectedDistance = 0
            }
    
        case 2:
            for i in 0 ..< sortByStates.count {
                sortByStates[i] = false
            }

            if value == true {
                sortByStates[indexPath.row] = value
                selectedSort = indexPath.row - 1
            }
            else {
                sortByStates[1] = true
                selectedSort = 0
            }
            
        case 3:
            categoriesStates[indexPath.row] = value
            
        default:
            isDealOn = value
        }
        
        tableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print ("indexPath Section = \(indexPath.section)")
        print ("indexPath Row ID = \(indexPath.row)")
        print ("---------------------------------------------------------->>>>")
        
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch indexPath.section {
        case 0:
            print("done nothing")
            
        case 1:
            if row == 0 {
                distanceHeaderOpened = !distanceHeaderOpened
                let section = NSIndexSet(index: section)
                self.tableView.reloadSections(section as IndexSet, with: UITableViewRowAnimation.automatic)
            }

        case 2:
            if row == 0 {
                sortByHeaderOpened = !sortByHeaderOpened
                let section = NSIndexSet(index: section)
                self.tableView.reloadSections(section as IndexSet, with: UITableViewRowAnimation.automatic)
            }
            
        case 3:
            print("done nothing")
            
        default:
            print("done nothing")
        }
    }
    
    
    
    
    

    func yelpCategories() -> [[String:String]] {
        let categories = [["name" : "Afghan", "code": "afghani"],
                          ["name" : "African", "code": "african"],
                          ["name" : "American, New", "code": "newamerican"],
                          ["name" : "American, Traditional", "code": "tradamerican"],
                          ["name" : "Arabian", "code": "arabian"],
                          ["name" : "Argentine", "code": "argentine"],
                          ["name" : "Armenian", "code": "armenian"],
                          ["name" : "Asian Fusion", "code": "asianfusion"],
                          ["name" : "Asturian", "code": "asturian"],
                          ["name" : "Australian", "code": "australian"],
                          ["name" : "Austrian", "code": "austrian"],
                          ["name" : "Baguettes", "code": "baguettes"],
                          ["name" : "Bangladeshi", "code": "bangladeshi"],
                          ["name" : "Barbeque", "code": "bbq"],
                          ["name" : "Basque", "code": "basque"],
                          ["name" : "Bavarian", "code": "bavarian"],
                          ["name" : "Beer Garden", "code": "beergarden"],
                          ["name" : "Beer Hall", "code": "beerhall"],
                          ["name" : "Beisl", "code": "beisl"],
                          ["name" : "Belgian", "code": "belgian"],
                          ["name" : "Bistros", "code": "bistros"],
                          ["name" : "Black Sea", "code": "blacksea"],
                          ["name" : "Brasseries", "code": "brasseries"],
                          ["name" : "Brazilian", "code": "brazilian"],
                          ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                          ["name" : "British", "code": "british"],
                          ["name" : "Buffets", "code": "buffets"],
                          ["name" : "Bulgarian", "code": "bulgarian"],
                          ["name" : "Burgers", "code": "burgers"],
                          ["name" : "Burmese", "code": "burmese"],
                          ["name" : "Cafes", "code": "cafes"],
                          ["name" : "Cafeteria", "code": "cafeteria"],
                          ["name" : "Cajun/Creole", "code": "cajun"],
                          ["name" : "Cambodian", "code": "cambodian"],
                          ["name" : "Canadian", "code": "New)"],
                          ["name" : "Canteen", "code": "canteen"],
                          ["name" : "Caribbean", "code": "caribbean"],
                          ["name" : "Catalan", "code": "catalan"],
                          ["name" : "Chech", "code": "chech"],
                          ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                          ["name" : "Chicken Shop", "code": "chickenshop"],
                          ["name" : "Chicken Wings", "code": "chicken_wings"],
                          ["name" : "Chilean", "code": "chilean"],
                          ["name" : "Chinese", "code": "chinese"],
                          ["name" : "Comfort Food", "code": "comfortfood"],
                          ["name" : "Corsican", "code": "corsican"],
                          ["name" : "Creperies", "code": "creperies"],
                          ["name" : "Cuban", "code": "cuban"],
                          ["name" : "Curry Sausage", "code": "currysausage"],
                          ["name" : "Cypriot", "code": "cypriot"],
                          ["name" : "Czech", "code": "czech"],
                          ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                          ["name" : "Danish", "code": "danish"],
                          ["name" : "Delis", "code": "delis"],
                          ["name" : "Diners", "code": "diners"],
                          ["name" : "Dumplings", "code": "dumplings"],
                          ["name" : "Eastern European", "code": "eastern_european"],
                          ["name" : "Ethiopian", "code": "ethiopian"],
                          ["name" : "Fast Food", "code": "hotdogs"],
                          ["name" : "Filipino", "code": "filipino"],
                          ["name" : "Fish & Chips", "code": "fishnchips"],
                          ["name" : "Fondue", "code": "fondue"],
                          ["name" : "Food Court", "code": "food_court"],
                          ["name" : "Food Stands", "code": "foodstands"],
                          ["name" : "French", "code": "french"],
                          ["name" : "French Southwest", "code": "sud_ouest"],
                          ["name" : "Galician", "code": "galician"],
                          ["name" : "Gastropubs", "code": "gastropubs"],
                          ["name" : "Georgian", "code": "georgian"],
                          ["name" : "German", "code": "german"],
                          ["name" : "Giblets", "code": "giblets"],
                          ["name" : "Gluten-Free", "code": "gluten_free"],
                          ["name" : "Greek", "code": "greek"],
                          ["name" : "Halal", "code": "halal"],
                          ["name" : "Hawaiian", "code": "hawaiian"],
                          ["name" : "Heuriger", "code": "heuriger"],
                          ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                          ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                          ["name" : "Hot Dogs", "code": "hotdog"],
                          ["name" : "Hot Pot", "code": "hotpot"],
                          ["name" : "Hungarian", "code": "hungarian"],
                          ["name" : "Iberian", "code": "iberian"],
                          ["name" : "Indian", "code": "indpak"],
                          ["name" : "Indonesian", "code": "indonesian"],
                          ["name" : "International", "code": "international"],
                          ["name" : "Irish", "code": "irish"],
                          ["name" : "Island Pub", "code": "island_pub"],
                          ["name" : "Israeli", "code": "israeli"],
                          ["name" : "Italian", "code": "italian"],
                          ["name" : "Japanese", "code": "japanese"],
                          ["name" : "Jewish", "code": "jewish"],
                          ["name" : "Kebab", "code": "kebab"],
                          ["name" : "Korean", "code": "korean"],
                          ["name" : "Kosher", "code": "kosher"],
                          ["name" : "Kurdish", "code": "kurdish"],
                          ["name" : "Laos", "code": "laos"],
                          ["name" : "Laotian", "code": "laotian"],
                          ["name" : "Latin American", "code": "latin"],
                          ["name" : "Live/Raw Food", "code": "raw_food"],
                          ["name" : "Lyonnais", "code": "lyonnais"],
                          ["name" : "Malaysian", "code": "malaysian"],
                          ["name" : "Meatballs", "code": "meatballs"],
                          ["name" : "Mediterranean", "code": "mediterranean"],
                          ["name" : "Mexican", "code": "mexican"],
                          ["name" : "Middle Eastern", "code": "mideastern"],
                          ["name" : "Milk Bars", "code": "milkbars"],
                          ["name" : "Modern Australian", "code": "modern_australian"],
                          ["name" : "Modern European", "code": "modern_european"],
                          ["name" : "Mongolian", "code": "mongolian"],
                          ["name" : "Moroccan", "code": "moroccan"],
                          ["name" : "New Zealand", "code": "newzealand"],
                          ["name" : "Night Food", "code": "nightfood"],
                          ["name" : "Norcinerie", "code": "norcinerie"],
                          ["name" : "Open Sandwiches", "code": "opensandwiches"],
                          ["name" : "Oriental", "code": "oriental"],
                          ["name" : "Pakistani", "code": "pakistani"],
                          ["name" : "Parent Cafes", "code": "eltern_cafes"],
                          ["name" : "Parma", "code": "parma"],
                          ["name" : "Persian/Iranian", "code": "persian"],
                          ["name" : "Peruvian", "code": "peruvian"],
                          ["name" : "Pita", "code": "pita"],
                          ["name" : "Pizza", "code": "pizza"],
                          ["name" : "Polish", "code": "polish"],
                          ["name" : "Portuguese", "code": "portuguese"],
                          ["name" : "Potatoes", "code": "potatoes"],
                          ["name" : "Poutineries", "code": "poutineries"],
                          ["name" : "Pub Food", "code": "pubfood"],
                          ["name" : "Rice", "code": "riceshop"],
                          ["name" : "Romanian", "code": "romanian"],
                          ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                          ["name" : "Rumanian", "code": "rumanian"],
                          ["name" : "Russian", "code": "russian"],
                          ["name" : "Salad", "code": "salad"],
                          ["name" : "Sandwiches", "code": "sandwiches"],
                          ["name" : "Scandinavian", "code": "scandinavian"],
                          ["name" : "Scottish", "code": "scottish"],
                          ["name" : "Seafood", "code": "seafood"],
                          ["name" : "Serbo Croatian", "code": "serbocroatian"],
                          ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                          ["name" : "Singaporean", "code": "singaporean"],
                          ["name" : "Slovakian", "code": "slovakian"],
                          ["name" : "Soul Food", "code": "soulfood"],
                          ["name" : "Soup", "code": "soup"],
                          ["name" : "Southern", "code": "southern"],
                          ["name" : "Spanish", "code": "spanish"],
                          ["name" : "Steakhouses", "code": "steak"],
                          ["name" : "Sushi Bars", "code": "sushi"],
                          ["name" : "Swabian", "code": "swabian"],
                          ["name" : "Swedish", "code": "swedish"],
                          ["name" : "Swiss Food", "code": "swissfood"],
                          ["name" : "Tabernas", "code": "tabernas"],
                          ["name" : "Taiwanese", "code": "taiwanese"],
                          ["name" : "Tapas Bars", "code": "tapas"],
                          ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                          ["name" : "Tex-Mex", "code": "tex-mex"],
                          ["name" : "Thai", "code": "thai"],
                          ["name" : "Traditional Norwegian", "code": "norwegian"],
                          ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                          ["name" : "Trattorie", "code": "trattorie"],
                          ["name" : "Turkish", "code": "turkish"],
                          ["name" : "Ukrainian", "code": "ukrainian"],
                          ["name" : "Uzbek", "code": "uzbek"],
                          ["name" : "Vegan", "code": "vegan"],
                          ["name" : "Vegetarian", "code": "vegetarian"],
                          ["name" : "Venison", "code": "venison"],
                          ["name" : "Vietnamese", "code": "vietnamese"],
                          ["name" : "Wok", "code": "wok"],
                          ["name" : "Wraps", "code": "wraps"],
                          ["name" : "Yugoslav", "code": "yugoslav"]]
        
        return categories
    }

}
