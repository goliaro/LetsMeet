//
//  ActivityTableViewCell.swift
//  Let's Meet
//
//  Created by Gabriele Oliaro on 12/4/17.
//  Copyright © 2019 Gabriele Oliaro. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var activityStartingTime: UILabel!
    @IBOutlet weak var activityEndingTime: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
