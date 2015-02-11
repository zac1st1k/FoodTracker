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
        
        //add : in selector!
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if usdaItem != nil {
            textVIew.attributedText = createAttreibutedString(usdaItem)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        if isViewLoaded() && view.window != nil {
            textVIew.attributedText = createAttreibutedString(usdaItem!)
        }
        println("usdaItemDIdComplete in DetailViewController")
    }
    
    func createAttreibutedString (usdaItem: USDAItem!) -> NSAttributedString {
        var itemAttributedString = NSMutableAttributedString()
        var centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = NSTextAlignment.Center
        centeredParagraphStyle.lineSpacing = 10.0
        var titleAttributesDictionary = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(22.0),
            NSParagraphStyleAttributeName: centeredParagraphStyle
        ]
        let titleString = NSAttributedString(string: "\(usdaItem.name)\n", attributes: titleAttributesDictionary)
        itemAttributedString.appendAttributedString(titleString)
        
        return itemAttributedString
    }
    // MARK: - IBAction
    @IBAction func eatItTapped(sender: UIBarButtonItem) {
    }


}
