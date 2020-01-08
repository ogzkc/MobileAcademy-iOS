//
//  User.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 20.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import Foundation

class UserMA: NSObject,NSCoding {
    
    var fbID = "-"
    var firstName = "-"
    var lastName = "-"
    var email = "-"
    var userId = 0
    var gender = "-"
    var fullName = "-"
    var password = "-"
    var nickname = "-"
    var university = "-"
    var registerType = "-"
    var userTypeID = 0
    var coin = 0
    var GPLink = "-"
    var googlePhotoURL = "-"
    
    override init(){
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fbID = aDecoder.decodeObjectForKey("fbID") as! String
        firstName = aDecoder.decodeObjectForKey("firstName") as! String
        lastName = aDecoder.decodeObjectForKey("lastName") as! String
        email = aDecoder.decodeObjectForKey("email") as! String
        userId = aDecoder.decodeObjectForKey("userId") as! Int
        gender = aDecoder.decodeObjectForKey("gender") as! String
        fullName = aDecoder.decodeObjectForKey("fullName") as! String
        password = aDecoder.decodeObjectForKey("password") as! String
        nickname = aDecoder.decodeObjectForKey("nickname") as! String
        university = aDecoder.decodeObjectForKey("university") as! String
        registerType = aDecoder.decodeObjectForKey("registerType") as! String
        userTypeID = aDecoder.decodeObjectForKey("userTypeID") as! Int
        coin = aDecoder.decodeObjectForKey("coin") as! Int
        GPLink = aDecoder.decodeObjectForKey("GPLink") as! String
        if(aDecoder.containsValueForKey("googlePhotoURL")){
            googlePhotoURL = aDecoder.decodeObjectForKey("googlePhotoURL") as! String
        }

    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(fbID, forKey: "fbID")
        aCoder.encodeObject(firstName, forKey: "firstName")
        aCoder.encodeObject(lastName, forKey: "lastName")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(userId, forKey: "userId")
        aCoder.encodeObject(gender, forKey: "gender")
        aCoder.encodeObject(fullName, forKey: "fullName")
        aCoder.encodeObject(password, forKey: "password")
        aCoder.encodeObject(nickname, forKey: "nickname")
        aCoder.encodeObject(university, forKey: "university")
        aCoder.encodeObject(registerType, forKey: "registerType")
        aCoder.encodeObject(userTypeID, forKey: "userTypeID")
        aCoder.encodeObject(coin, forKey: "coin")
        aCoder.encodeObject(GPLink, forKey: "GPLink")
        aCoder.encodeObject(googlePhotoURL, forKey: "googlePhotoURL")
        
    }
    
}