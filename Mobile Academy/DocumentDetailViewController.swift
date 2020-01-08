//
//  DocumentDetailViewController.swift
//  Mobile Academy
//
//  Created by Oguz Kucukcanbaz on 2.04.2016.
//  Copyright © 2016 Oguz Kucukcanbaz. All rights reserved.
//

import TWRDownloadManager
import UIKit
import MaterialKit
import CustomIOSAlertView
import CRToast
import MMMaterialDesignSpinner
import VAProgressCircle

class DocumentDetailViewController: UIViewController,Wsdl2CodeProxyDelegate,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var docNameLabel: UILabel!
    @IBOutlet weak var pubNameLabel: UILabel!
    @IBOutlet weak var previewButtonView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var unLikeButton: UIButton!
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var tableOfContButtonView: UIView!
    @IBOutlet weak var readButtonView: UIView!
    @IBOutlet weak var commentButtonView: UIView!
    @IBOutlet weak var plusReadImage: UIImageView!
    
    @IBOutlet weak var activityindicatorView: UIActivityIndicatorView!
    
    var tableViewComment: UITableView!
    var commentArr: [Comment] = [Comment]()
    
    var document: Document!
    var customAlert: CustomIOSAlertView!
    var progressCircle: VAProgressCircle!
    var commentTextField: UITextField!
    var isSending = false
    var service: MAServiceProxy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        setViews()
        setWebService()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func setWebService(){
        self.service = MAServiceProxy(url: "*****", andDelegate: self)
        self.service.service.timeout = 15
    }
    
    func setViews(){
        
        docNameLabel.text = document.displayName
        pubNameLabel.text = document.publisherName
        descriptionTextView.text = document.description_
        pointLabel.text = "\(document.point) Points"
        
        if(self.document.myRate == 0){
            self.likeButton.setImage(UIImage(named: "LikeButton"), forState: UIControlState.Normal)
            self.unLikeButton.setImage(UIImage(named: "UnlikeButton"), forState: UIControlState.Normal)
        }else if(self.document.myRate == 1){
            self.likeButton.setImage(UIImage(named: "LikeButtonSelected"), forState: UIControlState.Normal)
            self.unLikeButton.setImage(UIImage(named: "UnlikeButton"), forState: UIControlState.Normal)
        }else if(self.document.myRate == -1){
            self.likeButton.setImage(UIImage(named: "LikeButton"), forState: UIControlState.Normal)
            self.unLikeButton.setImage(UIImage(named: "UnlikeButtonSelected"), forState: UIControlState.Normal)
        }
        
        let addreadDocButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(DocumentDetailViewController.add_ReadDocumentButton(_:)))
        addreadDocButtonRecognizer.numberOfTapsRequired = 1
        readButtonView.addGestureRecognizer(addreadDocButtonRecognizer)
        
        let previewPDFButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(DocumentDetailViewController.previewPDFButton(_:)))
        previewPDFButtonRecognizer.numberOfTapsRequired = 1
        previewButtonView.addGestureRecognizer(previewPDFButtonRecognizer)
        
        let tableOfContentButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(DocumentDetailViewController.tableOfContentButton(_:)))
        tableOfContentButtonRecognizer.numberOfTapsRequired = 1
        tableOfContButtonView.addGestureRecognizer(tableOfContentButtonRecognizer)
        
        let commentButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(DocumentDetailViewController.commentButton(_:)))
        commentButtonRecognizer.numberOfTapsRequired = 1
        commentButtonView.addGestureRecognizer(commentButtonRecognizer)
        
        //        if(TWRDownloadManager.sharedManager().fileExistsForUrl(self.document.pDFLink)){
        //            plusReadImage.image = UIImage(named: "ReadIcon")
        //        }
        
        if(document.isHave){
            plusReadImage.image = UIImage(named: "ReadIcon")
        }
        
    }
    
    @IBAction func likeButtonAction(sender: UIButton) {
        if(!document.isHave){
            showToast(2, text: "You have not seen document yet.")
            return
        }
        
       
        
        
        likeButton.enabled = false
        unLikeButton.enabled = false
        activityindicatorView.startAnimating()
        
        switch document.myRate {
        case 1:
            document.point -= 1
            pointLabel.text = "\(document.point) Points"
            break
        case 0:
            document.point += 1
            pointLabel.text = "\(document.point) Points"
            break
        case -1:
            document.point += 2
            pointLabel.text = "\(document.point) Points"
            break
        default:
            break
        }
        
        if(document.myRate == 1){
            document.myRate = 0
            service.rateDocument(configVar.servicePass, Int32(Config.userMA_Valid.userId), document.docId, 0, Int32(configVar.iosPlatformID))
        }else{
            document.myRate = 1
            service.rateDocument(configVar.servicePass, Int32(Config.userMA_Valid.userId), document.docId, 1, Int32(configVar.iosPlatformID))
        }
        
       
        
        
        
    }
    
    @IBAction func unlikeButtonAction(sender: UIButton) {
        if(!document.isHave){
            showToast(2, text: "You have not seen document yet.")
            return
        }
        
        switch document.myRate {
        case 1:
            document.point -= 2
            pointLabel.text = "\(document.point) Points"
            break
        case 0:
            document.point -= 1
            pointLabel.text = "\(document.point) Points"
            break
        case -1:
            document.point += 1
            pointLabel.text = "\(document.point) Points"
            break
        default:
            break
        }

        
        likeButton.enabled = false
        unLikeButton.enabled = false
        activityindicatorView.startAnimating()
        
        
        if(document.myRate == -1){
            document.myRate = 0
            service.rateDocument(configVar.servicePass, Int32(Config.userMA_Valid.userId), document.docId, 0, Int32(configVar.iosPlatformID))
            
        }else{
            document.myRate = -1
            service.rateDocument(configVar.servicePass, Int32(Config.userMA_Valid.userId), document.docId, -1, Int32(configVar.iosPlatformID))
            
        }
        

        
        
    }
    
    func tableOfContentButton(gestureRecognizer: UITapGestureRecognizer){
        
        showPopUpPDF(document.tableofContentLink)
        
        activityindicatorView.stopAnimating()
        
    }
    
    func previewPDFButton(gestureRecognizer: UITapGestureRecognizer){
        
        showPopUpPDF(document.previewLink)
        
    }
    
    func commentButton(gestureRecognizer: UITapGestureRecognizer){
        
//        SweetAlert().showAlert("Coming Soon!", subTitle: "Comment section will be released in next version.", style: AlertStyle.Warning, buttonTitle: "OK")
        
        customAlert = showLoadingDialogIndeterminate_Util()
        service.getComments(Config().servicePass, self.document.docId)
        
 
        
        
    }
    
    
    func prepareAndShowCommentDialog(){
        customAlert.close()
        customAlert = CustomIOSAlertView()
        customAlert.buttonTitles = nil
        
        let commentView = CommentUIView().loadViewFromNib()
        
        var closebutton: UIButton!
        var sendButton: UIButton!
        
        
        for v in commentView.subviews {
            if(v is UITableView && v.tag == 0){
                tableViewComment = v as! UITableView
            }else if (v is UIButton && v.tag == 1){
                closebutton = v as! UIButton
            }else if(v is UITextField && v.tag == 2){
                commentTextField = v as! UITextField
            }else if(v is UIButton && v.tag == 3){
                sendButton = v as! UIButton
            }
        }
        
        
        tableViewComment.delegate = self
        tableViewComment.dataSource = self
        
        
        closebutton.addTarget(self, action: #selector(DocumentDetailViewController.closeAlert(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        sendButton.addTarget(self, action: #selector(DocumentDetailViewController.sendCommentButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.automaticallyAdjustsScrollViewInsets = false
        customAlert.containerView = commentView
        customAlert.show()
    }
    
    func sendCommentButton(sender: UIButton){
        if(isSending){
            showToast(2, text: "Your comment is still being sent.")
            return
        }
        if(commentTextField.text?.characters.count < 3){
            showToast(2, text: "Your comment cannot be shorter than 3 characters.")
            return
        }
        
        let newComment: Comment = Comment()
        newComment.name = Config.userMA_Valid.fullName
        if(Config.userMA_Valid.registerType == "g"){
            newComment.photoLink = Config.userMA_Valid.googlePhotoURL
        }else if(Config.userMA_Valid.registerType == "f"){
            newComment.photoLink = "http://graph.facebook.com/\(Config.userMA_Valid.fbID)/picture?type=large"
        }else{
            newComment.photoLink = "-"
        }
        newComment.text = commentTextField.text
        
        commentArr.append(newComment)
        tableViewComment.reloadData()
        
        service.makeComment(Config().servicePass,Int32(Config.userMA_Valid.userId), self.document.docId,self.commentTextField.text)
        isSending = true
        commentTextField.text = ""
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArr.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.registerNib(UINib(nibName: "CommentTableViewCell",bundle: nil), forCellReuseIdentifier: "commentTableViewCell")
        let cell: CommentUITableViewCell = tableView.dequeueReusableCellWithIdentifier("commentTableViewCell") as! CommentUITableViewCell
        cell.setCell(commentArr[indexPath.row])
        return cell

    }
    
    func showPopUpPDF(link: String){
        customAlert = CustomIOSAlertView()
        customAlert.buttonTitles = nil
        
        let popuppdfview = PopUpPDFUIView().loadViewFromNib()
        var webViewPop: UIWebView!
        var closebutton: UIButton!
        
        for v in popuppdfview.subviews {
            if(v is UIWebView){
                if(v.tag == 0){
                    webViewPop = v as! UIWebView
                }
            }else if (v is UIButton){
                if(v.tag == 1){
                    closebutton = v as! UIButton
                }
            }
        }
        
        webViewPop.loadRequest(NSURLRequest(URL: NSURL(string: link)!))
        closebutton.addTarget(self, action: #selector(DocumentDetailViewController.closeAlert(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        customAlert.containerView = popuppdfview
        customAlert.show()
    }
    
    func closeAlert(sender: UIButton){
        customAlert.close()
    }
    
    func add_ReadDocumentButton(gestureRecognizer: UITapGestureRecognizer){
        
        
        if(!document.isHave){
            service.addToLibrary(configVar.servicePass, Int32(Config.userMA_Valid.userId), Int32(document.docId), Int32(configVar.iosPlatformID), Int32(document.price))
            plusReadImage.image = UIImage(named: "ReadIcon")
        }
        
        
        if(TWRDownloadManager.sharedManager().fileExistsForUrl(document.pDFLink, inDirectory: "\(document.documentName.stringByReplacingOccurrencesOfString(" ", withString: ""))_v\(document.version)")){
            self.performSegueWithIdentifier("showDocumentFromDetailSegue", sender: self)
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
        TGLGuillotineMenu().createDirectory("\(document.documentName.stringByReplacingOccurrencesOfString(" ", withString: ""))_v\(document.version)", atFilePath: path)
        

        
        TWRDownloadManager.sharedManager().downloadFileForURL(document.pDFLink, inDirectoryNamed: "\(document.documentName.stringByReplacingOccurrencesOfString(" ", withString: ""))_v\(document.version)",progressBlock: { (prog: CGFloat) in
            
            self.progressCircle.setProgress(Int32(prog * 100))
            print("Progress: \(prog*100)")
            
            }, completionBlock: { (finish: Bool) in
                
                self.plusReadImage.image = UIImage(named: "ReadIcon")
                self.progressCircle.setProgress(100)
                self.customAlert.close()
                self.performSegueWithIdentifier("showDocumentFromDetailSegue", sender: self)
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
        
        if(segue.identifier == "showDocumentFromDetailSegue"){
            let vc = segue.destinationViewController as! DocumentViewController
            vc.pdfLink = self.document.pDFLink
            vc.selectedDocument = self.document
        }
        
    }
    
    func cancelDownloadButton(sender: UIButton!){
        print("cancel")
        TWRDownloadManager.sharedManager().cancelAllDownloads()
        self.customAlert.close()
        showToast(2, text: "Download was canceled.")
        
    }
    
    func proxydidFinishLoadingData(data: AnyObject!, inMethod method: String!) {
        
        switch method {
        case "rateDocument":
            activityindicatorView.stopAnimating()
            likeButton.enabled = true
            unLikeButton.enabled = true
            
            if( (data as! ResponseMA).success ){
                UIView.animateWithDuration(0.3, animations: { 
                    self.likeButton.alpha = 0
                    self.unLikeButton.alpha = 0
                    }, completion: { (finished: Bool) in
                        
                        if(self.document.myRate == 0){
                            self.likeButton.setImage(UIImage(named: "LikeButton"), forState: UIControlState.Normal)
                            self.unLikeButton.setImage(UIImage(named: "UnlikeButton"), forState: UIControlState.Normal)
                        }else if(self.document.myRate == 1){
                            self.likeButton.setImage(UIImage(named: "LikeButtonSelected"), forState: UIControlState.Normal)
                            self.unLikeButton.setImage(UIImage(named: "UnlikeButton"), forState: UIControlState.Normal)
                        }else if(self.document.myRate == -1){
                            self.likeButton.setImage(UIImage(named: "LikeButton"), forState: UIControlState.Normal)
                            self.unLikeButton.setImage(UIImage(named: "UnlikeButtonSelected"), forState: UIControlState.Normal)
                        }

                        UIView.animateWithDuration(0.3, animations: {
                            self.likeButton.alpha = 1
                            self.unLikeButton.alpha = 1
                            })
                })
            }
            break
        case "addToLibrary":
            if( (data as! ResponseMA).success ){
                showToast(1, text: "Document has been added to your library!")
                self.document.isHave = true
            }
            break
        case "getComments":
            if(data == nil){
                customAlert.close()
                return
            }
            self.prepareAndShowCommentDialog()
            self.commentArr = data as! [Comment]
            self.tableViewComment.reloadData()
            break
        case "makeComment":
            isSending = false
            if(data == nil){
                showToast(3, text: "Your comment couldn't be sent, please try again later.")
                commentArr.removeLast()
                tableViewComment.reloadData()
                return
            }
            let response: ResponseMA! = data as! ResponseMA
            if(!response.success){
                showToast(3, text: "Your comment couldn't be sent, please try again later.")
                commentArr.removeLast()
                tableViewComment.reloadData()
                return
            }
            if(response.status.statusCode == "902"){
                showToast(2, text: "You can't send comment before 2 minutes.")
                commentArr.removeLast()
                tableViewComment.reloadData()
                return
            }
            break
        default:
            break
        }
        
    }
    
    func proxyRecievedError(ex: NSException!, inMethod method: String!) {
        if(method == "makeComment"){
            isSending = false
            showToast(3, text: "Your comment couldn't be sent, please try again later.")
            commentArr.removeLast()
            tableViewComment.reloadData()
            return
        }
    }
    
    
    
    
    
}
