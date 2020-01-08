//
//  LoadingDialogView.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 15.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit

class LoadingDialogView: UIView {

    
    
    
    
    func loadViewFromNib() -> UIView {
        
        let view = NSBundle(forClass: self.dynamicType).loadNibNamed("LoadingDialog", owner: self, options: nil)[0] as! UIView
        
        
        return view
    }
    

}
