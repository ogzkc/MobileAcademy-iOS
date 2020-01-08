//
//  RegisterViewController.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 22.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit
import MaterialKit
import CustomIOSAlertView
import MMMaterialDesignSpinner

class RegisterViewController: UIViewController,Wsdl2CodeProxyDelegate {
    
    
    @IBOutlet weak var maleRadioButton: DLRadioButton!
    @IBOutlet weak var femaleRadioButton: DLRadioButton!
    @IBOutlet weak var uiViewButtonRegister: UIView!
    
    @IBOutlet weak var emailAdressTF: MKTextField!
    @IBOutlet weak var passwordTF: MKTextField!
    @IBOutlet weak var password2TF: MKTextField!
    @IBOutlet weak var nameTF: MKTextField!
    @IBOutlet weak var surnameTF: MKTextField!
    @IBOutlet weak var schoolTF: MKTextField!
    
    
    var userMA: UserMA!
    
    
    
    var service: MAServiceProxy!
    let servicePass = "*****"
    let nullForService = "-"
    let iosPlatformID = "2"
    
    var customAlert: CustomIOSAlertView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        self.service = MAServiceProxy(url: "http://kcdroid.com/MobilAkademi/Service/MAService.asmx", andDelegate: self)
        
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = UIColor(hex: 0x005a7c)
        //        navBar.barTintColor = UIColor(red: 0 / 255.0, green: 90.0 / 255.0, blue: 124.0 / 255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
//        let framee = self.password2TF.frame
//        self.nameTF.frame = CGRectMake(framee.origin.x, framee.origin.y, framee.size.width, framee.size.height)
//        self.nameTF.removeConstraints(self.nameTF.constraints)
//        
//        TGLGuillotineMenu().copyConstraintsFromView(self.password2TF, toView: self.nameTF)
//        
//        self.password2TF.removeFromSuperview()

    }
    
    
    
    func setViews(){
        
        let registerRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.registerButton(_:)))
        registerRecognizer.numberOfTapsRequired = 1
        uiViewButtonRegister.addGestureRecognizer(registerRecognizer)
        
    }
    
    func registerButton(gestureRecognizer: UITapGestureRecognizer){
        
        var emailTxt = emailAdressTF.text
        var passTxt = passwordTF.text
        var nameTxt = nameTF.text
        var surnameTxt = surnameTF.text
        var schoolTxt = schoolTF.text
        var gender = "-"
        
        
        if(emailAdressTF.text!.isEmpty || passwordTF.text!.isEmpty || password2TF.text!.isEmpty){
            showToast(2, text: "Email Adress and Password are required fields.")
            return
        }
        
        if(!isValidEmail(emailAdressTF.text!)){
            showToast(2, text: "Email Adress is not valid.")
            return
        }
        
        if(passwordTF.text!.characters.count < 4){
            showToast(2, text: "Password must be 4 characters at least.")
            return
        }
        
        if(passwordTF.text! != password2TF.text!){
            showToast(2, text: "Passwords are not match.")
            return
        }
        
        if(maleRadioButton.selected){
            gender = "m"
        }else if(femaleRadioButton.selected){
            gender = "f"
        }
        
        if(nameTxt!.isEmpty){
            nameTxt = "-"
        }
        if(surnameTxt!.isEmpty){
            surnameTxt = "-"
        }
        if(schoolTxt!.isEmpty){
            schoolTxt = "-"
        }
        
        
        customAlert = showLoadingDialogIndeterminate_Util()
        service.RegisterWithEmail(servicePass, nameTxt, surnameTxt, emailTxt, passTxt, schoolTxt, gender, iosPlatformID)
        
        
    }
    
    
    
    
    func proxydidFinishLoadingData(data: AnyObject!, inMethod method: String!) {
        
        customAlert.close()
   
        let response = data as! ResponseMA
        
        if(!response.success){
            SweetAlert().showAlert("Oops", subTitle: "Something went wrong.We're working on it!", style: AlertStyle.Error)
        }
        
        switch(method){
        case "RegisterWithEmail":
            print("Register cevap geldi : \(response.message) Status Code: \(response.status.statusCode)")
            
            

            
            if(response.status.statusCode == "302"){
                SweetAlert().showAlert("Welcome!", subTitle: "Your account has been created succesfully.Activation link has been sent to your email adress.", style: AlertStyle.Success, buttonTitle: "OK", action: { (isOtherButton) in
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            }else if(response.status.statusCode == "303"){
                SweetAlert().showAlert("Welcome!", subTitle: "Your account has been created succesfully.You can log in to Mobile Academy now!", style: AlertStyle.Success, buttonTitle: "OK", action: { (isOtherButton) in
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            }else if(response.status.statusCode == "301"){
                SweetAlert().showAlert("Email Adress", subTitle: "Email adress is used for register before.Please use a different email adress for registering.", style: AlertStyle.Warning)
            }
            
            
            break
        
        default:
            break
        }

    }
    
    func proxyRecievedError(ex: NSException!, inMethod method: String!) {
        SweetAlert().showAlert("Oops", subTitle: "Something went wrong.We're working on it!", style: AlertStyle.Error)
    }
    
    func saveUserMA(){
        let encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(userMA)
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject(encodedObject, forKey: "userMA_")
        def.synchronize()
    }
    
    
}
