
import UIKit
import Parse

@available(iOS 13.0, *)

class Categories: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /* Views */
    @IBOutlet weak var catTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
        
    /* Variables */
    var categories = [String]()
    var selCateg = ""

    override func viewDidLoad() {
            super.viewDidLoad()

        headerView.backgroundColor = MAIN_COLOR
        
        categories.removeAll()
        categories.append("All")
        
        // Call query
        queryCategories()
    }

        
    // MARK: - QUERY CATEGORIES
        func queryCategories() {
            showHUD("Lütfen Bekleyin...")

            let query = PFQuery(className: CATEGORIES_CLASS_NAME)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    for i in 0..<objects!.count {
                        var cObj = PFObject(className: CATEGORIES_CLASS_NAME)
                        cObj = objects![i]
                        
                        self.categories.append("\(cObj[CATEGORIES_CATEGORY]!)")
                    }
                    
                    self.hideHUD()
                    self.catTableView.reloadData()
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }}
        }
            
    // MARK: - TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "\(categories[indexPath.row])"
        
        
    return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
        
        
    // MARK: - CELL TAPPED -> SELECT A CATEGORY
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selCateg = "\(categories[indexPath.row])"
        selectedCategory = selCateg
        //dismiss(animated: true, completion: nil)
        
        if selectedCategory == "All" {
            //selectedCategory = selCateg
            selectedSubCategory = "All"
            dismiss(animated: true, completion: nil)
        } else {
            //selCateg = "\(categories[indexPath.row])"
            //selectedCategory = selCateg
            let aVC = storyboard?.instantiateViewController(withIdentifier: "Subcategories") as! Subcategories
            present(aVC, animated: true, completion: nil)
            //dismiss(animated: true, completion: nil)
            //self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
        
    // MARK: - CANCEL BUTTON
    @IBAction func cancelButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
}
