//
//  EditProfileViewController.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 23.04.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit
import MaterialKit
import CustomIOSAlertView
import CRToast
import MMMaterialDesignSpinner

class EditProfileViewController: UIViewController, Wsdl2CodeProxyDelegate {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelSchool: UILabel!
    @IBOutlet weak var labelCoin: UILabel!
    @IBOutlet weak var emailTF: MKTextField!
    @IBOutlet weak var nameTF: MKTextField!
    @IBOutlet weak var surnameTF: MKTextField!
    @IBOutlet weak var schoolTF: MKTextField!
    @IBOutlet weak var updateProfileView: UIView!
    @IBOutlet weak var nicknameTF: MKTextField!
    @IBOutlet weak var profileImageView: UIView!
    
    var fbProfilePic: FBSDKProfilePictureView!
    var letterProfilePic: UIImageView!
    
    var customAlert: CustomIOSAlertView!
    var service: MAServiceProxy!

    override func viewDidLoad() {
        super.viewDidLoad()

        setViews()
        setWebService()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    
    func setViews(){
        
        let updateRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.updateButtonRecognizer(_:)))
        updateRecognizer.numberOfTapsRequired = 1
        updateProfileView.addGestureRecognizer(updateRecognizer)
        
        labelName.text = Config.userMA_Valid.fullName
        labelSchool.text = Config.userMA_Valid.university
        labelCoin.text = "Coin: \(Config.userMA_Valid.coin)"
        
        if(Config.userMA_Valid.email != "-"){
            emailTF.text = Config.userMA_Valid.email
        }
        
        if(Config.userMA_Valid.firstName != "-"){
            nameTF.text = Config.userMA_Valid.firstName
        }
        
        if(Config.userMA_Valid.lastName != "-"){
            surnameTF.text = Config.userMA_Valid.lastName
        }
        
        if(Config.userMA_Valid.university != "-"){
            schoolTF.text = Config.userMA_Valid.university
        }
        
        if(Config.userMA_Valid.nickname != "-"){
            nicknameTF.text = Config.userMA_Valid.nickname
        }
        
        let frm = CGRectMake(0, 0, 54, 54)
        
        if(Config.userMA_Valid.registerType == "f"){
            fbProfilePic = FBSDKProfilePictureView(frame: frm)
            profileImageView.addSubview(fbProfilePic)
            fbProfilePic.profileID = Config.userMA_Valid.fbID
            fbProfilePic.layer.cornerRadius = fbProfilePic.frame.size.height / 2
            fbProfilePic.layer.masksToBounds = true
            fbProfilePic.layer.borderWidth = 0
        }else if(Config.userMA_Valid.registerType == "g"){
            letterProfilePic = UIImageView(frame: frm)
            if(Config.userMA_Valid.googlePhotoURL != "-"){
                letterProfilePic = UIImageView(frame: frm)
                letterProfilePic.sd_setImageWithURL(NSURL(string: Config.userMA_Valid.googlePhotoURL))
                profileImageView.addSubview(letterProfilePic)
                letterProfilePic.layer.cornerRadius = letterProfilePic.frame.size.height / 2
                letterProfilePic.layer.masksToBounds = true
                letterProfilePic.layer.borderWidth = 0
            }else{
                letterProfilePic = UIImageView(frame: frm)
                letterProfilePic.setImageWithString(Config.userMA_Valid.fullName, color: nil, circular: true)
                profileImageView.addSubview(letterProfilePic)
            }
            
        }else{
            letterProfilePic = UIImageView(frame: frm)
            letterProfilePic.setImageWithString(Config.userMA_Valid.fullName, color: nil, circular: true)
            profileImageView.addSubview(letterProfilePic)
        }
        
        
    }
    
    
    func setWebService(){
        self.service = MAServiceProxy(url: "****", andDelegate: self)
        self.service.service.timeout = 15
        
    }
    
    func updateButtonRecognizer(gestureRecognizer: UITapGestureRecognizer){
        
        if(!isConnectedToNetwork()){
            SweetAlert().showAlert("Offline Mode", subTitle: "You can not update your profile in offline mode.", style: AlertStyle.Warning, buttonTitle: "OK")
            return
        }
        
        if(Config.userMA_Valid.email != "-"){
            if((emailTF.text?.isEmpty)!){
                showToast(2, text: "Email field cannot be empty.")
                return
            }
        }
        
        customAlert = showLoadingDialogIndeterminate_Util()
        if(Config.userMA_Valid.registerType == "f"){
        service.updateUser(configVar.servicePass, Int32(Config.userMA_Valid.userId),Config.userMA_Valid.registerType, Config.userMA_Valid.fbID, configVar.nullForService, configVar.nullForService, self.nameTF.text, self.surnameTF.text, self.emailTF.text, configVar.nullForService, self.schoolTF.text, Config.userMA_Valid.gender, self.nicknameTF.text, "-")
        }else if(Config.userMA_Valid.registerType == "g"){
            service.updateUser(configVar.servicePass, Int32(Config.userMA_Valid.userId),Config.userMA_Valid.registerType, Config.userMA_Valid.GPLink, configVar.nullForService, configVar.nullForService, self.nameTF.text, self.surnameTF.text, self.emailTF.text, configVar.nullForService, self.schoolTF.text, Config.userMA_Valid.gender, self.nicknameTF.text, "-")
        }else if(Config.userMA_Valid.registerType == "m"){
            service.updateUser(configVar.servicePass, Int32(Config.userMA_Valid.userId),Config.userMA_Valid.registerType, configVar.nullForService, Config.userMA_Valid.email, Config.userMA_Valid.password, self.nameTF.text, self.surnameTF.text, self.emailTF.text, Config.userMA_Valid.password, self.schoolTF.text, Config.userMA_Valid.gender, self.nicknameTF.text, "-")
        }
        
        
    }
    
    
   
    
    func proxydidFinishLoadingData(data: AnyObject!, inMethod method: String!) {
        
        customAlert.close()
        let resp: ResponseMA! = data as! ResponseMA
        if(resp.success){
            if(resp.status.statusCode == "801"){
                
                if(!(nameTF.text?.isEmpty)!){
                    Config.userMA_Valid.firstName = nameTF.text!
                }else{
                    Config.userMA_Valid.firstName = "-"
                }
                
                if(!(surnameTF.text?.isEmpty)!){
                    Config.userMA_Valid.lastName = surnameTF.text!
                }else{
                    Config.userMA_Valid.lastName = "-"
                }
                
                if(!(emailTF.text?.isEmpty)!){
                    Config.userMA_Valid.email = emailTF.text!
                }else{
                    Config.userMA_Valid.email = "-"
                }
                
                if(!(nicknameTF.text?.isEmpty)!){
                    Config.userMA_Valid.nickname = nicknameTF.text!
                }else{
                    Config.userMA_Valid.nickname = "-"
                }
                
                if(!(schoolTF.text?.isEmpty)!){
                    Config.userMA_Valid.university = schoolTF.text!
                }else{
                    Config.userMA_Valid.university = "-"
                }
                
                Config.userMA_Valid.fullName = Config.userMA_Valid.firstName + " " + Config.userMA_Valid.lastName
                
                saveUserMA()
                
                showToast(1, text: "Your profile has been updated.")
            }else if(resp.status.statusCode == "207"){
                showToast(3, text: "User cannot login, please contact with us.")
            }
        }else{
            showToast(3, text: "There went something wrong in server, please try again later.")
        }

        
    }
    
    func proxyRecievedError(ex: NSException!, inMethod method: String!) {
        
        customAlert.close()
        showToast(3, text: "There went something wrong in server, please try again later.")
        
    }
    
    func saveUserMA(){
        let encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(Config.userMA_Valid)
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject(encodedObject, forKey: "userMA_")
        def.synchronize()
    }

}
