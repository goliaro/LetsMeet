//
//  AddMemberToGroupViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/7/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit

class AddMemberToGroupViewController: UIViewController, UITextFieldDelegate {

    var group_key: String?
    
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var ResultTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func lookupAndAdd(_ sender: UIButton) {
       
        

        
    }
    
}
