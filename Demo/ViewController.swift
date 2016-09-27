//
//  ViewController.swift
//  Demo
//
//  Created by GUANJIU ZHANG on 9/25/16.
//  Copyright © 2016 Conifer-Tech. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    /// Firebase reference super node
    var ref: FIRDatabaseReference!
    
    //MARK: - UI Variables
    
    /// Product name text field
    lazy var productNameField: UITextField = {
        let frame = CGRectMake(20.0, self.view.frame.height/6, self.view.frame.width - 40.0, 40.0)
        let field = UITextField(frame: frame)
        field.placeholder = "Product Name"
        field.delegate = self
        return field
    }()
    
    /// Dimension width text field
    lazy var dimensionWidthField: UITextField = {
        let frame = CGRectMake(20.0, self.productNameField.frame.maxY + 10.0, self.view.frame.width - 40.0, 40.0)
        let field = UITextField(frame: frame)
        field.placeholder = "Enter the width"
        field.delegate = self
        return field
    }()
    
    /// Dimension height text field
    lazy var dimensionLengthField: UITextField = {
        let frame = CGRectMake(20.0, self.dimensionWidthField.frame.maxY + 10.0, self.view.frame.width - 40.0, 40.0)
        let field = UITextField(frame: frame)
        field.placeholder = "Enter the height"
        field.delegate = self
        return field
    }()
    
    /// Submit button
    lazy var submitButton: UIButton = {
       let button = UIButton(type: .Custom)
        button.setTitle("Submit My Record to Database", forState: .Normal)
        button.frame = CGRectMake(20.0, self.dimensionLengthField.frame.maxY + 20.0, self.view.frame.width - 40.0, 40.0)
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        button.setTitleColor(UIColor.orangeColor(), forState: .Highlighted)
        button.layer.borderColor = UIColor.lightGrayColor().CGColor
        button.layer.cornerRadius = 8.0
        button.layer.borderWidth = 2.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.submit), forControlEvents: .TouchUpInside)
        return button
    }()
    
    
    //MARK: - View Controller Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        self.view.addSubview(self.productNameField)
        self.view.addSubview(self.dimensionWidthField)
        self.view.addSubview(self.dimensionLengthField)
        self.view.addSubview(self.submitButton)
    }
    
    /// Upload sample data to Firebase database
    func uploadSampleData(completion:(finished: Bool?, error: NSError?)->()){
        guard (self.productNameField.text != nil) && (self.dimensionWidthField.text != nil) && (self.dimensionLengthField.text != nil) else {
            let error = NSError(domain: "Demo.Main.Textfield", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Please fill out all fields to submit"
                ])
            completion(finished: false, error: error)
            return
        }
        
        if let _ = Double(self.dimensionWidthField.text!) {}
        else{
            let error = NSError(domain: "Demo.Main.Textfield", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Please only input number into width field"
                ])
            completion(finished: false, error: error)
            return
        }
        
        if let _ = Double(self.dimensionLengthField.text!) {}
        else{
            let error = NSError(domain: "Demo.Main.Textfield", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Please only input number into length field"
                ])
            completion(finished: false, error: error)
            return
        }
        
        let metaDataDictionary:[String: AnyObject] = [
            "width": Double(self.dimensionWidthField.text!)!,
            "length": Double(self.dimensionLengthField.text!)!,
            "units": "cm"
        ]
        let targetNode = self.ref.child("Products").childByAutoId()
        let aSampleProduct:[String: AnyObject] = [
            "image":targetNode.key,
            "name":self.productNameField.text!,
            "metaData":metaDataDictionary
        ]
        targetNode.setValue(aSampleProduct) { (error, ref) in
            // If there is any errors, alert view controller will pop up to show what error is
            guard error == nil else {
                // First way to pop up alert view
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "Got it!", style: .Cancel, handler: { (_) in
                    // Enter your later actions here
                })
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            // Second way to pop up alert view
            let alert = UIAlertView(title: "Success", message: "Sample data has been uploaded to Firebase!", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
    
    //MARK: UI Actions
    
    /// UI actions for submit button
    func submit(){
        self.uploadSampleData { (_, error) in
            guard error == nil else {
                // First way to pop up alert view
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "Got it!", style: .Cancel, handler: { (_) in
                    // Enter your later actions here
                })
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
        }
    }

}

extension ViewController: UITextFieldDelegate {
    
}

