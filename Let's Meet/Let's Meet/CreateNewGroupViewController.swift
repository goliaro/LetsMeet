//
//  CreateNewGroupViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import Firebase

class CreateNewGroupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var newGroupNameField: UITextField!
    @IBOutlet weak var newGroupDescriptionField: UITextField!
    @IBOutlet weak var newGroupProfilePhotoImageView: UIImageView!
    
    var refGroups: FIRDatabaseReference!
    let imagePicker = UIImagePickerController()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Done(_ sender: UIBarButtonItem) {
        
        // Ensure the name and email address fields are not empty
        if newGroupNameField.text == "" {
            let alertController = UIAlertController(title: "Alert", message: "The name of the group cannot be left blank", preferredStyle: .alert)
            
            let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                print("You've pressed OK");
            }
            
            alertController.addAction(OK_button)
            self.present(alertController, animated: true, completion: nil)
        }
        
        else {
            
            // Save the new group into firebase
            self.refGroups = FIRDatabase.database().reference().child("groups")
            
            let user = FIRAuth.auth()!.currentUser
            let userID = user?.uid
            
            let group_key = refGroups.childByAutoId().key
            let group = ["id": group_key, "name": newGroupNameField.text as! String, "description": newGroupDescriptionField.text as! String, "owner": userID]
            
            self.refGroups.child(group_key).setValue(group)
            
            //Upload the profile picture into Firebase
            // Saves the profile pictures in Firebase storage, in the folder groups_profile_pictures, with the group UID as the name
            let storageRef = FIRStorage.storage().reference().child("groups_profile_pictures/" + group_key + ".png")
            if let uploadData = UIImagePNGRepresentation(newGroupProfilePhotoImageView.image!) {
                storageRef.put(uploadData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        print("error")
                        
                        // Show an alert message
                        let alertController = UIAlertController(title: "Alert", message: "Could not upload the profile photo.", preferredStyle: .alert)
                        let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            print("You've pressed OK");
                        }
                        alertController.addAction(OK_button)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        
                    }
                }
            }
            
            
            // Ask the user if he or she wants to start adding members to the group immediately
            let alertController = UIAlertController(title: "New Group Created!", message: "Do you want to start adding members now?", preferredStyle: .actionSheet)
            
            let Yes = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
                self.performSegue(withIdentifier: "addMember", sender: self)
                print("You've pressed Yes button");
            }
            
            let No = UIAlertAction(title: "No", style: .destructive) { (action:UIAlertAction) in
                print("You've pressed No button");
                self.dismiss(animated: true, completion: nil)
            }
            
            
            alertController.addAction(Yes)
            alertController.addAction(No)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func pickProfilePhotoFromLibrary(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: ImagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as?
            
            UIImage {
            newGroupProfilePhotoImageView.contentMode = .scaleAspectFit
            newGroupProfilePhotoImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
}
