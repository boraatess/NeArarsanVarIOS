
import UIKit
import WebKit

@available(iOS 13.0, *)

class TermsOfService: UIViewController {
    
    /* Views */
    //@IBOutlet var webView: WKWebView!
    
    @IBOutlet weak var webView: WKWebView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set app main color
        view.backgroundColor = MAIN_COLOR
        
        // Show tou.html
        let url = Bundle.main.url(forResource: "tos", withExtension: "html")
        webView.load(URLRequest(url: url!))
    }
    
    // DISMISS BUTTON
    @IBAction func dismissButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
