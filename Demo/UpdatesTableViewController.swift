//
//  UpdatesTableViewController.swift
//  Demo
//
//  Created by GUANJIU ZHANG on 9/26/16.
//

import Foundation
import UIKit
import Firebase
import MBSimpleLoadingIndicator

class UpdatesTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var loadingIndicatorMaskView: UIView!
    var loadingIndicator: MBLoadingIndicator!
    var updates: [String] = []
    
    //MARK: - UI Variables
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        self.ref = FIRDatabase.database().reference()
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadingIndicatorMaskView = UIView(frame: CGRectMake(30.0, 100.0, self.view.frame.width - 60.0, self.view.frame.height - 300.0))
        self.loadingIndicatorMaskView.layer.cornerRadius = 10.0
        self.loadingIndicatorMaskView.layer.masksToBounds = true
        self.loadingIndicatorMaskView.backgroundColor = UIColor.lightGrayColor()
        self.loadingIndicatorMaskView.alpha = 0.7
        self.view.addSubview(self.loadingIndicatorMaskView)
        
        self.loadingIndicator = MBLoadingIndicator(frame: self.loadingIndicatorMaskView.frame)
        self.view.addSubview(self.loadingIndicator)
        self.loadingIndicator.start()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Demo App Daily Updates Log"
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(self.goBack))
//        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: #selector(self.submit))
        self.retrieveData { (updates, error) in
            guard error == nil else{
                return
            }
            self.updates = updates!
            // Since updating table view is not thread safe
            dispatch_async(dispatch_get_main_queue(), {
                // Update table view as long as updates have been retrieved from server
                self.tableView.reloadData()
                self.loadingIndicator.finish()
                // Fade out mask view
                UIView.animateWithDuration(0.3, animations: {
                    self.loadingIndicatorMaskView.alpha = 0.0
                })
            })
        }
    }
    
    //MARK: - Data Manager
    func retrieveData(completion:(updates: [String]?, error: NSError?)->()){
        self.ref.child("Updates").queryOrderedByChild("notes").observeEventType(.Value, withBlock: { (snapshot) in
            var updates:[String] = []
            print("snapshot: \(snapshot.value)")
            for eachChild in snapshot.children {
                print("eachChild:\(eachChild)")
                if let eachChildDictSnapshot = eachChild as? FIRDataSnapshot {
                    if let eachNoteDict = eachChildDictSnapshot.value as? [String: String] {
                        print("eachNoteDict:\(eachNoteDict)")
                        if let eachNote = eachNoteDict["notes"] {
                            updates.append(eachNote)
                        }
                    }
                }
                
            }
            completion(updates: updates, error: nil)
            
            }, withCancelBlock: nil)
    }
    
    //MARK: UI Actions
    
    func goBack(){
        // Go back to main view controller
        self.performSegueWithIdentifier("unwindToPrevious", sender: self)
    }
    
    
//    func submit(){
//        let dict: [String: AnyObject] = [
//            "notes":"2.(9/27/2016 - Guanjiu) Continue updating, added: \r\n - unwind segue demo \r\n - database & UI integration demo \r\n - Customized table view cell demo"
//        ]
//        self.ref.child("Updates").childByAutoId().setValue(dict)
//    }
    
    //MARK: - Table view delegates
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.updates.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 280.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellToAdd = tableView.dequeueReusableCellWithIdentifier("UpdatesTableViewCell") as! UpdatesTableViewCell
        cellToAdd.updateContentTextView.text = self.updates[indexPath.row]
        return cellToAdd
    }
}