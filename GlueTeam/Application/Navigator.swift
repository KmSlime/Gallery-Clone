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
    func pushToGallery()
    func pushToDetailPhoto(with index: IndexPath, target: UIViewController?)
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
    
    func pushToGallery() {
        let vc = GalleryCollectionView()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushToDetailPhoto(with index: IndexPath, target: UIViewController?) {
        let vc = DetailPhotoViewController()
        vc.beginIndex = index
        if let target = target, target.isKind(of: GalleryCollectionView.classForCoder()) {
            vc.galleryDelegate = target as! GalleryCollectionView
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
