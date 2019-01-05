//
//  ActivityViewController2.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//
import UIKit
import EventKit

class ActivityViewController2: UIViewController {
    
    var activity: Activity?
    var group_name: String?
    
    @IBOutlet weak var backToGroupHomebutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backToGroupHomebutton.setTitle("-> " + group_name! + " <-", for: .normal)
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
        
    }
    
    
    
}

