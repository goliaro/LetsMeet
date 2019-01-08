//
//  ActivityViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/4/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var activityPlaceLabel: UILabel!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var activityStartingTimeLabel: UILabel!
    @IBOutlet weak var activityEndingTimeLabel: UILabel!
    
    @IBOutlet weak var CanGoButtonOutlet: UIButton!
    @IBOutlet weak var LeaveActivityButtonOutlet: UIButton!
    
    
    var activity: ActivityInfo?
    var activity_members = [UserInfo]()
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
    
    func downloadActivityMembers(post_params: [String:Any]) -> Bool
    {
        
        // this mutex will be used to make sure that we don't return a value until the datatask is actually done
        let local_mutex = Mutex()
        local_mutex.lock() // lock so that the function cannot return until the dataTask releases the lock upon finishing
        
        var toreturn = false
        
        restoreCookies()
        
        // dowload the data
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/get_activity_members.php")
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
                self.activity_members = try decoder.decode([UserInfo].self, from:
                    dataResponse) //Decode JSON Response Data
                print(self.activity_members)
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
    
    func joinActivity(post_params: [String:Any]) -> String
    {
        
        // this mutex will be used to make sure that we don't return a value until the datatask is actually done
        let local_mutex = Mutex()
        local_mutex.lock() // lock so that the function cannot return until the dataTask releases the lock upon finishing
        
        restoreCookies()
        
        var toreturn = "Failed."
        
        // dowload the data
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/join_activity.php")
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "text/html",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
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
            
            print(dataResponse)
            toreturn = dataResponse
            
            local_mutex.unlock()
            
        }
        task.resume()
        
        local_mutex.lock()
        
        return toreturn
    }
    
    func checkIfMember() -> Bool
    {
        var isMember = false
        for member in activity_members {
            print (member.username)
            if (member.username == UUsername)
            {
                isMember = true
                break
            }
        }
        return isMember
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityTitleLabel.text = activity?.name
        activityPlaceLabel.text = activity?.place
        activityDescriptionLabel.text = activity?.description
        activityStartingTimeLabel.text = activity?.starting_time
        activityEndingTimeLabel.text = activity?.ending_time
        
        let params:[String:String] = ["activity_id": (activity?.activity_id)!]
        
        let result = downloadActivityMembers(post_params: params)
        print(result)
        print(activity_members)
        if (result)
        {
            if (checkIfMember()) {
                CanGoButtonOutlet.isEnabled = false
                LeaveActivityButtonOutlet.isEnabled = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func viewDetailsButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "view_members", sender: sender)
    }
    
    @IBAction func joinButton(_ sender: UIButton) {
        let join_params:[String:String] = ["activity_id": (activity?.activity_id)!]
        let return_string = joinActivity(post_params: join_params)
        if (return_string != "You successfully joined the activity.")
        {
            self.showAlertView(error_message: return_string)
        }
        else {
            LeaveActivityButtonOutlet.isEnabled = true
            CanGoButtonOutlet.isEnabled = false
            self.performSegue(withIdentifier: "view_members", sender: sender)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        //There is actually only one segue, so the code would work evern without the switch, but it's safer to include it in case a new segue is added in the future.
        switch(segue.identifier ?? "") {
            
        case "view_members":
            guard let ActivityViewController2 = segue.destination as? ActivityViewController2 else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // Pass the activity object
            ActivityViewController2.activity = activity
            ActivityViewController2.group_name = group_name
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
        }

    }
    

}
