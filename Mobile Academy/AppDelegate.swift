//
//  AppDelegate.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 13.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit
import MaterialKit
import CustomIOSAlertView
import CRToast
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TGLGuillotineMenuDelegate,Wsdl2CodeProxyDelegate  {
    
    var window: UIWindow?
    var menuVC: TGLGuillotineMenu!
    var userMAApp: UserMA!
    
    var service: MAServiceProxy!
    var customAlert: CustomIOSAlertView!
    var textFB: PlaceholderTextView!
    var floatRatingView: FloatRatingView!
    
    var fbProfilePic: FBSDKProfilePictureView!
    var letterProfilePic: UIImageView!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        IQKeyboardManager.sharedManager().enable = true
        
        
        return true
    }
    
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if(self.window?.rootViewController is UINavigationController){
            
            if (self.window?.rootViewController as! UINavigationController).visibleViewController is DocumentViewController {
                return UIInterfaceOrientationMask.All;
            } else {
                return UIInterfaceOrientationMask.Portrait;
            }
        }
        
        return UIInterfaceOrientationMask.Portrait;
        
    }
    
    func setMenuView(vc: UIViewController){
        
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        let vcStore = vc.storyboard?.instantiateViewControllerWithIdentifier("storeViewController") as! StoreViewController
        let vcLib = vc.storyboard?.instantiateViewControllerWithIdentifier("libraryViewController") as! LibraryViewController
        let vcPro = vc.storyboard?.instantiateViewControllerWithIdentifier("editProfileViewController") as! EditProfileViewController
        
        let vcArray: [AnyObject] = [vcStore,vcLib,vcPro]
        let titleArray: [AnyObject] = ["Store","Library","Profile"]
        let imageArray: [AnyObject] = ["MenuStore","MenuLibrary","MenuProfile"]
        
        menuVC = TGLGuillotineMenu(viewControllers: vcArray, menuTitles: titleArray, andImagesTitles: imageArray, andStyle: TGLGuillotineMenuStyle.Table)
        menuVC.delegate = self
        
        let navController = UINavigationController(rootViewController: menuVC)
        
        let frameS = UIScreen.mainScreen().bounds
        
        
        
        self.window = UIWindow(frame: frameS)
        self.window?.rootViewController = navController
        self.window?.backgroundColor = UIColor.clearColor()
        self.window?.makeKeyAndVisible()
        
        
        
        
    }
    
    
    
    func setButtonAndLabels(menuVc: TGLGuillotineMenu){
        
        var labelName: UILabel!
        var labelSchool: UILabel!
        var closeButton: UIButton!
        var logOutButton: UIButton!
        var feedbackButton: UIView!
        var pictureUIView: UIView!
        
        
        for v in menuVc.getMenuView().subviews {
            if(v is UILabel){
                if(v.tag == 5){
                    labelSchool = v as! UILabel
                }else if(v.tag == 6){
                    labelName = v as! UILabel
                }
            }else if(v is UIButton){
                if(v.tag == 3){
                    closeButton = v as! UIButton
                }else if(v.tag == 4){
                    logOutButton = v as! UIButton
                }
            }else if(v is UIView){
                if(v.tag == 7){
                    feedbackButton = v
                }else if (v.tag == 8){
                    pictureUIView = v
                }
            }
        }
        
        loadUserMA()
        
        labelName.text = self.userMAApp.fullName
        labelSchool.text = self.userMAApp.university
        closeButton.addTarget(self, action: #selector(AppDelegate.closeMenuButton), forControlEvents: UIControlEvents.TouchUpInside)
        logOutButton.addTarget(self, action: #selector(AppDelegate.logOutButton), forControlEvents: UIControlEvents.TouchUpInside)
        
        let feedbackRecog = UITapGestureRecognizer(target: self, action: #selector(AppDelegate.sendFeedbackButton(_:)))
        feedbackRecog.numberOfTapsRequired = 1
        feedbackButton.addGestureRecognizer(feedbackRecog)
        
        let frm = CGRectMake(0, 0, 54, 54)
        
        if(self.userMAApp.registerType == "f"){
            fbProfilePic = FBSDKProfilePictureView(frame: frm)
            pictureUIView.addSubview(fbProfilePic)
            fbProfilePic.profileID = self.userMAApp.fbID
            fbProfilePic.layer.cornerRadius = fbProfilePic.frame.size.height / 2
            fbProfilePic.layer.masksToBounds = true
            fbProfilePic.layer.borderWidth = 0
        }else if(self.userMAApp.registerType == "g"){
            letterProfilePic = UIImageView(frame: frm)
                if(userMAApp.googlePhotoURL != "-"){
                    letterProfilePic = UIImageView(frame: frm)
                    letterProfilePic.sd_setImageWithURL(NSURL(string: userMAApp.googlePhotoURL))
                    pictureUIView.addSubview(letterProfilePic)
                    letterProfilePic.layer.cornerRadius = letterProfilePic.frame.size.height / 2
                    letterProfilePic.layer.masksToBounds = true
                    letterProfilePic.layer.borderWidth = 0
                }else{
                    letterProfilePic = UIImageView(frame: frm)
                    letterProfilePic.setImageWithString(self.userMAApp.fullName, color: nil, circular: true)
                    pictureUIView.addSubview(letterProfilePic)
            }
    
        }else{
            letterProfilePic = UIImageView(frame: frm)
            letterProfilePic.setImageWithString(self.userMAApp.fullName, color: nil, circular: true)
            pictureUIView.addSubview(letterProfilePic)
        }
        
        
        
        
    }
    
    func sendFeedbackButton(gestureRecog: UITapGestureRecognizer){
        
        if(!isConnectedToNetwork()){
            SweetAlert().showAlert("Offline Mode", subTitle: "You can not send feedback in offline mode.", style: AlertStyle.Warning, buttonTitle: "OK")
            return
        }
        
        let sendfbview: UIView! = SendFeedbackUIView().loadViewFromNib()
        self.customAlert = CustomIOSAlertView()
        self.customAlert.buttonTitles = nil
        
        var sendView: UIView!
        var closeView: UIView!
        
        
        
        
        for v in sendfbview.subviews {
            if(v is PlaceholderTextView){
                if(v.tag == 0){
                    textFB = v as! PlaceholderTextView
                }
            }else if(v is FloatRatingView){
                if(v.tag == 1){
                    floatRatingView = v as! FloatRatingView
                }
            }else if(v is UIView){
                if(v.tag == 2){
                    sendView = v
                }else if(v.tag == 3){
                    closeView = v
                }
            }
        }
        
        let sendRecog = UITapGestureRecognizer(target: self, action: #selector(AppDelegate.sendButtonClick(_:)))
        sendRecog.numberOfTapsRequired = 1
        sendView.addGestureRecognizer(sendRecog)
        
        let closeRecog = UITapGestureRecognizer(target: self, action: #selector(AppDelegate.cancelButtonClick(_:)))
        closeRecog.numberOfTapsRequired = 1
        closeView.addGestureRecognizer(closeRecog)
        
        
        
        self.service = MAServiceProxy(url: "http://kcdroid.com/MobilAkademi/Service/MAService.asmx", andDelegate: self)
        self.service.service.timeout = 15
        
        
        
        self.customAlert.containerView = sendfbview
        self.customAlert.show()
        
        
        
    }
    
    func sendButtonClick(gestureRecog: UITapGestureRecognizer){
        
        service.sendFeedback(configVar.servicePass, Int32(userMAApp.userId), Int32(configVar.iosPlatformID), textFB.text, Int32(floatRatingView.rating))
        self.customAlert.close()
        showToast(1, text: "Your feedback has been sent. Thank you!")
        
    }
    
    func cancelButtonClick(gestureRecog: UITapGestureRecognizer){
        self.customAlert.close()
    }
    
    func closeMenuButton(){
        
        menuVC.dismissMenu()
        
    }
    
    func logOutButton(){
        
        saveUserMAUnRegister()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vcLoginNav = mainStoryboard.instantiateViewControllerWithIdentifier("loginNavController") as! UINavigationController
        
        let frameS = UIScreen.mainScreen().bounds
        self.window = UIWindow(frame: frameS)
        self.window?.rootViewController = vcLoginNav
        self.window?.backgroundColor = UIColor.clearColor()
        self.window?.makeKeyAndVisible()
        
    }
    
    func loadUserMA(){
        self.userMAApp = UserMA()
        let def = NSUserDefaults.standardUserDefaults()
        let tempUser: AnyObject? = def.objectForKey("userMA_")
        if(tempUser == nil){
            self.userMAApp.registerType = "-"
        }else{
            let encodedObject: NSData = def.objectForKey("userMA_") as! NSData
            let objUser: UserMA = NSKeyedUnarchiver.unarchiveObjectWithData(encodedObject) as! UserMA
            self.userMAApp = objUser
        }
        
    }
    
    
    func saveUserMAUnRegister(){
        let userMA = UserMA()
        userMA.registerType = "-"
        let encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(userMA)
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject(encodedObject, forKey: "userMA_")
        def.synchronize()
    }
    
    
    func menuDidOpen() {
        
        
        print("didopen geldi")
        setButtonAndLabels(menuVC)
        
        
        
    }
    
    func menuDidClose() {
        
    }
    
    func selectedMenuItemAtIndex(index: Int) {
        
    }
    
    
    
    //Google Login
    @available(iOS 9.0, *)
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String, annotation: nil)  || GIDSignIn.sharedInstance().handleURL(url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    //for IOS 8
    @available(iOS, introduced=8.0, deprecated=9.0)
    func application(application: UIApplication,
                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        //            return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication!, annotation: annotation)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: nil)  ||
            GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication!, annotation: annotation)
        
    }
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func proxydidFinishLoadingData(data: AnyObject!, inMethod method: String!) {
        
    }
    
    func proxyRecievedError(ex: NSException!, inMethod method: String!) {
        
    }
    
    
}

