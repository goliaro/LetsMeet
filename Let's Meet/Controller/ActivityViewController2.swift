//
//  ActivityViewController2.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//
import UIKit
import EventKit
import MessageUI

class ActivityViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    var activity: ActivityInfo?
    var activity_members = [UserInfo]()
    var group_name: String?
    
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var addToCalendarButtonOutlet: UIButton!
    @IBOutlet weak var sendMessageButtonOutlet: UIButton!
    
    @IBOutlet weak var membersTableView: UITableView!
    
    
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
    
    @IBOutlet weak var backToGroupHomebutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backToGroupHomebutton.setTitle("-> " + group_name! + " <-", for: .normal)
        
        membersTableView.dataSource = self
        membersTableView.delegate = self
        
        let params:[String:String] = ["activity_id": (activity?.activity_id)!]
        
        if (!downloadActivityMembers(post_params: params))
        {
            self.showAlertView(error_message: "Could not download activity members")
        }
        
        
        if (checkIfMember())
        {
            StatusLabel.text = "You are signed up for this!"
            addToCalendarButtonOutlet.isEnabled = true
            sendMessageButtonOutlet.isEnabled = true
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activity_members.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "activityMemberCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ActivityMemberTableViewCell
        
        let member = activity_members[indexPath.row]
        print("member: "); print(member)
        cell.memberName.text = member.name
        cell.memberUsername.text = member.username
        cell.memberPhoto.image = downloadMemberImage(username: member.username)
        
        
        return cell
    }
    
    // MARK: Actions
    @IBAction func addToMyCalendar(_ sender: UIButton) {
        let eventStore:EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: {(granted, error) in
            if (granted) && (error == nil)
            {
                print("granted \(granted)")
                print("error \(error)")
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = (self.activity?.name)!
                
                event.startDate = formatter.date(from: (self.activity?.starting_time)!)!
                
                if (self.activity?.ending_time != nil)
                {
                    event.endDate = formatter.date(from: (self.activity?.ending_time)!)!
                }
                event.notes = (self.activity?.description)!
                
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("error: \(error)")
                }
                let alertController = UIAlertController(title: "Confirmation", message: "The event was successfully saved!", preferredStyle: .alert)
                
                let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("You've pressed OK");
                }
                
                alertController.addAction(OK_button)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Alert", message: "The event was not saved!", preferredStyle: .alert)
                
                let OK_button = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("You've pressed OK");
                }
                
                alertController.addAction(OK_button)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail() {
            let message = MFMailComposeViewController()
            message.mailComposeDelegate = self
            
            var email_addresses = [String]()
            for activity_member in activity_members {
                email_addresses.append(activity_member.email)
            }
            
            message.setToRecipients(email_addresses)
            message.setSubject("Message from your fellow \(self.activity!.group_name)'s \(self.activity!.name) member")
            
            present(message, animated: true)
        } else {
            self.showAlertView(error_message: "could not send a message.")
        }
    }
    
    
    
    
    
    
}

