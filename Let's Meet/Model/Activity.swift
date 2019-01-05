//
//  Activity.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 12/3/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

/*
 THIS IS OUR DATA MODEL
 
 As per the official Apple Developer Guide "Start Developing iOS Apps (Swift)":
 
 "A data model represents the structure of the information stored in an app."
 
 In this data model, we're storing the information that the group scene (i.e. the app page with the table view of all the groups of people) needs to display. To do so, we'll define this simple class with a name, a photo, and a decription.
 
 */

import Foundation
import UIKit

class Activity {
    
    // These are the basic variable names used to store the information of each single activity
    //MARK: Properties
    
    var name: String
    var starting_time: Date
    var ending_time: Date
    var participants_usernames: [String]
    
    // The location and descriptions are optional
    var description: String?
    var location: String?
    
    
    
    // These methods allow the initialization of the class Activity
    //MARK: Initialization
    
    init?(name: String, starting_time: Date, ending_time: Date, description: String?, location: String?, participants_usernames: [String]) {
        
        // #cs50 Initialize stored properties. Basically copies the values given as parameters of the initialization function into the variables of the Activity object
        self.name = name
        self.starting_time = starting_time
        self.description = description
        self.location = location
        self.ending_time = ending_time
        self.participants_usernames = participants_usernames
        
        
        // We want the initialization to fail if there is no name or if there is no description.
        if name.isEmpty  {
            return nil
        }
        
    }
    
    
}
