//
//  PatientOnboardingVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit

extension UIView {
    
    func slideRightFromLeft(_ distance: CGFloat = 500, _ duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(translationX: distance, y: 0)
        }
    }
    
    func slideLeftFromRight(_ distance: CGFloat = 0, _ duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(translationX: distance, y: 0)
        }
    }
    
    func pressedAnimation(_ completionBlock: @escaping () -> Void) {
        isUserInteractionEnabled = false
        self.hapticFeedback(style: .soft)
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
            self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        }) {  (done) in
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
        }
    }
    
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle)  {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func performHapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
}
extension String {
    
    func sizeOfString (width: CGFloat = CGFloat.greatestFiniteMagnitude, font : UIFont, height: CGFloat = CGFloat.greatestFiniteMagnitude, drawingOption: NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin) -> CGSize {
        return (self as NSString).boundingRect(with: CGSize(width: width, height: height), options: drawingOption, attributes: [NSAttributedString.Key.font : font], context: nil).size
    }
    
    func numberOfLinesForString(size: CGSize, font: UIFont) -> Int {
        let textStorage = NSTextStorage(string: self, attributes: [NSAttributedString.Key.font: font])
        
        let textContainer = NSTextContainer(size: size)
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.textStorage = textStorage
        layoutManager.addTextContainer(textContainer)
        
        var numberOfLines = 0
        var index = 0
        var lineRange : NSRange = NSMakeRange(0, 0)
        
        while index < layoutManager.numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        
        return numberOfLines
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    var stringByDeletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    var stringByDeletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)
    }
    
    func trimSpaces() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func toBool() -> Bool {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return false
        }
    }
    
    public func isValidEmail() -> Bool {
        let stricterFilterString : String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest : NSPredicate = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
        return emailTest.evaluate(with: self)
    }
    
    public func isValidPincode() -> Bool {
        let stricterFilterString : String = "[1-9][0-9]{5}"
        let pincodeTest : NSPredicate = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
        return pincodeTest.evaluate(with: self)
    }
}


extension UIImage {
    func changeImageClr(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return nil }
        
        // Set the fill color
        color.setFill()
        
        // Draw the image in the context with the specified color
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage)
        context.fill(rect)
        
        // Create a new image from the context
        if let coloredImage = UIGraphicsGetImageFromCurrentImageContext() {
            return coloredImage
        } else {
            return nil
        }
    }
}

extension UIViewController {
    
    func enableTabbarItems(_ items: [Int]) {
        disableAllTabbarItems()
        if let arrayOfTabBarItems = tabBarController?.tabBar.items as NSArray? {
            for i in 0..<arrayOfTabBarItems.count {
                if items.contains(i) {
                    if let tabBarItem = arrayOfTabBarItems[i] as? UITabBarItem {
                        tabBarItem.isEnabled = true
                    }
                }
            }
        }
    }
    
    private func disableAllTabbarItems() {
        if let arrayOfTabBarItems = tabBarController?.tabBar.items as NSArray? {
            for i in 0..<arrayOfTabBarItems.count {
                if let tabBarItem = arrayOfTabBarItems[i] as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
    }
}
extension UIViewController {
    
    //Default Alert Box
    
    func displayAlert3( title:String,msg: String?, ok: String, okAction: (() -> Void)? = nil){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: ok, style: .default)
        { (action) in
            if let okAction = okAction {
                DispatchQueue.main.async(execute: {
                    okAction()
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        { (action) in
            // alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        // alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func displayAlert( title:String,msg: String?, ok: String, okAction: (() -> Void)? = nil){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: ok, style: .default)
        { (action) in
            if let okAction = okAction {
                DispatchQueue.main.async(execute: {
                    okAction()
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        { (action) in
            // alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayAlert2( title:String,msg: String?, ok: String, okAction: (() -> Void)? = nil){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: ok, style: .default)
        { (action) in
            if let okAction = okAction {
                DispatchQueue.main.async(execute: {
                    okAction()
                })
            }
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //MARK:- Set DropDown
    //    func setDropDown(dropDown:DropDown,arr:[String], arwClr: UIColor) {
    //
    //        dropDown.rowHeight = 40
    //        dropDown.optionArray = arr
    //        dropDown.arrowColor = arwClr
    //        dropDown.isSearchEnable = false
    //        dropDown.selectedRowColor = .clear
    //        dropDown.textColor = .clear
    //        dropDown.checkMarkEnabled = false
    //
    //    }
    
    func addCharactersToStringToLabels(string: String, lbls: [UILabel]) {
        let reversedString = String(string.reversed())
        let maxLength = min(reversedString.count, lbls.count)
        
        for index in 0..<lbls.count {
            if index < reversedString.count {
                lbls[index].text = String(reversedString[reversedString.index(reversedString.startIndex, offsetBy: index)])
            } else {
                lbls[index].text = "0"
            }
        }
    }
    
}
extension UIViewController {
    
    func switchController(_ storyBoardIdentifier: StoryBoardIDs, _ storyBoard: Storyboard) -> UIViewController? {
        let storyboard = UIStoryboard(name: storyBoard.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyBoardIdentifier.rawValue)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    func dismissOrPopViewController() {
        // Check if the view controller is embedded in a navigation controller
        if let navigationController = self.navigationController {
            // If it is, pop the view controller
            navigationController.popViewController(animated: true)
        } else {
            // If not, dismiss the view controller
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func pushOrPresentViewController(_ viewController: UIViewController, _ isPushed: Bool) {
        if isPushed {
            guard let navigationController = self.navigationController else {
                print("This view controller is not embedded in a navigation controller.")
                return
            }
            navigationController.pushViewController(viewController, animated: true)
        } else {
            self.present(viewController, animated: true)
        }
    }
    
    func debugPrint(_ message: String, function: String = #function, line: Int = #line) {
        let controllerName = String(describing: type(of: self))
        print("[\(controllerName)] \(function) [Line \(line)]: \(message)")
    }
}
extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}

extension UIImageView {
    
    func loadGif(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return
        }
        
        var images = [UIImage]()
        let count = CGImageSourceGetCount(source)
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        
        self.animationImages = images
        self.animationDuration = Double(images.count) / 30.0
        self.startAnimating()
    }
}

extension UIView {
    func addShadow(color: UIColor = .black, opacity: Float = 0.5, offset: CGSize = CGSize(width: 1.0, height: 2.0), radius: CGFloat = 3.0) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func addTopCornerRadius(radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}

// Mark:- Wrapper for String Optional
extension Optional where Wrapped == String {
    var orEmpty: String {
        self ?? ""
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}


