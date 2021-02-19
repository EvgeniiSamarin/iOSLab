//
//  CustomTableViewCell.swift
//  photoColormeter
//
//  Created by Евгений Самарин on 13.07.2020.
//  Copyright © 2020 Евгений Самарин. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var colorBox: UIView!
    @IBOutlet weak var colorPercentage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
