
import UIKit
import Parse
import AudioToolbox

@available(iOS 13.0, *)

class LikedAdCell: UICollectionViewCell {
    /* Views */
    @IBOutlet weak var adImage: UIImageView!
    
}

class MyLikes: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    /* Views */
    @IBOutlet weak var safeAreaView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var noLikesView: UIView!
    @IBOutlet weak var likesCollView: UICollectionView!
    @IBOutlet weak var adBannerView: UIView!
    @IBOutlet weak var adBannerViewHeight: NSLayoutConstraint!
    
   // let adMobBannerView = GADBannerView()
    
    /* Variables */
    var likesArray = [PFObject]()
    var cellSize = CGSize()

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        safeAreaView.backgroundColor = MAIN_COLOR
        headerView.backgroundColor = MAIN_COLOR
        
        likesCollView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        
        // Set cells size
        cellSize = CGSize(width: explorecellWidth, height: explorecellWidth)

        // Init ad banner
       // initAdMobBanner()
        
        queryLikes()

    }
    

    // MARK: - QUERY LIKES
    func queryLikes() {
        likesArray.removeAll()
        likesCollView.reloadData()
        
        showHUD("Lütfen Bekleyin...")
        
        let query = PFQuery(className: LIKES_CLASS_NAME)
        query.whereKey(LIKES_CURR_USER, equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.likesArray = objects!
                self.hideHUD()
                self.likesCollView.reloadData()
                
                // Show/hide noLikesView
                if self.likesArray.count == 0
                {
                    self.noLikesView.isHidden = false
                }
                else
                {
                    self.noLikesView.isHidden = true                    
                }
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }
        }
    }
    
    
    // MARK: - COLLECTION VIEW DELEGATES
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedAdCell", for: indexPath) as! LikedAdCell
        
        // Get Like Object
        var likeObj = PFObject(className: LIKES_CLASS_NAME)
        likeObj = likesArray[indexPath.row]
        
        // Get Ad Object
        let adObj = likeObj[LIKES_AD_LIKED] as! PFObject
        adObj.fetchIfNeededInBackground(block: { (object, error) in
            if error == nil {
                
                // AD HAS NOT BEEN REPORTED, SHOW IT
                if adObj[ADS_IS_REPORTED] as! Bool == false {
                    
                    // Get User Pointer
                    let userPointer = adObj[ADS_SELLER_POINTER] as! PFUser
                    userPointer.fetchIfNeededInBackground(block: { (user, error) in
                        if error == nil {
                            
                            // Get image 1
                            let imageFile = adObj[ADS_IMAGE1] as? PFFileObject
                            imageFile?.getDataInBackground(block: { (data, error) in
                                if error == nil { if let imageData = data {
                                    cell.adImage.image = UIImage(data: imageData)
                                    }}})
                            
                        } else {
                            self.simpleAlert("\(error!.localizedDescription)")
                        }})
                    
                    // AD HAS BEEN REPORTED!
                } else {
                    cell.adImage.image = UIImage(named:"report_image")

                }
                // error in adPointer
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }})
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    // TAP ON A CELL -> SHOW AD's DETAILS
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get Like Object
        var likeObj = PFObject(className: LIKES_CLASS_NAME)
        likeObj = likesArray[indexPath.row]
        
        // Get Ad Object
        let adObj = likeObj[LIKES_AD_LIKED] as! PFObject
        adObj.fetchIfNeededInBackground(block: { (object, error) in
            if error == nil {
                if adObj[ADS_IS_REPORTED] as! Bool == false {
                    
                    let aVC = self.storyboard?.instantiateViewController(withIdentifier: "AdDetails") as! AdDetails
                    aVC.adObj = adObj
                    self.navigationController?.pushViewController(aVC, animated: true)
                    
                } else {
                    self.simpleAlert("Bu reklamı göremezsiniz, inceleniyor!")
                }
                
            }})
    }
    
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - ADMOB BANNER METHODS
    func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = adBannerView.frame
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    */
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = adBannerView.frame
        UIView.commitAnimations()
        banner.isHidden = true
        
        adBannerViewHeight.constant = 0
        view.layoutIfNeeded()
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        adBannerViewHeight.constant = 50
        view.layoutIfNeeded()
        
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = adBannerView.frame
        UIView.commitAnimations()
        banner.isHidden = false
    }
    /*
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    */
}
