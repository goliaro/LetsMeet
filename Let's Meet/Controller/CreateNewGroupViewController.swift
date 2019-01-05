//
//  CreateNewGroupViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit
import os.log

class CreateNewGroupViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var newGroupNameField: UITextField!
    @IBOutlet weak var newGroupDescriptionField: UITextField!
    @IBOutlet weak var newGroupProfilePhotoImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var group_key: String?

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "addMember":
            os_log("Adding new members", log: OSLog.default, type: .debug)
            
            guard let navVC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination view controller \(segue.destination)")
            }
            
            guard let AddMemberToGroupViewController = navVC.viewControllers.first as? AddMemberToGroupViewController else {
                fatalError("Unexpected destination: \(navVC.viewControllers.first)")
                
            }
            
            AddMemberToGroupViewController.group_key = self.group_key
            

            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
            
    }
    
    
    
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
