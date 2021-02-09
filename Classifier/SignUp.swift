
//  Ne Ararsan Var
//
//  Created by bora on 9.02.2021.
//  Copyright © 2021 Developer Bora Ateş. All rights reserved.
//

import UIKit
import Parse

@available(iOS 13.0, *)

class SignUp: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    
    @IBOutlet weak var dismissOutlet: UIButton!
    @IBOutlet weak var fullnamenextOutlet: UIButton!
    @IBOutlet weak var emailnextOutlet: UIButton!
    @IBOutlet weak var passwordnextOutlet: UIButton!
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var touOutlet: UIButton!
    @IBOutlet weak var chooseView: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var checkboxButton: UIButton!
    
    @IBOutlet weak var fullnamemessageTxt: UITextView!
    @IBOutlet weak var emailmessageTxt: UITextView!
    @IBOutlet weak var passwordmessageTxt: UITextView!
    @IBOutlet weak var usernameMessageTxt: UITextView!
    
    @IBOutlet weak var tosView: UIView!
    @IBOutlet weak var fullnameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var fullnameMessageView: UIView!
    @IBOutlet weak var emailMessageView: UIView!
    @IBOutlet weak var passwordMessageView: UIView!
    @IBOutlet weak var usernameMessageView: UIView!
    
    /* Variables */
    var tosAccepted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailMessageView.isHidden = true
        passwordMessageView.isHidden = true
        usernameMessageView.isHidden = true
        
        tosView.isHidden = true
        emailView.isHidden = true
        passwordView.isHidden = true
        usernameView.isHidden = true
        
        emailnextOutlet.isHidden = true
        passwordnextOutlet.isHidden = true
        signUpOutlet.isHidden = true
        
        // Layouts
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 750)
        chooseView.layer.cornerRadius = 10
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        
        // Change placeholder's color
        let color = UIColor.white
        usernameTxt.attributedPlaceholder = NSAttributedString(string: "kullanıcı adı seç", attributes: [NSAttributedStringKey.foregroundColor: color])
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "parola seç", attributes: [NSAttributedStringKey.foregroundColor: color])
        emailTxt.attributedPlaceholder = NSAttributedString(string: "email adresinizi giriniz", attributes: [NSAttributedStringKey.foregroundColor: color])
        fullnameTxt.attributedPlaceholder = NSAttributedString(string: "tam adınızı girinizi", attributes: [NSAttributedStringKey.foregroundColor: color])
        
        //Signup button background color
        signUpOutlet.setTitleShadowColor(MAIN_COLOR, for: .normal)
        signUpOutlet.setTitle("Devam", for: .normal)
    }
    
    // MARK: - TAP TO DISMISS KEYBOARD
    @IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        fullnameTxt.resignFirstResponder()
    }
    
    // MARK: - CAMERA BUTTON
    @IBAction func camButt(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - LIBRARY BUTTON
    @IBAction func libraryButt(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImg.image = resizeImage(image: image, newWidth: 300)
        }
        dismiss(animated: true, completion: nil)
    }
    
    ////********************************************************************
    
    @IBAction func fullnamenextButt(_ sender: Any) {
        dismissKeyboard()
        
        if self.fullnameTxt.text == ""{
            self.simpleAlert("Lütfen tam adınızı girdiğinizden emin olunuz!")
        }
        else
        {
            fullnameView.isHidden = true
            fullnameMessageView.isHidden = true
            fullnamenextOutlet.isHidden = true
            emailView.isHidden = false
            emailMessageView.isHidden = false
            emailnextOutlet.isHidden = false
        }
    }
    
    @IBAction func emailnextButt(_ sender: Any) {
        dismissKeyboard()
        
        if self.emailTxt.text == ""{
            self.simpleAlert("Lütfen e-mail adresinizi girdiğinizden emin olunuz!")
        }
        else
        {
            let enteredEmail = emailTxt.text
            
            // Then query and compare
            let query = PFQuery(className: USER_CLASS_NAME)
            query.whereKey(USER_EMAIL, equalTo: enteredEmail!)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    if (objects!.count > 0)
                    {
                        self.simpleAlert("Bu e-mail adresi zaten başka bir kullanıcı tarafından kullanılıyor.")
                    }
                    else
                    {
                        self.emailView.isHidden = true
                        self.emailMessageView.isHidden = true
                        self.emailnextOutlet.isHidden = true
                        self.passwordView.isHidden = false
                        self.passwordMessageView.isHidden = false
                        self.passwordnextOutlet.isHidden = false
                    }
                }
                else
                {
                    self.simpleAlert("error")
                }
            }
        }
        
    }
    
    @IBAction func passwordnextButt(_ sender: Any) {
        dismissKeyboard()
        
        if self.passwordTxt.text == ""{
            self.simpleAlert("Lütfen parolanızı girdiğinizden emin olunuz!")
        }
        else{
            
            passwordView.isHidden = true
            passwordMessageView.isHidden = true
            passwordnextOutlet.isHidden = true
            usernameView.isHidden = false
            usernameMessageView.isHidden = false
            signUpOutlet.isHidden = false
            tosView.isHidden = false
        }

    }
    
    // MARK: - SIGNUP BUTTON
    @IBAction func signupButt(_ sender: AnyObject) {
        dismissKeyboard()
        
        if self.usernameTxt.text == ""{
            self.simpleAlert("Lütfen kullanıcı adınızı girdiğinizden emin olunuz!")
        }
        else
        {
            let enteredUsername = usernameTxt.text
            // Then query and compare
            let query = PFQuery(className: USER_CLASS_NAME)
            query.whereKey(USER_USERNAME, equalTo: enteredUsername!)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    if (objects!.count > 0){
                        self.simpleAlert("Bu kullanıcı adı daha önceden alınmış")
                    }
                    else
                    {
                        // You acepted the TOS
                        if self.tosAccepted {
                            
                            if self.usernameTxt.text == "" || self.passwordTxt.text == "" ||
                                self.emailTxt.text == "" || self.fullnameTxt.text == "" {
                                self.simpleAlert("Tüm alanları doldurduğunuzdan emin olun!")
                                self.hideHUD()
                                
                            }
                            else {
                                //self.showHUD("Hoşgeldin..."
                                let userForSignUp = PFUser()
                                userForSignUp.username = self.usernameTxt.text!.lowercased()
                                userForSignUp.password = self.passwordTxt.text
                                userForSignUp.email = self.emailTxt.text
                                userForSignUp[USER_FULLNAME] = self.fullnameTxt.text
                                userForSignUp[USER_IS_REPORTED] = false
                                let hasBlocked = [String]()
                                userForSignUp[USER_HAS_BLOCKED] = hasBlocked
                                
                                // Save Avatar
                                let imageData = UIImageJPEGRepresentation(self.avatarImg.image!, 1.0)
                                let imageFile = PFFileObject(name:"avatar.jpg", data:imageData!)
                                userForSignUp[USER_AVATAR] = imageFile
                                
                                userForSignUp.signUpInBackground { (succeeded, error) -> Void in
                                    if error == nil {
                                        self.hideHUD()
                                        
                                        let alert = UIAlertController(title: APP_NAME,
                                                                      message: "Kaydolduğunuz için teşekkürler. Şimdi giriş sayfasına geri dönebilirsiniz.",
                                                                      preferredStyle: .alert)
                                        
                                        // Logout and Go back to Login screen
                                        let ok = UIAlertAction(title: "TAMAM", style: .default, handler: { (action) -> Void in
                                            PFUser.logOutInBackground(block: { (error) in
                                                self.dismiss(animated: false, completion: nil)
                                            })
                                        })
                                        
                                        alert.addAction(ok)
                                        self.present(alert, animated: true, completion: nil)
                                        
                                        // ERROR
                                    } else {
                                        self.simpleAlert("\(error!.localizedDescription)")
                                        self.hideHUD()
                                    }}
                            }
                            
                            // YOU HAVEN'T ACEPTED THE TOS
                        } else {
                            self.simpleAlert("Kaydolmak için Hizmet Şartları'nı kabul etmelisiniz.")
                        }
                    }
                }
                else
                {
                    self.simpleAlert("error")
                }
            }
        }
}
        
    // MARK: - CHECKBOX BUTTON
    @IBAction func checkboxButt(_ sender: UIButton) {
        tosAccepted = true
        sender.setBackgroundImage(UIImage(named: "checkbox_on"), for: .normal)
    }
    
    // MARK: -  TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTxt {  dismissKeyboard()  }
        if textField == passwordTxt {  dismissKeyboard()     }
        if textField == emailTxt {  dismissKeyboard()     }
        if textField == fullnameTxt {  dismissKeyboard()  }
        
        return true
    }
    
    // MARK: - DISMISS BUTTON
    @IBAction func dismissButt(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - TERMS OF SERVICE BUTTON
    @IBAction func touButt(_ sender: AnyObject) {
        let aVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "TermsOfService") as! TermsOfService
        present(aVC, animated: true, completion: nil)
    }
}

