//
//  ViewController.swift
//  FoodTracker
//
//  Created by Zac on 9/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    let kAppId = "1e4a3403"
    let kAppKey = "26c3738674e4844f10eec95c6608b5d0"

    var searchController: UISearchController!
    var suggestedSearchFoods: [String] = []
    var filteredSuggestedSearchFoods: [String] = []
    var jsonResponse: NSDictionary!
    var apiSearchForFoods: [(name: String, idValue: String)] = []
    var dataController = DataController()
    var favouriteUSDAItems:[USDAItem] = []
    var filteredFavoritedUSDAItems:[USDAItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchController = UISearchController(searchResultsController: nil)

        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.frame = CGRectMake(searchController.searchBar.frame.origin.x
            , searchController.searchBar.frame.origin.y, searchController.searchBar.frame.size.height, 44.0)
        searchController.searchBar.scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        // Hide searchController when segue to detail controller
        definesPresentationContext = true
        suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
        
        //add : in selector!
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailVCSegue" {
            if sender != nil {
                var DetailVC = segue.destinationViewController as DetailViewController
                DetailVC.usdaItem = sender as? USDAItem
            }
            if sender == nil {
                var DetailVC = segue.destinationViewController as DetailViewController
                DetailVC.usdaItem = sender as? USDAItem
            }
        }
    }
    
    //MARK: - NSNotificationCenter
    func usdaItemDidComplete(notification: NSNotification) {
        println("usdaItemDidComplete in ViewController")
        requestFavouriteUSDAItems()
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 2 {
            tableView.reloadData()
        }
    }
    
    //MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {
                return filteredSuggestedSearchFoods.count
            }
            else {
                return suggestedSearchFoods.count
            }
        }
        else if selectedScopeButtonIndex == 1 {
            return apiSearchForFoods.count
        }
        else {
            if self.searchController.active {
                return filteredFavoritedUSDAItems.count
            }
            else {
                return favouriteUSDAItems.count
            }
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        var foodName: String
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if searchController.active {
                foodName = filteredSuggestedSearchFoods[indexPath.row]
            }
            else {
                foodName = suggestedSearchFoods[indexPath.row]
            }
        }
        else if selectedScopeButtonIndex == 1 {
                cell.accessoryType = UITableViewCellAccessoryType.DetailButton
                foodName = apiSearchForFoods[indexPath.row].name
        }
        else {
            if self.searchController.active {
                cell.accessoryType = UITableViewCellAccessoryType.DetailButton
                foodName = filteredFavoritedUSDAItems[indexPath.row].name
            }
            else {
                foodName = favouriteUSDAItems[indexPath.row].name
            }
        }
        
        cell.textLabel?.text = foodName
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        activityIndicator.startAnimating()
        tableView.userInteractionEnabled = false
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            var searchFoodName: String
            if searchController.active {
                searchFoodName = filteredSuggestedSearchFoods[indexPath.row]
            }
            else {
                searchFoodName = suggestedSearchFoods[indexPath.row]
            }
            searchController.searchBar.selectedScopeButtonIndex = 1
            makeRequest(searchFoodName)
        }
        else if selectedScopeButtonIndex == 1 {
            activityIndicator.stopAnimating()
            tableView.userInteractionEnabled = true
            let idValue = apiSearchForFoods[indexPath.row].idValue
            self.performSegueWithIdentifier("toDetailVCSegue", sender: nil)
            dataController.saveUSDAItemForId(idValue, jsonDic: jsonResponse)
        }
        else if selectedScopeButtonIndex == 2 {
            activityIndicator.stopAnimating()
            tableView.userInteractionEnabled = true
            if searchController.active {
                let usdaItem = filteredFavoritedUSDAItems[indexPath.row]
                performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
                println("active")
            }
            else {
                let usdaItem = favouriteUSDAItems[indexPath.row]
                performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
                println("NotActive")

            }
        }
    }

    //MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        
        filterContentForSearch(searchController.searchBar.text, scope: selectedScopeButtonIndex)
        searchController.searchBar.prompt = "Please input the food name"
        tableView.reloadData()
    }
    
    //MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        activityIndicator.startAnimating()
        searchBar.selectedScopeButtonIndex = 1
        makeRequest(searchBar.text)
    }
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 2 {
            requestFavouriteUSDAItems()
            filteredFavoritedUSDAItems = favouriteUSDAItems
        }
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchController.searchBar.prompt = nil
        tableView.reloadData()
        activityIndicator.stopAnimating()
        println("CancelButtonClicked")
    }
    
    //MARK: - Helper
    func filterContentForSearch (searchText: String, scope: Int) {
        if searchText == "" {
            filteredSuggestedSearchFoods = suggestedSearchFoods
        }
        else
        if scope == 0 {
            filteredSuggestedSearchFoods = suggestedSearchFoods.filter({ (food: String) -> Bool in
                var foodMatch = food.uppercaseString.rangeOfString(searchText.uppercaseString)
                return foodMatch != nil
            })
        }
        else if scope == 2 {
            filteredFavoritedUSDAItems = favouriteUSDAItems.filter({ (item: USDAItem) -> Bool in
                var stringMatch = item.name.uppercaseString.rangeOfString(searchText.uppercaseString)
                return stringMatch != nil
            })
        }
    }
    func makeRequest(searchString: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "appId" : kAppId,
            "appKey" : kAppKey,
            "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit"  : "50",
            "query"  : searchString,
            "filters": ["exists":["usda_fields": true]]
        ]
        var error:NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(stringData)
            var conversionError:NSError?
            var jsonDic = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
//            println(jsonDic)
            if conversionError != nil {
                println(conversionError!.localizedDescription)
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in Parsing\(errorString)")
            }
            else {
                if jsonDic == nil {
                    let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error Could not Parse Json")
                }
                else {
                    self.jsonResponse = jsonDic
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDic!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.tableView.userInteractionEnabled = true
                    })
                }
            }
        })
        task.resume()
        
        /*How to make a http GET Request
        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(stringData)
            println(response)
        })
        task.resume()
        */
    }
    
    //MARK: - Setup CoreData
    func requestFavouriteUSDAItems() {
        let fetchRequest = NSFetchRequest(entityName: "USDAItem")
//        fetchRequest.returnsDistinctResults == true
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        var error:NSError?
        favouriteUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as [USDAItem]
    }
}

