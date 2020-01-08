//
//  SendFeedBackUIView.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 9.04.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit

class SendFeedbackUIView: UIView {

    func loadViewFromNib() -> UIView {
        
        let view = NSBundle(forClass: self.dynamicType).loadNibNamed("SendFeedbackView", owner: self, options: nil)[0] as! UIView
        
        
        return view
    }

}
