//
//  GroupViewController.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 12/3/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit
import os.log

struct ActivityInfo: Codable {
    var activity_id: String
    var name: String
    var group_name: String
    var owner: String
    var place: String
    var description: String?
    var starting_time: String
    var ending_time: String?
}



class GroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    var activities = [ActivityInfo]()
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var descriptionTextField: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    /*
     This value should be passed by 'GroupTableViewController' in 'prepare(for:sender:)'
     */
    var group: GroupInfo?
    var image: UIImage?
    
    let unwind_mutex = Mutex()
    
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
    
    func sort_activities()
    {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.activities.sort(by: { formatter.date(from: $0.starting_time)!.compare(formatter.date(from: $1.starting_time)!) == .orderedAscending })
        
    }
    
    func remove_expired_activities()
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        var activities_not_expired = [ActivityInfo]()
        
        for current_activity in activities {
            //print ("comparing: ")
            //print(formatter.date(from: current_activity.starting_time)!)
            //print(Date())
            
            if (current_activity.ending_time == nil)
            {
                activities_not_expired.append(current_activity)
            }
            
            else if (formatter.date(from: current_activity.ending_time!)!.compare(Date()) == .orderedDescending) {
                //print ("starting after now")
                activities_not_expired.append(current_activity)
            }
        }
        
        self.activities = activities_not_expired
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
    
    func getUpdatedInfo()
    {
        let post_params:[String:String] = ["group_name": (group?.name)!]
        if (!downloadActivities(post_params: post_params))
        {
            showAlertView(error_message: "Could not download the user's activities")
        }
        
        self.sort_activities()
        self.remove_expired_activities()
        
        unwind_mutex.unlock()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleTextField.text = group?.name
        descriptionTextField.text = group?.description
        photoImageView.image = image
        
        getUpdatedInfo()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activities.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ActivityTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ActivityTableViewCell else {
            fatalError("The dequeued cell is not an instance of ActivityTableViewCell.")
        }
        
        // Fetches the appropriate activity for the data source layout.
        let activity = activities[indexPath.row]
        
        // Configure the cell...
        cell.activityTitle.text = activity.name
        cell.activityStartingTime.text = activity.starting_time
        cell.activityEndingTime.text = activity.ending_time
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "view_editMembers":
            os_log("Viewing or editing the members of the activity.", log: OSLog.default, type: .debug)
            
        case "showDetail":
            guard let activityDetailedViewController = segue.destination as? ActivityViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedActivityCell = sender as? ActivityTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedActivityCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedActivity = activities[indexPath.row]
            activityDetailedViewController.activity = selectedActivity
            activityDetailedViewController.group_name = group?.name
            
        case "addActivity":
            let destinationNavigationController = segue.destination as! UINavigationController
            let AddActivityViewController = destinationNavigationController.topViewController as!AddActivityViewController
            AddActivityViewController.group_name = group?.name
        
        case "showGroupMembers":
            guard let groupMembersViewController = segue.destination as? GroupMembersViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            groupMembersViewController.current_group_name = group?.name
            groupMembersViewController.current_group_owner = group?.owner
        default:
            print("default segue")
        }
    }
    
    
    // MARK: Private Methods
    /*
     let formatter = DateFormatter()
     formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
     formatter.locale = Locale(identifier: "en_US_POSIX")
     formatter.timeZone = TimeZone(secondsFromGMT: 0)
     */
    
    
    
    // MARK: Actions
    @IBAction func unwindToGroupView(segue:UIStoryboardSegue) {
        unwind_mutex.lock()
        self.getUpdatedInfo()
        unwind_mutex.lock()
        tableView.reloadData()
        unwind_mutex.unlock()
    }
}
