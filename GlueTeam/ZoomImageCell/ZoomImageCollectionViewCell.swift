//
//  ZoomImageCollectionViewCell.swift
//  GlueTeam
//
//  Created by Bui Tan Sang on 14/10/2023.
//

import UIKit

class ZoomImageCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    static let identifier = "ZoomImageCollectionViewCell"
    static let nibView = UINib(nibName: identifier, bundle: nil)
    
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(_ image: UIImage) {
        imageScrollView.display(image)
    }
}
