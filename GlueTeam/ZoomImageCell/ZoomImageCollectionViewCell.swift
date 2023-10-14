//
//  ZoomImageCollectionViewCell.swift
//  GlueTeam
//
//  Created by Bui Tan Sang on 14/10/2023.
//

import UIKit

class ZoomImageCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    var isZooming: Bool = false
    var originalImageCenter: CGPoint?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellStyle()
        setupViews()
        setupPinchGesture()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private extension ZoomImageCollectionViewCell {
    func setupViews() {
        self.clipsToBounds = false
        self.backgroundColor = .clear
    }

    
    func setupCellStyle() {
        self.backgroundColor = .clear
        self.clipsToBounds = false
    }
    
    func setupPinchGesture() {
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
//        pinch.delegate = self
//        imageView.addGestureRecognizer(pinch)
    }
    
    func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        pan.delegate = self
        imageView.addGestureRecognizer(pan)
    }
    
    @objc func pan(sender: UIPanGestureRecognizer) {
        if self.isZooming && sender.state == .began {
            self.originalImageCenter = sender.view?.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: self)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in:  imageView.superview)
        }
    }
}
