//
//  LibraryViewController.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 29.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import UIKit
import MaterialKit
import CustomIOSAlertView
import CRToast
import MMMaterialDesignSpinner
import VAProgressCircle
import TWRDownloadManager

class LibraryViewController: UIViewController,Wsdl2CodeProxyDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var libraryTableView: UITableView!
    
    
    
    var service: MAServiceProxy!
    
    
    var customAlert: CustomIOSAlertView!
    var spinnerContainer: UIView!
    var materialSpinner: MMMaterialDesignSpinner!
    var progressCircle: VAProgressCircle!
    
    var library: Library!
    var documents: [Document] = [Document]()
    var selectedDocument: Document!
    var userMA: UserMA!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = UIColor(hex: 0x005a7c)
        //        navBar.barTintColor = UIColor(red: 0 / 255.0, green: 90.0 / 255.0, blue: 124.0 / 255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        setWebService()
        loadUserMA()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.libraryTableView.contentInset = UIEdgeInsetsMake(64,0,0,0);
        if(!isConnectedToNetwork()){
            loadLibrary()
            return
        }
        getLibrary(0)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: LibraryTableViewCell = tableView.dequeueReusableCellWithIdentifier("libraryTableViewCell") as! LibraryTableViewCell
        cell.setCell(documents[indexPath.row])
        
        let readRecognizer = UITapGestureRecognizer(target: self, action: #selector(LibraryViewController.readButtonRecognizer(_:)))
        readRecognizer.numberOfTapsRequired = 1
        cell.docReadButtonView.addGestureRecognizer(readRecognizer)
        cell.docReadButtonView.tag = indexPath.row
        
        
        return cell
        
    }
    
    
    
    func setWebService(){
        self.service = MAServiceProxy(url: "******", andDelegate: self)
        self.service.service.timeout = 15
        
    }
    
    func getLibrary(depId: Int){
        customAlert = showLoadingDialogIndeterminate_Util()
        
        switch userMA.registerType {
        case "g":
            service.getLibraryByUser(configVar.servicePass, Int32(self.userMA.userId), self.userMA.registerType, self.userMA.GPLink, configVar.nullForService, configVar.nullForService)
            break
        case "f":
            service.getLibraryByUser(configVar.servicePass, Int32(self.userMA.userId), self.userMA.registerType, self.userMA.fbID, configVar.nullForService, configVar.nullForService)
            break
        case "m":
            service.getLibraryByUser(configVar.servicePass, Int32(self.userMA.userId), self.userMA.registerType, configVar.nullForService, self.userMA.email, self.userMA.password)
            break
            
        default:
            break
        }
    }
    
    func readButtonRecognizer(gestureRecognizer: UITapGestureRecognizer){
        
        
        selectedDocument = documents[(gestureRecognizer.view?.tag)!]
        
        
        
        if(TWRDownloadManager.sharedManager().fileExistsForUrl(selectedDocument.pDFLink, inDirectory: "\(selectedDocument.documentName.stringByReplacingOccurrencesOfString(" ", withString: ""))_v\(selectedDocument.version)")){
            self.performSegueWithIdentifier("showDocumentFromLibSegue", sender: self)
            return
        }
        
        if(!isConnectedToNetwork()){
            SweetAlert().showAlert("Offline Mode", subTitle: "You did not download the document before.", style: AlertStyle.Warning, buttonTitle: "OK")
            return
        }
        
        showDeterminateProgressView()
        
        var path = TWRDownloadManager.sharedManager().localPathForFile("asda.pdf", inDirectory: "deneme")
        if let range = path.rangeOfString("/", options: .BackwardsSearch) {
            path = path.substringToIndex(range.startIndex)
        }
        
        if let range = path.rangeOfString("/", options: .BackwardsSearch) {
            path = path.substringToIndex(range.startIndex)
        }
        TGLGuillotineMenu().createDirectory("\(selectedDocument.documentName.stringByReplacingOccurrencesOfString(" ", withString: ""))_v\(selectedDocument.version)", atFilePath: path)
        
        
        
        
        TWRDownloadManager.sharedManager().downloadFileForURL(selectedDocument.pDFLink, inDirectoryNamed: "\(selectedDocument.documentName.stringByReplacingOccurrencesOfString(" ", withString: ""))_v\(selectedDocument.version)",progressBlock: { (prog: CGFloat) in
            
            self.progressCircle.setProgress(Int32(prog * 100))
            print("Progress: \(prog*100)")
            
            }, completionBlock: { (finish: Bool) in
                
                self.progressCircle.setProgress(100)
                self.customAlert.close()
                self.performSegueWithIdentifier("showDocumentFromLibSegue", sender: self)
                print("bitti")
                
                
            }, enableBackgroundMode: false)

        
    }
    
    
    func showDeterminateProgressView(){
        
        customAlert = CustomIOSAlertView()
        customAlert.buttonTitles = nil
        
        let loadingView = LoadingDeterminateUIView().loadViewFromNib()
        var closeButton: UIButton!
        
        for v in loadingView.subviews {
            if(v is VAProgressCircle){
                if(v.tag == 0){
                    progressCircle = v as! VAProgressCircle
                }
            }else if(v is UIButton){
                if(v.tag == 1){
                    closeButton = v as! UIButton
                }
            }
            
        }
        
        progressCircle.setColor(UIColor.greenColor(), withHighlightColor:  UIColor(red: 35, green: 177, blue: 70, alpha: 1))
        progressCircle.transitionType = VAProgressCircleColorTransitionType.Gradual
        progressCircle.setTransitionColor(UIColor.colorFromRGB(0x005a7c), withHighlightTransitionColor: UIColor(red: 32, green: 149, blue: 242, alpha: 1))
        progressCircle.rotationDirection = VAProgressCircleRotationDirection.Clockwise;
        closeButton.addTarget(self, action: #selector(DocumentDetailViewController.cancelDownloadButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        customAlert.containerView = loadingView
        customAlert.show()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "showDocumentFromLibSegue"){
            let vc = segue.destinationViewController as! DocumentViewController
            vc.pdfLink = selectedDocument.pDFLink
            vc.selectedDocument = selectedDocument
        }else if(segue.identifier == "cellClickSegue"){
            let cell = sender as! LibraryTableViewCell
            let indexPath = libraryTableView.indexPathForCell(cell)! as NSIndexPath
            let documentvc: DocumentDetailViewController = segue.destinationViewController as! DocumentDetailViewController
            documentvc.document = documents[indexPath.row]
        }
        
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if(!isConnectedToNetwork() && identifier == "cellClickSegue"){
            SweetAlert().showAlert("Offline Mode", subTitle: "You can only read your documents when you are offline.", style: AlertStyle.Warning, buttonTitle: "OK")
            return false
        }
        return true
    }
    
    func cancelDownloadButton(sender: UIButton!){
        print("cancel")
        TWRDownloadManager.sharedManager().cancelAllDownloads()
        self.customAlert.close()
        showToast(2, text: "Download was canceled.")
        
    }
    
    
    func proxydidFinishLoadingData(data: AnyObject!, inMethod method: String!) {
        
        self.customAlert.close()
        
        
        if(data == nil){
            print("data nil geldi")
            return
        }
        
        let response: ResponseMA = data as! ResponseMA
        
        print(response.message)
        print(response.library.documentCount)
        
        if(response.library.documentCount == 0){
            return
        }
        
        self.library = response.library
        
        if(self.library.documentCount == 0){
            return
        }
        
        
        saveLibrary()
        let nsarraydocs = response.library.documents.copy() as! NSArray
        self.documents = nsarraydocs as! [Document]
        
        libraryTableView.reloadData()
        
        
    }
    
    func proxyRecievedError(ex: NSException!, inMethod method: String!) {
        self.customAlert.close()
        
    }
    
    func saveLibrary(){
        let encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(documents)
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject(encodedObject, forKey: "library_")
        def.synchronize()
    }
    
    func loadLibrary(){
        let def = NSUserDefaults.standardUserDefaults()
        let tempDocs: AnyObject? = def.objectForKey("library_")
        if(tempDocs == nil){
            self.userMA.registerType = "-"
        }else{
            let encodedObject: NSData = def.objectForKey("library_") as! NSData
            let objUser: [Document] = NSKeyedUnarchiver.unarchiveObjectWithData(encodedObject) as! [Document]
            self.documents = objUser
        }
        libraryTableView.reloadData()
    }
    
    func loadUserMA(){
        
        self.userMA = UserMA()
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
