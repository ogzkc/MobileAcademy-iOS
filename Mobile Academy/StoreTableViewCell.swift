//
//  StoreTableViewCell.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 31.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//


import UIKit
import TWRDownloadManager

class StoreTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var depLogoImageView: UIImageView!
    @IBOutlet weak var docNameLabel: UILabel!
    @IBOutlet weak var docPubNameLabel: UILabel!
    @IBOutlet weak var docPriceLabel: UILabel!
    @IBOutlet weak var docDownloadView: UIView!
    @IBOutlet weak var docPreviewView: UIView!
    @IBOutlet weak var download_ReadImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setCell(doc: Document){
        
        depLogoImageView.sd_setImageWithURL(NSURL(string: doc.departmentLogo), placeholderImage: UIImage(named: "PlaceHolderLogo"))
        docNameLabel.text = doc.displayName
        docPubNameLabel.text = doc.publisherName
        if(doc.price == 0){
            docPriceLabel.text = "Free"
        }else{
            docPriceLabel.text = "\(doc.price) Coins"
        }
        
        if(doc.isHave){
            download_ReadImage.image = UIImage(named: "ReadIcon")
        }
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

}
