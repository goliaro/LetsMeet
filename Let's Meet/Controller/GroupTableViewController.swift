//
//  GroupTableViewController.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 12/2/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

/*
 
 THIS IS OUR TABLE VIEW CONTROLLER. 
 
 As per the official Apple Developer Guide "Start Developing iOS Apps (Swift)":

 "To display any real data in your table cells, you need to write code to load that data." 
 
 We've created our data model for a group: the Group class in the Group.swift file. Now we also need to keep a list of those groups. The natural place to track this is in a custom view controller subclass that’s connected to the group list scene (the app page that shows all the groups in a table view). This view controller will manage the view that displays the list of meals, and have a reference to the data model behind what’s shown in the user interface.
 
 */


import UIKit
import os.log
import Foundation

struct GroupInfo: Codable {
    var name: String
    var description: String
    var owner: String
}



class GroupTableViewController: UITableViewController {
    
    //MARK: Properties
    var groups = [GroupInfo]() // This creates the array of objects Groups
    //var users = [User]()
    
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
    
    func downloadGroups() -> Bool
    {
        
        // this mutex will be used to make sure that we don't return a value until the datatask is actually done
        let local_mutex = Mutex()
        local_mutex.lock() // lock so that the function cannot return until the dataTask releases the lock upon finishing
        
        var toreturn = false
        
        restoreCookies()
        
        // dowload the data
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/get_groups.php")
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "application/json"
        ]
        
        let session = URLSession(configuration: config)
        var request = URLRequest(url: webservice_URL!)
        request.httpMethod = "GET"
        
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
                self.groups = try decoder.decode([GroupInfo].self, from:
                    dataResponse) //Decode JSON Response Data
                print(self.groups)
                toreturn = true
                
            } catch let parsingError {
                print("Error", parsingError)
                return
            }
            
            local_mutex.unlock()
            
        }
        task.resume()
        
        local_mutex.lock()
        return toreturn
    }
    
    func downloadGroupImage(groupname: String) -> UIImage
    {
        //restoreCookies() // actually not needed since the images are not protected yet
        
        let local_mutex = Mutex()
        local_mutex.lock()
        
        // by default, if we can't download a profile picture from the network, this function returns the default image
        var returnimage = UIImage(named: "defaultPhoto")!
        
        // download the profile picture
        let imageLocation = "https://www.gabrieleoliaro.it/db/uploads/groups_pictures/" + groupname + ".jpg"
        print("imagelocation:" + imageLocation)
        guard let imageUrl = URL(string: imageLocation) else {
            print("Cannot create URL")
            local_mutex.unlock()
            return returnimage
        }
        
        let image_task = URLSession.shared.downloadTask(with: imageUrl) {(location, response, error) in
            
            guard let location = location else {
                print("location is nil")
                local_mutex.unlock()
                return
            }
            
            print(location)
            
            let imageData = try! Data(contentsOf: location)
            let image = UIImage(data: imageData)
            
            if (image != nil)
            {
                returnimage = image!
            }
            local_mutex.unlock()
        }
        image_task.resume()
        
        local_mutex.lock()
        return returnimage
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!downloadGroups())
        {
            showAlertView(error_message: "Could not download the user's groups")
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Table view data source

    // This functions defines the number of sections of the table view. In our case, the table is pretty simple, and so one section is enough
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    // This function determines the number of rows that the table will need by counting the number of groups in the groups array.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("group count: "); print(groups.count); print("\n")
        return groups.count
    }

    // this function configures and displays the table's visible cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GroupTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GroupTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let group = groups[indexPath.row]
        
        cell.groupNameLabel.text = group.name
        cell.groupPhotoImageView.image = downloadGroupImage(groupname: group.name)
        cell.groupDescriptionLabel.text = group.description
        
        return cell
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Just call superclass implementation
        super.prepare(for: segue, sender: sender)
        
        
        switch(segue.identifier ?? "") {
            
        case "showProfile":
            os_log("Viewing or editing the members of the activity.", log: OSLog.default, type: .debug)
            
            
        case "showGroup":
            guard let groupDetailedViewController = segue.destination as? GroupViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedGroupCell = sender as? GroupTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedGroupCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedGroup = groups[indexPath.row]
            //groupDetailedViewController.group = selectedGroup
        
        case "newGroup":
            os_log("Adding a new group.", log: OSLog.default, type: .debug)
        default:
            fatalError("Weird")
        }
        
    }
    
    
    
    //MARK: Private Methods
    
    // This function will load for the demo the 4 sample group whose images are saved into the Assets.xcassets
    /*private func loadSampleGroups() {
        
        // Declare a constant for each image in Assets.xcassets
        let photo1 = UIImage(named: "CS 50")
        let photo2 = UIImage(named: "Ec 10")
        let photo3 = UIImage(named: "CSA group")
        let photo4 = UIImage(named: "Best friends")
        
        let recent_activities_sample = ["apple picking", "pset 8", "lunch", "running"]
        
        // Instantiate the sample groups with name, photo and description
        guard let group1 = Group(name: "CS 50", photo: photo1, description: "Official group for Fall 2017") else {
            fatalError("Unable to instantiate group1")
        }
        group1.recent_activities = recent_activities_sample
        
        guard let group2 = Group(name: "EC 10", photo: photo2, description: "Official group for Fall 2017") else {
            fatalError("Unable to instantiate group1")
        }
        
        group2.recent_activities = recent_activities_sample
        
        guard let group3 = Group(name: "CSA", photo: photo3, description: "Catholic Student Association (all members)") else {
            fatalError("Unable to instantiate group1")
        }
        
        group3.recent_activities = recent_activities_sample
        
        guard let group4 = Group(name: "Friends", photo: photo4, description: "Ryan, Pawel, Gabriele, Pedro, Joey, Caleb") else {
            fatalError("Unable to instantiate group1")
        }
        
        group4.recent_activities = recent_activities_sample
        
        groups += [group1, group2, group3, group4]
    }*/


}
