//
//  UsersCell.swift
//  CampusTalk
//
//  Created by Erman Sahin Tatar on 12/12/17.
//  Copyright © 2017 Erman Sahin Tatar. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell {

    @IBOutlet var fullnameLbl: UILabel!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var avaImg: UIImageView!
    // first load func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round corners
        avaImg.layer.cornerRadius = avaImg.bounds.width / 2
        avaImg.clipsToBounds = true
        
        // color
        usernameLbl.textColor = colorBrand
        
    }
}
