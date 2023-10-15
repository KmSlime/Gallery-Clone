//
//  ImageLoader.swift
//  ImageFeed
//
//  Created by Hưng Phan on 13/10/2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit
import Photos

func main_queue(block: (() -> Void)?) {
    if Thread.isMainThread {
        block?()
        return
    }
    DispatchQueue.main.async {
        block?()
    }
}

class ImageLoader {
    static let loader = ImageLoader()
    private let cachedImages = NSCache<NSString, NSData>()
    private init() {
        cachedImages.totalCostLimit = 50_000_000
    }
    func image(localIdentifier: String) -> NSData? {
        return cachedImages.object(forKey: NSString(string: localIdentifier))
    }
    
    func load(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
//        if let imgData = image(localIdentifier: asset.localIdentifier) {
//            print("get from cache \(asset.localIdentifier)")
//            main_queue {
//                completion(UIImage(data: imgData as Data))
//            }
//            return
//        }
        
        ImageLoader.phManager().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { [weak self] image, _ in
            guard let self = self, let image = image, let imageData = image.jpegData(compressionQuality: 0.1) else {
                main_queue {
                    completion(nil)
                    return
                }
                return
            }
            self.cachedImages.setObject(imageData as NSData, forKey: NSString(string: asset.localIdentifier), cost: imageData.count)
            print("load from gallery \(asset.localIdentifier)")
            main_queue {
                completion(UIImage(data: imageData))
            }
        }
    }
    
    static func phManager() -> PHImageManager {
        return PHImageManager.default()
    }
}
