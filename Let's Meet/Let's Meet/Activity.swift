//
//  Activity.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 12/3/17.
//  Copyright © 2017 Kit, Alejandro & Gabriel. All rights reserved.
//

/*
 #cs50
 THIS IS OUR DATA MODEL
 
 As per the official Apple Developer Guide "Start Developing iOS Apps (Swift)":
 
 "A data model represents the structure of the information stored in an app."
 
 In this data model, we're storing the information that the group scene (i.e. the app page with the table view of all the groups of people) needs to display. To do so, we'll define this simple class with a name, a photo, and a decription.
 
 */

import Foundation
import UIKit

class Activity {
    
    // #cs50 These are the basic variable names used to store the information of each single activity
    //MARK: Properties
    
    var name: String
    var time: Date
    
    //#cs50 The location and descriptions are optional
    var description: String?
    var location: String?
    
    
    // #cs50 These methods allow the initialization of the class Activity
    //MARK: Initialization
    
    init?(name: String, time: Date, description: String?, location: String?) {
        
        // #cs50 Initialize stored properties. Basically copies the values given as parameters of the initialization function into the variables of the Activity object
        self.name = name
        self.time = time
        self.description = description
        self.location = location
        
        
        // We want the initialization to fail if there is no name or if there is no description.
        if name.isEmpty || _time == nil  {
            return nil
        }
        
    }
    
    
}
