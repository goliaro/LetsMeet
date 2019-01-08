//
//  AddActivityViewController2.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
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
    var activityPlace: String?
    
    // This will contain the activity object after the Start!! button is pressed.
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
    
    func create_activity(post_params: [String:Any]) -> Bool
    {
        // this mutex will be used to make sure that we don't return a value until the datatask is actually done
        let local_mutex = Mutex()
        local_mutex.lock() // lock so that the function cannot return until the dataTask releases the lock upon finishing
        
        // remove cookies from previous sessions
        restoreCookies()
        
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/create_activity.php")
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Accept": "text/html",
                                        "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        var toreturn = false
        
        let session = URLSession(configuration: config)
        var request = URLRequest(url: webservice_URL!)
        request.httpMethod = "POST"
        
        let parameterArray = getPostString(params: post_params)
        request.httpBody = parameterArray.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request) { data, response, error in
            
            print(response)
            
            guard let dataResponse = String(data: data!, encoding: .utf8), error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                
                // done with the datatask (failed), so unlock the mutex
                local_mutex.unlock()
                //print("toreturn: "); print(toreturn); print("\n")
                return
            }
            
            print("dataResponse: " + dataResponse + "\n")
            
            if (dataResponse == "New activity was created with success.")
            {
                toreturn = true
            }
            
            DispatchQueue.main.async {
                self.showAlertView(error_message: dataResponse)
            }
            
            print("toreturn: "); print(toreturn); print("\n")
            
            // we should be all done with the dataTask once we get here. No matter if we succeeded or failed
            local_mutex.unlock()
            
        }
        task.resume()
        
        // Aquire the lock right before returning, to make sure that we are actually done with the dataTask
        local_mutex.lock()
        
        return toreturn
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityStartingTimePicker.minimumDate = Date()
        
        
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let create_activity_params:[String:Any] = ["activity_name": activityName!, "description": activityDescription!, "group_name": group_name!, "place": activityPlace!, "starting_time": formatter.string(from: activityStartingTimePicker.date), "ending_time": formatter.string(from: activityEndingTimePicker.date)]
        let result = self.create_activity(post_params: create_activity_params)
        print(result)
        
        if (result)
        {
            self.performSegue(withIdentifier: "unwind_segue_create_activity2", sender: sender)
        }
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
        
        
        
    }
    

}
