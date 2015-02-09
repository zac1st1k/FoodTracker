//
//  DataContoller.swift
//  FoodTracker
//
//  Created by Zac on 9/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    class func jsonAsUSDAIdAndNameSearchResults (json: NSDictionary) -> [(name: String, idValue: String)] {
        var usdaItemsSearchResults:[(name: String, idValue: String)] = []
        var searchResult: (name: String, idValue: String)
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as [AnyObject]
            for itemDcitionary in results {
                if itemDcitionary["_id"] != nil {
                    if itemDcitionary["fields"] != nil {
                        let fieldsDictionary = itemDcitionary["fields"] as NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                            let idValue:String = itemDcitionary["_id"] as String
                            let name:String = fieldsDictionary["item_name"]! as String
                            searchResult = (name: name, idValue: idValue)
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
            }
        }
        return usdaItemsSearchResults
    }
    
}
