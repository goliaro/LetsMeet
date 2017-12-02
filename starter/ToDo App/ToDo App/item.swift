//
//  item.swift
//  ToDo App
//
//  Created by Gracia-Zhang, Alejandro on 12/2/17.
//  Copyright © 2017 Echessa. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Item {
    
    var ref: DatabaseReference?
    var title: String?
    
    init (snapshot: DataSnapshot) {
        ref = snapshot.ref
        
        let data = snapshot.value as! Dictionary<String, String>
        title = data["title"]! as String
    }
    
}
