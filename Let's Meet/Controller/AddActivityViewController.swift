//
//  AddActivityViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
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
    
    var activities = [ActivityInfo]()
    var group_name: String?

    func showAlertView(error_message: String)
    {
        // Show an alert message
        let alertController = UIAlertController(title: "Alert", message: error_message, preferredStyle: .alert)
        let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            //print("You've pressed OK");
        }
        alertController.addAction(OK_button)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func downloadActivities(post_params: [String:Any]) -> Bool
    {
        
        // this mutex will be used to make sure that we don't return a value until the datatask is actually done
        let local_mutex = Mutex()
        local_mutex.lock() // lock so that the function cannot return until the dataTask releases the lock upon finishing
        
        var toreturn = false
        
        restoreCookies()
        
        // dowload the data
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/get_group_activities.php")
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let session = URLSession(configuration: config)
        var request = URLRequest(url: webservice_URL!)
        request.httpMethod = "POST"
        
        let parameterArray = getPostString(params: post_params)
        request.httpBody = parameterArray.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            print(response)
            
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                
                local_mutex.unlock()
                return
            }
            
            print(dataResponse)
            
            do {
                //here dataResponse received from a network request
                let decoder = JSONDecoder()
                self.activities = try decoder.decode([ActivityInfo].self, from:
                    dataResponse) //Decode JSON Response Data
                print(self.activities)
                toreturn = true
                
            } catch let parsingError {
                print("Error:", parsingError)
                return
            }
            
            local_mutex.unlock()
            
        }
        task.resume()
        
        local_mutex.lock()
        
        return toreturn
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Handle the text field's user input through delegate callbacks.
        activityNameLabel.delegate = self
        activityDescriptionLabel.delegate = self
        activityLocationLabel.delegate = self
        
        let post_params:[String:String] = ["group_name": group_name!]
        let result = downloadActivities(post_params: post_params)
        print(result)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // When the user starts typing, scroll down the page using a scroll view, so that no textfield is covered by the keyboard.
        scrollView.setContentOffset(CGPoint(x: 0, y: 175), animated: true)
    }*/
    
    
    //MARK: Picker Delegate and Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activities.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0
        {
            return "New activity..."
        }
        else
        {
            return activities[row-1].name
        }
        
    }

    
    // MARK: - Navigation

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func NextButtonPressed(_ sender: UIButton) {
        // If the selected row in the picker view shows "New activity..." and the Name text field is empty, the user is not providing any valid name for the activity, so we need to fire an alert message.
        if ((activityNamePicker.selectedRow(inComponent: 0) == 0) && activityNameLabel.text == "")
        {
            self.showAlertView(error_message: "The name of the activity is missing!")
            return
            
        }
        
        // If the selected row in the picker view does not show "New activity..." and the Name text field is not empty, the user is providing two names for the same activity, which of course cannot be allowed
        else if ((activityNamePicker.selectedRow(inComponent: 0) > 0) && activityNameLabel.text != "")
        {
            self.showAlertView(error_message: "You provided two different names for the same activity")
            return
        }
        else {
            self.performSegue(withIdentifier: "goto_part2", sender: sender)
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        
        // There is actually only one segue, so the code would work evern without the switch, but it's safer to include it in case a new segue is added in the future.
        switch(segue.identifier ?? "") {
            
        case "goto_part2":
            
            guard let AddActivityViewController2 = segue.destination as? AddActivityViewController2 else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // If the chosen row is "New Activity..." save the name typed into the text field, instead of the string in the selected row in the UIPickerView
            if (activityNamePicker.selectedRow(inComponent: 0) == 0) {
                AddActivityViewController2.activityName = activityNameLabel.text
            }
            // Otherwise save the name of the activity in the selected row in the pickerView
            else {
                AddActivityViewController2.activityName = activities[activityNamePicker.selectedRow(inComponent: 0) - 1].name
                //print(activities[activityNamePicker.selectedRow(inComponent: 0) - 1].name)
            }
            
            AddActivityViewController2.activityDescription = activityDescriptionLabel.text
            AddActivityViewController2.activityPlace = activityLocationLabel.text
            
            AddActivityViewController2.group_name = group_name
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
        }
    }
    
}
