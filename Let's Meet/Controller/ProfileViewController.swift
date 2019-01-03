//
//  ProfileViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import Firebase
import Foundation



class ProfileViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Reference to an image file in Firebase Storage
        
        let user = FIRAuth.auth()!.currentUser
        
        let string = "users_profile_pictures/" + (user?.uid)! + ".png"
        let reference = FIRStorage.storage().reference(withPath: string)
        
        // UIImageView in your ViewController
        let imageView: UIImageView = self.profilePictureImageView
        
        // Placeholder image
        let placeholderImage = UIImage(named: "defaultPhoto.jpg")
        
        
        
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        
        reference.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let myImage: UIImage! = UIImage(data: data!)
                self.profilePictureImageView.image = myImage
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
