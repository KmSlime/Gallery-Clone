//
//  BaseViewController.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import UIKit

@objcMembers 
final class BaseViewController: UIViewController {

    static let shared = GalleryCollectionView(collectionViewLayout: UICollectionViewLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        pushToFlashScreen()
        view.backgroundColor = .red
    }
}

