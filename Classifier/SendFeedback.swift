
import UIKit
import Parse

@available(iOS 13.0, *)

class SendFeedback: UIViewController, UITextViewDelegate
{
    /* Views */
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet var revTxt: UITextView!
    @IBOutlet var starsView: UIView!
    
    @IBOutlet weak var sButt1: UIButton!
    @IBOutlet weak var sButt2: UIButton!
    @IBOutlet weak var sButt3: UIButton!
    @IBOutlet weak var sButt4: UIButton!
    @IBOutlet weak var sButt5: UIButton!
    
    var charsLabel = UILabel()
    
    /* Variables */
    var sellerObj = PFUser()
    var adObj = PFObject(className: ADS_CLASS_NAME)
    var starNr = 0
    var starButtons = [UIButton]()

    override func viewDidLoad() {
            super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate

        headerView.backgroundColor = MAIN_COLOR
        
        usernameLabel.text = "\(sellerObj[USER_USERNAME]!)"
        
        // Layout
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)
        revTxt.layer.cornerRadius = 8
        starsView.layer.cornerRadius = 8
        starNr = 0
        
        // Initialize Star buttons
        starButtons.append(sButt1)
        starButtons.append(sButt2)
        starButtons.append(sButt3)
        starButtons.append(sButt4)
        starButtons.append(sButt5)
        
        for butt in starButtons {
            butt.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
            butt.addTarget(self, action: #selector(starButtTapped(_:)), for: .touchUpInside)
        }
        
        // Init a keyboard toolbar
        let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 44))
        toolbar.backgroundColor = SECOND_COLOR
        
        charsLabel = UILabel(frame: CGRect(x: view.frame.size.width-42, y: 0, width: 32, height: 44))
        charsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 12)
        //charsLabel.textColor = UIColor.black
        charsLabel.textAlignment = .center
        charsLabel.adjustsFontSizeToFitWidth = true
        charsLabel.text = "150"
        toolbar.addSubview(charsLabel)
        
        revTxt.inputAccessoryView = toolbar
        revTxt.delegate = self

    }

    // MARK: - STAR BUTTON
    @objc func starButtTapped (_ sender: UIButton) {
        let button = sender as UIButton
        
        for i in 0..<starButtons.count {
            starButtons[i].setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        }
        
        starNr = button.tag + 1
        print("STARS: \(starNr)")
        for star in 0..<starNr {
            starButtons[star].setBackgroundImage(UIImage(named: "fullStar"), for: .normal)
        }
    }
        
    // SEND FEEDBACK BUTTON
    @IBAction func sendFeedbackButt(_ sender: Any) {
        //showHUD("Gönderiliyor...")
        revTxt.resignFirstResponder()
        
        if revTxt.text == "" || starNr == 0 {
            self.simpleAlert("Puanlamalı ve kısa bir görüş yazmalısınız!")
            hideHUD()
            
        } else {
            let fObj = PFObject(className: FEEDBACKS_CLASS_NAME)
        
            fObj[FEEDBACKS_STARS] = starNr as Int
            fObj[FEEDBACKS_TEXT] = revTxt.text!
            fObj[FEEDBACKS_AD_TITLE] = "\(adObj[ADS_TITLE]!)"
            fObj[FEEDBACKS_REVIEWER_POINTER] = PFUser.current()!
            fObj[FEEDBACKS_SELLER_POINTER] = sellerObj
            
            fObj.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                
                    // Send Push Notification
                    let pushStr = "\(PFUser.current()![USER_USERNAME]!) sent you a \(self.starNr)-star feedback for: '\(self.adObj[ADS_TITLE]!)'"
                    
                    let data = [ "badge" : "Increment",
                                 "alert" : pushStr,
                                 "sound" : "bingbong.aiff"
                    ]
                    let request = [
                        "someKey" : self.sellerObj.objectId!,
                        "data" : data
                    ] as [String : Any]
                    PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                        if error == nil {
                            print ("\nPUSH SENT TO: @\(self.sellerObj[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                        } else {
                            print ("\(error!.localizedDescription)")
                        }
                    })
                    
                    // Save Activity
                    let activityClass = PFObject(className: ACTIVITY_CLASS_NAME)
                    activityClass[ACTIVITY_CURRENT_USER] = self.sellerObj
                    activityClass[ACTIVITY_OTHER_USER] = PFUser.current()!
                    activityClass[ACTIVITY_TEXT] = pushStr
                    activityClass.saveInBackground()
                    
                    // Fire Alert
                    let alert = UIAlertController(title: APP_NAME,
                            message: "Teşekkürler, geri bildiriminiz gönderildi!",
                            preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Bitti", style: .default, handler: { (action) -> Void in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                // error
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
            }})
        }
    }
        
    // MARK: - LIMIT CHARACTERS FOR THE REVIEW
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxCharacters = 200
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if numberOfChars >= maxCharacters { simpleAlert("İnceleme için izin verilen maksimum karakter sayısına ulaştınız!") }
        charsLabel.text = "\(maxCharacters-numberOfChars)"
        return numberOfChars < maxCharacters
    }
        
    // BACK BUTTON
    @IBAction func backButt(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    }
