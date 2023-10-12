//
//  UIButtonExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import UIKit

extension UIButton {
    @objc func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
    @objc func centerTitleVertically(_ topTitleSpacing: CGFloat = 10) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: topTitleSpacing,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
    }
    
    @objc func centerTitleVerticallyWithEdge(_ edgeInset: UIEdgeInsets) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: edgeInset.top,
            left: -imageViewSize.width - edgeInset.left,
            bottom: -(totalHeight - titleLabelSize.height) - edgeInset.bottom,
            right: edgeInset.right
        )
    }
    
    @objc func centerHorizontally(padding: CGFloat = 6.0) {
        self.contentHorizontalAlignment = .left
        let totalHeight = self.bounds.height + padding
        guard let imageViewSize = self.imageView?.frame.size, let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        self.imageEdgeInsets = UIEdgeInsets (
            top: (totalHeight - imageViewSize.height)/4,
            left: 0.0,
            bottom: (totalHeight - imageViewSize.height)/4,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets (
            top: 0.0,
            left: padding,
            bottom: 0,
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets (
            top: 0.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0
        )
    }
    
    @objc func setPaddingImage(with padding: CGFloat = 6.0) {
        self.contentHorizontalAlignment = .left
        guard let titleLabelSize = self.titleLabel?.frame.size else { return }
        self.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -titleLabelSize.width)
        self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: padding, bottom: 0, right: 0.0)
        self.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    @objc func setGradientLinear(with colors: [UIColor]) {
        self.setGradient(with: colors,
                         startPoint: CGPoint(x: 0.25, y: 0.5),
                         endPoint: CGPoint(x: 0.75, y: 0.5))
    }

}
