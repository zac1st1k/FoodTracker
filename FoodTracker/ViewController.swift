//
//  ViewController.swift
//  FoodTracker
//
//  Created by Zac on 9/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    var suggestedSearchFoods:[String] = []
    var filteredSuggestedSearchFoods:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchController = UISearchController(searchResultsController: nil)

        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.frame = CGRectMake(searchController.searchBar.frame.origin.x
            , searchController.searchBar.frame.origin.y, searchController.searchBar.frame.size.height, 44.0)
        searchController.searchBar.scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
//        definesPresentationContext = true
        suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active {
            return filteredSuggestedSearchFoods.count
        }
        else {
            return suggestedSearchFoods.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        var foodName: String
        if searchController.active {
            foodName = filteredSuggestedSearchFoods[indexPath.row]
        }
        else {
            foodName = suggestedSearchFoods[indexPath.row]
        }
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        return cell
    }
    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    //MARK: - UISearchResultsUpdating

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        filterContentForSearch(searchController.searchBar.text, scope: selectedScopeButtonIndex)
        tableView.reloadData()
        
    }
    
    //MARK: - Helper
    
    func filterContentForSearch (searchText: String, scope: Int) {
        filteredSuggestedSearchFoods = suggestedSearchFoods.filter({ (food: String) -> Bool in
            var foodMatch = food.rangeOfString(searchText)
            return foodMatch != nil
        })
    }

}

