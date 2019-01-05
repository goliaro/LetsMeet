//
//  Person.swift
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

class Person {
    
    // These are the basic variable names used to store the information of each single person
    //MARK: Properties
    
    var username: String // or user_id
    var password: String //to be encrypted
    var name: String
    var photo: UIImage?
    
    
    // These methods allow the initialization of the class Activity
    //MARK: Initialization
    
    init?(username: String, password: String, name: String, photo: UIImage) {
        
        // #cs50 Initialize stored properties. Basically copies the values given as parameters of the initialization function into the variables of the Activity object
        self.username = username
        self.password = password
        self.name = name
        self.photo = photo
        
        
        // We want the initialization to fail if there is no name or if there is no description.
        if name.isEmpty  || password.isEmpty || name.isEmpty || photo == nil {
            return nil
        }
        
    }
    
    
}

