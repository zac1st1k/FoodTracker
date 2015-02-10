//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Zac on 9/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var textVIew: UITextView!
    var usdaItem:USDAItem?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete", name: kUSDAItemCompleted, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func usdaItemDidComplete(notification: NSNotification) {
        usdaItem = notification.object as? USDAItem
    }
    
    @IBAction func eatItTapped(sender: UIBarButtonItem) {
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
