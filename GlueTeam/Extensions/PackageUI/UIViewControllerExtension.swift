//
//  UIViewControllerExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// Move it to here
extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        
        child.view.frame = view.frame
        
        view.bringSubviewToFront(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        DispatchQueue.main.async {
            self.view.removeFromSuperview()
        }
    }
}

@objc extension UIViewController {
    static func initFromNib() -> Self {
        func instanceFromNib<T: UIViewController>() -> T {
            return T(nibName: String(describing: self), bundle: nil)
        }
        return instanceFromNib()
    }

    @objc func dismissAnyAlertControllerIfPresent() {
        guard let window: UIWindow = UIApplication.shared.keyWindow,
              var topVC = window.rootViewController?.presentedViewController else { return }
        while topVC.presentedViewController != nil {
            topVC = topVC.presentedViewController!
        }
        if topVC.isKind(of: UIAlertController.self) {
            topVC.dismiss(animated: false, completion: nil)
        }
    }
    
    func removeFromParentController() {
        self.removeFromParent()
        self.view.removeFromSuperview()
        self.didMove(toParent: nil)
    }


    /// Need to set textfield keyboardType = numberpad
    @objc func finalNumberStringForTextFieldIfNeed(textfield: UITextField, text: NSString, range: NSRange, string: String) -> String {
        if textfield.keyboardType == .numberPad {
            return text.replacingCharacters(in: range, with: string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: ""))
        } else if textfield.keyboardType == .decimalPad {
            return text.replacingCharacters(in: range, with: string.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined(separator: ""))
        } else {
            return text.replacingCharacters(in: range, with: string)
        }
    }

    @objc func topMostViewController() -> UIViewController {
        // Handling Modal views
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        // Handling UIViewController's added as subviews to some other views.
        else {
            for view in self.view.subviews {
                // Key property which most of us are unaware of / rarely use.
                if let subViewController = view.next {
                    if subViewController is UIViewController {
                        let viewController = subViewController as! UIViewController
                        return viewController.topMostViewController()
                    }
                }
            }
            return self
        }
    }
    
    @objc var hasTopNotch: Bool { //tai thỏ
            if #available(iOS 11.0, *) {
                return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
            } else {
                return false
            }
    }    
}
