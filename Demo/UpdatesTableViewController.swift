//
//  UpdatesTableViewController.swift
//  Demo
//
//  Created by GUANJIU ZHANG on 9/26/16.
//

import Foundation
import UIKit

class UpdatesTableViewController: UITableViewController {
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        self.title = "Demo App Daily Updates Log"
    }
    
    //MARK: - Table view delegates
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 500.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellToAdd = tableView.dequeueReusableCellWithIdentifier("UpdatesTableViewCell") as! UpdatesTableViewCell
        cellToAdd.updateContentTextView.text = "1.(9/26/2016 - Guanjiu) Set up basic environment, added: \r\n - textfields & textfields validation demo \r\n - database construction demo \r\n - asynchronous callback (completion block) demo \r\n - Table view basic demo \r\n - Cocoapods dependencies installation demo \r\n - Present/Dismiss View Controller demo"
        return cellToAdd
    }
}