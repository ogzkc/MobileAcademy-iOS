//
//  StoreViewController.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 28.03.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import TWRDownloadManager
import UIKit
import MaterialKit
import CustomIOSAlertView
import CRToast
import MMMaterialDesignSpinner
import VAProgressCircle


class StoreViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,Wsdl2CodeProxyDelegate,UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate {
    

    @IBOutlet weak var storeTableView: UITableView!
    
    var service: MAServiceProxy!
    let servicePass = "****"
    let nullForService = "-"
    let iosPlatformID = "2"
    
    var customAlert: CustomIOSAlertView!
    var spinnerContainer: UIView!
    var materialSpinner: MMMaterialDesignSpinner!
        var progressCircle: VAProgressCircle!
    
    var library: Library!
    var documents: [Document] = [Document]()
    var selectedDocument: Document!
    var userMA: UserMA!
    
    //search vars
    var searchController: UISearchController!
    var scopeArr = ["Document Name"]
    var searchOpen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = UIColor(hex: 0x005a7c)
//        navBar.barTintColor = UIColor(red: 0 / 255.0, green: 90.0 / 255.0, blue: 124.0 / 255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        setWebService()
        loadUserMA()
        
        if(!isConnectedToNetwork()){
            SweetAlert().showAlert("Offline Mode", subTitle: "You can only access your library when you are offline.", style: AlertStyle.Warning, buttonTitle: "OK")
         return
        }
        getDocumentsByDepartment(0)
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        
        
        
    }
    
    
    func addSearchBar(){
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.scopeButtonTitles = scopeArr
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = "Search"
        self.searchController.searchBar.setValue("Cancel", forKey: "_cancelButtonText")
        
        self.storeTableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.layoutIfNeeded()
        
        
//        self.storeTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController){
        let searchStr: String = searchController.searchBar.text!
        NSLog("Search: \(searchStr)")
        let scopeStr:String  = scopeArr[searchController.searchBar.selectedScopeButtonIndex]
//        searchForText(searchStr, scope: scopeStr)
        
    }
    
    func didDismissSearchController(searchController: UISearchController) {
//        self.storeTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
//        self.arrRadyo = self.tempRadyoArr
//        self.radyoTableView.reloadData()
//        editRows()
//        favsToTop()
        searchOpen = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        NSLog("cancel")
        searchOpen = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func willPresentSearchController(searchController: UISearchController) {
//        self.tempRadyoArr = self.arrRadyo
        searchOpen = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        
        
    }
    
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        let searchStr: String = searchBar.text!
        NSLog("Search: \(searchStr)")
        let scopeStr:String  = scopeArr[searchBar.selectedScopeButtonIndex]
//        searchForText(searchStr, scope: scopeStr)
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: StoreTableViewCell = tableView.dequeueReusableCellWithIdentifier("storeTableViewCell") as! StoreTableViewCell
        cell.setCell(documents[indexPath.row])
        
        let previewRecognizer = UITapGestureRecognizer(target: self, action: #selector(StoreViewController.previewButtonRecognizer(_:)))
        previewRecognizer.numberOfTapsRequired = 1
        cell.docPreviewView.addGestureRecognizer(previewRecognizer)
        cell.docPreviewView.tag = indexPath.row
        
        let downloadRecognizer = UITapGestureRecognizer(target: self, action: #selector(StoreViewController.downloadButtonRecognizer(_:)))
        downloadRecognizer.numberOfTapsRequired = 1
        cell.docDownloadView.addGestureRecognizer(downloadRecognizer)
        cell.docDownloadView.tag = indexPath.row
        
        return cell
        
    }
    
    func previewButtonRecognizer(gestureRecognizer: UITapGestureRecognizer){
        
        selectedDocument = documents[(gestureRecognizer.view?.tag)!]
        performSegueWithIdentifier("showDocumentDetailViewSegue", sender: self)
        
    }
    
    
    
    
    
    func downloadButtonRecognizer(gestureRecognizer: UITapGestureRecognizer){
        
        selectedDocument = documents[(gestureRecognizer.view?.tag)!]
        
        if(!selectedDocument.isHave){
            service.addToLibrary(configVar.servicePass, Int32(Config.userMA_Valid.userId), Int32(selectedDocument.docId), Int32(configVar.iosPlatformID), Int32(selectedDocument.price))
            (gestureRecognizer.view?.subviews[0] as! UIImageView).image = UIImage(named: "ReadIcon")
            showToast(1, text: "Document has been added to your library!")
        }
        
        
        if(TWRDownloadManager.sharedManager().fileExistsForUrl(selectedDocument.pDFLink, inDirectory: "\(selectedDocument.documentName.stringByReplacingOccurrencesOfString(" ", withString: ""))_v\(selectedDocument.version)")){
            self.performSegueWithIdentifier("showDocumentFromStoreSegue", sender: self)
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
                
                (gestureRecognizer.view?.subviews[0] as! UIImageView).image = UIImage(named: "ReadIcon")
                self.progressCircle.setProgress(100)
                self.customAlert.close()
                self.performSegueWithIdentifier("showDocumentFromStoreSegue", sender: self)
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
        
        if(segue.identifier == "showDocumentFromStoreSegue"){
            let vc = segue.destinationViewController as! DocumentViewController
            vc.pdfLink = selectedDocument.pDFLink
            vc.selectedDocument = selectedDocument
        }
        
        if(segue.identifier == "showDocumentDetailViewSegue"){
            let documentvc: DocumentDetailViewController = segue.destinationViewController as! DocumentDetailViewController
            documentvc.document = selectedDocument
        }

        
    }
    
    func cancelDownloadButton(sender: UIButton!){
        print("cancel")
        TWRDownloadManager.sharedManager().cancelAllDownloads()
        self.customAlert.close()
        showToast(2, text: "Download was canceled.")
        
    }

    
    
    
    func setWebService(){
        self.service = MAServiceProxy(url: "http://kcdroid.com/MobilAkademi/Service/MAService.asmx", andDelegate: self)
        self.service.service.timeout = 15
        
    }
    
    func getDocumentsByDepartment(depId: Int){
        customAlert = showLoadingDialogIndeterminate_Util()
        service.getDocumentsByDepartment(servicePass, Int32(userMA.userId), 0, 1)
    }
    
    
    func proxydidFinishLoadingData(data: AnyObject!, inMethod method: String!) {
        
        if(method != "getDocumentsByDepartment"){
            return
        }
        
        self.customAlert.close()
        
        if(data == nil){
            print("data nil geldi")
            return
        }
        
        let response: ResponseMA = data as! ResponseMA
        
        print(response.message)
        print(response.library.documentCount)
        
        self.library = response.library
        if(self.library.documentCount == 0){
            return
        }
        let nsarraydocs = response.library.documents.copy() as! NSArray
        self.documents = nsarraydocs as! [Document]
        storeTableView.reloadData()
        addSearchBar()

    }
    
    func proxyRecievedError(ex: NSException!, inMethod method: String!) {
        
        print("METHOD: \(method) HATA : \(ex.description)")
        self.customAlert.close()
        
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



