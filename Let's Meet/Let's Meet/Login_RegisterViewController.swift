//
//  Login_RegisterViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import Firebase

class Login_RegisterViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
    }
    
    // MARK: Actions
    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        
        // Firebase login
        FIRAuth.auth()!.signIn(withEmail: EmailTextField.text!, password: PasswordTextField.text!) {(user, error) in
            
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
