
import UIKit

@available(iOS 13.0, *)

class SortBy: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    /* Views */
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var sortTableView: UITableView!
    
    /* Variables */
    var sortByArr = ["En Yeni",
                     "En Eski",
                     "En Popüler",
                     "Düşük Fiyat",
                     "Yüksek Fiyat",
                     ]
    
    var selectedSort = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.backgroundColor = MAIN_COLOR
    }
    
    // MARK: - TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortByArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "\(sortByArr[indexPath.row])"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: - CELL TAPPED
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSort = "\(sortByArr[indexPath.row])"
        sortBy = selectedSort
        dismiss(animated: true, completion: nil)
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
