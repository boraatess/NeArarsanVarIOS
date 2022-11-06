
import UIKit
import Parse
import AudioToolbox

@available(iOS 13.0, *)

// MARK: - SUBCATEGORY CELL
class SubCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var subcatImage: UIImageView!
    @IBOutlet weak var subcatLabel: UILabel!
}

// MARK: - HOME CONTROLLER
class HomeSubCategory: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var subcategoriesCollView: UICollectionView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    
    /* Variables */
    var subcategoriesArray: [PFObject] = []
    var cellSize = CGSize()
    var string: String?
    //var substringchat: String?
    //var substringlike: String?
    //var substringcomment: String?
    //var substringfeedback: String?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        IQKeyboardManager.shared.enable = false
        
        appNameLabel.text = APP_NAME.uppercased()

        // Set cells size
        let cellSizeConst = homecellWidth
        cellSize = CGSize(width: cellSizeConst, height: cellSizeConst/2.35)
        
        // Set header background color
        headerView.backgroundColor = MAIN_COLOR
        
        // Init ad banners
        //initAdMobBanner()
        
        // Call query
        querySubCategories()
        
        switch traitCollection.userInterfaceStyle {
        case .dark:
            appNameLabel.textColor = .darkText
            break
        case .light:
            
            break
        default:
            print("something else")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //searchPlaceholderLabel.isHidden = !searchTextField.text!.isEmpty
        //changeTabBar(hidden: false, animated: true)
        //setupPushNotifications()
    }

    // MARK: - QUERY CATEGORIRS
    func querySubCategories() {
        //showHUD("Please Wait...")
        
        let query = PFQuery(className: SUBCATEGORIES_CLASS_NAME).whereKey(SUBCATEGORIES_TOPCATEGORY, equalTo: selectedCategory)
        query.order(byAscending: "createdAt")
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                //self.categoriesArray.insert(objects![0], at: 0)
                //self.categoriesArray.insert(objects![1], at: 1)
                //self.categoriesArray.insert(objects![4], at: 2)
                self.subcategoriesArray = objects!
                self.hideHUD()
                self.subcategoriesCollView.reloadData()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }
        }
    }

    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension HomeSubCategory: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subcategoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
        
        var cObj = PFObject(className: SUBCATEGORIES_CLASS_NAME)
        cObj = subcategoriesArray[indexPath.row]
        
        cell.subcatLabel.text = "\(cObj[SUBCATEGORIES_SUBCATEGORY]!)".uppercased()
        
        let imageFile = cObj[SUBCATEGORIES_IMAGE] as? PFFileObject
        imageFile?.getDataInBackground(block: {
            (data, error) in
            if error == nil, let imageData = data
            {
                cell.subcatImage.image = UIImage(data: imageData)
            }
        })
        
        if(cObj.objectId == "916b7GUBrG"){
            cell.subcatLabel.text = "EV".uppercased()
        }
        else if(cObj.objectId == "iIHcbTG5YF"){
            cell.subcatLabel.text = "Ofis".uppercased()
        }
        else if(cObj.objectId == "PuOatii394"){
            cell.subcatLabel.text = "Telefon".uppercased()
        }
        else if(cObj.objectId == "0H5Z4sG1rK"){
            cell.subcatLabel.text = "Otomobil".uppercased()
        }
        else if(cObj.objectId == "JxRZ77zB6u"){
            cell.subcatLabel.text = "Motorsiklet".uppercased()
        }
        else if(cObj.objectId == "4qbLAm4D43"){
            cell.subcatLabel.text = "Kadın".uppercased()
        }
        else if(cObj.objectId == "NeZDJaIkvn"){
            cell.subcatLabel.text = "Erkek".uppercased()
        }
        else if(cObj.objectId == "OX0yGsTrEl"){
            cell.subcatLabel.text = "Çocuk".uppercased()
        }
        else if(cObj.objectId == "A2gENdYPSf"){
            cell.subcatLabel.text = "Kolye".uppercased()
        }
        else if(cObj.objectId == "xDGnRY5HXE"){
            cell.subcatLabel.text = "Küpe".uppercased()
        }
        else if(cObj.objectId == "azkdLUiOVL"){
            cell.subcatLabel.text = "Evlilik".uppercased()
        }
        else if(cObj.objectId == "SXGv5hOacE"){
            cell.subcatLabel.text = "Konser".uppercased()
        }
        else if(cObj.objectId == "4wBERE8S5o"){
            cell.subcatLabel.text = "Oturma Odası".uppercased()
        }
        else if(cObj.objectId == "n5EpRbdFJf"){
            cell.subcatLabel.text = "Mutfak".uppercased()
        }
        else if(cObj.objectId == "nyWy7WF3zx"){
            cell.subcatLabel.text = "Makyaj".uppercased()
        }
        else if(cObj.objectId == "ALYIbqCGCS"){
            cell.subcatLabel.text = "Vücut Bakım".uppercased()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    //TAP ON A CELL -> SHOW ADS
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cObj = PFObject(className: SUBCATEGORIES_CLASS_NAME)
        cObj = subcategoriesArray[indexPath.row]
        
        //selectedHomeCategoryID = "\(cObj[CATEGORIES_HOME_ID]!)"
        selectedSubCategory = "\(cObj[SUBCATEGORIES_SUBCATEGORY]!)"
        //selectedSubCategory = "All"
        
        let aVC = storyboard?.instantiateViewController(withIdentifier: "AdsList") as! AdsList
        navigationController?.pushViewController(aVC, animated: true)
    }
    
}
