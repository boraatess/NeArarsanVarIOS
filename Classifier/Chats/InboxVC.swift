
import UIKit
import Parse
import MessageUI
import AudioToolbox
import MobileCoreServices
import AssetsLibrary
import AVFoundation

@available(iOS 13.0, *)

// MARK: - CUSTOM INBOX CELLS
class InboxCell: UITableViewCell {
    /* Views */
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTxtView: UITextView!
    
    @IBOutlet weak var imageOutlet: UIButton!
    
    /* Variables */
    var theImage = UIImage()
}


class InboxCell2: UITableViewCell {
    /* Views */
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTxtView: UITextView!
    
    @IBOutlet weak var imageOutlet: UIButton!

    
    /* Variables */
    var theImage = UIImage()
}

// MARK: - INBOX CONTROLLER
class Inbox: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /* Views */
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inboxTableView: UITableView!
    @IBOutlet weak var fakeView: UIView!
    @IBOutlet weak var fakeTxt: UITextField!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImage: UIImageView!

    let messageTxt = UITextView()
    var sendButt = UIButton()
    
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adPriceLabel: UILabel!
    
    // Ad banners properties
    //var adMobBannerView = GADBannerView()

    /* Variables */
    var adObj = PFObject(className: ADS_CLASS_NAME)
    var userObj = PFUser()
    var inboxArray = [PFObject]()
    var chatsArray = [PFObject]()
    
    var cellHeight = CGFloat()
    var refreshTimer = Timer()
    var lastMessageStr = ""
    var imageToSend:UIImage?
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
        
    override func viewDidLoad() {
            super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        headerView.backgroundColor = MAIN_COLOR
        fakeView.backgroundColor = MAIN_COLOR
        
        // Get User's username
        titleLabel.text = "\(userObj[USER_USERNAME]!)  >"
        
        // Get AD details
        if adObj.allKeys.count > 0 {
            adTitleLabel.text = adObj[ADS_TITLE] as? String
            adPriceLabel.text = "\(adObj[ADS_CURRENCY]!)\(adObj[ADS_PRICE]!)"
            let imageFile = adObj[ADS_IMAGE1] as? PFFileObject
        
            imageFile?.getDataInBackground(block: { (data, error) in
                if error == nil { if let imageData = data {
                    self.adImage.image = UIImage(data: imageData)
            }}})
        }
        
        // Initial setup
        self.edgesForExtendedLayout = UIRectEdge()
        lastMessageStr = ""
        previewView.frame.origin.y = view.frame.size.height
        
        // INIT A KEYBOARD TOOLBAR ----------------------------------------------------------------------------
        let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 60))
        toolbar.backgroundColor = MAIN_COLOR
        
        // Message Txt
        messageTxt.frame = CGRect(x: 8, y: 2, width: toolbar.frame.size.width - 100, height: 58)
        messageTxt.delegate = self
        messageTxt.font = UIFont(name: "Titillium-Light", size: 16)
        messageTxt.textColor = UIColor.darkText
        messageTxt.keyboardAppearance = .dark
        messageTxt.autocorrectionType = .no
        messageTxt.autocapitalizationType = .sentences
        messageTxt.spellCheckingType = .no
        messageTxt.backgroundColor = UIColor.white
        toolbar.addSubview(messageTxt)
        
        // Send button
        sendButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 50, height: 44))
        sendButt.setTitle("Gönder", for: .normal)
        //sendButt.titleLabel?.textColor = UIColor.darkText
        sendButt.setTitleColor(.darkText, for: .normal)
        sendButt.titleLabel?.font = UIFont(name: "Titillium-Semibold", size: 16)
        sendButt.addTarget(self, action: #selector(sendButton), for: .touchUpInside)
        sendButt.showsTouchWhenHighlighted = true
        sendButt.isEnabled = false
        toolbar.addSubview(sendButt)
        
        // Hide keyboard button
        let hideKBButt = UIButton(frame: CGRect(x: sendButt.frame.origin.x - 48, y: 0, width: 44, height: 44))
        hideKBButt.titleLabel?.textColor = UIColor.darkText
        hideKBButt.setBackgroundImage(UIImage(named: "hide_keyboard_inbox"), for: .normal)
        hideKBButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        hideKBButt.showsTouchWhenHighlighted = true
        toolbar.addSubview(hideKBButt)
        
        fakeTxt.inputAccessoryView = toolbar
        fakeTxt.delegate = self
    
        // Timer to automatically check messages in the Inbox
        startRefreshTimer()
        
        // Call query
        queryInbox()

        // Set collectionView's height
        if UIScreen.main.bounds.size.height == 812 {
            // iPhone X
            inboxTableView.frame.size.height = view.frame.size.height - 213
        } else {
            inboxTableView.frame.size.height = view.frame.size.height - 185
        }
        
        
        // Init ad banners
        //initAdMobBanner()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
    }
        
    // MARK: - START THE REFRESH INBOX TIMER
    func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(queryInbox), userInfo: nil, repeats: true)
    }
        

    // MARK: - QUERY MESSAGES FROM YOUR INBOX
    @objc func queryInbox() {
        let inboxId1 = "\(PFUser.current()!.objectId!)\(userObj.objectId!)"
        let inboxId2 = "\(userObj.objectId!)\(PFUser.current()!.objectId!)"
        
        let predicate = NSPredicate(format:"inboxID = '\(inboxId1)' OR inboxID = '\(inboxId2)'")
        let query = PFQuery(className: INBOX_CLASS_NAME, predicate: predicate)
        
        query.whereKey(INBOX_AD_POINTER, equalTo: adObj)
        
        query.order(byAscending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.inboxArray = objects!
                self.inboxTableView.reloadData()
                
                if objects!.count != 0 {
                    Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.scrollTableViewToBottom), userInfo: nil, repeats: false)
                }
                
            // error
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}
    }
        
    // MARK: - TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxArray.count
    }
        
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get inboxObj
        var inboxObj = PFObject(className: INBOX_CLASS_NAME)
        inboxObj = inboxArray[indexPath.row]
        
        // Get userPointer
        var userPointer = inboxObj[INBOX_SENDER] as! PFUser
        do { userPointer = try userPointer.fetchIfNeeded() } catch {}
        
     
            
        // CELL WITH MESSAGE FROM CURRENT USER ------------------------------------------
        if userPointer.objectId == PFUser.current()!.objectId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! InboxCell
            
            // Default layout
            //cell.backgroundColor = UIColor.clear
            cell.imageOutlet.isHidden = true
            
            cell.messageTxtView.text = "\(inboxObj[INBOX_MESSAGE]!)"
            cell.messageTxtView.sizeToFit()
            cell.messageTxtView.frame.origin.x = 77
            cell.messageTxtView.frame.size.width = cell.frame.size.width - 87
            cell.messageTxtView.layer.cornerRadius = 5
            
            // Reset cellHeight
            self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + 15
            
            // Get Date
            let inboxDate = inboxObj.createdAt
            let date = Date()
            cell.dateLabel.text = timeAgoSinceDate(inboxDate!, currentDate: date, numericDates: true)

            // THIS MESSAGE HAS AN IMAGE -------------------
            if inboxObj[INBOX_IMAGE] != nil {
                cell.imageOutlet.imageView!.contentMode = .scaleAspectFill

                cell.messageTxtView.frame.size.height = 0
                cell.imageOutlet.tag = indexPath.row
                cell.imageOutlet.frame.size.width = 180
                cell.imageOutlet.frame.size.height = 180
                cell.imageOutlet.layer.cornerRadius = 8
                cell.imageOutlet.isHidden = false
                
                
                // Get the image
                let imageFile = inboxObj[INBOX_IMAGE] as? PFFileObject
                imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.theImage = UIImage(data: imageData)!
                            cell.imageOutlet.setBackgroundImage(UIImage(data: imageData)!, for: .normal)
                }}})
                
                // Reset cellHeight
                self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + cell.imageOutlet.frame.size.height + 40
                
            }
            
            
        return cell
     
        // CELL WITH MESSAGE FROM OTHER USER --------------------------------------------
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell2", for: indexPath) as! InboxCell2
            
            // Default layout
            //cell.backgroundColor = UIColor.clear
            cell.imageOutlet.isHidden = true
            
            // Get message
            cell.messageTxtView.text = "\(inboxObj[INBOX_MESSAGE]!)"
            cell.messageTxtView.sizeToFit()
            cell.messageTxtView.frame.origin.x = 8
            cell.messageTxtView.frame.size.width = cell.frame.size.width - 87
            cell.messageTxtView.layer.cornerRadius = 5

            // Reset cellheight
            self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + 15

            
            // Get Date
            let date = Date()
            let inboxDate = inboxObj.createdAt
            cell.dateLabel.text = timeAgoSinceDate(inboxDate!, currentDate: date, numericDates: true)
            
            // THIS MESSAGE HAS AN IMAGE -------------------
            if inboxObj[INBOX_IMAGE] != nil {
                cell.imageOutlet.imageView!.contentMode = .scaleAspectFill
                
                cell.messageTxtView.frame.size.height = 0
                
                cell.imageOutlet.tag = indexPath.row
                cell.imageOutlet.frame.size.width = 180
                cell.imageOutlet.frame.size.height = 180
                cell.imageOutlet.layer.cornerRadius = 8
                cell.imageOutlet.isHidden = false
                
                // Get the image
                let imageFile = inboxObj[INBOX_IMAGE] as? PFFileObject
                imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.theImage = UIImage(data: imageData)!
                            cell.imageOutlet.setBackgroundImage(UIImage(data: imageData)!, for: .normal)
                }}})
                
                
                // Reset cellHeight
                self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + cell.imageOutlet.frame.size.height + 40
            }
            
            
        return cell
        
        }
        
    }
        

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // MARK: - SCROLL TABLEVIEW TO BOTTOM
    @objc func scrollTableViewToBottom() {
        inboxTableView.scrollToRow(at: IndexPath(row: self.inboxArray.count-1, section: 0), at: .bottom, animated: true)
    }
    
    // MARK: - CHAT IMAGE BUTTON | INBOX CELL 1
    @IBAction func imageButt(_ sender: UIButton) {
        let butt = sender
        let indexP = IndexPath(row: butt.tag, section: 0)
        let cell = inboxTableView.cellForRow(at: indexP) as! InboxCell
        
        // Show the image preview
        previewImage.image = cell.theImage
        showImagePreview()
    }
      
    // MARK: - CHAT IMAGE BUTTON | INBOX CELL 2
    @IBAction func imageVideoButt2(_ sender: UIButton) {
        let butt = sender
        let indexP = IndexPath(row: butt.tag, section: 0)
        let cell = inboxTableView.cellForRow(at: indexP) as! InboxCell2
            
        // Show the image preview
        previewImage.image = cell.theImage
        showImagePreview()
    }
      
    // MARK: - SHOW/HIDE IMAGE PREVIEW
    func showImagePreview() {
        messageTxt.resignFirstResponder()
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
            self.previewView.frame.origin.y = 0
        }, completion: { (finished: Bool) in })
    }
    func hideImagePreview() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
            self.previewView.frame.origin.y = self.view.frame.size.height
        }, completion: { (finished: Bool) in })
    }
        
    // MARK: - SWIPE TO CLOSE IMAGE PREVIEW
    @IBAction func swipeToClose(_ sender: UISwipeGestureRecognizer) {
        hideImagePreview()
    }
        
    // MARK: - DISMISS KEYBOARD
    @objc func dismissKeyboard() {
        messageTxt.resignFirstResponder()
        messageTxt.text = ""
        fakeTxt.resignFirstResponder()
        fakeTxt.text = "mesajını yaz"
        sendButt.isEnabled = false
    }
        
        
        
    // MARK: - TEXT FIELD DELEGATES
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == fakeTxt {
            messageTxt.text = ""
            messageTxt.becomeFirstResponder()
            sendButt.isEnabled = true
        }
        
    return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == fakeTxt {
            messageTxt.text = ""
            messageTxt.becomeFirstResponder()
        }
        
    return true
    }
        
        
    // MARK: - SEND IMAGE BUTTON
    @IBAction func sendImageButt(_ sender: AnyObject) {
        let alert = UIAlertController(title: APP_NAME,
            message: "Kaynak Seç",
            preferredStyle: .alert)
        
        // Open Camera
        let camera = UIAlertAction(title: "Resim Çek", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        
        // Open Photo library
        let library = UIAlertAction(title: "Resim Seç", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "İptal", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
        
    // ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageToSend = resizeImage(image: image, newWidth: 400)
        }
        
        dismiss(animated: true, completion: nil)
        sendButton()
    }
        
    // MARK: - SEND MESSAGE BUTTON ------------------
    @objc func sendButton() {
        // Stop the refresh timer
        refreshTimer.invalidate()
        
        let inboxObj = PFObject(className: INBOX_CLASS_NAME)
        let currentUser = PFUser.current()!
        
        // Save Message to Inbox Class
        inboxObj[INBOX_SENDER] = currentUser
        inboxObj[INBOX_RECEIVER] = userObj
        inboxObj[INBOX_AD_POINTER] = adObj
        inboxObj[INBOX_INBOX_ID] = "\(currentUser.objectId!)\(userObj.objectId!)"
        inboxObj[INBOX_MESSAGE] = messageTxt.text
        lastMessageStr = messageTxt.text
    
        // SEND AN IMAGE OR A STICKER (if it exists) ------------------
        if imageToSend != nil {
            showHUD("Gönderiliyor...")
            
            let imageData = UIImageJPEGRepresentation(imageToSend!, 1)
            let imageFile = PFFileObject(name:"image.jpg", data:imageData!)
            inboxObj[INBOX_IMAGE] = imageFile
            
            inboxObj[INBOX_MESSAGE] = "[Picture]"
            lastMessageStr = "[Picture]"
        }


        // Saving block ------------------------------------------------------
        inboxObj.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.hideHUD()
                
                self.messageTxt.resignFirstResponder()
                self.fakeTxt.resignFirstResponder()
                
                // Call save LastMessage
                self.saveLastMessageInChats()
                // Add message to the array (it's temporary, before a new query gets automatically called)
                self.inboxArray.append(inboxObj)
                self.inboxTableView.reloadData()
                self.scrollTableViewToBottom()
     
                // Reset variables
                self.imageToSend = nil
                self.startRefreshTimer()
                
                
                // Send Push notification
                let pushStr = "\(PFUser.current()![USER_USERNAME]!) sana bir mesaj gönderdi. \nAlakalı ürün: \(self.adObj[ADS_TITLE]!)"
                //\(self.lastMessageStr)
                
                let data = [ "badge" : "Increment",
                             "alert" : pushStr,
                             "sound" : "bingbong.aiff"
                ]
                let request = [
                            "someKey" : self.userObj.objectId!,
                            "data" : data
                ] as [String : Any]
                PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                    if error == nil {
                        print ("\nPUSH SENT TO: \(self.userObj[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                    } else {
                        print ("\(error!.localizedDescription)")
                    }
                })
                
            // error on saving
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}

    }
      
    // MARK: - SAVE LAST MESSAGE IN CHATS CLASS
    func saveLastMessageInChats() {
        let currentUser = PFUser.current()!

        let inboxId1 = "\(PFUser.current()!.objectId!)\(userObj.objectId!)"
        let inboxId2 = "\(userObj.objectId!)\(PFUser.current()!.objectId!)"
        
        let predicate = NSPredicate(format:"\(CHATS_ID) = '\(inboxId1)'  OR  \(CHATS_ID) = '\(inboxId2)' ")
        let query = PFQuery(className: CHATS_CLASS_NAME, predicate: predicate)
        query.whereKey(CHATS_AD_POINTER, equalTo: adObj)
        
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.chatsArray = objects!

                var chatsObj = PFObject(className: CHATS_CLASS_NAME)

                if self.chatsArray.count != 0 {
                    chatsObj = self.chatsArray[0]
                }
                
                // print("CHATS ARRAY: \(self.chatsArray)\n")
                // Update Last message
                chatsObj[CHATS_LAST_MESSAGE] = self.lastMessageStr
                chatsObj[CHATS_USER_POINTER] = currentUser
                chatsObj[CHATS_OTHER_USER] = self.userObj
                chatsObj[CHATS_ID] = "\(currentUser.objectId!)\(self.userObj.objectId!)"
                chatsObj[CHATS_AD_POINTER] = self.adObj
                
                // Saving block
                chatsObj.saveInBackground { (success, error) -> Void in
                    if error == nil { print("LAST MESS SAVED: \(self.lastMessageStr)\n")
                    } else { self.simpleAlert("\(error!.localizedDescription)")
                }}
             
        
            // error in query
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}
    }
        
    // MARK: - VIEW AD BUTTON
    @IBAction func viewAdButt(_ sender: Any) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "AdDetails") as! AdDetails
        aVC.adObj = adObj
        navigationController?.pushViewController(aVC, animated: true)
    }
        
    // MARK: - OPTIONS BUTTON
    @IBAction func optionsButt(_ sender: Any) {
        // Check blocked users array
        let currUser = PFUser.current()!
        var hasBlocked = currUser[USER_HAS_BLOCKED] as! [String]
        
        // Set blockUser  Action title
        var blockTitle = String()
        if hasBlocked.contains(userObj.objectId!) {
            blockTitle = "Kullanıcı Engelleme"
        } else {
            blockTitle = "Kullanıcı Engelle"
        }
        
        let alert = UIAlertController(title: APP_NAME,
            message: "Seçenek Seç",
            preferredStyle: .alert)
        
        // REPORT USER ------------------------------------------------
        let repUser = UIAlertAction(title: "Kullanıcı Rapor", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportAdOrUser") as! ReportAdOrUser
            aVC.adObj = self.adObj
            aVC.reportType = "User"
            aVC.userObj = self.userObj
            self.present(aVC, animated: true, completion: nil)
        })
        
        // BLOCK/UNBLOCK USER ----------------------------------------
        let blockUser = UIAlertAction(title: blockTitle, style: .default, handler: { (action) -> Void in
            // Block User
            if blockTitle == "Engelle" {
                hasBlocked.append(self.userObj.objectId!)
                currUser[USER_HAS_BLOCKED] = hasBlocked
                currUser.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        self.simpleAlert("Bu Kullanıcıyı engellediniz, bundan böyle Sohbet mesajlarını almayacaksınız \(self.userObj[USER_USERNAME]!)")
                        _ = self.navigationController?.popViewController(animated: true)
                }})
                
            // Unblock User
            } else {
                let hasBlocked2 = hasBlocked.filter{$0 != "\(self.userObj.objectId!)"}
                currUser[USER_HAS_BLOCKED] = hasBlocked2
                currUser.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        self.simpleAlert("Engelini kaldırdın \(self.userObj[USER_USERNAME]!).")
                }})
            }
        })
        
        // DELETE CHAT ------------------------------------------------
        let deleteChat = UIAlertAction(title: "Sohbet Sil", style: .default, handler: { (action) -> Void in
           
            let alert = UIAlertController(title: APP_NAME,
                message: "Bu Sohbeti silmek istediğinizden emin misiniz? \(self.userObj[USER_USERNAME]!) bu mesajları da göremeyecek.",
                preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Sohbet Sil", style: .default, handler: { (action) -> Void in
                // Delete all Inbox messages
                for i in 0..<self.inboxArray.count {
                    var iObj = PFObject(className: INBOX_CLASS_NAME)
                    iObj = self.inboxArray[i]
                    iObj.deleteInBackground(block: { (succ, error) in
                        if error == nil {
                            _ = self.navigationController?.popToRootViewController(animated: true)
                    }})
                }
                
                // Delete Chat in Chats class
                let inboxId1 = "\(PFUser.current()!.objectId!)\(self.userObj.objectId!)"
                let inboxId2 = "\(self.userObj.objectId!)\(PFUser.current()!.objectId!)"
                let predicate = NSPredicate(format:"\(CHATS_ID) = '\(inboxId1)'  OR  \(CHATS_ID) = '\(inboxId2)' ")
                let query = PFQuery(className: CHATS_CLASS_NAME, predicate: predicate)
                query.findObjectsInBackground { (objects, error)-> Void in
                    if error == nil {
                        self.chatsArray = objects!
                        var chatsObj = PFObject(className: CHATS_CLASS_NAME)
                        chatsObj = self.chatsArray[0]
                    
                        chatsObj.deleteInBackground(block: { (succ, error) in
                            if error == nil {
                               print("Chat deleted in Chats class!")
                        }})
                        
                    // error in query
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                }}
                
            })
            
            // Cancel button
            let cancel = UIAlertAction(title: "İptal", style: .destructive, handler: { (action) -> Void in })

            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "İptal", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(repUser)
        alert.addAction(blockUser)
        alert.addAction(deleteChat)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
        
    // MARK: - BACK BUTTON
    @IBAction func backButt(_ sender: Any) {
        refreshTimer.invalidate()
        _ = navigationController?.popViewController(animated: true)
    }

        @IBAction func sellerButton(_ sender: Any) {
     
                let aVC = storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfile
                aVC.userObj = userObj
                navigationController?.pushViewController(aVC, animated: true)
        }
        
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}


