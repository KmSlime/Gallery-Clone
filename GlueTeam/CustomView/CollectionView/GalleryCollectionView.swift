//
//  GalleryCollectionView.swift
//  GlueTeam
//
//  Created by Hưng Phan on 14/10/2023.
//

import UIKit
import Photos

class GalleryCollectionView: UICollectionViewController {
    private var assets: [PHAsset] = []
    private let itemSize: Int = 20
    private var currentPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchGallery()
    }
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: view.bounds.width, height: 200)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.indicatorStyle = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.kIdentifier)
    }
    
    private func fetchGallery() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", "dir_003")
                let collection = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                                       subtype: .any,
                                                                                       options: fetchOptions)
                let results = PHAsset.fetchAssets(in: collection[0], options: nil)
                results.enumerateObjects({ asset, index, stop in
                    self.assets.append(asset)
                })
                main_queue {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(assets.count, currentPage * itemSize)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.kIdentifier, for: indexPath) as? PhotoCell, !assets.isEmpty else {
            preconditionFailure("Failed to load collection view cell")
        }
        let asset = assets[indexPath.item]
        ImageLoader.loader.load(for: asset, targetSize: cell.frame.size) { loadedImage in
            if let loadedImage = loadedImage {
                cell.imageView.image = loadedImage
            }
        }

        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            currentPage += 1
            collectionView.reloadData()
        }
    }
    
}


