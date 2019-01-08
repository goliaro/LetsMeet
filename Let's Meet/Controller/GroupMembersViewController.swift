//
//  GroupMembersViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit

class GroupMembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate { 
    
    @IBOutlet weak var membersTableView: UITableView!
    
    //MARK: Properties
    var group_members = [UserInfo]()
    var current_group_name: String?
    var current_group_owner: String?
    @IBOutlet weak var removeButtonOutlet: UIButton!
    
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
    
    func downloadGroupMembers(post_params: [String:Any]) -> Bool
    {
        
        // this mutex will be used to make sure that we don't return a value until the datatask is actually done
        let local_mutex = Mutex()
        local_mutex.lock() // lock so that the function cannot return until the dataTask releases the lock upon finishing
        
        var toreturn = false
        
        restoreCookies()
        
        // dowload the data
        let webservice_URL = URL(string: "https://www.gabrieleoliaro.it/db/get_group_members.php")
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
                self.group_members = try decoder.decode([UserInfo].self, from:
                    dataResponse) //Decode JSON Response Data
                print(self.group_members)
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
    
    func downloadMemberImage(username: String) -> UIImage
    {
        //restoreCookies() // actually not needed since the images are not protected yet
        
        let local_mutex = Mutex()
        local_mutex.lock()
        
        // by default, if we can't download a profile picture from the network, this function returns the default image
        var returnimage = UIImage(named: "defaultPhoto")!
        
        // download the profile picture
        let username_safe = username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let imageLocation = "https://www.gabrieleoliaro.it/db/uploads/profile_pictures/" + username_safe + ".jpg"
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
    
    func getUpdatedInfo()
    {
        let post_params:[String:String] = ["group_name": current_group_name!]
        
        // Do any additional setup after loading the view.
        if (!downloadGroupMembers(post_params: post_params))
        {
            showAlertView(error_message: "Could not download the user's groups")
        }
        unwind_mutex.unlock()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        membersTableView.dataSource = self
        membersTableView.delegate = self
        
        // only the owner can remove members from a group
        if (current_group_owner == UUsername)
        {
            removeButtonOutlet.isEnabled = true
        }
        self.getUpdatedInfo()
        
    }
    
    @IBAction func removeMember(_ sender: UIButton) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("group_members.count: "); print(group_members.count); print("\n")
        return group_members.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cellReuseIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroupMembersTableViewCell
        
        let member = group_members[indexPath.row]
        print("member: "); print(member)
        cell.memberNameLabel.text = member.name
        cell.memberUsernameLabel.text = member.username
        cell.memberProfilePhoto.image = downloadMemberImage(username: member.username)
        
        
        
        return cell
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
            
        case "addMember":
            let destinationNavigationController = segue.destination as! UINavigationController
            let AddMemberToGroupViewController = destinationNavigationController.topViewController as!AddMemberToGroupViewController
            
            
            AddMemberToGroupViewController.group_name = current_group_name
        
        case "removeMember":
            let destinationNavigationController = segue.destination as! UINavigationController
            let RemoveMemberFromGroupViewController = destinationNavigationController.topViewController as!RemoveMemberFromGroupViewController
            
            
            RemoveMemberFromGroupViewController.group_name = current_group_name
            RemoveMemberFromGroupViewController.owner = current_group_owner
            
            
        case "leaveOrDeleteGroup":
            let destinationNavigationController = segue.destination as! UINavigationController
            let LeaveOrDeleteGroupViewController = destinationNavigationController.topViewController as!LeaveOrDeleteGroupViewController
            
            
            LeaveOrDeleteGroupViewController.group_name = current_group_name
            LeaveOrDeleteGroupViewController.owner = current_group_owner
            
        default:
            print("default segue")
        }
    }
    
    
    @IBAction func unwindToGroupMembers(segue:UIStoryboardSegue) {
        unwind_mutex.lock()
        self.getUpdatedInfo()
        unwind_mutex.lock()
        membersTableView.reloadData()
        unwind_mutex.unlock()
    }


}
