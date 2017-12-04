//
//  ActivityTableViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/4/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import Foundation
import UIKit

class ActivityTableViewController: UITableViewController {
    
    //MARK: Properties
    var activities = [Activity]()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSampleActivities()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ActivityTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ActivityTableViewCell else {
            fatalError("The dequeued cell is not an instance of ActivityTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let activity = activities[indexPath.row]
        
        // Configure the cell...
        cell.activityTitle.text = activity.name
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        cell.activityStartingTime.text = formatter.string(from: activity.starting_time)
        cell.activityEndingTime.text = formatter.string(from: activity.ending_time)

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Private Methods
    
    private func loadSampleActivities() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        //let someDateTime = formatter.date(from: "2016/10/08 22:31")
        
        guard let activity1 = Activity(name: "Lunch", starting_time: formatter.date(from: "2017/12/05 14:00")!, ending_time: formatter.date(from: "2017/12/05 14:30")!, description: "Lunch together!", location: "Winthrop Dining Hall") else {
            fatalError("Unable to instantiate activity 1.")
        }
        
        guard let activity2 = Activity(name: "Run on the river", starting_time: formatter.date(from: "2017/12/05 18:00")!, ending_time: formatter.date(from: "2017/12/05 19:30")!, description: "We'll run to MIT and back", location: "John Harvard Statue") else {
            fatalError("Unable to instantiate activity 2.")
        }
        
        guard let activity3 = Activity(name: "Ice-cream at JP Licks", starting_time: formatter.date(from: "2017/12/06 15:00")!, ending_time: formatter.date(from: "2017/12/06 15:30")!, description: "", location: "") else {
            fatalError("Unable to instantiate activity 3.")
        }
        
        activities += [activity1, activity2, activity3]
        
    }

}
