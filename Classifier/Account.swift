
import UIKit
import Parse

@available(iOS 13.0, *)

class MyAdCell: UITableViewCell {
    /* Vƒiews */
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
}

@available(iOS 13.0, *)
class Account: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var safeAreaView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var verifiedLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var myAdsTableView: UITableView!
    @IBOutlet weak var noAdsView: UIView!
    @IBOutlet weak var aboutMeTxt: UITextView!
    @IBOutlet weak var detailsView: UIView!
    
    /* Variables */
    var myAdsArray = [PFObject]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Call queries
        getUserDetails()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Layouts
        myAdsTableView.backgroundColor = UIColor.clear
    }
    
    // MARK: - GET USER'S DETAILS
    func getUserDetails() {
        guard let currUser = PFUser.current() else { return }
        
        // Get username
        //titleLabel.text = "@\(currUser[USER_USERNAME]!)"
        
        // Get fullname
        fullnameLabel.text = "\(currUser[USER_FULLNAME]!)"
        
        // Get about me
        if currUser[USER_ABOUT_ME] != nil {
            aboutMeTxt.text = currUser[USER_ABOUT_ME] as? String == "" ? "Kendin hakkında bir şeyler yaz." : "\(currUser[USER_ABOUT_ME]!)"
        }
        else
        {
            aboutMeTxt.text = "Kendin hakkında bir şeyler yaz."
            aboutMeTxt.font = UIFont.italicSystemFont(ofSize: 14)
            aboutMeTxt.textColor = UIColor.darkGray
        }
        
        // Get joined since
        let date = Date()
        self.joinedLabel.text = "Katıldı: \(self.timeAgoSinceDate(currUser.createdAt!, currentDate: date, numericDates: true))"
        
        // Get verified
        if currUser[USER_EMAIL_VERIFIED] != nil {
            self.verifiedLabel.text = currUser[USER_EMAIL_VERIFIED] as? Bool == true ? "Onaylı Profil: Evet" : "Onaylı Profil: Hayır"
        } else {
            self.verifiedLabel.text = "Onaylı Profil: Hayır"
        }
        
        // Get avatar
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        avatarImg.layer.borderWidth = 2
        avatarImg.layer.borderColor = UIColor.darkGray.cgColor
        let imageFile = currUser[USER_AVATAR] as? PFFileObject
        imageFile?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.avatarImg.image = UIImage(data: imageData)
                }}})
        
        // Call query
        queryMyAds()
    }
    
    // MARK: - QUERY MY ADS
    func queryMyAds() {
        let query = PFQuery(className: ADS_CLASS_NAME)
        query.whereKey(ADS_SELLER_POINTER, equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.myAdsArray = objects!
                self.myAdsTableView.reloadData()
                
                // Show/hide noAdsView
                if self.myAdsArray.count == 0 { self.noAdsView.isHidden = false
                } else { self.noAdsView.isHidden = true }
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    // MARK: - TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myAdsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAdCell", for: indexPath) as! MyAdCell
        
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = myAdsArray[indexPath.row]
        
        var adCurrency = ""
        var adPriceString = ""
        var formattedNumberString = ""
        
        adCurrency = "\(adObj[ADS_CURRENCY]!)"
        adPriceString = "\(adObj[ADS_PRICE]!)"
        
        let adPriceNumber = Int(adPriceString)!
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:adPriceNumber))
        
        formattedNumberString = String(formattedNumber!)
        
        print(formattedNumberString)
        
        // Get ad title
        cell.adTitleLabel.text = "\(adObj[ADS_TITLE]!)"
        
        // Get price
        //cell.priceLabel.text = "\(adObj[ADS_CURRENCY]!) \(adObj[ADS_PRICE]!)"
        cell.priceLabel.text! = adCurrency + " " + formattedNumberString

        // Get type
        cell.typeLabel.text = "\(adObj[ADS_CONDITION]!)"

        switch cell.typeLabel.text {
        case "Hediye":
            cell.priceLabel.isHidden = true
            cell.typeLabel.isHidden = false
            
        case "Takas":
            cell.priceLabel.isHidden = true
            cell.typeLabel.isHidden = false
            
        default:
            cell.priceLabel.isHidden = false
            cell.typeLabel.isHidden = true
        }
        
        //cell.priceLabel.textColor = MAIN_COLOR
        
        // Get date
        let date = Date()
        cell.dateLabel.text = timeAgoSinceDate(adObj.createdAt!, currentDate: date, numericDates: true)
        
        // Get image1
        let imageFile = adObj[ADS_IMAGE1] as? PFFileObject
        cell.adImage.layer.cornerRadius = cell.adImage.bounds.size.width/2
        imageFile?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                cell.adImage.image = UIImage(data: imageData)
                cell.adImage.layer.borderWidth = 0.6
                cell.adImage.layer.borderColor = UIColor.gray.cgColor
                }}})
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: - CELL TAPPED -> EDIT AD
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var adObj = PFObject(className: ADS_CLASS_NAME)
        adObj = myAdsArray[indexPath.row]
        
        let aVC = storyboard?.instantiateViewController(withIdentifier: "SellEditItem") as! SellEditItem
        aVC.adObj = adObj
        present(aVC, animated: true, completion: nil)
    }
    
    
    @IBAction func profilePicButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! EditProfile
        navigationController?.pushViewController(aVC, animated: true)
    }
    
    
    
    
    // MARK: - FEEDBACKS BUTTON
    @IBAction func feedbacksButt(_ sender: Any) {
        let currUser = PFUser.current()!
        
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Feedbacks") as! Feedbacks
        aVC.userObj = currUser
        navigationController?.pushViewController(aVC, animated: true)
    }
    
    // MARK: - EDIT PROFILE BUTTON
    @IBAction func editProfileButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! EditProfile
        navigationController?.pushViewController(aVC, animated: true)
    }
    
    @IBAction func mylikesButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "MyLikes") as! MyLikes
        navigationController?.pushViewController(aVC, animated: true)
    }
    
    // MARK: - LOGOUT BUTTON
    @IBAction func logoutButt(_ sender: UIButton) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Çıkış yapmak istediğinizden emin misiniz?",
                                      preferredStyle: .actionSheet)
        
        let ok = UIAlertAction(title: "Çıkış", style: .destructive, handler: { (action) -> Void in
            self.showHUD("Güle Güle...")
            
            PFUser.logOutInBackground(block: { (error) in
                if error == nil {
                    // Show the Wizard screen
                    let loginVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Wizard") as! Wizard
                    self.present(loginVC, animated: true, completion: nil)
                }
                self.hideHUD()
            })
        })
        let cancel = UIAlertAction(title: "İptal", style: .cancel, handler: { (action) -> Void in })
        alert.addAction(ok); alert.addAction(cancel)
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            let origin = CGPoint(x: sender.frame.midX, y: 180)
            popoverPresentationController.sourceRect = CGRect(origin: origin, size: sender.frame.size)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

