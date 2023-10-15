//
//  PhotoCell.swift
//  GlueTeam
//
//  Created by Hưng Phan on 14/10/2023.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    static let kIdentifier = "PhotoCell"
    private(set) var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.autoresizesSubviews = true
        self.cornerRadius = 4
        imageView.frame = self.bounds
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
