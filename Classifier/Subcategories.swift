
import UIKit
import Parse

@available(iOS 13.0, *)

class Subcategories: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /* Views */
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var subcatTableView: UITableView!
    
    /* Variables */
    var subCategories = [String]()
    var selSubCateg = ""
    
    var subCatArr = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.backgroundColor = MAIN_COLOR
        
        subCategories.removeAll()
        subCategories.append("All")
        
        // Call query
        queryCategories()
    }
    
    // MARK: - QUERY CATEGORIES
    func queryCategories() {
        showHUD("Lütfen Bekleyin...")

        //let query = PFQuery(className: SUBCATEGORIES_CLASS_NAME)
        let query = PFQuery(className: SUBCATEGORIES_CLASS_NAME).whereKey(SUBCATEGORIES_TOPCATEGORY, equalTo: selectedCategory)
        var cObj = PFObject(className: SUBCATEGORIES_CLASS_NAME)

        //topCategoryPointer.fetchIfNeededInBackground(block: { (object, error) in
        //if error == nil {
        
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                for i in 0..<objects!.count {
                    cObj = objects![i]
                    
                    self.subCategories.append("\(cObj[SUBCATEGORIES_SUBCATEGORY]!)")
                    //}
                    //}
                }
                
                self.hideHUD()
                self.subcatTableView.reloadData()
                
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
        return subCategories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "\(subCategories[indexPath.row])"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    // MARK: - CELL TAPPED -> SELECT A CATEGORY
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selSubCateg = "\(subCategories[indexPath.row])"
        selectedSubCategory = selSubCateg
      
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


