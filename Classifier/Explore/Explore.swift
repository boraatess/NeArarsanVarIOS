
import UIKit
import Parse
import AudioToolbox

@available(iOS 13.0, *)

class ExploreAdCell: UICollectionViewCell{
    
    @IBOutlet weak var exploreadImage: UIImageView!
    
}

class Explore: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var adBannerView: UIView!
    @IBOutlet weak var adBannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var exploreadsCollView: UICollectionView!
    
   // let adMobBannerView = GADBannerView()
    
    var exploreadsArray = [PFObject]()
    
    var cellSize = CGSize()
    
    var refresher:UIRefreshControl!

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        //safeAreaView.backgroundColor = MAIN_COLOR
        headerView.backgroundColor = MAIN_COLOR
        
        cellSize = CGSize(width: explorecellWidth, height: explorecellWidth)
    
        // Init ad banners
       // initAdMobBanner()

        self.refresher = UIRefreshControl()
        self.exploreadsCollView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.black
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.exploreadsCollView!.addSubview(refresher)
        
        queryAds()
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        
        let installation = PFInstallation.current()
        print("BADGE: \(installation!.badge)")
        if installation?.badge != 0 {
            self.tabBarController?.tabBar.items![3].badgeValue = "!"
        }

    }
    
    @objc func loadData() {
        //code to execute during refresher
        stopRefresher()
        //Call this to stop refresher
        
        exploreadsArray.shuffle()
        exploreadsCollView.reloadData()
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    // MARK: - QUERY ADS
    func queryAds() {
        
        showHUD("Lütfen Bekleyin...")

        let query = PFQuery(className: ADS_CLASS_NAME)

        query.order(byDescending: "createdAt")
        query.whereKey(ADS_IS_REPORTED, equalTo: false)
        
        // Query block
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.exploreadsArray = objects!
                self.hideHUD()
                self.exploretypeAds()
                
            }
            else
            {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }
            
        }
    }
    
    func exploretypeAds() {

        self.exploreadsCollView.reloadData()
    }

    /*
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

// MARK: - COLLECTION VIEW DELEGATES
extension Explore: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exploreadsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreAdCell", for: indexPath) as! ExploreAdCell
        
        // Get Ad Object
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = exploreadsArray[indexPath.row]
        
        // Get User Pointer
        let userPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // Get image 1
                let imageFile = adObj[ADS_IMAGE1] as? PFFileObject
                imageFile?.getDataInBackground(block: { (data, error) in
                    if error == nil { if let imageData = data {
                        cell.exploreadImage.image = UIImage(data: imageData)
                        }}})

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
        // Get Ad Object
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = exploreadsArray[indexPath.row]
        
        let aVC = storyboard?.instantiateViewController(withIdentifier: "AdDetails") as! AdDetails
        aVC.adObj = adObj
        navigationController?.pushViewController(aVC, animated: true)
    }
}


