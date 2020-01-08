//
//  CommentUIView.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 21.05.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit

class CommentUIView: UIView {

    func loadViewFromNib() -> UIView {
        
        let view = NSBundle(forClass: self.dynamicType).loadNibNamed("CommentView", owner: self, options: nil)[0] as! UIView
        return view
        
    }

}
