//
//  ActivityViewController2.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

import UIKit
import EventKit
import Foundation
import MessageUI

class ActivityViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    // MARK: Actions
    @IBAction func addToMyCalendar(_ sender: UIButton) {
        
        let eventStore:EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: {(granted, error) in
            if (granted) && (error == nil)
            {
                print("granted \(granted)")
                print("error \(error)")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = "Add event testing Title"
                event.startDate = Date()
                event.endDate = Date()
                event.notes = "This is a note"
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
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let toRecipients = ["graciazhang@college.harvard.edu"]
        let subject = "Feedback"
        let body = "Enter comments here...<br><br><p>I have a \(versionText()).<br> And iOS version \(UIDevice.current.systemVersion).<br</p>"
        let mail = configuredMailComposeViewController(recipients: toRecipients, subject: subject, body: body, isHtml: true, images: nil)
        presentMailComposeViewController(mailComposeViewController: mail)
    }
    
    
    
    

}
