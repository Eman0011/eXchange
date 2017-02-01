//
//  UserViewController.swift
//  eXchange
//
//  Created by Emanuel Castaneda on 5/3/16.
//  Copyright © 2016 Emanuel Castaneda. All rights reserved.
//

import UIKit
import RSKImageCropper
import Firebase

class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {

    @IBOutlet var eXchangeBanner: UIImageView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var clubLabel: UILabel!
    @IBOutlet var netIDlabel: UILabel!
    @IBOutlet var clubImageView: UIImageView!
    
    @IBOutlet var logOutButton: UIButton!
    @IBOutlet var changePicButton: UIButton!
    var dataBaseRoot = Firebase(url:"https://princeton-exchange.firebaseIO.com")
    var userNetID: String = ""
    
    override func viewDidLoad() {
        eXchangeBanner.image = UIImage(named:"exchange_banner")!
        self.navigationController?.isNavigationBarHidden = true
        
        
        changePicButton.layer.cornerRadius = 5
        changePicButton.backgroundColor = UIColor.black
        logOutButton.layer.cornerRadius = 5
        logOutButton.backgroundColor = UIColor.red
        
        let tbc = self.tabBarController as! eXchangeTabBarController
        self.userNetID = tbc.userNetID;
        nameLabel.text = tbc.currentUser.name
        clubLabel.text = "Club: \(tbc.currentUser.club)"
        netIDlabel.text = "NetID: \(tbc.userNetID)"
        clubImageView.image = UIImage(named: tbc.currentUser.club + ".png")
        if (tbc.currentUser.image != "") {
            let decodedData = Data(base64Encoded: tbc.currentUser.image, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            userImageView.image = UIImage(data: decodedData!)!
        } else {
            userImageView.image = UIImage(named: "princetonTiger.png")
        }
    }
    
    @IBAction func changeUserImage(_ sender: AnyObject) {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image : UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        picker.dismiss(animated: false, completion: { () -> Void in
            
            var imageCropVC : RSKImageCropViewController!
            
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            
            imageCropVC.delegate = self
            self.navigationController?.pushViewController(imageCropVC, animated: true)
        })
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        userImageView.image = croppedImage
        let imageData: Data = UIImageJPEGRepresentation(croppedImage, 0.3)!
        let imageString = imageData.base64EncodedString(options: .lineLength64Characters)
        let studentsRoot = dataBaseRoot?.child(byAppendingPath: "students")
        let student = studentsRoot?.child(byAppendingPath: userNetID)
        let imageFolder = ["image" : imageString]
        student?.updateChildValues(imageFolder)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginView = mainStoryboard.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginView

//        UIApplication.sharedApplication().keyWindow?.rootViewController = loginView

        
//        self.performSegueWithIdentifier("login", sender: sender)
    }
}
