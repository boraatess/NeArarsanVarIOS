
import UIKit
import Parse

@available(iOS 13.0, *)

class SubCatCell: UITableViewCell {
}

class SubCategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var safeAreaView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var subcategoriesTableView: UITableView!
    
    var subcategoriesArray: [PFObject] = []
    
    var didSelectSubCategory: ((_ subcategory: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subcategoriesTableView.register(SubCatCell.self, forCellReuseIdentifier: "SubCategoryCell")
        
        // Set header background color
        headerView.backgroundColor = MAIN_COLOR
        safeAreaView.backgroundColor = MAIN_COLOR
        
        querySubCategories()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func cancelSubCatButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    // MARK: - QUERY CATEGORIRS
    func querySubCategories() {
        let query = PFQuery(className: SUBCATEGORIES_CLASS_NAME).whereKey(SUBCATEGORIES_TOPCATEGORY, equalTo: selectedCategory)
        //let query = PFQuery(className: SUBCATEGORIES_CLASS_NAME)

        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.subcategoriesArray = objects!
                self.subcategoriesTableView.reloadData()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subcategoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoryCell", for: indexPath)
        
        var cObj = PFObject(className: SUBCATEGORIES_CLASS_NAME)
        cObj = subcategoriesArray[indexPath.row]
        cell.textLabel?.text = "\(cObj[SUBCATEGORIES_SUBCATEGORY]!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cObj = PFObject(className: SUBCATEGORIES_CLASS_NAME)
        cObj = subcategoriesArray[indexPath.row]
        
        let selectedSubCategory = cObj[SUBCATEGORIES_SUBCATEGORY] as? String ?? "N/A"
        didSelectSubCategory?(selectedSubCategory)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
