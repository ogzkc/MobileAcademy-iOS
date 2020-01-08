//
//  LibraryTableViewCell.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 2.04.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var docNameLabel: UILabel!
    @IBOutlet weak var docPublisherLabel: UILabel!
    @IBOutlet weak var docDepLogoImage: UIImageView!
    @IBOutlet weak var docReadButtonView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        

        // Configure the view for the selected state
    }
    
    
    func setCell(doc: Document){
        
        docDepLogoImage.sd_setImageWithURL(NSURL(string: doc.departmentLogo), placeholderImage: UIImage(named: "PlaceHolderLogo"))
        docNameLabel.text = doc.displayName
        docPublisherLabel.text = doc.publisherName
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }


}
