//
//  Utilities.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 15.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import Foundation
import CRToast
import MaterialKit
import CustomIOSAlertView
import MMMaterialDesignSpinner
import SystemConfiguration

func isValidEmail(testStr:String) -> Bool {
    // println("validate calendar: \(testStr)")
    let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(testStr)
}

func showToast(mode:Int, text:String){
    let options: NSMutableDictionary = [
        kCRToastTextKey : text,
        kCRToastAnimationInDirectionKey : CRToastAnimationDirection.Left.rawValue,
        kCRToastAnimationInTypeKey : CRToastAnimationType.Linear.rawValue,
        kCRToastAnimationOutDirectionKey : CRToastAnimationDirection.Right.rawValue,
        kCRToastAnimationOutTypeKey : CRToastAnimationType.Linear.rawValue,
        kCRToastNotificationPresentationTypeKey : CRToastPresentationType.Push.hashValue,
        kCRToastNotificationTypeKey : CRToastType.NavigationBar.rawValue,
        kCRToastTextAlignmentKey : NSTextAlignment.Left.rawValue,
        kCRToastTimeIntervalKey : 2,
        kCRToastUnderStatusBarKey : NSNumber(bool: false),
        kCRToastBackgroundColorKey : UIColor.orangeColor(),
        kCRToastImageKey : UIImage(named:"WarningToast")!
    ]
    if(mode == 1){
        options.setObject(UIColor.colorFromRGB(0x7FC24F), forKey: kCRToastBackgroundColorKey)
        options.setObject(UIImage(named:"SuccessToast")!, forKey: kCRToastImageKey)
    }else if(mode == 2){
        options.setObject(UIColor.orangeColor(), forKey: kCRToastBackgroundColorKey)
        options.setObject(UIImage(named:"WarningToast")!, forKey: kCRToastImageKey)
    }else if(mode == 3){
        options.setObject(UIColor.redColor(), forKey: kCRToastBackgroundColorKey)
        options.setObject(UIImage(named:"ErrorToast")!, forKey: kCRToastImageKey)
    }
    CRToastManager.showNotificationWithOptions(options as [NSObject : AnyObject], completionBlock: {})
}

func showLoadingDialogIndeterminate_Util() -> CustomIOSAlertView{
    
    let customAlert = CustomIOSAlertView()
    customAlert.buttonTitles = nil
    let loadingDialogView = LoadingDialogView()
    let loadingContainer = loadingDialogView.loadViewFromNib()
    var materialSpinner: MMMaterialDesignSpinner!
    
    for v in loadingContainer.subviews {
        if(v is MMMaterialDesignSpinner){
            if(v.tag == 1){
                materialSpinner = v as! MMMaterialDesignSpinner
            }
        }
        
    }
    
    materialSpinner.lineWidth = CGFloat(4)
    materialSpinner.startAnimating()
    customAlert.containerView = loadingContainer
    customAlert.show()
    
    return customAlert
}


func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
