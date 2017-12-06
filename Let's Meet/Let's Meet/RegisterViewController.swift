//
//  RegisterViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import Foundation
import Firebase


class RegisterViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // #cs50 Hide the keyboard
        textField.resignFirstResponder()
        
        if (textField.tag > 2)
        {
            // Scroll back up to show all the elements in the page
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // #cs50 When the user starts typing, scroll down the page using a scroll view, so that no textfield is covered by the keyboard.
        // If the selected text field is the password or the confirm password one (We tagged them from 1 to 4 in order), scroll down so that the text field is not hidden by the keyboard
        if (textField.tag > 2) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
        }
    }
    
    
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Cancel and unwind to login/register homepage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        // Ensure the name and email address fields are not empty
        if nameTextField.text == "" || emailTextField.text == "" {
            let alertController = UIAlertController(title: "Alert", message: "The name and email address fields cannot be empty", preferredStyle: .alert)
            
            let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                print("You've pressed OK");
            }
            
            alertController.addAction(OK_button)
            self.present(alertController, animated: true, completion: nil)
        }
        
        // Ensure the password is at least 6 characters long
        if (passwordTextField.text?.count)! < 6 {
            let alertController = UIAlertController(title: "Alert", message: "Password should be of 6 characters or more", preferredStyle: .alert)
            
            let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                print("You've pressed OK");
            }
            
            alertController.addAction(OK_button)
            self.present(alertController, animated: true, completion: nil)
        }
        
        // Ensure the two passwords match
        if (passwordTextField.text != confirmPasswordTextField.text) {
            let alertController = UIAlertController(title: "Alert", message: "Passwords do not match.", preferredStyle: .alert)
            
            let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                print("You've pressed OK");
            }
            
            alertController.addAction(OK_button)
            self.present(alertController, animated: true, completion: nil)
        }
        
        FIRAuth.auth()!.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {(user, error) in
            
            if error == nil
            {
                // add name and photo to user
                // Firebase login
                FIRAuth.auth()!.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) {(user, error) in
                    
                    // If the login is successfull
                    if (error == nil)
                    {
                        // Show groups page
                        self.performSegue(withIdentifier: "showGroupsTable", sender: nil)
                    }
                        // Login was not successfull
                    else {
                        // Show an alert message
                        let alertController = UIAlertController(title: "Alert", message: "The login was not successful. Make sure your email and password are correct.", preferredStyle: .alert)
                        let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            print("You've pressed OK");
                        }
                        alertController.addAction(OK_button)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                // go to groups
            }
            else {
                let alertController = UIAlertController(title: "Alert", message: error.debugDescription, preferredStyle: .alert)
                let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("You've pressed OK");
                }
                alertController.addAction(OK_button)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    
    @IBAction func loadImage(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as?
        
            UIImage {
                profilePhotoImageView.contentMode = .scaleAspectFit
                profilePhotoImageView.image = pickedImage
            }
        
            dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
