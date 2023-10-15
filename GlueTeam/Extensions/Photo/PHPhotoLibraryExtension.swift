//
//  PHPhotoLibraryExtension.swift
//  GlueTeam
//
//  Created by Liêm Nguyễn on 15/10/2023.
//

import UIKit
import Photos

typealias ImageFetchCompletion = ((PHAsset, Int, Bool) -> ())
typealias GalleryFetchCompletion = ((PHFetchResult<PHAsset>)->())

extension PHPhotoLibrary {
    func fetchGallery(completion: @escaping GalleryFetchCompletion) {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            if status == .authorized {
                completion(PHAsset.fetchAssets(with: .image, options: nil))
            } else {
                main_queue {
                    let alert = UIAlertController(title: "Oops!", message: "PHPhotoLibrary requestAuthorization denied", preferredStyle: .alert)
                    let cancelaction = UIAlertAction(title: "Cancel", style: .cancel)
                    let action = UIAlertAction(title: "Settings", style: .default) { _ in
                        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
                        UIApplication.shared.open(url)
                    }
                    alert.addAction(action)
                    alert.addAction(cancelaction)
                    BaseViewController.shared.present(alert, animated: true)
                }
            }
        }
    }
}
