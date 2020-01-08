//
//  PopUpPDFUIView.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 3.04.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit

class PopUpPDFUIView: UIView {
    
    
    
    func loadViewFromNib() -> UIView {
        
        let view = NSBundle(forClass: self.dynamicType).loadNibNamed("PopUpPDFView", owner: self, options: nil)[0] as! UIView
        
        
        return view
    }
    

}
