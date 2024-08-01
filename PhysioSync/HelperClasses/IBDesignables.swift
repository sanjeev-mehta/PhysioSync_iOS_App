//
//  PatientOnboardingVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//

import UIKit

// MARK: - UIView Corner Radius
private var cornerRadiusKey: UInt8 = 0

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let borderColor = layer.borderColor {
                return UIColor(cgColor: borderColor)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var topCornerRadius: CGFloat {
           get {
               return objc_getAssociatedObject(self, &cornerRadiusKey) as? CGFloat ?? 0.0
           }
           set {
               objc_setAssociatedObject(self, &cornerRadiusKey, newValue, .OBJC_ASSOCIATION_RETAIN)
               applyCornerRadius()
           }
       }
    
    func applyCornerRadius() {
            clipsToBounds = true
            layer.cornerRadius = cornerRadius
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    
}

// MARK: - Letter Spacing of UIButton

@IBDesignable
extension UIButton {
    @IBInspectable
    var letterSpacing: CGFloat {
        get {
            guard let attributedTitle = attributedTitle(for: .normal) else { return 0 }
            let range = NSRange(location: 0, length: attributedTitle.length)
            var kerningValue: CGFloat = 0
            attributedTitle.enumerateAttribute(.kern, in: range, options: []) { (value, _, _) in
                if let kern = value as? CGFloat {
                    kerningValue = kern
                }
            }
            return kerningValue
        }
        set {
            guard let currentTitle = title(for: .normal), newValue != letterSpacing else { return }
            
            let attributedString = NSMutableAttributedString(string: currentTitle)
            attributedString.addAttribute(.kern, value: newValue, range: NSRange(location: 0, length: attributedString.length))
            
            setAttributedTitle(attributedString, for: .normal)
        }
    }
}

// MARK: - Letter Spacing of UILabel

@IBDesignable
extension UILabel {
    @IBInspectable
    var letterSpacing: CGFloat {
        get {
            guard let attributedText = attributedText else { return 0 }
            let range = NSRange(location: 0, length: attributedText.length)
            var kerningValue: CGFloat = 0
            attributedText.enumerateAttribute(.kern, in: range, options: []) { (value, _, _) in
                if let kern = value as? CGFloat {
                    kerningValue = kern
                }
            }
            return kerningValue
        }
        set {
            guard let text = text, newValue != letterSpacing else { return }
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.kern, value: newValue, range: NSRange(location: 0, length: attributedString.length))
            
            attributedText = attributedString
        }
    }
}

// MARK: - Set Fonts
@IBDesignable extension UIView {
    
    private struct AssociatedKeys {
        static var customFontName: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "Outfit-Regular".hashValue)!
        static var customFontSize: UnsafeRawPointer = UnsafeRawPointer(bitPattern: "14.0".hashValue)!
    }
    
    @IBInspectable var customFontName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customFontName) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customFontName, newValue, .OBJC_ASSOCIATION_RETAIN)
            applyCustomFontIfNeeded()
        }
    }
    
    @IBInspectable var customFontSize: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customFontSize) as? CGFloat ?? 17.0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customFontSize, newValue, .OBJC_ASSOCIATION_RETAIN)
            applyCustomFontIfNeeded()
        }
    }
    
    private func applyCustomFontIfNeeded() {
        guard let fontName = customFontName else {
            return
        }
        
        applyCustomFont(fontName: fontName, fontSize: customFontSize)
    }
    
    
    private func applyCustomFont(fontName: String, fontSize: CGFloat) {
        guard let customFont = UIFont(name: fontName, size: fontSize) else {
           // print("Failed to load the \(fontName) \(fontSize) font.")
            return
        }
        if let label = self as? UILabel {
            label.font = customFont
        } else if let button = self as? UIButton {
            button.titleLabel?.font = customFont
        } else if let textField = self as? UITextField {
            textField.font = customFont
        } else if let textView = self as? UITextView {
            textView.font = customFont
        }
    }
}
