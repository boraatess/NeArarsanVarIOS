
import UIKit
import Parse
import AudioToolbox

@available(iOS 13.0, *)

// MARK: - AD CELL
class AdCell: UICollectionViewCell {
    
    /* Views */
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adTypeLabel: UILabel!
    @IBOutlet weak var adPriceLabel: UILabel!
    @IBOutlet weak var adsellerImage: UIImageView!
    @IBOutlet weak var adgiftimage: UIImageView!
    @IBOutlet weak var adexchangeimage: UIImageView!
    @IBOutlet weak var likeBackgroundView: UIImageView!
    @IBOutlet weak var adslistPriceBackground: UIImageView!
    
}

// MARK: - ADS LIST CONTROLLER
class AdsList: UIViewController  {
    
    @IBOutlet weak var safeAreaView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchPlaceholderLabel: UILabel!
    @IBOutlet weak var cancelOutlet: UIButton!
    @IBOutlet weak var adsCollView: UICollectionView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var filtersView: UIView!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var adBannerView: UIView!
    @IBOutlet weak var adBannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var appNameLabelView: UIView!
    @IBOutlet weak var appNameLabel: UILabel!
    
    /* Views */
//    let adMobBannerView = GADBannerView()
    
    /* Variables */
    var searchTxt = ""
    var adsArray = [PFObject]()
    
    //var locationManager: CLLocationManager!
    //var currentLocation: CLLocation?
    var cellSize = CGSize()
    //fileprivate var isLocationDenied = false
    
    var adObj = PFObject(className: ADS_CLASS_NAME)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate

        appNameLabel.text = APP_NAME.uppercased()
        appNameLabelView.alpha = 0.0
        
        safeAreaView.backgroundColor = MAIN_COLOR
        headerView.backgroundColor = MAIN_COLOR
                
        //adsCollView.backgroundColor = UIColor.clear
        noResultsView.isHidden = true

        cellSize = CGSize(width: adscellWidth, height: 240)

        // Init ad banners
        //initAdMobBanner()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Set search variables for the query
        if searchTxt != "" {
            searchTextField.text = searchTxt
        }
        
        cityLabel.text = selectedCity
        
        if selectedCategory != "All"
        {
            if selectedSubCategory != "All"
            {
                categoryLabel.text = selectedSubCategory
                searchPlaceholderLabel.text = selectedSubCategory
            }
            else
            {
                categoryLabel.text = selectedCategory
                searchPlaceholderLabel.text = selectedCategory
            }
            
        }
        else
        {
            categoryLabel.text = selectedCategory
            searchPlaceholderLabel.text = selectedCategory
        }
        
        //categoryLabel.text = selectedCategory
        //searchPlaceholderLabel.text = selectedCategory
        
        //categoryLabel.text = selectedSubCategory
        //searchPlaceholderLabel.text = selectedSubCategory
        searchPlaceholderLabel.isHidden = !searchTxt.isEmpty

        sortLabel.text = sortBy
        typeLabel.text = type
        

        queryAds()
        
    }
    
    // MARK: - ENTER CHATS BUTTON
    @IBAction func chatsButt(_ sender: Any) {
        if PFUser.current() != nil {
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Chats") as! Chats
            navigationController?.pushViewController(aVC, animated: true)
        } else {
            showLoginAlert("You need to be logged in. Want to Login now?")
        }
    }
    
    // MARK: - BACK BUTTON
    @IBAction func backButt(_ sender: Any) {
        //changeTabBar(hidden: false, animated: true)
        _ = navigationController?.popViewController(animated: true)
        //_ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - CANCEL BUTTON
    @IBAction func cancelButt(_ sender: Any) {
        
        searchTxt = ""
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        cancelOutlet.isHidden = true
        searchPlaceholderLabel.isHidden = !searchTxt.isEmpty
        
        selectedCategory = "Hepsi"
        selectedSubCategory = "Hepsi"
        categoryLabel.text = "Hepsi"
        //categoryLabel.text = selectedCategory
        //categoryLabel.text = selectedSubCategory
        selectedCity = "Hepsi"
        cityLabel.text = selectedCity
        queryAds()
        
        
    }
    
    

    // MARK: - QUERY ADS
    func queryAds() {
        noResultsView.isHidden = true
        
        let keywords = searchTxt.lowercased().components(separatedBy: " ")
        showHUD("Lütfen Bekleyin...")
        //print("KEYWORDS: \(keywords)\nCATEGORY: \(selectedCategory)")
        
        let query = PFQuery(className: ADS_CLASS_NAME)
        
        // query by text and/or Category
        if searchTxt != "" { query.whereKey(ADS_KEYWORDS, containedIn: keywords) }
        
        
        
        if selectedCategory != "All"
        {
            if selectedSubCategory != "All"
            {
                query.whereKey(ADS_SUBCATEGORY, equalTo: selectedSubCategory)
            }
            else
            {
                query.whereKey(ADS_CATEGORY, equalTo: selectedCategory)
            }
        }
        
        if selectedCity != "All" { query.whereKey(ADS_CITY, equalTo: selectedCity) }
        

        
        // query sortBy
        switch sortBy {
        case "Newest": query.order(byDescending: "createdAt")
        case "Oldest": query.order(byAscending: "createdAt")
        case "Most Popular": query.order(byDescending: ADS_LIKES)
        case "Minimum Price": query.order(byAscending: ADS_PRICE)
        case "Maximum Price": query.order(byDescending: ADS_PRICE)
        
        default:break}
        
        // query type
        switch type {
        case "Sell": query.whereKey(ADS_CONDITION, equalTo: "Sell")
        case "Rent": query.whereKey(ADS_CONDITION, equalTo: "Rent")
        case "Exchange": query.whereKey(ADS_CONDITION, equalTo: "Exchange")
        case "Gift": query.whereKey(ADS_CONDITION, equalTo: "Gift")
            
        default:break}
        
        // Query block
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.adsArray = objects!
                self.hideHUD()
                self.sortAds()
                self.typeAds()
                // Show/hide noResult view
                if self.adsArray.count == 0
                {
                    self.noResultsView.isHidden = false
                    
                }
                else
                {
                    self.noResultsView.isHidden = true
                }
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
    
    func sortAds() {
        switch sortBy {
        case "Newest":
            self.adsArray.sort(by: { $1.createdAt ?? Date() < $0.createdAt ?? Date() })
        default:
            break
        }
        self.adsCollView.reloadData()
    }
    
    func typeAds() {
        switch type {
        case "All":
            self.adsCollView.reloadData()
        default:
            break
        }
        self.adsCollView.reloadData()
    }
    
    // MARK: - CHANGE CATEGORY BUTTON
    @IBAction func categoryButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Categories") as! Categories
        present(aVC, animated: true, completion: nil)
    }
    

    @IBAction func cityButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Cities") as! Cities
        present(aVC, animated: true, completion: nil)
    }
    
    @IBAction func typeButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Type") as! Type
        present(aVC, animated: true, completion: nil)
    }
    
    // MARK: - SORT BUTTON
    @IBAction func sortButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "SortBy") as! SortBy
        present(aVC, animated: true, completion: nil)
    }
        
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
extension AdsList: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdCell", for: indexPath) as! AdCell
        
        cell.adgiftimage.isHidden = true
        cell.adexchangeimage.isHidden = true
        cell.likeBackgroundView.layer.cornerRadius = cell.likeBackgroundView.frame.height/2
        
        // Get Ad Object
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = adsArray[indexPath.row]
        
        var adCurrency = ""
        var adPriceString = ""
        var formattedNumberString = ""
        
        adCurrency = "\(adObj[ADS_CURRENCY]!)"
        adPriceString = "\(adObj[ADS_PRICE]!)"
        
        let adPriceNumber = (Int(adPriceString))!
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:adPriceNumber))
        
        formattedNumberString = String(formattedNumber!)
        
        print(formattedNumberString)
        
        // Get User Pointer
        let userPointer = adObj[ADS_SELLER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // Get Avatar
                cell.adsellerImage.layer.borderWidth = 1
                cell.adsellerImage.layer.masksToBounds = false
                cell.adsellerImage.layer.borderColor = UIColor.black.cgColor
                cell.adsellerImage.layer.cornerRadius = cell.adsellerImage.frame.height/2
                cell.adsellerImage.clipsToBounds = true
                let imageFileAvatar = userPointer[USER_AVATAR] as? PFFileObject
                imageFileAvatar?.getDataInBackground(block: { (data, error) in
                    if error == nil { if let imageData = data {
                        cell.adsellerImage.image = UIImage(data: imageData)
                        }}})
                
                // Get image 1
                let imageFile = adObj[ADS_IMAGE1] as? PFFileObject
                imageFile?.getDataInBackground(block: { (data, error) in
                    if error == nil { if let imageData = data {
                        cell.adImage.image = UIImage(data: imageData)
                        
                        }}})
                
                
                // Get title
                cell.adTitleLabel.text = "\(adObj[ADS_TITLE]!)"
                
                // Get type
                cell.adTypeLabel.text = "\(adObj[ADS_CONDITION]!)"
                //cell.adTypeLabel.text = "\(adObj[ADS_SUBCATEGORY]!)"

                // Get price
                //cell.adPriceLabel.text = "\(adObj[ADS_PRICE]!) \(adObj[ADS_CURRENCY]!)"
                cell.adPriceLabel.text! = adCurrency + " " + formattedNumberString

                switch cell.adTypeLabel.text {
                case "Gift":
                    cell.adPriceLabel.isHidden = true
                    cell.adgiftimage.isHidden = false

                case "Exchange":
                    cell.adPriceLabel.isHidden = true
                    cell.adexchangeimage.isHidden = false
                    
                default:
                    cell.adPriceLabel.isHidden = false
                    cell.adgiftimage.isHidden = true
                    cell.adexchangeimage.isHidden = true
                }
                
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }})
        
        //cell.contentView.layer.cornerRadius = 13
        cell.contentView.layer.borderWidth = 1.0
        //cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = true
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    // TAP ON A CELL -> SHOW AD's DETAILS
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get Ad Object
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = adsArray[indexPath.row]
        
        let aVC = storyboard?.instantiateViewController(withIdentifier: "AdDetails") as! AdDetails
        aVC.adObj = adObj
        //navigationController?.present(aVC, animated: true, completion: nil)
        navigationController?.pushViewController(aVC, animated: true)
    }
}

extension AdsList: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        searchPlaceholderLabel.isHidden = true
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelOutlet.isHidden = false
        textField.frame.size.width = view.frame.size.width - 124
        textField.frame.size.width = textField.frame.size.width - 58
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            searchTxt = textField.text!
            
            // Call query
            queryAds()
            
            textField.resignFirstResponder()
        } else {
            // No text -> No search
            simpleAlert("Birşeyler yazmalısın!")
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchPlaceholderLabel.isHidden = !textField.text!.isEmpty
    }
}

