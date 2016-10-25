//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    var businesses: [Business]!
    var searchedBusinesses: [Business]!
    var searchBar: UISearchBar!
    var isOnSearched: Bool!
    var isMoreDataLoading: Bool!
    var loadingMoreView:InfiniteScrollActivityView?
    var reloadDataCount: Int!
    var previousFilters: [String : AnyObject]!
    var previousSearchedText:String!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Resutarurants"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        isOnSearched = false
        isMoreDataLoading = false
        reloadDataCount = 0
        previousSearchedText = String("")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        //loading
        let frame = CGRect(x:0, y:tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        Business.searchWithTerm(term: "Thai", reloadCount: reloadDataCount, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // TODO: remove keybaord when tap outside
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//    
//
//    @IBAction func tapScreen(_ sender: AnyObject) {
//        self.view.endEditing(true)
//    }
//    func textFieldShouldReturn(textField: UITextField!) -> Bool{
//        textField.resignFirstResponder()
//        
//        return true
//    }

    
    
    
    // TableView related ---
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        if isOnSearched == true {
            cell.cellId = indexPath.row + 1
            cell.business = searchedBusinesses[indexPath.row]
        }
        else {
            cell.cellId = indexPath.row + 1
            cell.business = businesses[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOnSearched == true {
            if searchedBusinesses != nil {
                return searchedBusinesses.count
            }
            else {
                return 0
            }
        }
        else {
            if businesses != nil {
                return businesses.count
            }
            else {
                return 0
            }
        }
    }
    
    // SearchBar related ---
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            self.searchBar.endEditing(true)
            
            searchedBusinesses = []
            isOnSearched = false
            previousSearchedText = ""
            self.tableView.reloadData()
        }
        else{
            isOnSearched = true
            previousSearchedText = searchText
            prepareSerachedData(searchText: searchText)
        }
    }
    
    func prepareSerachedData(searchText: String) {
        searchedBusinesses = []
        for business in businesses! {
            let restaurantName = business.name
            if (restaurantName?.lowercased().contains(searchText.lowercased()))! {
                searchedBusinesses?.append(business)
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        searchedBusinesses = []
        isOnSearched = false
        tableView.reloadData()
    }
    
    
    // TableView related ---
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x:0, y:tableView.contentSize.height, width: tableView.bounds.size.width, height:InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        reloadDataCount! += 1
        
        if previousFilters != nil {
            let sortBy = YelpSortMode(rawValue:(previousFilters["sortBy"] as! Int))
            let categories = previousFilters["categories"] as? [String]
            let deals = previousFilters["deal"] as? Bool
            let distance = previousFilters["distance"] as? Double
            
            Business.searchWithTerm(term: "Thai", sort: sortBy, categories: categories, deals: deals, distance:distance, reloadCount: 0, completion: { (businesses: [Business]?, error: Error?) -> Void in
                
                if self.reloadDataCount > 0 { // reload case
                    self.businesses = self.businesses + businesses!
                    if self.isOnSearched == true {
                        self.prepareSerachedData(searchText: self.previousSearchedText)
                    }
                   
                    self.tableView.reloadData()
                }
                else {
                    self.businesses = businesses
                    if self.isOnSearched == true {
                        self.prepareSerachedData(searchText: self.previousSearchedText)
                    }

                    self.tableView.reloadData()
                }
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()
            })
        }
        else {
            Business.searchWithTerm(term: "Thai", reloadCount: reloadDataCount, completion: { (businesses: [Business]?, error: Error?) -> Void in
                if self.reloadDataCount > 0 { // reload case
                    self.businesses = self.businesses + businesses!
                    if self.isOnSearched == true {
                        self.prepareSerachedData(searchText: self.previousSearchedText)
                    }
                    
                    self.tableView.reloadData()
                }
                else {
                    self.businesses = businesses
                    if self.isOnSearched == true {
                        self.prepareSerachedData(searchText: self.previousSearchedText)
                    }
                    
                    self.tableView.reloadData()
                }
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()
            })
        }
    }

     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.searchBar.endEditing(true)
        
        if segue.identifier == "toFilters" {
            let navigationController = segue.destination as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            
            filtersViewController.delegate = self
        }
        else if segue.identifier == "toDetails" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            
            var business = businesses[(indexPath?.row)!]
            if self.isOnSearched == true {
                business = searchedBusinesses![indexPath!.row]
            }
    
            let navigationController = segue.destination as! UINavigationController
            let detailsViewController = navigationController.topViewController as! DetailsViewController
            detailsViewController.business = business
        }
     }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        reloadDataCount = 0 // new serach filters - so need to reset reloadDataCount
        previousFilters = filters
       
        let sortBy = YelpSortMode(rawValue:(filters["sortBy"] as! Int))
        let categories = filters["categories"] as? [String]
        let deals = filters["deal"] as? Bool
        let distance = filters["distance"] as? Double
        
        Business.searchWithTerm(term: "Restaurants", sort: sortBy, categories: categories, deals: deals, distance:distance, reloadCount: 0, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
}
