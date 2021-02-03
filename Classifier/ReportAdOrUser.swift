
import UIKit
import Parse

@available(iOS 13.0, *)

class ReportAdOrUser: UIViewController,
UITableViewDelegate,
UITableViewDataSource
{
    /* Views */
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var reportTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    /* Variables */
    var adObj = PFObject(className: ADS_CLASS_NAME)
    var userObj = PFUser()
    var reportType = ""
    var reportArray = [String]()
    
    
        
    override func viewDidLoad() {
            super.viewDidLoad()

        headerView.backgroundColor = MAIN_COLOR
        
        print("REPORT TYPE: \(reportType)")
        titleLabel.text = "Rapor \(reportType)"
        
        if reportType == "User" {
            reportArray = reportUserOptions
        } else {
            reportArray = reportAdOptions
        }
    }

    // MARK: - TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "\(reportArray[indexPath.row])"
            
    return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
        
        
        
    // MARK: - CELL TAPPED -> REPORT AD
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "İnceleme için İşaretle?",
            message: "Bunu rapor etmek istediğinden emin misin \(reportType) şu sebepten dolayı:\n\(reportArray[indexPath.row])?",
            preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Evet, eminim", style: .default, handler: { (action) -> Void in
            self.showHUD("Lütfen Bekleyin...")
            
            // Report the AD
            if self.reportType == "Ad" {
                self.adObj[ADS_IS_REPORTED] = true
                self.adObj[ADS_REPORT_MESSAGE] = "\(self.reportArray[indexPath.row])"
            
                // Saving block
                self.adObj.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        self.hideHUD()
                        
                        let alert = UIAlertController(title: APP_NAME,
                            message: "Bu İlanı bildirdiğiniz için teşekkürler. 24 saat içinde inceleyeceğiz!",
                            preferredStyle: .alert)
                        
                        let ok = UIAlertAction(title: "TAMAM", style: .default, handler: { (action) -> Void in
                            self.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    
                    // error
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                        self.hideHUD()
                }})
                
                // Report the USER
            } else {
                let request = [
                    "userId" : self.userObj.objectId!,
                    "reportMessage" : "\(self.reportArray[indexPath.row])"
                ] as [String : Any]
                
                PFCloud.callFunction(inBackground: "reportUser", withParameters: request as [String : Any], block: { (results, error) in
                    if error == nil {
                        print ("@\(self.userObj[USER_USERNAME]!) bildirilmiştir!")
                        
                        self.simpleAlert("Bu Kullanıcıyı bildirdiğiniz için teşekkür ederiz, 24 saat içinde kontrol edeceğiz!")
                        self.hideHUD()
             
                        // Query all Ads posted by this User...
                        let query = PFQuery(className: ADS_CLASS_NAME)
                        query.whereKey(ADS_SELLER_POINTER, equalTo: self.userObj)
                        query.findObjectsInBackground { (objects, error) in
                            if error == nil {
                                
                                // ...and report Ads them one by one
                                for i in 0..<objects!.count {
                                    var adObj = PFObject(className: ADS_CLASS_NAME)
                                    adObj = objects![i]
                                    adObj[ADS_IS_REPORTED] = true
                                    adObj[ADS_REPORT_MESSAGE] = "**Satıcısını bildirdikten sonra otomatik olarak raporlanır**"
                                    adObj.saveInBackground()
                                }
                                
                            } else {
                                self.simpleAlert("\(error!.localizedDescription)")
                        }}

                    // error in Cloud Code
                    } else {
                        print ("\(error!.localizedDescription)")
                        self.hideHUD()
                }})
            }
            
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Hayır", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
        
    // MARK: - DIMSISS BUTTON
    @IBAction func cancelButt(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
