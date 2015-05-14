//
//  SignUpTableViewController.swift
//  LetsChat
//
//  Created by Zhehan Zhang on 2015-05-13.
//  Copyright (c) 2015 training. All rights reserved.
//

import UIKit

class SignUpTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    var change = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        
        if change {
            doneBarButtonItem.action = "changeProfile"
            
            usernameTextField.text = PFUser.currentUser().username
            emailTextField.text = PFUser.currentUser().email
            firstnameTextField.text = PFUser.currentUser()["firstName"] as! String
            lastnameTextField.text = PFUser.currentUser()["lastName"] as! String
            
            passwordTextField.enabled = false;
            repeatPasswordTextField.enabled = false;
            
            let profileImageFile = PFUser.currentUser()["profileImage"] as! PFFile
            profileImageFile.getDataInBackgroundWithBlock({ (data: NSData!, error: NSError!) -> Void in
                if error == nil {
                    self.profileImageView.image = UIImage(data: data)
                }
            })
        }
    }

    @IBAction func addProfileImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Choose Your Image Source", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camara Roll", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageSize = image.size
        let width = imageSize.width
        let height = imageSize.height
        
        if width != height {
            let newDimensions = min(width, height)
            let widthOffset = (width - newDimensions) / 2
            let heightOffset = (height - newDimensions) / 2
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimensions, newDimensions), false, 0.0)
            image.drawAtPoint(CGPointMake(-widthOffset, -heightOffset), blendMode: kCGBlendModeCopy, alpha: 1.0)
            image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContext(CGSizeMake(150, 150))
        let context = UIGraphicsGetCurrentContext()
        image.drawInRect(CGRectMake(0, 0, 150, 150))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        
        profileImageView.image = smallImage
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func completeSignUp(sender: AnyObject) {
        let profileImageData = UIImageJPEGRepresentation(self.profileImageView.image, 0.6)
        let profileImageFile = PFFile(data: profileImageData)
        
        if usernameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != "" && firstnameTextField.text != "" && lastnameTextField.text != "" {
            var user = PFUser()
            user.username = usernameTextField.text
            user.email = emailTextField.text
            if passwordTextField.text == repeatPasswordTextField.text {
                user.password = passwordTextField.text
            }else {
                let alert = UIAlertController(title: "Check Your Password", message: "Your entered passwords are not same", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            user["firstName"] = firstnameTextField.text
            user["lastName"] = lastnameTextField.text
            user["profileImage"] = profileImageFile
            
            user.signUpInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                if error == nil {
                    let installation = PFInstallation.currentInstallation()
                    installation["user"] = user
                    installation.saveInBackgroundWithBlock(nil)
                    
                    self.showChatOverview()
                }
            })
        }else {
            let alert = UIAlertController(title: "Missing Information", message: "Please fill out all items", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func changeProfile() {
        let profileImageData = UIImageJPEGRepresentation(self.profileImageView.image, 0.6)
        let profileImageFile = PFFile(data: profileImageData)
        
        if usernameTextField.text != "" && emailTextField.text != "" && firstnameTextField.text != "" && lastnameTextField.text != "" {
            var user = PFUser.currentUser()
            user.username = usernameTextField.text
            user.email = emailTextField.text
            
            user["firstName"] = firstnameTextField.text
            user["lastName"] = lastnameTextField.text
            user["profileImage"] = profileImageFile
            
            user.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                if error == nil {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }else {
            let alert = UIAlertController(title: "Missing Information", message: "Please fill out all items", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func showChatOverview() {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let overviewVC = sb.instantiateViewControllerWithIdentifier("ChatOverviewVC") as! OverviewTableViewController
        overviewVC.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.pushViewController(overviewVC, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
