//
//  PhotoCollectionCell.swift
//  GlueTeam
//
//  Created by Hưng Phan on 14/10/2023.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {

    var onSelectAction: (() -> Void)?
    @IBOutlet weak private(set) var labelView: UIView!
    @IBOutlet weak var photoText: UILabel!
    @IBOutlet weak private(set) var imageView: UIImageView!
    @IBOutlet weak private(set) var selectView: UIView!
    var localIdentifier: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.cornerRadius = 8
        self.autoresizesSubviews = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        labelView.cornerRadius = 16
        labelView.backgroundColor = .white.withAlphaComponent(0.5)
        labelView.layer.borderWidth = 2
        labelView.layer.borderColor = UIColor.white.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        localIdentifier = ""
        selectView.isHidden = true
        photoText.text = nil
    }

    @IBAction func onSelectAction(_ sender: Any) {
        onSelectAction?()
    }
}

extension PhotoCollectionCell {
    static let kIdentifier = "PhotoCollectionCell"
    static let nib = UINib(nibName: "PhotoCollectionCell", bundle: nil)
}
