//
//  DetailPhotoViewController.swift
//  GlueTeam
//
//  Created by LIEMNH on 14/10/2023.
//

import UIKit
import Photos

protocol GalleryCollectionViewDelegate: AnyObject {
    func indexPatchDidChanged(selected: IndexPath)
}

class DetailPhotoViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var mainCollectionView: UICollectionView!
    @IBOutlet private weak var miniCollectionView: UICollectionView!
    
    
    // MARK: - Properties
    private var assets: [PHAsset] = []
    private var selectedIndexPath: IndexPath? {
        didSet {
            guard let selectedIndexPath = selectedIndexPath else { return }
            galleryDelegate?.indexPatchDidChanged(selected: selectedIndexPath)
        }
    }
    weak var galleryDelegate: GalleryCollectionViewDelegate?
    var beginIndex: IndexPath?
    var beginImage: PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiniMapCollectionView()
        setupMainCollectionView()
        configCollectionViewFlowLayout()
        fetchGallery()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    private func setupMiniMapCollectionView() {
        miniCollectionView.delegate = self
        miniCollectionView.dataSource = self
        miniCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.kIdentifier)
        miniCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.decelerationRate = .fast
    }
    
    private func setupMainCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(ZoomImageCollectionViewCell.nibView, forCellWithReuseIdentifier: ZoomImageCollectionViewCell.identifier)
        mainCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func configCollectionViewFlowLayout() {
        let pagingFlowLayout = PagingCollectionViewLayout()
        pagingFlowLayout.scrollDirection = .horizontal
        pagingFlowLayout.itemSize = CGSize(width: Device.screenWidth, height: mainCollectionView.frame.height)
        mainCollectionView.collectionViewLayout = pagingFlowLayout
        
        let pagingFlowLayout2 = UICollectionViewFlowLayout()
        pagingFlowLayout2.scrollDirection = .horizontal
        pagingFlowLayout2.itemSize = CGSize(width: 60, height: 60)
        miniCollectionView.collectionViewLayout = pagingFlowLayout2
    }
    
    private func fetchGallery() {
        PHPhotoLibrary.shared().fetchGallery { [weak self] allImageInGallery in
            guard let self = self else { return }
            allImageInGallery.enumerateObjects({ asset, index, stop in
                self.assets.append(asset)
            })
            beginImage = assets.first!
            assets[0] = assets[beginIndex!.item]
            main_queue {
                if let index = self.beginIndex?.item {
                    self.beginImage = self.assets[index]
                }
                self.miniCollectionView.reloadData()
                self.mainCollectionView.reloadData()
                if let beginIndex = self.beginIndex {
                    UIView.setAnimationsEnabled(false)
                    self.mainCollectionView.scrollToItem(at: beginIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                    self.miniCollectionView.scrollToItem(at: beginIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                    self.assets[0] = self.beginImage!
                    self.beginImage = nil
                    UIView.setAnimationsEnabled(true)
                }
            }
        }
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = .fast
        guard let selectedIndexPath = selectedIndexPath else { return }
        if scrollView == mainCollectionView {
            miniCollectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        } else {
            miniCollectionView.decelerationRate = .normal
            mainCollectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

extension DetailPhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { assets.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = assets[indexPath.item]
        if collectionView == mainCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZoomImageCollectionViewCell.identifier, for: indexPath) as? ZoomImageCollectionViewCell else { return UICollectionViewCell() }
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { loadedImage, _ in
                if let loadedImage = loadedImage {
                    cell.bind(loadedImage)
                }
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.kIdentifier, for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
            PHImageManager.default().requestImage(for: asset, targetSize: cell.frame.size, contentMode: .aspectFill, options: nil) { loadedImage, _ in
                if let loadedImage = loadedImage {
                    cell.imageView.image = loadedImage
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        selectedIndexPath = collectionView == miniCollectionView
        ? IndexPath.init(row: Int(Double(indexPath.row) //current indexPath will show up
                                  - round(Double(collectionView.visibleCells.count/2))), // middle visible cell
                         section: indexPath.section)
        : indexPath
    }
}
