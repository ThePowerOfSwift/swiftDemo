//
//  ViewController.swift
//  Demo
//
//  Created by GUANJIU ZHANG on 9/25/16.
//  

import UIKit
import Firebase
import ALCameraViewController
import DriftAnimationImageView

class MainViewController: UIViewController {
    
    /// Firebase reference super node
    var ref: FIRDatabaseReference!
    
    //MARK: - UI Variables
    
    /// Animating background view
    lazy var animatingBackgroundView: DriftAnimationImageView = {
        let imageView = DriftAnimationImageView(frame: self.view.frame)
        imageView.image = UIImage(named: "mhacks6")
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    /// Product picture image view
    lazy var productPictureImageView: UIImageView = {
        let frame = CGRectMake(0.0, (self.navigationController?.navigationBar.frame.maxY)! + 20.0, self.view.frame.width/4, self.view.frame.width/4)
        let imageView = UIImageView(frame: frame)
        imageView.backgroundColor = UIColor.lightGrayColor()
        imageView.image = UIImage(named: "logo-m")
        imageView.contentMode = .ScaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.triggerCameraViewController))
        imageView.addGestureRecognizer(tapGesture)
        imageView.userInteractionEnabled = true
        return imageView
    }()
    
    /// Product name text field
    lazy var productNameField: UITextField = {
        let frame = CGRectMake(20.0, self.view.frame.height/3, self.view.frame.width - 40.0, 40.0)
        let field = UITextField(frame: frame)
        field.placeholder = "Product Name"
        field.borderStyle = .RoundedRect
        field.delegate = self
        return field
    }()
    
    /// Dimension width text field
    lazy var dimensionWidthField: UITextField = {
        let frame = CGRectMake(20.0, self.productNameField.frame.maxY + 10.0, self.view.frame.width - 40.0, 40.0)
        let field = UITextField(frame: frame)
        field.placeholder = "Enter the width"
        field.borderStyle = .RoundedRect
        field.delegate = self
        return field
    }()
    
    /// Dimension height text field
    lazy var dimensionLengthField: UITextField = {
        let frame = CGRectMake(20.0, self.dimensionWidthField.frame.maxY + 10.0, self.view.frame.width - 40.0, 40.0)
        let field = UITextField(frame: frame)
        field.placeholder = "Enter the height"
        field.borderStyle = .RoundedRect
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
    
    
    var cameraViewController:CameraViewController!
    
    //MARK: - Super Class Variables Override
    
    //MARK: - View Controller Life Cycles
    
    override func viewWillAppear(animated: Bool) {
        self.view.addSubview(self.animatingBackgroundView)
        self.view.sendSubviewToBack(self.animatingBackgroundView)
        self.animatingBackgroundView.beginDriftAnimations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configNavigationItem()
        self.ref = FIRDatabase.database().reference()
        self.view.addSubview(self.productPictureImageView)
        self.productPictureImageView.center.x = self.view.center.x
        self.view.addSubview(self.productNameField)
        self.view.addSubview(self.dimensionWidthField)
        self.view.addSubview(self.dimensionLengthField)
        self.view.addSubview(self.submitButton)
        self.cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true, completion: { [weak self] (image, asset) in
            guard image != nil else {
                self?.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            // Recommend to update product profile picture on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                self?.productPictureImageView.image = image
                self?.dismissViewControllerAnimated(true, completion: nil)
            })
            
        })
    }
    
    //MARK: - UI Elements
    
    /// Config navigation item in this view controller
    func configNavigationItem(){
        self.title = "Swift Demo"
        let updateLogButton = UIBarButtonItem(title: "Updates", style: .Plain, target: self, action: #selector(self.triggerUpdatesViewController))
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItem(updateLogButton, animated: true)
    }
    
    //MARK: - Database Data Upload and Retrieval
    
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
    
    /// UI actions to trigger table view controller to show daily update for this demo
    func triggerUpdatesViewController(){
        let tableViewToPresent = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UpdatesTableVC") as! UpdatesTableViewController
        self.navigationController?.pushViewController(tableViewToPresent, animated: true)
    }
    
    /// UI actions to pop up camera view controller
    func triggerCameraViewController(){
        self.presentViewController(self.cameraViewController, animated: true, completion: nil)
    }

}

extension MainViewController: UITextFieldDelegate {
    
}

