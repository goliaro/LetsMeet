//
//  GroupMembersTableViewCell.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/5/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit

class GroupMembersTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var memberProfilePhoto: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberUsernameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
