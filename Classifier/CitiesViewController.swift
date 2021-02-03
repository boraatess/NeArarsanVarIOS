 
 import UIKit
 import Parse
 
 @available(iOS 13.0, *)

 class CtyCell: UITableViewCell {
 }
 
 class CitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var safeAreaView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var citiesTableView: UITableView!
        
     var citiesArray: [PFObject] = []
     
     var didSelectCity: ((_ city: String) -> Void)?
     
     override func viewDidLoad() {
     super.viewDidLoad()
     
     citiesTableView.register(CtyCell.self, forCellReuseIdentifier: "CityCell")
     
     // Set header background color
     headerView.backgroundColor = MAIN_COLOR
     safeAreaView.backgroundColor = MAIN_COLOR
     
     queryCities()
    }
     
     override var preferredStatusBarStyle: UIStatusBarStyle {
     return .lightContent
     }
     
        @IBAction func doneCtyViewButt(_ sender: Any) {
            dismiss(animated: true, completion: nil)
        }
        
     // MARK: - QUERY CITIES
     func queryCities() {
     let query = PFQuery(className: CITIES_CLASS_NAME)
     query.findObjectsInBackground { (objects, error) in
     if error == nil {
     self.citiesArray = objects!
     self.citiesTableView.reloadData()
     } else {
     self.simpleAlert("\(error!.localizedDescription)")
     }}
     }
     
     
     // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
     return 1
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
     
        var cObj = PFObject(className: CITIES_CLASS_NAME)
        cObj = citiesArray[indexPath.row]
        cell.textLabel?.text = "\(cObj[CITIES_CITY]!)"
     
        return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         var cObj = PFObject(className: CITIES_CLASS_NAME)
         cObj = citiesArray[indexPath.row]
         
         let selectedCity = cObj[CITIES_CITY] as? String ?? "N/A"
         didSelectCity?(selectedCity)
         dismiss(animated: true, completion: nil)
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return 50
        
     }
     
 }


