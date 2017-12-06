//
//  RegisterViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/6/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import Foundation


class RegisterViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
