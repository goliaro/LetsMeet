//
//  GroupTableViewCell.swift
//  Let's Meet
//
//  Created by Oliaro, Gabriele on 11/30/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//



/* What does this class do:
 this class manages each cell of the table view in the groups page. It is called "GroupTableViewCell" because each cell shows a group, just like in Whatsapp.
 */

import UIKit

class GroupTableViewCell: UITableViewCell {
    
    
    /* 
     The following section is responsible for creating the outlets of the photo, title and description elements of every cell in the table view. As per the official Apple Developer Guide "Start Developing iOS Apps (Swift):
 
     "Before you can display dynamic data in your table view cells, you need to create outlet connections between the prototype in your storyboard and the code that represents the table view cell in MealTableViewCell.swift."
     */
    //MARK: Properties
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupDescriptionLabel: UILabel!
    @IBOutlet weak var groupPhotoImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
