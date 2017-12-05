//
//  ActivityViewController.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/4/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var activityPlaceLabel: UILabel!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var activityStartingTimeLabel: UILabel!
    @IBOutlet weak var activityEndingTimeLabel: UILabel!
    
    
    
    var activity: Activity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityTitleLabel.text = "prova"
        
        // Display details of current activity
        if let activity = activity {
            activityTitleLabel.text = activity.name
            
            
            if (activity.location != "")
            {
                activityPlaceLabel.text = activity.location
            }
            else
            {
                activityPlaceLabel.text = "no location provided"
            }
            
            if (activity.description != "")
            {
                activityDescriptionLabel.text = activity.description
            }
            else {
                activityDescriptionLabel.text = "no description provided"
            }
            
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            

            activityStartingTimeLabel.text = formatter.string(from: activity.starting_time)
            activityEndingTimeLabel.text = formatter.string(from: activity.ending_time)
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

}
