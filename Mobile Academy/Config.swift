//
//  Config.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 15.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import Foundation

class Config{
    
    init(){
        
        self.mobileAcademy_blue = "#005a7c"
        self.mobileAcademy_green = "#7FC24F"
        self.servicePass = "*******"
        self.iosPlatformID = 2
        self.nullForService = "-"
        
    }
    
    var mobileAcademy_blue = "#005a7c"
    var mobileAcademy_green = "#7FC24F"
    static var userMA_Valid: UserMA!
    var servicePass = "******"
    var nullForService = "-"
    var iosPlatformID = 2
    
}


var configVar = Config()

