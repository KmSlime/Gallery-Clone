//
//  Navigator.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import UIKit

protocol Navigator {
    func pushToFlashScreen()
    func pushTo(vc: UIViewController)
    func back()
}


extension BaseViewController: Navigator {
    func pushToFlashScreen() {
        //do something with this screen?
    }
        
    func pushTo(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
}
