
import UIKit
import Parse

@available(iOS 13.0, *)

// MARK: - FEEDBACK CELL
class FeedbackCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var feedbackTxt: UITextView!
    @IBOutlet weak var byDateLabel: UILabel!
    @IBOutlet weak var starsImage: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
}

// MARK: - FEEDBACKS CONTROLLER
class Feedbacks: UIViewController,
UITableViewDataSource,
UITableViewDelegate
{

    /* Views */
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var feedbacksTableView: UITableView!
    @IBOutlet weak var noFeedbacksView: UIView!

    /* Variables */
    var feedbacksArray = [PFObject]()
    var userObj = PFUser()
    var cellHeight = CGFloat()
    
    override func viewDidAppear(_ animated: Bool) {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(queryFeedbacks), userInfo: nil, repeats: false)
    }
        
    override func viewDidLoad() {
            super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate

        headerView.backgroundColor = MAIN_COLOR
        
        // Call query
        queryFeedbacks()
    }

        
    // MARK: - QUERY FEEDBACKS
    @objc func queryFeedbacks() {
        showHUD("Lütfen bekleyin...")
        
        let query = PFQuery(className: FEEDBACKS_CLASS_NAME)
        query.whereKey(FEEDBACKS_SELLER_POINTER, equalTo: userObj)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.hideHUD()
                self.feedbacksArray = objects!
                self.feedbacksTableView.reloadData()
                
                // Show/hide noLikesView
                if self.feedbacksArray.count == 0 {
                    self.noFeedbacksView.isHidden = false
                }
                else {
                    self.noFeedbacksView.isHidden = true
                }
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }
        }
    }
        
    // MARK: - TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacksArray.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackCell
            
        var fObj = PFObject(className: FEEDBACKS_CLASS_NAME)
        fObj = feedbacksArray[indexPath.row]
            
        // Get Reviewer Pointer
        let reviewerPointer = fObj[FEEDBACKS_REVIEWER_POINTER] as! PFUser
        reviewerPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // Get Ad title
                cell.adTitleLabel.text = "\(fObj[FEEDBACKS_AD_TITLE]!)"
                        
                // Get feedback text
                cell.feedbackTxt.text = "\(fObj[FEEDBACKS_TEXT]!)"
                cell.feedbackTxt.sizeToFit()
                cell.feedbackTxt.frame.size.width = cell.frame.size.width - 20
                self.cellHeight = cell.feedbackTxt.frame.origin.y + cell.feedbackTxt.frame.size.height + 15
                
                // Get Date & Author
                let date = Date()
                let dateStr = self.timeAgoSinceDate(fObj.createdAt!, currentDate: date, numericDates: true)
                        
                cell.byDateLabel.text = "@\(reviewerPointer[USER_USERNAME]!) • \(dateStr)"
                cell.byDateLabel.frame.size.width = cell.frame.size.width - cell.starsImage.frame.size.width
                        
                // Get stars image
                cell.starsImage.image = UIImage(named: "\(fObj[FEEDBACKS_STARS]!)star")
                if fObj[FEEDBACKS_STARS] == nil { cell.starsImage.image = UIImage(named: "0star") }
                        
        }}) // end reviewerPointer
            
            
    return cell
    }
        
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
        
    // MARK: - BACK BUTTON
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
        
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

}
