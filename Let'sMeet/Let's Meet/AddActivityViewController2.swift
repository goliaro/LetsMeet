//
//  AddActivityViewController2.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import os.log

class AddActivityViewController2: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var activityStartingTimePicker: UIDatePicker!
    @IBOutlet weak var activityEndingTimePicker: UIDatePicker!
    @IBOutlet weak var startButton: UIButton!
    
    var activityName: String?
    var activityDescription: String?
    var activityLocation: String?
    
    // This will contain the activity object after the Start!! button is pressed.
    var activity: Activity?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func StartingTimePickerValueChanged(_ sender: UIDatePicker) {
        // Ensure that the ending date always comes after the starting date
        activityEndingTimePicker.minimumDate = activityStartingTimePicker.date
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view only when the Start!! button is pressed
        guard let button = sender as? UIButton, button === startButton else {
            os_log("The start button was not pressed. Weird.", log: OSLog.default, type: .debug)
            return
        }
        
        activity = Activity(name: activityName!, starting_time: activityStartingTimePicker.date, ending_time: activityEndingTimePicker.date, description: activityDescription!, location: activityLocation!, participants_usernames: [])
        
        
    }
    

}
