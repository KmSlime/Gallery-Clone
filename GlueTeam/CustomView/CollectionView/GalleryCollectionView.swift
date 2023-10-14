//
//  GalleryCollectionView.swift
//  GlueTeam
//
//  Created by Hưng Phan on 14/10/2023.
//

import UIKit
import Photos

class GalleryCollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var assets: [PHAsset] = []
    private let itemSize: Int = 20
    private var currentPage: Int = 1
    private var albums: PHAssetCollection?
    private var collectionView: UICollectionView!
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var indexPathSelected: [IndexPath] = [] {
        didSet {
            navigationItem.rightBarButtonItem?.title = isSelectMode ?
            indexPathSelected.isEmpty ? "Done" : "Selected (\(indexPathSelected.count))" :
            "Select"
            navigationItem.leftBarButtonItem = (isSelectMode && !indexPathSelected.isEmpty) ? UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelAction)) : nil
        }
    }
    private var isSelectMode = false {
        didSet {
            navigationItem.rightBarButtonItem?.title = isSelectMode ? "Done" : "Select"
            if !isSelectMode {
                indexPathSelected = []
                navigationItem.leftBarButtonItem = nil
            }
            collectionView.reloadData()
        }
    }
    
    private func showOption() {
        let assetsAction: [PHAsset] = indexPathSelected.compactMap({ assets[$0.item] })
        var img: [UIImage] = []
        let dispathGroup = DispatchGroup()
        var enter = 0
        var out = 0
        LoadingManager.shared.show()
        assetsAction.forEach { asset in
            dispathGroup.enter()
            enter += 1
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image, _ in
                out += 1
                if out <= enter {
                    dispathGroup.leave()
                    if let image = image {
                        img.append(image)
                    }
                }
            }
        }
        dispathGroup.notify(queue: .main) {
            LoadingManager.shared.hide()
            let activity = UIActivityViewController(activityItems: img, applicationActivities: nil)
            activity.completionWithItemsHandler = { (activity, success, items, error) in
                if success {
                    self.isSelectMode = false
                }
            }
            self.present(activity, animated: true)
        }
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchGallery()
        title = "Like Glue"
        let rightBarButtonItem = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(selectAction))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc private func selectAction() {
        if !indexPathSelected.isEmpty {
            showOption()
            return
        }
        isSelectMode = !isSelectMode
    }
    
    @objc private func cancelAction() {
        isSelectMode = false
    }
    
    private func setupCollectionView() {
        let flowLayout = GridLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCollectionCell.nib, forCellWithReuseIdentifier: PhotoCollectionCell.kIdentifier)
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
                self.albums = collection[0]
                let results = PHAsset.fetchAssets(in: self.albums!, options: nil)
                results.enumerateObjects({ asset, index, stop in
                    self.assets.append(asset)
                })
                main_queue {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(assets.count, currentPage * 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.kIdentifier, for: indexPath) as? PhotoCollectionCell, !assets.isEmpty else {
            preconditionFailure("Failed to load collection view cell")
        }
        let asset = assets[indexPath.item]
        let localIdentifier = asset.localIdentifier
        cell.localIdentifier = localIdentifier
        cell.selectView.isHidden = !isSelectMode
        let isCellSelected = cellSelected(indexPath: indexPath) != nil
        if isCellSelected {
            cell.photoText.text = "\(getIndex(indexPath: indexPath))"
        }
        cell.selectView.backgroundColor = isCellSelected ? .black.withAlphaComponent(0.6) : .clear
        cell.onSelectAction = { [weak self] in
            guard let self = self else { return }
            if let removeIndexPath = self.append(indexPath: indexPath) {
                var indexPaths: [IndexPath] = [indexPath]
                for i in removeIndexPath.0..<self.indexPathSelected.count {
                    indexPaths.append(self.indexPathSelected[i])
                }
                self.collectionView.reloadItems(at: indexPaths)
            } else {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: cell.frame.size, contentMode: .aspectFill, options: nil) { image, _ in
            if let image = image, localIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        }

        return cell
    }
    
    private func append(indexPath: IndexPath) -> (Int, IndexPath)? {
        if let firstIndex = indexPathSelected.firstIndex(of: indexPath) {
            let removed = indexPathSelected.remove(at: firstIndex)
            return (firstIndex, removed)
        } else {
            indexPathSelected.append(indexPath)
            return nil
        }
    }
    
    private func getIndex(indexPath: IndexPath) -> Int {
        if let first = indexPathSelected.firstIndex(of: indexPath) {
            return first + 1
        }
        return 0
    }
    private func cellSelected(indexPath: IndexPath) -> Int? {
        return indexPathSelected.firstIndex(of: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            currentPage += 1
            if currentPage * 50 > assets.count {
                return
            }
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailPhotoViewController()
        vc.beginIndex = indexPath
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
