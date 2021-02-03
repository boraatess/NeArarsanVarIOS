
import UIKit
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import AVFoundation
import Parse

@available(iOS 13.0, *)

extension SellEditItem: UIImagePickerControllerDelegate {
    
}

extension SellEditItem: UITextFieldDelegate, UITextViewDelegate {
    
}

class SellEditItem: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    /* Views */
    @IBOutlet weak var safeAreaView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
        
    @IBOutlet weak var priceBorderView: BorderView!
    @IBOutlet weak var categoryBorderView: BorderView!
    @IBOutlet weak var subcategoryBorderView: BorderView!
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var picButt1: UIButton!
    @IBOutlet weak var picButt2: UIButton!
    @IBOutlet weak var picButt3: UIButton!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    
    @IBOutlet weak var cityOutlet: UIButton!
   
    @IBOutlet weak var categoryOutlet: UIButton!
    
    @IBOutlet weak var subcategoryOutlet: UIButton!
   
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var conditionSegmented: UISegmentedControl!
    
    @IBOutlet weak var descriptionTxt: UITextView!

    @IBOutlet weak var deleteOutlet: UIButton!
    

    /* Variables */
    var adObj = PFObject(className: ADS_CLASS_NAME)
    var pictureTag = Int()
    var categoryName = ""
    var subcategoryName = ""
    var cityName = ""
    var condition = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = true
        
        condition = "Sell"
        
        subcategoryOutlet.isEnabled = false
        subcategoryBorderView.alpha = 0.3
        
        
        // Set header background color
        topView.backgroundColor = MAIN_COLOR
        safeAreaView.backgroundColor = MAIN_COLOR
        
        // Init a keyboard toolbar (to dismiss the keyboard on the descriptionTxt)
        let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 44))
        toolbar.backgroundColor = UIColor(red: 236/255, green: 210/255, blue: 88/255, alpha: 1.0)
        
        let doneButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
        doneButt.setTitle("BİTTİ", for: .normal)
        doneButt.setTitleColor(UIColor.black, for: .normal)
        doneButt.titleLabel?.font = UIFont(name: "Titillium-Semibold", size: 13)
        doneButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        toolbar.addSubview(doneButt)
        
        descriptionTxt.inputAccessoryView = toolbar
        priceTxt.inputAccessoryView = toolbar
        descriptionTxt.delegate = self
        priceTxt.delegate = self
        
        
        // Check if you're editing or selling an item
        if adObj.objectId != nil {
            titleLabel.text = "Düzenle"
            showAdDetails()
            deleteOutlet.isHidden = false
        } else {
            titleLabel.text = "Paylaş"
            deleteOutlet.isHidden = true
        }
        
    }

    
    // MARK: - SHOW AD's DETAILS
    func showAdDetails() {
        
        // Get image1
        let imageFile1 = adObj[ADS_IMAGE1] as? PFFileObject
        imageFile1?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.img1.image = UIImage(data: imageData)
                }}})
        
        // Get image2
        let imageFile2 = adObj[ADS_IMAGE2] as? PFFileObject
        imageFile2?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.img2.image = UIImage(data: imageData)
                }}})
        
        // Get image3
        let imageFile3 = adObj[ADS_IMAGE3] as? PFFileObject
        imageFile3?.getDataInBackground(block: { (data, error) in
            if error == nil { if let imageData = data {
                self.img3.image = UIImage(data: imageData)
                }}})
        
        // Get Category
        categoryOutlet.setTitle("\(adObj[ADS_CATEGORY]!)", for: .normal)
        categoryName = "\(adObj[ADS_CATEGORY]!)"
        
        // Get SubCategory
        subcategoryOutlet.setTitle("\(adObj[ADS_SUBCATEGORY]!)", for: .normal)
        subcategoryName = "\(adObj[ADS_SUBCATEGORY]!)"
        
        //Get City
        cityOutlet.setTitle("\(adObj[ADS_CITY]!)", for: .normal)
        cityName = "\(adObj[ADS_CITY]!)"
        
        // Get title
        titleTxt.text = "\(adObj[ADS_TITLE]!)"
        
        // Get price
        priceTxt.text = "\(adObj[ADS_PRICE]!)"
        
        // Get title
        titleTxt.text = "\(adObj[ADS_TITLE]!)"
        
        // Get condition
        condition = "\(adObj[ADS_CONDITION]!)"
        if condition == "Sat" {
            conditionSegmented.selectedSegmentIndex = 0
        }
        else if condition == "Kirala" {
            conditionSegmented.selectedSegmentIndex = 1
        }
        else if condition == "Takas" {
            conditionSegmented.selectedSegmentIndex = 2
        }
        else { conditionSegmented.selectedSegmentIndex = 3 }
        
        // Get description
        descriptionTxt.text = "\(adObj[ADS_DESCRIPTION]!)"
    }
    
    // MARK: - CHOOSE CATEGORY BUTTON
    @IBAction func categoryButt(_ sender: Any) {
        subcategoryOutlet.isEnabled = true
        subcategoryBorderView.alpha = 1

        let ctr = CategoriesViewController()
        ctr.didSelectCategory = { category in
            self.categoryOutlet.setTitle(category, for: .normal)
            self.categoryName = category
            selectedCategory = self.categoryName
        }
        present(ctr, animated: true, completion: nil)
    }
    
    // MARK: - CHOOSE SUBCATEGORY BUTTON
    @IBAction func subcategoryButt(_ sender: Any) {
        let ctr = SubCategoriesViewController()
        ctr.didSelectSubCategory = { subcategory in
            self.subcategoryOutlet.setTitle(subcategory, for: .normal)
            self.subcategoryName = subcategory
            selectedCategory = self.subcategoryName
        }
        present(ctr, animated: true, completion: nil)
    }
    
    @IBAction func chooseCityButt(_ sender: Any) {
        let ctr = CitiesViewController()
        ctr.didSelectCity = { city in
            self.cityOutlet.setTitle(city, for: .normal)
            self.cityName = city
        }
        present(ctr, animated: true, completion: nil)
    }
    
    @IBAction func chooseCityButt2(_ sender: Any) {
        let ctr = CitiesViewController()
        ctr.didSelectCity = { city in
            self.cityOutlet.setTitle(city, for: .normal)
            self.cityName = city
        }
        present(ctr, animated: true, completion: nil)
    }
    
    
    // MARK: - ADD A PICTURE BUTTON
    @IBAction func addPicButt(_ sender: UIButton) {
        // Assign the picture tag
        pictureTag = sender.tag
        
        let alert = UIAlertController(title: nil, message: "Kaynak Seç", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Resim Çek", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let library = UIAlertAction(title: "Galeriden Seç", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let cancel = UIAlertAction(title: "İptal", style: .cancel, handler: { (action) -> Void in })
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            let origin = CGPoint(x: 60, y: 30)
            popoverPresentationController.sourceRect = CGRect(origin: origin, size: sender.frame.size)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IMAGE PICKER DELEGATE (VIDEOS AND IMAGES)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        // mediaType is IMAGE
        if mediaType == kUTTypeImage as String {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if pictureTag == 1 {
                img1.image = resizeImage(image: image, newWidth: 400)
            } else if pictureTag == 2 {
                img2.image = resizeImage(image: image, newWidth: 400)
            } else if pictureTag == 3 {
                img3.image = resizeImage(image: image, newWidth: 400)
            }
        }
            
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TYPE BUTTONS
    @IBAction func conditionChanged(_ sender: UISegmentedControl) {
        // Set the newUsedString
        if sender.selectedSegmentIndex == 0 {
            priceBorderView.isHidden = false
            priceBorderView.alpha = 1.0
            condition = "Sat"
        }
        else if sender.selectedSegmentIndex == 1 {
            priceBorderView.isHidden = false
            priceBorderView.alpha = 1.0
            condition = "Kirala"
        }
        else if sender.selectedSegmentIndex == 2 {
            priceTxt.text = "0"
            priceBorderView.isHidden = true
            condition = "Takas"
        }
        else {
            priceTxt.text = "0"
            priceBorderView.isHidden = true
            condition = "Hediye"
        }
    }
    
    // MARK: - TEXTFIELD DELEGATES
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    @objc func dismissKeyboard() {
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        descriptionTxt.resignFirstResponder()
    }

    // MARK: - SUBMIT AD BUTTON
    @IBAction func submitAdButt(_ sender: Any) {
        let currentUser = PFUser.current()
        
                dismissKeyboard()
        
        if titleTxt.text == "" || condition == "" || priceTxt.text == "" || img1.image == nil || descriptionTxt.text == "" || categoryName == "" || subcategoryName == "" || cityName == "" {
            simpleAlert("Aşağıdaki ayrıntıları girdiğinizden emin olmalısınız")
        }
        else {
            showHUD("Onaylanıyor...")
            
            adObj[ADS_SELLER_POINTER] = currentUser
            adObj[ADS_TITLE] = titleTxt.text!
            adObj[ADS_CATEGORY] = categoryName
            adObj[ADS_SUBCATEGORY] = subcategoryName
            adObj[ADS_CITY] = cityName
            adObj[ADS_CONDITION] = condition
            if condition == "Takas" || condition == "Hediye" {
                priceTxt.text = "0"
            }

            adObj[ADS_DESCRIPTION] = descriptionTxt.text!
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: "EN")
            if let number = formatter.number(from: priceTxt.text!) {
                adObj[ADS_PRICE] = number.intValue
            } else {
                adObj[ADS_PRICE] = 0
            }
            adObj[ADS_CURRENCY] = CURRENCY
            var keywords =
                titleTxt.text!.lowercased().components(separatedBy: " ") +
                    descriptionTxt.text!.lowercased().components(separatedBy: " ") +
                    condition.lowercased().components(separatedBy: " ")
            keywords.append("\(PFUser.current()![USER_USERNAME]!)")
            adObj[ADS_KEYWORDS] = keywords
            
            // In case this is a new Ad
            if adObj.objectId == nil {
                adObj[ADS_LIKES] = 0
                adObj[ADS_COMMENTS] = 0
                adObj[ADS_IS_REPORTED] = false
            }
            
            // Save Image1
            if img1.image != nil {
                let imageData = UIImageJPEGRepresentation(img1.image!, 1.0)
                let imageFile = PFFileObject(name:"img1.jpg", data:imageData!)
                adObj[ADS_IMAGE1] = imageFile
            }
            // Save Image2 (if it exists)
            if img2.image != nil {
                let imageData = UIImageJPEGRepresentation(img2.image!, 1.0)
                let imageFile = PFFileObject(name:"img2.jpg", data:imageData!)
                adObj[ADS_IMAGE2] = imageFile
            }
            // Save Image3 (if it exists)
            if img3.image != nil {
                let imageData = UIImageJPEGRepresentation(img3.image!, 1.0)
                let imageFile = PFFileObject(name:"img3.jpg", data:imageData!)
                adObj[ADS_IMAGE3] = imageFile
            }
            
            // Saving block
            adObj.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                    
                    
                    let alert = UIAlertController(title: APP_NAME,
                                                  message: "Ürünün başarıyla yayınlandı.",
                                                  preferredStyle: .alert)
                    
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: { (action) -> Void in
                        // Go back to Home screen
                        let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                        tbc.selectedIndex = 0
                        self.present(tbc, animated: false, completion: nil)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                    // error on saving
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }})
            
            
        }// en IF
    }
    
    // MARK: - DELETE ITEM BUTTON
    @IBAction func deleteItemButt(_ sender: Any) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Bu ürünü silmek istediğinden emin misin?",
                                      preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Sil", style: .destructive, handler: { (action) -> Void in
            self.adObj.deleteInBackground { (succ, error) in
                if error == nil {
                    self.deleteAdInOtherClasses()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.closeScreen()
                    })
                }
            }
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "İptal", style: .default, handler: { (action) -> Void in })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func closeScreen() {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Ürünün zaten silinmiş!",
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "TAMAM", style: .default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - DELETE AD IN OTHER CLASSES
    func deleteAdInOtherClasses() {
        print("\(adObj.objectId!)")
        
        // Delete adPointer in Chats class
        let query = PFQuery(className: CHATS_CLASS_NAME)
        query.whereKey(CHATS_AD_POINTER, equalTo: adObj)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                for i in 0..<objects!.count {
                    let obj = objects![i]
                    obj.deleteInBackground()
                }
            }}
        
        // Delete adPointer in Comments class
        let query2 = PFQuery(className: COMMENTS_CLASS_NAME)
        query2.whereKey(COMMENTS_AD_POINTER, equalTo: adObj)
        query2.findObjectsInBackground { (objects, error) in
            if error == nil {
                for i in 0..<objects!.count {
                    let obj = objects![i]
                    obj.deleteInBackground()
                }
            }}
        
        // Delete adPointer in Inbox class
        let query3 = PFQuery(className: INBOX_CLASS_NAME)
        query3.whereKey(INBOX_AD_POINTER, equalTo: adObj)
        query3.findObjectsInBackground { (objects, error) in
            if error == nil {
                for i in 0..<objects!.count {
                    let obj = objects![i]
                    obj.deleteInBackground()
                }
            }}
        
        // Delete adPointer in Likes class
        let query4 = PFQuery(className: LIKES_CLASS_NAME)
        query4.whereKey(LIKES_AD_LIKED, equalTo: adObj)
        query4.findObjectsInBackground { (objects, error) in
            if error == nil {
                for i in 0..<objects!.count {
                    let obj = objects![i]
                    obj.deleteInBackground()
                }
            }}
    }
    
    // MARK: - CANCEL BUTTON
    @IBAction func cancelButt(_ sender: Any) {
        if adObj.objectId == nil {
            // Go back to Home screen
            let tbc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
            tbc.selectedIndex = 0
            self.present(tbc, animated: false, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    

}
