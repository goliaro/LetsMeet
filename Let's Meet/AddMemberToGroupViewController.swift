//
//  AddMemberToGroupViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/7/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import Firebase

class AddMemberToGroupViewController: UIViewController, UITextFieldDelegate {

    var group_key: String?
    var refUsers: FIRDatabaseReference!
    var refGroupMembers: FIRDatabaseReference!
    var refUserGroups: FIRDatabaseReference!
    var refHandle: UInt!
    
    
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
        
        self.refUsers = FIRDatabase.database().reference().child("users")
        refHandle = refUsers.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let current_email = dictionary["email"] as! String
                
                if current_email == self.EmailTextField.text
                {
                    
                    let user_id = dictionary["id"] as! String
                    
                    // Add the user to the group
                    self.refGroupMembers = FIRDatabase.database().reference().child("groups/\(self.group_key!)/members")
                    let member_key = self.self.refGroupMembers.childByAutoId().key
                    var member = ["id": user_id]
                    
                    self.refGroupMembers.child(member_key).setValue(member)
                    
                    // Add the group to the groups list of the user
                    self.refUserGroups = FIRDatabase.database().reference().child("users/\(user_id)/groups")
                    let group_key_user = self.refUserGroups.childByAutoId().key
                    var group2 = ["id": self.group_key]
                    
                    self.refUserGroups.child(group_key_user).setValue(group2)
                    
                    self.ResultTextField.text = "The user was added to the group"
                }
            }
            
        }, withCancel: nil)
        
        

        
    }
    
}
