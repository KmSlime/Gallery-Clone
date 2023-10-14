//
//  GalleryCollectionView.swift
//  GlueTeam
//
//  Created by Hưng Phan on 14/10/2023.
//

import UIKit
import Photos

class GalleryCollectionView: UIViewController {
    //MARK: - Private propeties
    private var assets: [PHAsset] = []
    private var collectionView: UICollectionView!
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
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupCollectionView()
        fetchGallery()
    }
    
    // MARK: - Private method
    private func setupNavigation() {
        title = "Like Glue"
        let rightBarButtonItem = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(selectAction))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc private func selectAction() {
        if !indexPathSelected.isEmpty {
            sharedSelectedAsset()
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
        view.addSubview(collectionView)
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
                guard let albums = collection.firstObject else { return }
                let results = PHAsset.fetchAssets(in: albums, options: nil)
                results.enumerateObjects({ asset, index, stop in
                    self.assets.append(asset)
                })
                main_queue {
                    self.collectionView.reloadData()
                }
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
                    self.present(alert, animated: true)
                }
            }
        }
    }
    

    private func selectedModeDidChanged(for indexPath: IndexPath) -> (Int, IndexPath)? {
        if let firstIndex = indexPathSelected.firstIndex(of: indexPath) {
            let removed = indexPathSelected.remove(at: firstIndex)
            return (firstIndex, removed)
        }
        indexPathSelected.append(indexPath)
        return nil
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
    
    private func sharedSelectedAsset() {
        let assetsAction: [PHAsset] = indexPathSelected.compactMap({ assets[$0.item] })
        var img: [UIImage] = []
        let dispathGroup = DispatchGroup()
        var enter = 0
        var leave = 0
        LoadingManager.shared.show()
        assetsAction.forEach { asset in
            dispathGroup.enter()
            enter += 1
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { image, _ in
                leave += 1
                if leave <= enter {
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
            activity.completionWithItemsHandler = { (_, success, _, _) in
                if success {
                    self.isSelectMode = false
                }
            }
            self.present(activity, animated: true)
        }
        
    }
    
}

extension GalleryCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.kIdentifier, for: indexPath) as? PhotoCollectionCell, !assets.isEmpty else {
            preconditionFailure("Failed to load collection view cell")
        }
        let asset = assets[indexPath.item]
        let localIdentifier = asset.localIdentifier
        let isCellSelected = cellSelected(indexPath: indexPath) != nil
        cell.bind(localIdentifier: localIdentifier,
                  isSelectMode: isSelectMode,
                  isCellSelected: isCellSelected,
                  selectedText: isCellSelected ? "\(getIndex(indexPath: indexPath))" : "")
        cell.onSelectAction = { [weak self] in
            guard let self = self else { return }
            if let removeIndexPath = self.selectedModeDidChanged(for: indexPath) {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailPhotoViewController()
        vc.beginIndex = indexPath
        vc.galleryDelegate = self
        navigationController?.pushViewController(vc, animated: true)

    }
}

extension GalleryCollectionView: GalleryCollectionViewDelegate {
    func indexPatchDidChanged(selected: IndexPath) {
        collectionView?.scrollToItem(at: selected, at: .centeredVertically, animated: false)
    }
}


