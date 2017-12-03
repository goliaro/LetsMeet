//
//  GroupViewController.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 12/3/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var descriptionTextField: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    /*
     This value should be passed by 'GroupTableViewController' in 'prepare(for:sender:)'
     */
    var group: Group?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // Set up the views with the info of the group currently selected
        if let group = group {
            titleTextField.text = group.name
            descriptionTextField.text = group.description
            photoImageView.image = group.photo
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
