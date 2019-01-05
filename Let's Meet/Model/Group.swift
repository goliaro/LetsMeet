//
//  Group.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 12/2/17.
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

class Group {
    
    
    // These are the basic variable names used to store the information of each single group
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    var description: String
    var activities = [Activity]()
    var recent_activities: [String]
    var members_usernames: [String]
    
    
    
    // These methods allow the initialization of the class Group
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?, description: String) {
        
        // Initialize stored properties. Basically copies the values given as parameters of the initialization function into the variables of the Group object
        self.name = name
        self.photo = photo
        self.description = description
        
        self.recent_activities = []
        self.members_usernames = []
        
        
        // We want the initialization to fail if there is no name or if there is no description.
        if name.isEmpty || description.isEmpty  {
            return nil
        }
        
    }
    
}
