
//  Ne Ararsan Var
//
//  Created by bora on 9.02.2021.
//  Copyright © 2021 Developer Bora Ateş. All rights reserved.
//

import UIKit
import Parse
import AuthenticationServices

@available(iOS 13.0, *)

class Wizard: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {

    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var signInButton: UIButton!
    
    /* Variables */
    var scrollTimer = Timer()
    var user: AppleUser?
    
    // SET THE NUMBER OF IMAGES ACCORDINGLY TO THE IMAGES YOU'VE PLACED IN THE 'WIZARD IMAGES' FOLDER IN Assets.xcassets
    let numberOfImages = 3
        
    // Hide the status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        // Call functions
        setupWizardImages()
        // COMMENT THIS LINE OF CODE IF YOU DON'T WANT AN AUTOMATIC SCROLL OF THE WIZARD
        scrollTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        
        print("User id is \(user?.id ?? "") \n First name is \(String(describing: user?.firstname))   Last name is \(String(describing: user?.lastname)) \n email is \(String(describing: user?.email))")
    
    }
    
    @IBAction func SigninWithApple(_ sender: Any) {
        didTapSignIn()
    }
    
    // MARK: - SETUP WIZARD IMAGES
    func setupWizardImages() {
            // Variables for setting the Views
            var xCoord:CGFloat = 0
            let yCoord:CGFloat = 0
            let width:CGFloat = view.frame.size.width
            let height: CGFloat = view.frame.size.height
            
            // Counter for items
            var itemCount = 0
            
            // Loop for creating imageViews -----------------
            for i in 0..<numberOfImages {
                itemCount = i
                
                // Create the imageView
                let aImage = UIImageView()
                aImage.frame = CGRect(x: xCoord,
                                      y: yCoord,
                                      width: width,
                                      height: height)
                aImage.image = UIImage(named: "wizard\(i)")
                aImage.contentMode = .scaleAspectFill
                aImage.clipsToBounds = true
                aImage.alpha = 0.6
                
                // Create the Label
                let textLabel = UILabel()
                textLabel.frame = CGRect(x:xCoord + 10,
                                      y:view.frame.size.height - 350,
                                      width: view.frame.size.width - 40,
                                      height: 100)
                textLabel.numberOfLines = 8
                textLabel.adjustsFontSizeToFitWidth = true
                textLabel.font = UIFont(name: "Titillium-Regular", size: 15)
                textLabel.textColor = UIColor.white
                textLabel.textAlignment = .center
                textLabel.adjustsFontSizeToFitWidth = true
                textLabel.shadowOffset = CGSize(width: 1, height: 1)
                textLabel.shadowColor = UIColor.darkGray
                textLabel.text = wizardLabels[i]
                
                // Add imageViews one after the other
                xCoord +=  width
                containerScrollView.addSubview(aImage)
                containerScrollView.addSubview(textLabel)
            } // end For Loop --------------------------
            
            // Place ImageViews into the container ScrollView
            containerScrollView.contentSize = CGSize(width: width * CGFloat(itemCount+1), height: yCoord)
    }
        
    // MARK: - SCROLLVIEW DELEGATE: SHOW CURRENT PAGE IN THE PAGE CONTROL
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = containerScrollView.frame.size.width
        let page = Int(floor((containerScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
        pageControl.currentPage = page
    }
        
    // MARK: - AUTOMATIC SCROLL
    @objc func automaticScroll() {
        var scroll = containerScrollView.contentOffset.x
        if scroll < CGFloat(view.frame.size.width) * CGFloat(numberOfImages-1) {
            scroll += CGFloat(view.frame.size.width)
            containerScrollView.setContentOffset(CGPoint(x: scroll, y:0), animated: true)
        } else {
            // Stop the timer
            scrollTimer.invalidate()
        }
    }
        
    // MARK: - FACEBOOK LOGIN BUTTON
    @IBAction func facebookButt(_ sender: Any)
    {
        let alertController = UIAlertController(title:APP_NAME,
                                                message:"Facebook ile giriş yapmak şuan için aktif değil",
                                                preferredStyle:.alert)
        self.present(alertController,animated:true,completion:{Timer.scheduledTimer(withTimeInterval: 2, repeats:false, block: {_ in
            self.dismiss(animated: true, completion: nil)
        })})
    }
        
    // MARK: - SIGN IN BUTTON
    @IBAction func signInButt(_ sender: Any) {
        let aVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Login") as! Login
        present(aVC, animated: true, completion: nil)
    }
    
    // MARK: - TERMS OF SERVICE BUTTON
    @IBAction func tosButt(_ sender: Any) {
        let aVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "TermsOfService") as! TermsOfService
        present(aVC, animated: true, completion: nil)
    }
        
    // MARK: - DISMISS BUTTON
    @IBAction func dismissButton(_ sender: Any) {
        // Go to Home screen
        let tbc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        tbc.selectedIndex = 0
        tbc.modalPresentationStyle = .overFullScreen
        self.present(tbc, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    @objc func didTapSignIn(){
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
}

extension Wizard: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("failed...")
        print(error.localizedDescription)
    }
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            let appleuser = AppleUser(credentials: credentials)
            let userid = appleuser.id
            let firstName = appleuser.firstname
            let lastName = appleuser.lastname
            let email = appleuser.email
            print("User id is \(userid) \n First name is \(String(describing: firstName)) Last name is \(String(describing: lastName)) \n email is \(String(describing: email))")
            
            if userid.isEmpty && firstName.isEmpty && lastName.isEmpty && email.isEmpty {
                print("Error! something wrong")
            }
            else{
                let tbc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                tbc.selectedIndex = 0
                tbc.modalPresentationStyle = .overFullScreen
                self.present(tbc, animated: false, completion: nil)
            }
            
            break
        default:
            break
        }
    }
} 

extension Wizard: ASAuthorizationControllerPresentationContextProviding {
   
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
}
