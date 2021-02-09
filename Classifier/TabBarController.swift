
//  Ne Ararsan Var
//
//  Created by bora on 9.02.2021.
//  Copyright © 2021 Developer Bora Ateş. All rights reserved.
//

import UIKit
import Parse

enum TabBarPage: Int {
    case home = 0
    case explore
    case addItem
    case activity
    case account
    
    var index: Int {
        return self.rawValue
    }
}

@available(iOS 13.0, *)
class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var appleUserId: String = ""
    var appleFirstName: String = ""
    var appleLastName: String = ""
    var appleEmail: String = ""
    var user: AppleUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        print("User id is \(user?.id ?? "") \n First name is \(String(describing: user?.firstname)) Last name is \(String(describing: user?.lastname)) \n email is \(String(describing: user?.email))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setImage(#imageLiteral(resourceName: "tb_home_icon"), selectedImage: #imageLiteral(resourceName: "tb_home_selected_icon"), title: "Ana Sayfa", forPage: .home)
        setImage(#imageLiteral(resourceName: "tb_explore_icon"), selectedImage: #imageLiteral(resourceName: "tb_explore_selected_icon"), title: "Keşfet",  forPage: .explore)
        setImage(#imageLiteral(resourceName: "tb_add"), selectedImage: #imageLiteral(resourceName: "tb_add"), title: nil,  forPage: .addItem)
        setImage(#imageLiteral(resourceName: "tb_activity_icon"), selectedImage: #imageLiteral(resourceName: "tb_activity_selected_icon"), title: "Bildirimler",  forPage: .activity)
        setImage(#imageLiteral(resourceName: "tb_user_icon"), selectedImage: #imageLiteral(resourceName: "tb_user_selected_icon"), title: "Profil",  forPage: .account)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else {
            return
        }

        switch index {
        case 2...4:
            if PFUser.current() == nil {
                
                let aVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Wizard") as! Wizard
                aVC.modalPresentationStyle = .overFullScreen
                present(aVC, animated: true, completion: nil)
           
            }
            else if user?.id != nil && user?.firstname != nil &&
                        user?.lastname != nil && user?.email != nil {
                
                let aVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Wizard") as! Wizard
                aVC.modalPresentationStyle = .overFullScreen
                present(aVC, animated: true, completion: nil)
            
            }
        default:
            break
        }
    }
    
    private func setImage(_ image: UIImage?, selectedImage: UIImage?, title: String?, forPage page: TabBarPage) {
        self.updateTabBarItem(title: title,
                              image: image,
                              selectedImage: selectedImage,
                              atIndex: page.index)
    }
}

extension UITabBarController {
    
    func updateTabBarItem(title: String? = nil, image: UIImage?, selectedImage: UIImage?, atIndex index: Int) {
        guard let tabItems = tabBar.items, index < tabItems.count && index >= 0 else {
            return
        }
        let tabBarItem = tabItems[index]
        
        // TabBarItem Title
        tabBarItem.title = title
        
        let color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        let font = UIFont.systemFont(ofSize: 12)
        let attributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
            
        tabBarItem.setTitleTextAttributes(attributes, for: .selected)
        tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        
        // TabBarItem Image
        tabBarItem.image = image?.withRenderingMode(.alwaysOriginal)
        tabBarItem.selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

extension UIViewController {
  func presentInFullScreen(_ viewController: UIViewController,
                           animated: Bool,
                           completion: (() -> Void)? = nil) {
    viewController.modalPresentationStyle = .overFullScreen
    present(viewController, animated: animated, completion: completion)
  }
}
