
import Foundation
import UIKit
import AVFoundation
import CoreLocation

// IMPORTANT: Replace the red string below with the new name you'll give to this app
let APP_NAME = "Ne Ararsan Var"

// IMPORTANT: REPLACE THE RED STRING BELOW WITH YOUR OWN BANNER UNIT ID YOU'LL GET FROM  http://apps.admob.com
let ADMOB_BANNER_UNIT_ID = "ca-app-pub-3066798903065241/1964533803"

// YOU CAN CHANGE THE STRING BELOW INTO THE CURRENCY YOU WANT
let CURRENCY = "tl"

// THIS IS THE RED MAIN COLOR OF THIS APP
let MAIN_COLOR = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
let SECOND_COLOR = UIColor(red: 246/255, green: 210/255, blue: 88/255, alpha: 1.0)

// REPLACE THE RED STRINGS BELOW WITH YOUR OWN TEXTS FOR THE EACH WIZARD'S PAGE
let wizardLabels = [
    "ÜRÜNÜNÜZÜ KOLAYCA PAYLAŞIN \n\nÜrünlerinizi kolayca yükleyip satılık, kiralık, takas veya hediye olarak paylaşabilirsiniz.",
    
    "KATEGORİLERE GÖRE ÜRÜNLERİ GÖRÜNTÜLE \n\nHer kategorideki ürünleri arayabilir ve paylaşabilirsiniz",
    
    "DİĞER KULLANICILARLA SOHBET \n\nGelişmiş sohbet modülü sayesinde diğer kullanıcılarla sohbet edebilirsiniz.",
]

// YOU CAN CHANGE THE AD REPORT OPTIONS BELOW AS YOU WISH
let reportAdOptions = [
    "Yasaklı madde",
    "Conterfeit",
    "Yanlış kategori",
    "Anahtar kelime spam",
    "Tekrarlanan gönderi",
    "Çıplaklık / pornografi / yetişkin içeriği",
    "Nefret söylemi / şantaj",
]

// YOU CAN CHANGE THE USER REPORT OPTIONS BELOW AS YOU WISH
let reportUserOptions = [
    "Taklit ürünler satmak",
        "Yasaklı ürünlerin satışı",
        "Yanlış kategorilere ayrılmış öğeler",
        "Çıplaklık / pornografi / yetişkin içeriği",
        "Anahtar kelime spam'i yapan",
        "Nefret söylemi / şantaj",
        "Şüpheli dolandırıcı",
        "Buluşmada görünmeme",
        "Anlaşmadan geri çekildi",
        "Touting",
        "Spam",
]

// HUD View extension
let hudView = UIView(frame: CGRect(x:0, y:0, width:120, height: 120))
let label = UILabel()
let indicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:80, height:80))

@available(iOS 13.0, *)
extension UIViewController {
    
    var homecellWidth: CGFloat {
        
        return view.frame.width
    }
    
    var adscellWidth: CGFloat {
        
        return (view.frame.width - 20) / 2
    }
    
    var explorecellWidth: CGFloat {
        
        return (view.frame.width - 4) / 3
    }
    
    func showHUD(_ mess:String) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        //hudView.backgroundColor = MAIN_COLOR
        hudView.backgroundColor = SECOND_COLOR
        hudView.alpha = 1.0
        hudView.layer.cornerRadius = 8
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = .gray
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
        
        label.frame = CGRect(x: 0, y: 90, width: 140, height: 20)
        label.font = UIFont(name: "Gerbera W04 Light", size: 15)
        label.text = mess
        label.textAlignment = .center
        label.textColor = UIColor.black
        hudView.addSubview(label)
    }
    
    func hideHUD() {
        hudView.removeFromSuperview()
        label.removeFromSuperview()
    }
    
    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME, message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "TAMAM", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // SHOW LOGIN ALERT
    func showLoginAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: mess,
                                      preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Giriş yap", style: .default, handler: { (action) -> Void in
            let aVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "Wizard") as! Wizard
            self.present(aVC, animated: true, completion: nil)
            
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "İptal", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

/* Global Variables */
var distanceInMiles:Double = 50
var sortBy = "Newest"
var exploresortBy = "Most Popular"
var type = "All"
var exploretype = "All"

var selectedCategory = "All"
var selectedSubCategory = "All"
var selectedCity = "All"

//var chosenLocation:CLLocation?

// MARK: - METHOD TO CREATE A THUMBNAIL OF YOUR VIDEO
func createVideoThumbnail(_ url:URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = min(time.value, 2)
    do { let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: imageRef)
    } catch let error as NSError {
        print("Image generation failed with error \(error)")
        return nil
    }
}

// MARK: - EXTENSION TO RESIZE A UIIMAGE
extension UIViewController {
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

// EXTENSION TO FORMAT LARGE NUMBERS INTO K OR M (like 1.1M, 2.5K)
extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}

// EXTENSION TO SHOW TIME AGO DATES
extension UIViewController {
    func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) yıl önce"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 yıl önce"
            } else {
                return "Geçen yıl"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) Ay önce"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 Ay önce"
            } else {
                return "Geçen Ay"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) hafta önce"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 hafta önce"
            } else {
                return "Geçen Hafta"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) gün önce"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 gün önce"
            } else {
                return "Dün"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) saat önce"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 sa önce"
            } else {
                return "Bir sa önce"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) dakika önce"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 dk önce"
            } else {
                return "Bir dk önce"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) saniye"
        } else {
            return "Şimdi"
        }
        
    }
    
}
