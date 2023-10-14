//
//  TestZoomingImageViewController.swift
//  GlueTeam
//
//  Created by Bui Tan Sang on 14/10/2023.
//

import UIKit

class TestZoomingImageViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ZoomImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ZoomImageCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension TestZoomingImageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZoomImageCollectionViewCell", for: indexPath) as? ZoomImageCollectionViewCell else { return UICollectionViewCell() }
        cell.bind(UIImage(named: "robin")!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
}
