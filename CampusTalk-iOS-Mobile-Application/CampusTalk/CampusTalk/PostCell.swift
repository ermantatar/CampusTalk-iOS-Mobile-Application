//
//  PostCell.swift
//  CampusTalk
//
//  Created by Erman Sahin Tatar on 11/26/17.
//  Copyright © 2017 Erman Sahin Tatar. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    
    
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var textLbl: UILabel!
    @IBOutlet var pictureImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // color
        usernameLbl.textColor = colorBrand
        
        // round corners
        pictureImg.layer.cornerRadius = pictureImg.bounds.width / 20
        pictureImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
