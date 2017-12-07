//
//  ActivityViewController2.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//
import UIKit
import EventKit

class ActivityViewController2: UIViewController {
    
    var activity: Activity?
    var group_name: String?
    
    
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
                event.title = self.group_name! + " - " + (self.activity?.name)!
                event.startDate = (self.activity?.starting_time)!
                event.endDate = (self.activity?.ending_time)!
                event.notes = self.activity?.description
                event.location = self.activity?.location
                
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("error: \(error)")
                }
                print("Save event")
            } else {
                print("error: \(error)")
            }
        })
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
    }
    
    
    
}

