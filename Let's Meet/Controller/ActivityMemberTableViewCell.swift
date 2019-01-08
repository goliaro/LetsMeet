//
//  ActivityMemberTableViewCell.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 08/01/2019.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit

class ActivityMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var memberPhoto: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberUsername: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
