//
//  UINavigationControllerExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 12/10/2023.
//

import UIKit

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
    
    override func topMostViewController() -> UIViewController {
        return self.visibleViewController!.topMostViewController()
    }
    
    @objc func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
}

