//
//  AddActivityViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import os.log

class AddActivityViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var activityNamePicker: UIPickerView!
    @IBOutlet weak var activityNameLabel: UITextField!
    @IBOutlet weak var activityDescriptionLabel: UITextField!
    @IBOutlet weak var activityLocationLabel: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var recent_activities: [String]?
    var group_name: String?



    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Handle the text field's user input through delegate callbacks.
        activityNameLabel.delegate = self
        activityDescriptionLabel.delegate = self
        activityLocationLabel.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // #cs50 When the user starts typing, scroll down the page using a scroll view, so that no textfield is covered by the keyboard.
        scrollView.setContentOffset(CGPoint(x: 0, y: 175), animated: true)
    }
    
    
    //MARK: Picker Delegate and Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recent_activities!.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == recent_activities!.count
        {
            return "New activity..."
        }
        else
        {
            return recent_activities![row]
        }
        
    }

    
    // MARK: - Navigation

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        
        //#cs50 There is actually only one segue, so the code would work evern without the switch, but it's safer to include it in case a new segue is added in the future.
        switch(segue.identifier ?? "") {
            
        case "goto_part2":
            
            // #cs50 If the selected row in the picker view shows "New activity..." and the Name text field is empty, the user is not providing any valid name for the activity, so we need to fire an alert message.
            if ((activityNamePicker.selectedRow(inComponent: 0) == recent_activities!.count) && activityNameLabel.text == "")
            {
                let alertController = UIAlertController(title: "Alert", message: "The name of the activity is missing!", preferredStyle: .alert)
                
                let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("You've pressed OK");
                }
                
                alertController.addAction(OK_button)
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            // #cs50 If the selected row in the picker view does not show "New activity..." and the Name text field is not empty, the user is providing two names for the same activity, which of course cannot be allowed
            if ((activityNamePicker.selectedRow(inComponent: 0) < recent_activities!.count) && activityNameLabel.text != "")
            {
                let alertController = UIAlertController(title: "Alert", message: "You specified two different names for the same activity", preferredStyle: .alert)
                let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("You've pressed OK");
                }
                
                alertController.addAction(OK_button)
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            guard let AddActivityViewController2 = segue.destination as? AddActivityViewController2 else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            
            // If the chosen row is "New Activity..." save the name typed into the text field, instead of the string in the selected row in the UIPickerView
            if (activityNamePicker.selectedRow(inComponent: 0) == recent_activities!.count) {
                AddActivityViewController2.activityName = activityNameLabel.text
            }
            // Otherwise save the name of the activity in the selected row in the pickerView
            else {
                // Pass the name of the activity in the datasource in the same row as the PickerView
                AddActivityViewController2.activityName = recent_activities![activityNamePicker.selectedRow(inComponent: 0)]
            }
            
            AddActivityViewController2.activityDescription = activityDescriptionLabel.text
            AddActivityViewController2.activityLocation = activityLocationLabel.text
            
            
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
        }
    }
    
}
