//
//  ViewController.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 13.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//


import UIKit
import MaterialKit
import CustomIOSAlertView
import CRToast
import MMMaterialDesignSpinner
import IQKeyboardManager

class LoginViewController: UIViewController,Wsdl2CodeProxyDelegate,GIDSignInUIDelegate,GIDSignInDelegate{
    
    
    
    
    var service: MAServiceProxy!
    let servicePass = "*****"
    let nullForService = "-"
    let iosPlatformID = "2"
    
    var customAlert: CustomIOSAlertView!
    var spinnerContainer: UIView!
    var materialSpinner: MMMaterialDesignSpinner!
    
    
    var userMA:UserMA = UserMA()
    
    //facebooklogin
    var profil : FBSDKProfile!
    
    
    
    
    @IBOutlet weak var tf_emailAdress: MKTextField!
    @IBOutlet weak var tf_password: MKTextField!
    @IBOutlet weak var uiViewButton_Login: UIView!
    @IBOutlet weak var uiViewButton_GoogleLogin: UIView!
    @IBOutlet weak var uiViewButton_FacebookLogin: UIView!
    @IBOutlet weak var uiViewButton_FirstTimeUser: UIView!
    
    var passUser: String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = UIColor(hex: 0x005a7c)
        //        navBar.barTintColor = UIColor(red: 0 / 255.0, green: 90.0 / 255.0, blue: 124.0 / 255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        loadUserMA()
        
        if(userMA.registerType == "-"){
            print("user yok")
        }else{
            print("user var  !!! \(userMA.fullName)")
            openMenuAndSetUser()
            return
        }
        
        
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        setWebService()
        setViews()
        setUIViewButtons()
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func setUIViewButtons(){
        let loginemailRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.loginEmailButtonRecognizer(_:)))
        loginemailRecognizer.numberOfTapsRequired = 1
        uiViewButton_Login.addGestureRecognizer(loginemailRecognizer)
        
        let loginGoogleRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.loginGoogleButtonRecognizer(_:)))
        loginGoogleRecognizer.numberOfTapsRequired = 1
        uiViewButton_GoogleLogin.addGestureRecognizer(loginGoogleRecognizer)
        
        let loginFBRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.loginFacebookButtonRecognizer(_:)))
        loginFBRecognizer.numberOfTapsRequired = 1
        uiViewButton_FacebookLogin.addGestureRecognizer(loginFBRecognizer)
        
        let registerRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.registerButtonRecognizer(_:)))
        registerRecognizer.numberOfTapsRequired = 1
        uiViewButton_FirstTimeUser.addGestureRecognizer(registerRecognizer)
    }
    
    
    func setWebService(){
        
        self.service = MAServiceProxy(url: "******", andDelegate: self)
        self.service.service.timeout = 15
    }
    
    func setViews(){
        tf_emailAdress.layer.borderColor = UIColor.clearColor().CGColor
        tf_password.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    func registerButtonRecognizer(gestureRecognizer: UITapGestureRecognizer){
        performSegueWithIdentifier("toRegisterSegue", sender: uiViewButton_FirstTimeUser)
    }
    
    func loginEmailButtonRecognizer(gestureRecognizer: UITapGestureRecognizer){
        print("tap")
        let emailText = tf_emailAdress.text
        let passText = tf_password.text
        passUser = passText
        
        if(!isValidEmail(emailText!)){
            showToast(2, text: "Email adress is not valid")
            return
        }
        
        if(passText?.characters.count < 4){
            showToast(2, text: "Password length cannot be less than 3 characters")
            return
        }
        
        showLoadingDialog()
        service.LoginWithEmailPassword(servicePass, emailText, passText)
        
    }
    
    func loginFacebookButtonRecognizer(gestureRecognizer: UITapGestureRecognizer){
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile", "email", "user_education_history"], fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if(error != nil){
                print(error.localizedDescription)
            }else{
                //fb login succes
                
                if((FBSDKAccessToken.currentAccessToken()) != nil){
                    
                    FBSDKGraphRequest(graphPath: "me", parameters:["fields": "first_name, last_name, name, id, email, education, gender, locale"]).startWithCompletionHandler{ (connection, result, error) -> Void in
                        
                        if(error != nil){
                            self.service.sendFeedback(self.servicePass, 80, 2, "iOS Facebook login hatası otomatik bildirim: \(error.description)   - DebugDesc: \(error.debugDescription)", 0)
                            SweetAlert().showAlert("Oops", subTitle: "Something went wrong.We're working on it!", style: AlertStyle.Error)
                            return
                        }
                        
                        self.profil = FBSDKProfile.currentProfile()
                        
                        NSLog("fetched user:\(result)")
                        self.userMA.email = result["email"] as! String
                        self.userMA.fbID = result["id"] as! String
                        self.userMA.gender = result["gender"] as! String
                        
                        self.userMA.firstName = self.profil.firstName
                        self.userMA.lastName = self.profil.lastName
                        self.userMA.fullName = self.profil.name
                        
                        //                        var deneme = result["education"]
                        //                        NSLog("deneme: \(deneme)")
                        
                        if(result["education"] != nil){
                            
                            let arr : NSArray! = result["education"] as! NSArray
                            //                NSLog("sayı: \(arr.count)")
                            
                            for edu in arr{
                                let schoolName :String = (edu["school"] as! NSDictionary).objectForKey("name") as! String
                                let type : String = (edu["type"] as! String)
                                
                                if(type == "College"){
                                    
                                    self.userMA.university = schoolName
                                }
                            }
                        }else{
                            self.userMA.university = "-"
                            
                        }
                        
                        
                        self.showLoadingDialog()
                        self.service.LoginWithFacebook(self.servicePass, self.userMA.firstName, self.userMA.lastName, self.userMA.email, self.nullForService, self.userMA.university, self.userMA.gender.substringToIndex(self.userMA.gender.startIndex.advancedBy(1)), self.iosPlatformID, self.userMA.fbID)
                        
                        
                    }
                    
                }
                
                
            }
        }
    }
    
    func loginGoogleButtonRecognizer(gestureRecognizer: UITapGestureRecognizer){
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            let userId = user.userID
            
            userMA.fullName = user.profile.name
            userMA.email = user.profile.email
            if(user.profile.hasImage){
                userMA.googlePhotoURL = user.profile.imageURLWithDimension(150).absoluteString
            }
            
            var firstName = ""
            var lastname = ""
            
            let fullNameArr = userMA.fullName.characters.split { $0 == " " }.map(String.init)
            
            
            
            if(fullNameArr.count <= 2){
                firstName = fullNameArr[0]
                lastname = fullNameArr[1]
            }else{
                for nm in fullNameArr{
                    if(nm != fullNameArr[fullNameArr.count - 1]){
                        firstName+="\(nm) "
                    }
                }
            }
            
            userMA.firstName = firstName
            userMA.lastName = lastname
            userMA.GPLink = userId
            
            showLoadingDialog()
            service.LoginWithGoogleV2(servicePass, userMA.firstName, userMA.lastName, userMA.email, nullForService, nullForService, nullForService, iosPlatformID, userMA.GPLink,userMA.googlePhotoURL)
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //        customAlert.close()
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func showLoadingDialog(){
        
        customAlert = CustomIOSAlertView()
        customAlert.buttonTitles = nil
        let loadingDialogView = LoadingDialogView()
        let loadingContainer = loadingDialogView.loadViewFromNib()
        
        for v in loadingContainer.subviews {
            if(v is MMMaterialDesignSpinner){
                if(v.tag == 1){
                    self.materialSpinner = v as! MMMaterialDesignSpinner
                }
            }
            
        }
        materialSpinner.lineWidth = CGFloat(4)
        materialSpinner.startAnimating()
        customAlert.containerView = loadingContainer
        customAlert.show()
    }
    
    
    
    
    func proxydidFinishLoadingData(data: AnyObject!, inMethod method: String!) {
        
        customAlert.close()
        
        
        
        let response: ResponseMA = data as! ResponseMA
        
        if(!response.success){
            SweetAlert().showAlert("Oops", subTitle: "Something went wrong.We're working on it!", style: AlertStyle.Error)
            return
        }
        
        switch(method){
        case "LoginWithEmailPassword":
            print("Email login geldi : \(response.message)")
            
            
            if(response.status.statusCode == "201"){
                
                userMA.registerType = "m"
                userMA.fullName = "\(response.user.name) \(response.user.surname)"
                userMA.coin = Int(response.user.coin)
                userMA.email = response.user.email
                userMA.fbID = "-"
                userMA.firstName = response.user.name
                userMA.gender = response.user.gender
                userMA.GPLink = "-"
                userMA.lastName = response.user.surname
                userMA.nickname = response.user.nickname
                userMA.password = self.passUser
                userMA.university = response.user.school
                userMA.userId = Int(response.user.userId)
                userMA.userTypeID = 1
                
                saveUserMA()
                
                openMenuAndSetUser()
                
                //                let storeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("menuNavController")
                //                self.presentViewController(storeViewController!, animated: true, completion: nil)
                
                
                tf_password.resignFirstResponder()
                
                
                return
            }
            
            if(response.status.statusCode == "203"){
                SweetAlert().showAlert("Banned", subTitle: "You are banned from the Mobile Academy.If you think there is a mistake please contact with us from mobileacademycontact@gmail.com", style: AlertStyle.Error)
            }else if(response.status.statusCode == "202"){
                SweetAlert().showAlert("Not Activated", subTitle: "Your account has not been activated.Activation link will be sent to your email adress again.", style: AlertStyle.Warning)
            }else if(response.status.statusCode == "99"){
                SweetAlert().showAlert("Oops", subTitle: "Something went wrong.We're working on it!", style: AlertStyle.Error)
            }else if(response.status.statusCode == "206"){
                showToast(3, text: "Email adress or password is incorrect")
            }else if(response.status.statusCode == "204"){
                showToast(3, text: "Email adress or password is incorrect")
            }
            
            break
        case "LoginWithGoogleV2":
            print("Google login geldi : \(response.message)")
            
            userMA.registerType = "g"
            userMA.fullName = "\(response.user.name) \(response.user.surname)"
            userMA.coin = Int(response.user.coin)
            userMA.email = response.user.email
            userMA.fbID = response.user.fbID
            userMA.firstName = response.user.name
            userMA.gender = response.user.gender
            userMA.GPLink = response.user.gPLink
            userMA.lastName = response.user.surname
            userMA.nickname = response.user.nickname
            userMA.password = "-"
            userMA.university = response.user.school
            userMA.userId = Int(response.user.userId)
            userMA.userTypeID = 1
            
            saveUserMA()
            
            openMenuAndSetUser()
            
            
            break
        case "LoginWithFacebook":
            print("Facebook login geldi : \(response.message)")
            
            userMA.registerType = "f"
            userMA.fullName = "\(response.user.name) \(response.user.surname)"
            userMA.coin = Int(response.user.coin)
            userMA.email = response.user.email
            userMA.fbID = response.user.fbID
            userMA.firstName = response.user.name
            userMA.gender = response.user.gender
            userMA.GPLink = response.user.gPLink
            userMA.lastName = response.user.surname
            userMA.nickname = response.user.nickname
            userMA.password = "-"
            userMA.university = response.user.school
            userMA.userId = Int(response.user.userId)
            userMA.userTypeID = 1
            
            saveUserMA()
            
            openMenuAndSetUser()
            
            break
        default:
            break
        }
        
    }
    
    func proxyRecievedError(ex: NSException!, inMethod method: String!) {
        print("proxyReceievedError")
        SweetAlert().showAlert("Oops", subTitle: "Something went wrong.We're working on it!", style: AlertStyle.Error)
    }
    
    func openMenuAndSetUser(){
        Config.userMA_Valid = userMA
        let appdel = UIApplication.sharedApplication().delegate as! AppDelegate
        appdel.setMenuView(self)
    }
    
    
    
    
    
    func saveUserMA(){
        let encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(userMA)
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject(encodedObject, forKey: "userMA_")
        def.synchronize()
    }
    
    func loadUserMA(){
        
        let def = NSUserDefaults.standardUserDefaults()
        let tempUser: AnyObject? = def.objectForKey("userMA_")
        if(tempUser == nil){
            self.userMA.registerType = "-"
        }else{
            let encodedObject: NSData = def.objectForKey("userMA_") as! NSData
            let objUser: UserMA = NSKeyedUnarchiver.unarchiveObjectWithData(encodedObject) as! UserMA
            self.userMA = objUser
        }
        
    }
    
    
}

