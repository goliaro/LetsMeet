//
//  LoginViewController.swift
//  Let's Meet
//
//  Created by Gracia-Zhang, Alejandro on 12/5/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//
/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Constants
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!, password: textFieldLoginPassword.text!) { (user, error) in
            
            if error == nil
            {
                self.performSegue(withIdentifier: "LoginToGroups", sender: nil)
            }
            else {
                let alertController = UIAlertController(title: "Alert", message: "Invalid email or password", preferredStyle: .alert)
                let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                print("You've pressed OK");
                }
                alertController.addAction(OK_button)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        //UIAlertController allows the user to sign up for an account
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
            
           //get user's email and password from UIAlertController textFields array that is stored in the alert constant
           let emailField = alert.textFields![0]
           let passwordField = alert.textFields![1]
        
           // create user with Firebase Auth with email and password
          FIRAuth.auth()!.createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
               //If there are no errors, sign in to authenticate the user with Firebase
               if error == nil
               {
                    FIRAuth.auth()!.signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                        if error == nil
                        {
                            self.performSegue(withIdentifier: "LoginToGroups", sender: nil)
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
               else
               {
                let alertController = UIAlertController(title: "Alert", message: error.debugDescription, preferredStyle: .alert)
                let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("You've pressed OK");
                }
                alertController.addAction(OK_button)
                self.present(alertController, animated: true, completion: nil)
                }
        }
        
        }
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

//If user is writing the email for loggin in, the onscreen keyboad appears for writing the email.  If the user is writing the password, the same happens for the password
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
