//
//  CommentUITableViewCell.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 21.05.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit

class CommentUITableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commLabel: SOLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCell(comment: Comment){
        if(comment.photoLink != "-"){
            profileimage.sd_setImageWithURL(NSURL(string: comment.photoLink))
            profileimage.layer.cornerRadius = profileimage.frame.size.height / 2
            profileimage.layer.masksToBounds = true
            profileimage.layer.borderWidth = 0
        }else{
            profileimage.setImageWithString(comment.name, color: nil, circular: true)
        }
        nameLabel.text = comment.name
        commLabel.text = comment.text
        
        commLabel.sizeToFit()
        
        
        
        
        
        
        
    }
    
}
