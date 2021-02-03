
import UIKit
import Parse

@available(iOS 13.0, *)

class CatCell: UITableViewCell {
}

class CategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var safeAreaView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var categoriesTableView: UITableView!
    
    var categoriesArray: [PFObject] = []
    
    var didSelectCategory: ((_ category: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriesTableView.register(CatCell.self, forCellReuseIdentifier: "CategoryCell")
        
        // Set header background color
        headerView.backgroundColor = MAIN_COLOR
        safeAreaView.backgroundColor = MAIN_COLOR
        
        queryCategories()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func doneCatViewButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - QUERY CATEGORIRS
    func queryCategories() {
        let query = PFQuery(className: CATEGORIES_CLASS_NAME)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.categoriesArray = objects!
                self.categoriesTableView.reloadData()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
        cObj = categoriesArray[indexPath.row]
        cell.textLabel?.text = "\(cObj[CATEGORIES_CATEGORY]!)"
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
        cObj = categoriesArray[indexPath.row]
        
        let selectedCategory = cObj[CATEGORIES_CATEGORY] as? String ?? "N/A"
        didSelectCategory?(selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
