//
//  DocumentViewController.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 4.04.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import TWRDownloadManager
import UIKit
import MaterialKit
import CustomIOSAlertView
import CRToast
import MMMaterialDesignSpinner
import VAProgressCircle

class DocumentViewController: UIViewController {
    
    
    @IBOutlet weak var webView: UIWebView!
    var pdfLink: String!
    var selectedDocument: Document!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = UIColor(hex: 0x005a7c)
        //        navBar.barTintColor = UIColor(red: 0 / 255.0, green: 90.0 / 255.0, blue: 124.0 / 255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
//        let pdfFilePath = TWRDownloadManager.sharedManager().localPathForFile(self.pdfLink)
        let pdfFilePath = TWRDownloadManager.sharedManager().localPathForFile(self.pdfLink, inDirectory: "\(selectedDocument.documentName.stringByReplacingOccurrencesOfString(" ", withString: ""))_v\(selectedDocument.version)")
        let target = NSURL(fileURLWithPath: pdfFilePath)
        let req = NSURLRequest(URL: target)
        webView.loadRequest(req)
     
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewDidDisappear(animated: Bool) {
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    
    
    
    
}
