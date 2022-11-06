
import UIKit
import Parse
import MediaPlayer

@available(iOS 13.0, *)

class AdDetails: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var safeAreaView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adTimeAgoLabel: UILabel!
    @IBOutlet weak var adPriceLabel: UILabel!
    @IBOutlet weak var adConditionlabel: UILabel!
    @IBOutlet weak var adCategoryLabel: UILabel!
    @IBOutlet weak var adSubCategoryLabel: UILabel!
    @IBOutlet weak var adCityLabel: UILabel!
    @IBOutlet weak var adDescriptionTxt: UILabel! //UITextView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    
    @IBOutlet weak var likeOutlet: UIButton!
    
    @IBOutlet weak var imagePreviewView: UIView!
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var imgPrev: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var carouselView: ImageCarouselView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var gradientBackgroundImageView: UIImageView!
    
    @IBOutlet weak var feedbackOutlet: UIButton!
    @IBOutlet weak var sendMessageOutlet: UIButton!

    @IBOutlet weak var likesCounter: UILabel!
    
    /* Variables */
    var adObj = PFObject(className: ADS_CLASS_NAME)
    var adCurrency = ""
    var adPriceString = ""
    var formattedNumberString = ""
    var user: AppleUser?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.topView.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        self.bottomView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 20.0)
        
        adCurrency = "\(adObj[ADS_CURRENCY]!)"
        adPriceString = "\(adObj[ADS_PRICE]!)"
        
        let adPriceNumber = Int(adPriceString)!
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:adPriceNumber))
        
        formattedNumberString = String(formattedNumber!)
        
        print(formattedNumberString)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate

        safeAreaView.backgroundColor = MAIN_COLOR
        headerView.backgroundColor = MAIN_COLOR
        
        carouselView.didOpenPage = { page in
            self.previewImageAt(page: page)
        }
        
        adPriceLabel.adjustsFontSizeToFitWidth = true
        adPriceLabel.minimumScaleFactor = 0.2

        adPriceLabel.numberOfLines = 1 // or 1

        // Position ImagePreview
        imagePreviewView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        instructionsLabel.isHidden = true
        imgPrev.frame = imgScrollView.frame
        
        // Call query
        getAdDetails()
        
        // Check if you've liked this Ad
        if PFUser.current() != nil {
            
            let query = PFQuery(className: LIKES_CLASS_NAME)
            query.whereKey(LIKES_CURR_USER, equalTo: PFUser.current()!)
            query.whereKey(LIKES_AD_LIKED, equalTo: adObj)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    if objects!.count != 0 {
                        //                    let likes = self.adObj[ADS_LIKES] as! Int
                        self.likeOutlet.setImage(#imageLiteral(resourceName: "ad_details_liked_butt"), for: .normal)
                        //                    self.likeLabel.text = likes.abbreviated
                    } else {
                        self.likeOutlet.setImage(#imageLiteral(resourceName: "ad_details_no_like_butt"), for: .normal)
                        //                    self.likeLabel.text = "Like"
                    }
                    // error
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
        }
        
    }
    
    var carouselImages: [UIImage] = [] {
        didSet {
            self.carouselView.images = carouselImages
        }
    }
    
    // MARK: - GET AD DETAILS
    func getAdDetails() {
        
        // Get image1
        let imageFile1 = adObj[ADS_IMAGE1] as? PFFileObject
        imageFile1?.getDataInBackground(block: { (data, error) in
            if error == nil, let imageData = data {
                if let img = UIImage(data: imageData) {
                    self.carouselImages.append(img)
                }
            }
        })
        
        // Get image2
        let imageFile2 = adObj[ADS_IMAGE2] as? PFFileObject
        imageFile2?.getDataInBackground(block: { (data, error) in
            if error == nil, let imageData = data {
                if let img = UIImage(data: imageData) {
                    self.carouselImages.append(img)
                }
            }
        })
        
        // Get image3
        let imageFile3 = adObj[ADS_IMAGE3] as? PFFileObject
        imageFile3?.getDataInBackground(block: { (data, error) in
            if error == nil, let imageData = data {
                if let img = UIImage(data: imageData) {
                    self.carouselImages.append(img)
                }
            }
        })
        
        // Get title
        pageTitleLabel.text = "\(adObj[ADS_TITLE]!)"
        
        // Get title
        adTitleLabel.text = "\(adObj[ADS_TITLE]!)"
        adTitleLabel.sizeToFit()
        
        if "\(adObj[ADS_LIKES]!)" == "1" || "\(adObj[ADS_LIKES]!)" == "0" {
            likesCounter.text = "\(adObj[ADS_LIKES]!) like"
        }
        else {
            likesCounter.text = "\(adObj[ADS_LIKES]!) likes"
        }
        
        // Get time ago
        let date = Date()
        adTimeAgoLabel.text = timeAgoSinceDate(adObj.createdAt!, currentDate: date, numericDates: true)
        
        // Get price
        if "\(adObj[ADS_CONDITION]!)" == "Exchange" {
            adPriceLabel.text = "Exc."
        }
        else if "\(adObj[ADS_CONDITION]!)" == "Gift" {
            adPriceLabel.text = "Gift"
        }
        else
        {
            //adPriceLabel.text = "\(adObj[ADS_CURRENCY]!)" \(adObj[ADS_PRICE]!)"
            //adPriceLabel.text = "\(adObj[ADS_CURRENCY]!) \(adObj[ADS_PRICE]!)"
            adPriceLabel.text! = adCurrency + " " + formattedNumberString
        }
        
        //adPriceLabel.textColor = MAIN_COLOR
        // Get condition
        adConditionlabel.text = "\(adObj[ADS_CONDITION]!)"
        
        // Get category
        adCategoryLabel.text = "\(adObj[ADS_CATEGORY]!)"
        
        if adObj[ADS_SUBCATEGORY] != nil {
            self.adSubCategoryLabel.text = adObj[ADS_SUBCATEGORY] as? String == "" ? "N/A" : "\(adObj[ADS_SUBCATEGORY]!)"
        }
        else {
            adSubCategoryLabel.text = "N/A"
        }
 
        // Get city
        adCityLabel.text = "\(adObj[ADS_CITY]!)"
    
        // Get description
        adDescriptionTxt.text = "\(adObj[ADS_DESCRIPTION]!)"
        adDescriptionTxt.sizeToFit()
        
        // SELLERS DETAILS ---------------------------
        let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        sellerPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // Get Avatar
                self.avatarImg.layer.cornerRadius = self.avatarImg.bounds.size.width/2
                self.avatarImg.layer.borderWidth = 2
                self.avatarImg.layer.borderColor = UIColor.black.cgColor
                let imageFile = sellerPointer[USER_AVATAR] as? PFFileObject
                imageFile?.getDataInBackground(block: { (data, error) in
                    if error == nil { if let imageData = data {
                        self.avatarImg.image = UIImage(data: imageData)
                        }}})
            }
        })
    }
    
    func previewImageAt(page: Int) {
        imgPrev.image = carouselImages[page]
        self.showImagePrevView()
    }
    
    // MARK: - TAP ON IMAGE TO CLOSE PREVIEW
    @IBAction func tapToClosePreview(_ sender: UITapGestureRecognizer) {
        hideImagePrevView()
    }
    
    // MARK: - SHOW/HIDE PREVIEW IMAGE VIEW
    func showImagePrevView() {
        UIView.animate(withDuration: 0.14, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.imagePreviewView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.instructionsLabel.isHidden = false
            self.imgPrev.frame = self.imagePreviewView.frame
        }, completion: { (finished: Bool) in  })
    }
    
    func hideImagePrevView() {
        imgPrev.image = nil
        UIView.animate(withDuration: 0.14, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.imagePreviewView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.instructionsLabel.isHidden = true
            self.imgPrev.frame = self.imagePreviewView.frame
        }, completion: { (finished: Bool) in  })
    }
    
    
    // MARK: - SCROLLVIEW DELEGATE FOR ZOOMING IMAGE
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgPrev
    }
        
    // MARK: - SELLER BUTTON -> VIEW SELLER'S PROFILE
    @IBAction func sellerButt(_ sender: Any) {
        let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        sellerPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                let aVC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfile
                aVC.userObj = sellerPointer
                self.navigationController?.pushViewController(aVC, animated: true)
            }})
    }

    // MARK: - SEND A FEEDBACK BUTTON
    @IBAction func sendFeedbackButt(_ sender: Any) {
        if PFUser.current() != nil {
        let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        sellerPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                let query = PFQuery(className: FEEDBACKS_CLASS_NAME)
                query.whereKey(FEEDBACKS_REVIEWER_POINTER, equalTo: PFUser.current()!)
                query.whereKey(FEEDBACKS_SELLER_POINTER, equalTo: sellerPointer)
                query.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        
                        // Enter the Send Feedback screen
                        if objects!.count == 0 {
                            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "SendFeedback") as! SendFeedback
                            aVC.sellerObj = sellerPointer
                            aVC.adObj = self.adObj
                            self.navigationController?.pushViewController(aVC, animated: true)
                            
                            // Feedback already sent!
                        } else { self.simpleAlert("Bu satıcıya zaten bir geri bildirim gönderdin!") }
                        
                        // error
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                    }}
                
            }})
        } else {
            showLoginAlert("Giriş yapmalısın. Şimdi giriş yapmak ister misin?")
        }
    }

    // MARK: - OPTIONS BUTTON
    @IBAction func optionsButt(_ sender: UIButton) {
        if PFUser.current() != nil {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        // REPORT AD
        let report = UIAlertAction(title: "Rapor", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportAdOrUser") as! ReportAdOrUser
            aVC.adObj = self.adObj
            aVC.reportType = "Ad"
            self.present(aVC, animated: true, completion: nil)
        })
        
        // SHARE AD
        let share = UIAlertAction(title: "Paylaş", style: .default, handler: { (action) -> Void in
            let messageStr  = "Kontrol et: \(self.adObj[ADS_TITLE]!) on #\(APP_NAME)"
            let img = self.carouselImages.first ?? UIImage(named: "neararsanvar")!
            
            let shareItems = [messageStr, img] as [Any]
            
            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.print, .postToWeibo, .copyToPasteboard, .addToReadingList, .postToVimeo]
    
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad
                activityViewController.modalPresentationStyle = .popover
                self.present(activityViewController, animated: true, completion: nil)
            } else {
                // iPhone
                self.present(activityViewController, animated: true, completion: nil)
            }
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "İptal", style: .cancel, handler: { (action) -> Void in })
        
        alert.addAction(share)
        alert.addAction(report)
        alert.addAction(cancel)
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            let origin = CGPoint(x: sender.frame.midX, y: 40)
            popoverPresentationController.sourceRect = CGRect(origin: origin, size: sender.frame.size)
        }
        
        present(alert, animated: true, completion: nil)
            
        } else {
            showLoginAlert("Giriş yapmalısın. Şimdi giriş yapmak ister misin?")
        }
    }
    
    // MARK: - LIKE AD BUTTON
    @IBAction func likeButt(_ sender: UIButton) {
        if PFUser.current() != nil {
            
            let currUser = PFUser.current()!
            
            // 1. CHECK IF YOU'VE ALREADY LIKED THIS AD
            let query = PFQuery(className: LIKES_CLASS_NAME)
            query.whereKey(LIKES_CURR_USER, equalTo: currUser)
            query.whereKey(LIKES_AD_LIKED, equalTo: adObj)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    // 2. LIKE THIS AD!
                    if objects!.count == 0 {
                        
                        let likeObj = PFObject(className: LIKES_CLASS_NAME)
                        
                        // Save data
                        likeObj[LIKES_CURR_USER] = currUser
                        likeObj[LIKES_AD_LIKED] = self.adObj
                        likeObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.likeOutlet.setImage(#imageLiteral(resourceName: "ad_details_liked_butt"), for: .normal)
                                self.hideHUD()
                                
                                // Increment likes for the adObj
                                self.adObj.incrementKey(ADS_LIKES, byAmount: 1)
                                
                                // Add the user's objectID
                                if self.adObj[ADS_LIKED_BY] != nil {
                                    var likedByArr = self.adObj[ADS_LIKED_BY] as! [String]
                                    likedByArr.append(currUser.objectId!)
                                    self.adObj[ADS_LIKED_BY] = likedByArr
                                } else {
                                    var likedByArr = [String]()
                                    likedByArr.append(currUser.objectId!)
                                    self.adObj[ADS_LIKED_BY] = likedByArr
                                }
                                self.adObj.saveInBackground()
      
                                // Send Push Notification
                                let sellerPointer = self.adObj[ADS_SELLER_POINTER] as! PFUser
                                let pushStr = "\(PFUser.current()![USER_USERNAME]!) liked your ad: \(self.adObj[ADS_TITLE]!)"
                                
                                let data = [ "badge" : "Increment",
                                             "alert" : pushStr,
                                             "sound" : "bingbong.aiff"
                                ]
                                let request = [
                                    "someKey" : sellerPointer.objectId!,
                                    "data" : data
                                    ] as [String : Any]
                                
                                PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                                    if error == nil {
                                        print ("\nPUSH SENT TO: \(sellerPointer[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                                    } else {
                                        print ("\(error!.localizedDescription)")
                                    }
                                })
                                
                                // Save Activity
                                let activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
                                activityClass[ACTIVITY_CURRENT_USER] = sellerPointer
                                activityClass[ACTIVITY_OTHER_USER] = PFUser.current()!
                                activityClass[ACTIVITY_TEXT] = pushStr
                                activityClass.saveInBackground()

                                // error on saving like
                            } else {
                                self.simpleAlert("\(error!.localizedDescription)")
                                self.hideHUD()
                            }})
                            // 3. UNLIKE THIS AD :(
                    } else {
                        var likeObj = PFObject(className: LIKES_CLASS_NAME)
                        likeObj = objects![0]
                        likeObj.deleteInBackground(block: { (succ, error) in
                            if error == nil {
                                self.likeOutlet.setImage(#imageLiteral(resourceName: "ad_details_no_like_butt"), for: .normal)
                                self.hideHUD()
                                
                                // Decrement likes for the adObj
                                self.adObj.incrementKey(ADS_LIKES, byAmount: -1)
                                
                                // Remove the user's objectID
                                var likedByArr = self.adObj[ADS_LIKED_BY] as! [String]
                                likedByArr = likedByArr.filter { $0 != currUser.objectId! }
                                self.adObj[ADS_LIKED_BY] = likedByArr
                                
                                self.adObj.saveInBackground()
                                
                            } else {
                                self.simpleAlert("\(error!.localizedDescription)")
                                self.hideHUD()
                            }})
                    }
                    
                    
                    // error in query
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }}
            
        }
        else if user?.id != nil {
            showLoginAlert("Giriş yapmalısın. Şimdi giriş yapmak ister misin?")
        }
        else {
            showLoginAlert("Giriş yapmalısın. Şimdi giriş yapmak ister misin?")
        }
    }
    
    @IBAction func chatButt(_ sender: Any) {
        if PFUser.current() != nil {
            
            let sellerPointer = adObj[ADS_SELLER_POINTER] as! PFUser
            sellerPointer.fetchIfNeededInBackground(block: { (user, error) in
                if error == nil {
                    
                    // Seller has blocked you
                    let hasBlocked = sellerPointer[USER_HAS_BLOCKED] as! [String]
                    if hasBlocked.contains(PFUser.current()!.objectId!) {
                        self.simpleAlert("Sorry, @\(sellerPointer[USER_USERNAME]!) has blocked you, you can't chat with this user :(")
                        
                        // Chat with Seller
                    } else {
                        let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Inbox") as! Inbox
                        aVC.adObj = self.adObj
                        aVC.userObj = sellerPointer
                        self.navigationController?.pushViewController(aVC, animated: true)
                    }
                    
                }}) // end sellerPointer
            
        } else {
            showLoginAlert("Giriş yapmalısın. Şimdi giriş yapmak ister misin?")
        }
    }
    
    // MARK: - BACK BUTTON
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIView {
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
        }
    }
}



