//
//  GroupViewController.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 12/3/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import os.log

class GroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    var activities = [Activity]()
    
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var descriptionTextField: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
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
        
        loadSampleActivities()
        
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        cell.activityStartingTime.text = formatter.string(from: activity.starting_time)
        cell.activityEndingTime.text = formatter.string(from: activity.ending_time)
        
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
            guard let navVC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination view controller \(segue.destination)")
            }
            
            guard let addActivityViewController1 = navVC.viewControllers.first as? AddActivityViewController else {
                fatalError("Unexpected destination: \(navVC.viewControllers.first)")
                
            }
            
            addActivityViewController1.recent_activities = group?.recent_activities
        
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        
        }
    }
    
    
    // MARK: Private Methods
    
    private func loadSampleActivities() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        //let someDateTime = formatter.date(from: "2016/10/08 22:31")
        
        guard let activity1 = Activity(name: "Lunch", starting_time: formatter.date(from: "2017/12/05 14:00")!, ending_time: formatter.date(from: "2017/12/05 14:30")!, description: "Lunch together!", location: "Winthrop Dining Hall", participants_usernames: ["mario", "guido", "giulio"]) else {
            fatalError("Unable to instantiate activity 1.")
        }
        
        guard let activity2 = Activity(name: "Run on the river", starting_time: formatter.date(from: "2017/12/05 18:00")!, ending_time: formatter.date(from: "2017/12/05 19:30")!, description: "We'll run to MIT and back", location: "John Harvard Statue", participants_usernames: ["mario", "guido", "giulio"]) else {
            fatalError("Unable to instantiate activity 2.")
        }
        
        guard let activity3 = Activity(name: "Ice-cream at JP Licks", starting_time: formatter.date(from: "2017/12/06 15:00")!, ending_time: formatter.date(from: "2017/12/06 15:30")!, description: "", location: "", participants_usernames: ["mario", "guido", "giulio"]) else {
            fatalError("Unable to instantiate activity 3.")
        }
        
        activities += [activity1, activity2, activity3]
        
    }
    
    
    // MARK: Actions
    @IBAction func unwindToGroupView(sender: UIStoryboardSegue) {
        if let sourceviewController = sender.source as? AddActivityViewController2, let activity = sourceviewController.activity {
            // Add a new activity
            let newIndexPath = IndexPath(row: activities.count, section: 0)
            
            activities.append(activity)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
}
