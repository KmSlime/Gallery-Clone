//
//  DetailPhotoViewController.swift
//  GlueTeam
//
//  Created by LIEMNH on 14/10/2023.
//

import UIKit
import Photos

class DetailPhotoViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet private weak var mainCollectionView: UICollectionView!
    @IBOutlet private weak var miniCollectionView: UICollectionView!
    
    private var assets: [PHAsset] = []
    private var selectedIndexPath: IndexPath?
    
    // MARK: - Overrides
    var beginIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainCollectionView.delegate = self
        miniCollectionView.delegate = self
        
        mainCollectionView.dataSource = self
        miniCollectionView.dataSource = self
        
        mainCollectionView.register(UINib(nibName: "ZoomImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ZoomImageCollectionViewCell")
        miniCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.kIdentifier)
        mainCollectionView.decelerationRate = .fast
        
        reConfigCollectionViewFlowLayout()
        
        fetchGallery()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let beginIndex = beginIndex {
            mainCollectionView.scrollToItem(at: beginIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            miniCollectionView.scrollToItem(at: beginIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    private func fetchGallery() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                let results = PHAsset.fetchAssets(with: .image, options: nil)
                results.enumerateObjects({ asset, index, stop in
                    self.assets.append(asset)
                })
                main_queue {
                    self.miniCollectionView.reloadData()
                    self.mainCollectionView.reloadData()
                }
                
            }
        }
    }
    
    func reConfigCollectionViewFlowLayout() {
        let pagingFlowLayout = PagingCollectionViewLayout()
        pagingFlowLayout.scrollDirection = .horizontal
        pagingFlowLayout.itemSize = CGSize(width: Device.screenWidth, height: mainCollectionView.frame.height)
        mainCollectionView.collectionViewLayout = pagingFlowLayout
        
        let pagingFlowLayout2 = UICollectionViewFlowLayout()
        pagingFlowLayout2.scrollDirection = .horizontal
        pagingFlowLayout2.itemSize = CGSize(width: 60, height: 60)
        miniCollectionView.collectionViewLayout = pagingFlowLayout2
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mainCollectionView {
            guard let selectedIndexPath = selectedIndexPath else { return }
            miniCollectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        } else {
            for cell in self.miniCollectionView.visibleCells {
                if let indexPath = mainCollectionView.indexPath(for: cell) {
                    mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
}

extension DetailPhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { assets.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = assets[indexPath.item]
        if collectionView == mainCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZoomImageCollectionViewCell", for: indexPath) as? ZoomImageCollectionViewCell else { return UICollectionViewCell() }
            ImageLoader.loader.load(for: asset, targetSize: PHImageManagerMaximumSize) { loadedImage in
                if let loadedImage = loadedImage {
                    cell.bind(loadedImage)
                }
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.kIdentifier, for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
            ImageLoader.loader.load(for: asset, targetSize: PHImageManagerMaximumSize) { loadedImage in
                if let loadedImage = loadedImage {
                    cell.imageView.image = loadedImage
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        miniCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
}


class PagingCollectionViewLayout: UICollectionViewFlowLayout {
    var velocityThresholdPerPage: CGFloat = 2
    var numberOfItemsPerPage: CGFloat = 1
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let pageLength: CGFloat
        let approxPage: CGFloat
        let currentPage: CGFloat
        let speed: CGFloat
        
        if scrollDirection == .horizontal {
            pageLength = (self.itemSize.width + self.minimumLineSpacing) * numberOfItemsPerPage
            approxPage = collectionView.contentOffset.x / pageLength
            speed = velocity.x
        } else {
            pageLength = (self.itemSize.height + self.minimumLineSpacing) * numberOfItemsPerPage
            approxPage = collectionView.contentOffset.y / pageLength
            speed = velocity.y
        }
        
        if speed < 0 {
            currentPage = ceil(approxPage)
        } else if speed > 0 {
            currentPage = floor(approxPage)
        } else {
            currentPage = round(approxPage)
        }
        
        guard speed != 0 else {
            if scrollDirection == .horizontal {
                return CGPoint(x: currentPage * pageLength, y: 0)
            } else {
                return CGPoint(x: 0, y: currentPage * pageLength)
            }
        }
        
        var nextPage: CGFloat = currentPage + (speed > 0 ? 1 : -1)
        
        let increment = speed / velocityThresholdPerPage
        nextPage += (speed < 0) ? ceil(increment) : floor(increment)
        
        if scrollDirection == .horizontal {
            return CGPoint(x: nextPage * pageLength, y: 0)
        } else {
            return CGPoint(x: 0, y: nextPage * pageLength)
        }
    }
}
